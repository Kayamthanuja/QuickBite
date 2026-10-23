package com.tap.util;

/**
 * Razorpay keys — replace with your Dashboard → Settings → API Keys values.
 * Use Test keys while developing (rzp_test_...).
 */
public final class RazorpayConfig {

	// TODO: replace with your Razorpay KEY ID and KEY SECRET
	public static final String KEY_ID = "rzp_test_TpeRfZ4YI7CJDg";
	public static final String KEY_SECRET = "QJcaDN3SBHfRa3OtDCSlTc17";

	public static final String CURRENCY = "INR";
	public static final String COMPANY_NAME = "QuickBite";

	private RazorpayConfig() {
	}

	public static boolean isConfigured() {
		return KEY_ID != null && !KEY_ID.contains("REPLACE")
				&& KEY_SECRET != null && !KEY_SECRET.contains("REPLACE");
	}
}
