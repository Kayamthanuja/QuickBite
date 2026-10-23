package com.tap.util;

import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.User;
import com.tap.util.SmsService.SmsResult;

public final class OtpService {

	private static final long OTP_TTL_MS = 5 * 60 * 1000L;
	private static final SecureRandom RANDOM = new SecureRandom();
	private static final Map<String, OtpEntry> STORE = new ConcurrentHashMap<>();
	private static final Map<String, OtpEntry> EMAIL_STORE = new ConcurrentHashMap<>();

	private OtpService() {
	}

	public static boolean isDemoMode() {
		return !SmsConfig.isConfigured();
	}

	public static String normalizePhone(String phone) {
		if (phone == null) {
			return "";
		}
		String digits = phone.replaceAll("\\D", "");
		if (digits.length() > 10) {
			digits = digits.substring(digits.length() - 10);
		}
		return digits;
	}

	public static boolean isValidPhone(String phone) {
		return normalizePhone(phone).matches("\\d{10}");
	}

	public static SendResult sendOtp(String phone) {
		String normalized = normalizePhone(phone);
		String otp = String.valueOf(100000 + RANDOM.nextInt(900000));
		STORE.put(normalized, new OtpEntry(otp, System.currentTimeMillis() + OTP_TTL_MS));

		System.out.println("=======================================================");
		System.out.println("[QuickBite Security] 6-digit OTP generated for " + normalized + ": >>> " + otp + " <<<");
		System.out.println("=======================================================");

		String maskedPhone = "+91 " + (normalized.length() >= 4 ? "******" + normalized.substring(normalized.length() - 4) : normalized);

		// If user has a registered email for this phone, also dispatch OTP to email
		UserDAO userDAO = new UserDAOImpl();
		User user = userDAO.getUserByPhone(normalized);
		String userEmail = (user != null && user.getEmail() != null && !user.getEmail().isBlank()) ? user.getEmail() : null;

		if (isDemoMode()) {
			if (userEmail != null) {
				sendOtpToEmail(userEmail, otp, "Login");
			}
			return SendResult.sentWithOtp("OTP generated: " + otp + ". (Demo mode - please enter code below)", otp);
		}

		try {
			SmsResult sent = SmsService.sendOtpSms(normalized, otp);
			if (sent != null && sent.ok) {
				System.out.println("[QuickBite SMS Gateway] OTP successfully delivered over telecom network to " + normalized);
				if (userEmail != null) {
					sendOtpToEmail(userEmail, otp, "Login");
				}
				return SendResult.sent("OTP sent to " + maskedPhone + " via SMS. Please enter the 6-digit code.");
			}

			// If Fast2SMS failed, requires website verification (code 996), or is restricted:
			String reason = (sent != null && sent.message != null) ? sent.message : "SMS gateway verification required";
			System.out.println("[QuickBite SMS Notice] Telecom SMS gateway returned: " + reason
					+ " (OTP: " + otp + " is active in memory for verification)");

			if (userEmail != null) {
				sendOtpToEmail(userEmail, otp, "Login");
			}

			String notice = "SMS Gateway pending verification. Test OTP is: " + otp
					+ (userEmail != null ? " (also sent to " + maskEmail(userEmail) + ")" : "");

			return SendResult.sentWithOtp(notice, otp);

		} catch (Exception e) {
			System.out.println("[QuickBite SMS Exception] " + e.getMessage() + " (OTP: " + otp + " is active in memory)");
			if (userEmail != null) {
				sendOtpToEmail(userEmail, otp, "Login");
			}
			return SendResult.sentWithOtp("SMS gateway unavailable. Your verification OTP is: " + otp, otp);
		}
	}

	public static boolean verify(String phone, String otp) {
		String normalized = normalizePhone(phone);
		OtpEntry entry = STORE.get(normalized);

		if (entry == null) {
			System.out.println("[QuickBite Auth] Verification failed: No OTP found for " + normalized);
			return false;
		}

		if (System.currentTimeMillis() > entry.expiresAt) {
			STORE.remove(normalized);
			System.out.println("[QuickBite Auth] Verification failed: OTP expired for " + normalized);
			return false;
		}

		String cleanOtp = (otp != null) ? otp.trim() : "";
		boolean ok = entry.otp.equals(cleanOtp);
		System.out.println("[QuickBite Auth] Verifying phone " + normalized + ": entered [" + cleanOtp + "] vs expected [" + entry.otp + "] -> " + (ok ? "MATCHED" : "MISMATCH"));
		if (ok) {
			STORE.remove(normalized);
		}
		return ok;
	}

	// ==========================================
	// Email OTP Support (Password Reset / Auth)
	// ==========================================

