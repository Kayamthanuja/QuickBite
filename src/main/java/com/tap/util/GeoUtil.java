package com.tap.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.tap.model.Order;

public final class GeoUtil {

	private static final Pattern COORD_PATTERN = Pattern
			.compile("\\[lat:(-?\\d+(?:\\.\\d+)?)\\s*,\\s*lng:(-?\\d+(?:\\.\\d+)?)\\]", Pattern.CASE_INSENSITIVE);

	private GeoUtil() {
	}

	public static Double[] parseLatLng(String address) {
		if (address == null) {
			return null;
		}
		Matcher matcher = COORD_PATTERN.matcher(address);
		if (!matcher.find()) {
			return null;
		}
		try {
			return new Double[] { Double.parseDouble(matcher.group(1)), Double.parseDouble(matcher.group(2)) };
		} catch (NumberFormatException e) {
			return null;
		}
	}

	public static void fillMissingCoords(Order order) {
		if (order == null) {
			return;
		}
		if (order.getDestLat() != null && order.getDestLng() != null) {
			return;
		}
		Double[] coords = parseLatLng(order.getDeliveryAddress());
		if (coords != null) {
			order.setDestLat(coords[0]);
			order.setDestLng(coords[1]);
		}
	}

	public static Double parseDouble(String value) {
		if (value == null || value.isBlank()) {
			return null;
		}
		try {
			return Double.parseDouble(value.trim());
		} catch (NumberFormatException e) {
			return null;
		}
	}

	public static String displayAddress(String address) {
		if (address == null) {
			return "";
		}
		return COORD_PATTERN.matcher(address).replaceAll("").trim();
	}
}
