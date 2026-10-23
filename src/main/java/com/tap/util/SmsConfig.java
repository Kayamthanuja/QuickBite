package com.tap.util;

/**
 * Fast2SMS credentials — paste your Dev API key from
 * https://www.fast2sms.com/dashboard/dev-api
 *
 * OTP SMS uses the built-in OTP route (template: "Your OTP: {code}").
 * Order alerts use Quick SMS (route q).
 */
public final class SmsConfig {

	public static final String FAST2SMS_API_KEY = "KaStXnkUtWZN3oR6I8tEO6gqx6tjPz6XEcpnTMVNNmwrtCAjmm9OfQ3MEq6U";

	public static final String SENDER_NAME = "QuickBite";

	private SmsConfig() {
	}

	public static boolean isConfigured() {
		return FAST2SMS_API_KEY != null
				&& !FAST2SMS_API_KEY.isBlank()
				&& !FAST2SMS_API_KEY.contains("REPLACE");
	}
}