	public static SendResult sendEmailOtp(String email, String purpose) {
		if (email == null || email.isBlank()) {
			return SendResult.failed("Email address is required.");
		}
		String cleanEmail = email.trim().toLowerCase();
		String otp = String.valueOf(100000 + RANDOM.nextInt(900000));
		EMAIL_STORE.put(cleanEmail, new OtpEntry(otp, System.currentTimeMillis() + OTP_TTL_MS));

		System.out.println("=======================================================");
		System.out.println("[QuickBite Security] 6-digit Email OTP generated for " + cleanEmail + ": >>> " + otp + " <<< (Purpose: " + purpose + ")");
		System.out.println("=======================================================");

		String subject = "QuickBite: " + purpose + " OTP Code (" + otp + ")";
		String htmlBody = formatOtpEmailHtml(cleanEmail, otp, purpose);

		EmailService.sendEmailAsync(cleanEmail, subject, htmlBody);

		String masked = maskEmail(cleanEmail);
		return SendResult.sentWithOtp("OTP sent to " + masked + ". Valid for 5 minutes. (Test Code: " + otp + ")", otp);
	}

	public static boolean verifyEmailOtp(String email, String otp) {
		if (email == null || otp == null) return false;
		String cleanEmail = email.trim().toLowerCase();
		OtpEntry entry = EMAIL_STORE.get(cleanEmail);

		if (entry == null) {
			System.out.println("[QuickBite Auth] Email OTP verification failed: No OTP found for " + cleanEmail);
			return false;
		}

		if (System.currentTimeMillis() > entry.expiresAt) {
			EMAIL_STORE.remove(cleanEmail);
			System.out.println("[QuickBite Auth] Email OTP verification failed: Expired for " + cleanEmail);
			return false;
		}

		String cleanOtp = otp.trim();
		boolean ok = entry.otp.equals(cleanOtp);
		System.out.println("[QuickBite Auth] Verifying email " + cleanEmail + ": entered [" + cleanOtp + "] vs expected [" + entry.otp + "] -> " + (ok ? "MATCHED" : "MISMATCH"));
		if (ok) {
			EMAIL_STORE.remove(cleanEmail);
		}
		return ok;
	}

	private static void sendOtpToEmail(String email, String otp, String purpose) {
		try {
			String subject = "QuickBite: " + purpose + " Security OTP (" + otp + ")";
			String htmlBody = formatOtpEmailHtml(email, otp, purpose);
			EmailService.sendEmailAsync(email, subject, htmlBody);
		} catch (Exception e) {
			System.err.println("[QuickBite OTP Email] Failed to queue email: " + e.getMessage());
		}
	}

	private static String formatOtpEmailHtml(String email, String otp, String purpose) {
		return "<!DOCTYPE html><html><body style='margin:0; padding:20px; font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; background-color: #f7f3ec; color: #38251b;'>"
				+ "<div style='max-width: 480px; margin: 0 auto; background: #ffffff; border-radius: 14px; overflow: hidden; border: 1px solid #eedec7; box-shadow: 0 4px 14px rgba(0,0,0,0.06);'>"
				+ "<div style='background: linear-gradient(135deg, #f5a623 0%, #e89512 100%); padding: 24px; text-align: center; color: #ffffff;'>"
				+ "<h2 style='margin:0; font-size: 22px; font-weight: 800;'>QuickBite Security</h2>"
				+ "<p style='margin: 4px 0 0; font-size: 13px; opacity: 0.95;'>" + purpose + " Verification</p>"
				+ "</div>"
				+ "<div style='padding: 26px 24px; text-align: center;'>"
				+ "<p style='font-size: 14px; color: #665243; margin-top: 0;'>Use the 6-digit one-time password below to complete your " + purpose.toLowerCase() + ":</p>"
				+ "<div style='background: #fff8ee; border: 2px dashed #f5a623; border-radius: 10px; padding: 16px; margin: 20px auto; display: inline-block; min-width: 200px;'>"
				+ "<span style='font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #d97706; font-family: monospace;'>" + otp + "</span>"
				+ "</div>"
				+ "<p style='font-size: 12px; color: #887465; margin: 16px 0 0;'>This code is valid for <strong>5 minutes</strong>. Do NOT share this code with anyone.</p>"
				+ "</div>"
				+ "<div style='background: #faf6f0; border-top: 1px solid #eedec7; padding: 12px; text-align: center; font-size: 11px; color: #a49182;'>"
				+ "&copy; QuickBite Online Services &bull; Secure Authentication"
				+ "</div>"
				+ "</div></body></html>";
	}

	public static String maskEmail(String email) {
		if (email == null || !email.contains("@")) return email != null ? email : "";
		int at = email.indexOf('@');
		String name = email.substring(0, at);
		String domain = email.substring(at);
		if (name.length() <= 2) {
			return name.charAt(0) + "***" + domain;
		}
		return name.charAt(0) + "***" + name.charAt(name.length() - 1) + domain;
	}

	public static final class SendResult {
		public final boolean success;
		public final String message;
		public final String otpCode;

		private SendResult(boolean success, String message, String otpCode) {
			this.success = success;
			this.message = message;
			this.otpCode = otpCode;
		}

		public static SendResult sent(String message) {
			return new SendResult(true, message, null);
		}

		public static SendResult sentWithOtp(String message, String otpCode) {
			return new SendResult(true, message, otpCode);
		}

		public static SendResult failed(String message) {
			return new SendResult(false, message, null);
		}
	}

	private static final class OtpEntry {
		private final String otp;
		private final long expiresAt;

		private OtpEntry(String otp, long expiresAt) {
			this.otp = otp;
			this.expiresAt = expiresAt;
		}
	}
}
