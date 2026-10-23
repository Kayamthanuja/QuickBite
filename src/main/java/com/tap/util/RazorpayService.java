package com.tap.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public final class RazorpayService {

	private static final String ORDERS_URL = "https://api.razorpay.com/v1/orders";

	private RazorpayService() {
	}

	/**
	 * Creates a Razorpay order. Amount must be in paise (₹1 = 100).
	 * Returns Razorpay order id (order_xxx) or null on failure.
	 */
	public static String createOrder(int amountPaise, String receipt) throws Exception {
		String payload = "{"
				+ "\"amount\":" + amountPaise + ","
				+ "\"currency\":\"" + RazorpayConfig.CURRENCY + "\","
				+ "\"receipt\":\"" + escapeJson(receipt) + "\","
				+ "\"payment_capture\":1"
				+ "}";

		URL url = new URL(ORDERS_URL);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod("POST");
		conn.setDoOutput(true);
		conn.setRequestProperty("Content-Type", "application/json");
		conn.setConnectTimeout(15000);
		conn.setReadTimeout(15000);
		conn.setRequestProperty("Authorization", basicAuth());

		try (OutputStream os = conn.getOutputStream()) {
			os.write(payload.getBytes(StandardCharsets.UTF_8));
		}

		int status = conn.getResponseCode();
		BufferedReader reader = new BufferedReader(new InputStreamReader(
				status >= 200 && status < 300 ? conn.getInputStream() : conn.getErrorStream(),
				StandardCharsets.UTF_8));

		StringBuilder response = new StringBuilder();
		String line;
		while ((line = reader.readLine()) != null) {
			response.append(line);
		}
		reader.close();

		if (status < 200 || status >= 300) {
			System.err.println("Razorpay create order failed: " + response);
			return null;
		}

		return extractJsonString(response.toString(), "id");
	}

	public static boolean verifyPaymentSignature(String orderId, String paymentId, String signature) {
		try {
			String payload = orderId + "|" + paymentId;
			Mac mac = Mac.getInstance("HmacSHA256");
			mac.init(new SecretKeySpec(RazorpayConfig.KEY_SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
			byte[] hash = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));

			StringBuilder hex = new StringBuilder();
			for (byte b : hash) {
				String h = Integer.toHexString(0xff & b);
				if (h.length() == 1) {
					hex.append('0');
				}
				hex.append(h);
			}

			return hex.toString().equals(signature);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	private static String basicAuth() {
		String raw = RazorpayConfig.KEY_ID + ":" + RazorpayConfig.KEY_SECRET;
		return "Basic " + Base64.getEncoder().encodeToString(raw.getBytes(StandardCharsets.UTF_8));
	}

	private static String extractJsonString(String json, String key) {
		Pattern pattern = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]+)\"");
		Matcher matcher = pattern.matcher(json);
		if (matcher.find()) {
			return matcher.group(1);
		}
		return null;
	}

	private static String escapeJson(String value) {
		if (value == null) {
			return "";
		}
		return value.replace("\\", "\\\\").replace("\"", "\\\"");
	}
}
