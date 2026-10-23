package com.tap.util;

/**
 * Configuration for QuickBite Email Service.
 * To enable live SMTP delivery via Gmail or any standard provider:
 * 1. Set SENDER_EMAIL to your email address (e.g., yourname@gmail.com).
 * 2. Generate a 16-character Google App Password (not your normal password):
 *    myaccount.google.com -> Security -> 2-Step Verification -> App Passwords.
 * 3. Set SENDER_PASSWORD to that App Password.
 */
public final class EmailConfig {

	public static final String SMTP_HOST = System.getProperty("quickbite.mail.host",
			System.getenv().getOrDefault("QUICKBITE_MAIL_HOST", "smtp.gmail.com"));

	public static final int SMTP_PORT = Integer.parseInt(System.getProperty("quickbite.mail.port",
			System.getenv().getOrDefault("QUICKBITE_MAIL_PORT", "587")));

	public static final String SENDER_NAME = "QuickBite";

	// Default configured sender or read from environment/system properties
	public static final String SENDER_EMAIL = System.getProperty("quickbite.mail.sender",
			System.getenv().getOrDefault("QUICKBITE_MAIL_SENDER", "quickbite.orders@gmail.com"));

	public static final String SENDER_PASSWORD = System.getProperty("quickbite.mail.password",
			System.getenv().getOrDefault("QUICKBITE_MAIL_PASSWORD", ""));

	private EmailConfig() {
	}

	public static boolean isConfigured() {
		return SENDER_EMAIL != null && !SENDER_EMAIL.isBlank()
				&& SENDER_PASSWORD != null && !SENDER_PASSWORD.isBlank()
				&& !SENDER_PASSWORD.contains("REPLACE");
	}
}
