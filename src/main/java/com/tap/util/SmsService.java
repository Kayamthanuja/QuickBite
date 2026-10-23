package com.tap.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public final class SmsService {

	private static final String API_URL = "https://www.fast2sms.com/dev/bulkV2";

	private SmsService() {
	}

	public static SmsResult sendOtpSms(String phone, String otp) {
		if (!SmsConfig.isConfigured()) {
			return SmsResult.notConfigured();
		}

		SmsResult otpRoute = sendOtpGet(phone, otp);
		if (otpRoute.ok) {
			return otpRoute;
		}

		SmsResult otpPost = sendOtpPost(phone, otp);
		if (otpPost.ok) {
			return otpPost;
		}

		String message = "QuickBite OTP " + otp + " is valid for 5 minutes. Do not share this code.";
		SmsResult quick = sendQuickSms(phone, message);
		if (quick.ok) {
			return quick;
		}

		String combined = firstMessage(otpRoute, otpPost, quick);
		boolean restricted = isAccountRestriction(combined);
		return new SmsResult(false, restricted, combined);
	}

	public static boolean sendText(String phone, String message) {
		return sendQuickSms(phone, message).ok;
	}

	public static void notifyOrderPlaced(String phone, int orderId, double amount) {
		if (!SmsConfig.isConfigured() || phone == null || phone.isBlank()) {
			return;
		}

		String message = "QuickBite: Your order #QB-" + orderId
				+ " is placed successfully. Amount Rs." + Math.round(amount)
				+ ". We will keep you updated. - " + SmsConfig.SENDER_NAME;

		boolean sent = sendText(OtpService.normalizePhone(phone), message);
		if (!sent) {
			System.err.println("[QuickBite SMS] Order notification failed for " + phone);
		}
	}

	private static SmsResult sendOtpGet(String phone, String otp) {
		try {
			String url = API_URL
					+ "?authorization=" + url(SmsConfig.FAST2SMS_API_KEY)
					+ "&route=otp"
					+ "&variables_values=" + url(otp)
					+ "&flash=0"
					+ "&numbers=" + url(phone);
			return parse(get(url));
		} catch (Exception e) {
			e.printStackTrace();
			return SmsResult.failed(e.getMessage());
		}
	}

	private static SmsResult sendOtpPost(String phone, String otp) {
		String payload = "{"
				+ "\"route\":\"otp\","
				+ "\"variables_values\":\"" + escapeJson(otp) + "\","
				+ "\"flash\":0,"
				+ "\"numbers\":\"" + escapeJson(phone) + "\""
				+ "}";
		try {
			return parse(post(payload));
		} catch (Exception e) {
			e.printStackTrace();
			return SmsResult.failed(e.getMessage());
		}
	}

	private static SmsResult sendQuickSms(String phone, String message) {
		try {
			String url = API_URL
					+ "?authorization=" + url(SmsConfig.FAST2SMS_API_KEY)
					+ "&route=q"
					+ "&language=english"
					+ "&flash=0"
					+ "&message=" + url(message)
					+ "&numbers=" + url(phone);
			return parse(get(url));
		} catch (Exception e) {
			e.printStackTrace();
			return SmsResult.failed(e.getMessage());
		}
	}

	private static HttpResponse get(String url) throws Exception {
		HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
		conn.setRequestMethod("GET");
		conn.setConnectTimeout(12000);
		conn.setReadTimeout(12000);
		conn.setRequestProperty("authorization", SmsConfig.FAST2SMS_API_KEY);
		conn.setRequestProperty("Authorization", SmsConfig.FAST2SMS_API_KEY);
		conn.setRequestProperty("Accept", "application/json");
		return read(conn);
	}

	private static HttpResponse post(String jsonBody) throws Exception {
		HttpURLConnection conn = (HttpURLConnection) new URL(API_URL).openConnection();
		conn.setRequestMethod("POST");
		conn.setDoOutput(true);
		conn.setConnectTimeout(12000);
		conn.setReadTimeout(12000);
		conn.setRequestProperty("authorization", SmsConfig.FAST2SMS_API_KEY);
		conn.setRequestProperty("Authorization", SmsConfig.FAST2SMS_API_KEY);
		conn.setRequestProperty("Content-Type", "application/json");
		conn.setRequestProperty("Accept", "application/json");

		try (OutputStream os = conn.getOutputStream()) {
			os.write(jsonBody.getBytes(StandardCharsets.UTF_8));
		}
		return read(conn);
	}

	private static HttpResponse read(HttpURLConnection conn) {
		int status = 500;
		try {
			status = conn.getResponseCode();
		} catch (Exception ignored) {
		}

		java.io.InputStream is = null;
		try {
			if (status >= 200 && status < 300) {
				is = conn.getInputStream();
			} else {
				is = conn.getErrorStream();
			}
		} catch (Exception ignored) {
		}

		if (is == null) {
			try {
				is = conn.getErrorStream();
			} catch (Exception ignored) {
			}
		}

		if (is == null) {
			return new HttpResponse(status, "Fast2SMS response status " + status);
		}

		StringBuilder response = new StringBuilder();
		try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
			String line;
			while ((line = reader.readLine()) != null) {
				response.append(line);
			}
		} catch (Exception e) {
			return new HttpResponse(status, "Error reading Fast2SMS stream: " + e.getMessage());
		}

		return new HttpResponse(status, response.toString());
	}

	private static SmsResult parse(HttpResponse response) {
		String body = response.body == null ? "" : response.body;
		boolean ok = response.status >= 200 && response.status < 300
				&& (body.contains("\"return\":true") || body.contains("\"return\": true")
						|| body.contains("\"status_code\":200") || body.contains("SMS sent")
						|| body.contains("\"message\":\"SMS sent successfully.\""));

		if (!ok) {
			System.err.println("[QuickBite SMS] Fast2SMS response " + response.status + ": " + body);
			return new SmsResult(false, isAccountRestriction(body), extractMessage(body));
		}
		return SmsResult.ok();
	}

	private static boolean isAccountRestriction(String body) {
		if (body == null || body.isBlank()) {
			return true;
		}
		String lower = body.toLowerCase();
		return lower.contains("website verification")
				|| lower.contains("complete one transaction")
				|| lower.contains("otp message menu")
				|| lower.contains("status_code\":996")
				|| lower.contains("status_code\":999")
				|| lower.contains("996")
				|| lower.contains("999")
				|| lower.contains("dlt sms")
				|| lower.contains("authorization key")
				|| lower.contains("invalid")
				|| lower.contains("recharge")
				|| lower.contains("wallet");
	}

	private static String extractMessage(String body) {
		if (body == null || body.isBlank()) {
			return "Fast2SMS request failed.";
		}
		int start = body.indexOf("\"message\":\"");
		if (start >= 0) {
			start += 11;
			int end = body.indexOf('"', start);
			if (end > start) {
				return body.substring(start, end);
			}
		}
		return body;
	}

	private static String firstMessage(SmsResult... results) {
		for (SmsResult result : results) {
			if (result != null && result.message != null && !result.message.isBlank()) {
				return result.message;
			}
		}
		return "Could not send SMS.";
	}

	private static String url(String value) throws Exception {
		return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
	}

	private static String escapeJson(String value) {
		if (value == null) {
			return "";
		}
		return value.replace("\\", "\\\\").replace("\"", "\\\"");
	}

	private static final class HttpResponse {
		final int status;
		final String body;

		HttpResponse(int status, String body) {
			this.status = status;
			this.body = body;
		}
	}

	public static final class SmsResult {
		public final boolean ok;
		public final boolean accountRestricted;
		public final String message;

		SmsResult(boolean ok, boolean accountRestricted, String message) {
			this.ok = ok;
			this.accountRestricted = accountRestricted;
			this.message = message;
		}

		static SmsResult ok() {
			return new SmsResult(true, false, "SMS sent");
		}

		static SmsResult failed(String message) {
			return new SmsResult(false, false, message);
		}

		static SmsResult notConfigured() {
			return new SmsResult(false, false, "Fast2SMS API key is not configured.");
		}
	}
}
