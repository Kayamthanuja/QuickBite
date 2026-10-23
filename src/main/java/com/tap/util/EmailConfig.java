
package com.tap.util;

public final class EmailConfig {

    public static final String SMTP_HOST =
            System.getProperty(
                    "quickbite.mail.host",
                    System.getenv().getOrDefault(
                            "QUICKBITE_MAIL_HOST", "smtp.gmail.com"));

    public static final int SMTP_PORT =
            Integer.parseInt(
                    System.getProperty(
                            "quickbite.mail.port",
                            System.getenv().getOrDefault(
                                    "QUICKBITE_MAIL_PORT", "587")));

    public static final String SENDER_NAME = "QuickBite";

    // Sender Gmail address is read from a Windows environment variable.
    public static final String SENDER_EMAIL =
            System.getProperty(
                    "quickbite.mail.sender",
                    System.getenv().getOrDefault(
                            "QUICKBITE_MAIL_SENDER", ""));

    // Gmail App Password is read from a Windows environment variable.
    public static final String SENDER_PASSWORD =
            System.getProperty(
                    "quickbite.mail.password",
                    System.getenv().getOrDefault(
                            "QUICKBITE_MAIL_PASSWORD", ""));

    private EmailConfig() {
    }

    public static boolean isConfigured() {
        return SENDER_EMAIL != null
                && !SENDER_EMAIL.isBlank()
                && SENDER_PASSWORD != null
                && !SENDER_PASSWORD.isBlank();
    }
}
