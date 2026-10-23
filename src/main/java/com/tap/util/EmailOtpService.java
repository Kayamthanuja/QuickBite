package com.tap.util;

import java.io.UnsupportedEncodingException;
import java.util.Properties;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public final class EmailOtpService {

    private EmailOtpService() {
    }

    public static void sendOtp(String recipientEmail, String otp)
            throws MessagingException {

        if (!EmailConfig.isConfigured()) {
            throw new MessagingException(
                    "Email SMTP is not configured. Set your sender email "
                    + "and Gmail App Password.");
        }

        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", EmailConfig.SMTP_HOST);
        properties.put("mail.smtp.port",
                String.valueOf(EmailConfig.SMTP_PORT));
        properties.put("mail.smtp.ssl.trust", EmailConfig.SMTP_HOST);
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "10000");
        properties.put("mail.smtp.writetimeout", "10000");

        Session mailSession = Session.getInstance(
                properties,
                new Authenticator() {
                    @Override
                    protected PasswordAuthentication
                            getPasswordAuthentication() {
                        return new PasswordAuthentication(
                                EmailConfig.SENDER_EMAIL,
                                EmailConfig.SENDER_PASSWORD);
                    }
                });

        Message message = new MimeMessage(mailSession);

        try {
            message.setFrom(new InternetAddress(
                    EmailConfig.SENDER_EMAIL,
                    EmailConfig.SENDER_NAME,
                    "UTF-8"));
        } catch (UnsupportedEncodingException e) {
            throw new MessagingException(
                    "Unable to configure sender email address.", e);
        }

        // Recipient is the registered email checked by OtpLoginController.
        message.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(recipientEmail));

        message.setSubject("QuickBite Login Verification Code");
        message.setText(
        	    "Hello,\n\n"
        	    + "Your QuickBite login verification code is: " + otp + "\n\n"
        	    + "This code expires in 5 minutes and can only be used once.\n"
        	    + "If you did not request this code, you can ignore this email.\n\n"
        	    + "Thank you,\nQuickBite Team"
        	);

        Transport.send(message);
    }
}