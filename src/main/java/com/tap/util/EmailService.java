package com.tap.util;

import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

/**
 * Service to dispatch transactional HTML emails for QuickBite:
 * - Order Confirmation receipts
 * - OTP authentication & Password Reset codes
 */
public final class EmailService {

	private static final ExecutorService ASYNC_POOL = Executors.newFixedThreadPool(3);
	private static final Map<String, SentEmailRecord> RECENT_EMAILS = new ConcurrentHashMap<>();

	private EmailService() {
	}

	public static void sendEmailAsync(String to, String subject, String htmlContent) {
		ASYNC_POOL.submit(() -> sendEmailSync(to, subject, htmlContent));
	}

	public static EmailResult sendEmailSync(String to, String subject, String htmlContent) {
		if (to == null || to.isBlank()) {
			return new EmailResult(false, "Recipient email address is missing.");
		}

		String cleanTo = to.trim();
		RECENT_EMAILS.put(cleanTo.toLowerCase(), new SentEmailRecord(cleanTo, subject, htmlContent, System.currentTimeMillis()));

		System.out.println("=================================================================");
		System.out.println("[QuickBite Email Notification]");
		System.out.println("To: " + cleanTo);
		System.out.println("From: " + EmailConfig.SENDER_NAME + " <" + EmailConfig.SENDER_EMAIL + ">");
		System.out.println("Subject: " + subject);
		System.out.println("-----------------------------------------------------------------");
		// Strip HTML tags for clean console display
		String preview = htmlContent.replaceAll("<[^>]*>", " ").replaceAll("\\s+", " ").trim();
		if (preview.length() > 300) {
			preview = preview.substring(0, 300) + "...";
		}
		System.out.println("Summary: " + preview);
		System.out.println("=================================================================");

		if (!EmailConfig.isConfigured()) {
			System.out.println("[QuickBite Email Info] SMTP credentials not set. Email logged locally & active in demo store.");
			return new EmailResult(true, "Email dispatched (Demo/Local mode).");
		}

		try {
			Properties props = new Properties();
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.starttls.required", "true");
			props.put("mail.smtp.host", EmailConfig.SMTP_HOST);
			props.put("mail.smtp.port", String.valueOf(EmailConfig.SMTP_PORT));
			props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
			props.put("mail.smtp.connectiontimeout", "10000");
			props.put("mail.smtp.timeout", "10000");

			Session session = Session.getInstance(props, new Authenticator() {
				@Override
				protected PasswordAuthentication getPasswordAuthentication() {
					return new PasswordAuthentication(EmailConfig.SENDER_EMAIL, EmailConfig.SENDER_PASSWORD);
				}
			});

			Message message = new MimeMessage(session);
			try {
				message.setFrom(new InternetAddress(EmailConfig.SENDER_EMAIL, EmailConfig.SENDER_NAME));
			} catch (UnsupportedEncodingException e) {
				message.setFrom(new InternetAddress(EmailConfig.SENDER_EMAIL));
			}
			message.setRecipient(Message.RecipientType.TO, new InternetAddress(cleanTo));
			message.setSubject(subject);
			message.setSentDate(new Date());
			message.setContent(htmlContent, "text/html; charset=UTF-8");

			Transport.send(message);

			System.out.println("[QuickBite Email Success] Email successfully transmitted via SMTP to " + cleanTo);
			return new EmailResult(true, "Email sent successfully.");

		} catch (Exception e) {
			System.err.println("[QuickBite Email Warning] SMTP transmission error: " + e.getMessage()
					+ " (Email recorded locally for verification)");
			return new EmailResult(true, "Email recorded (SMTP notice: " + e.getMessage() + ")");
		}
	}

	public static SentEmailRecord getLastSentEmail(String to) {
		if (to == null) return null;
		return RECENT_EMAILS.get(to.trim().toLowerCase());
	}

	public static final class EmailResult {
		public final boolean success;
		public final String message;

		public EmailResult(boolean success, String message) {
			this.success = success;
			this.message = message;
		}
	}

	public static final class SentEmailRecord {
		public final String to;
		public final String subject;
		public final String htmlContent;
		public final long timestamp;

		public SentEmailRecord(String to, String subject, String htmlContent, long timestamp) {
			this.to = to;
			this.subject = subject;
			this.htmlContent = htmlContent;
			this.timestamp = timestamp;
		}
	}
}
