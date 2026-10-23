
package com.tap.util;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.tap.DAO.MenuDAO;
import com.tap.DAO.RestaurantDAO;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.Restaurant;
import com.tap.model.User;

public final class OrderNotificationService {

	/*
	 * Keep this URL consistent with your Tomcat deployment. "FoodWala" is the
	 * context path used in your existing email link. Change it if your deployed
	 * application uses a different context path.
	 */
	private static final String APP_BASE_URL = "http://localhost:8080/FoodWala";

	private OrderNotificationService() {
	}

	public static void notifyOrder(Order order, List<OrderItem> items, User user) {

		if (order == null || user == null) {
			return;
		}

		try {
			RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

			Restaurant restaurant = restaurantDAO.getRestaurant(order.getRestaurantId());

			String restaurantName = (restaurant != null && restaurant.getName() != null) ? restaurant.getName()
					: "QuickBite Kitchen";

			// Build the HTML email receipt.
			String subject = "QuickBite: Order #QB-" + order.getOrderId() + " Confirmed!";

			String htmlBody = formatHtmlEmailReceipt(order, items, restaurantName, user);

			/*
			 * SMS is not being used. Keep the smsMessage field empty for compatibility with
			 * existing JSP code that may still reference it.
			 */
			NOTIFICATION_STORE.put(order.getOrderId(),
					new SentNotification(order.getOrderId(), user.getPhone() != null ? user.getPhone() : "",
							user.getEmail() != null ? user.getEmail() : "", "", subject, htmlBody,
							System.currentTimeMillis()));

			// Send the order confirmation email.
			if (user.getEmail() != null && !user.getEmail().isBlank()) {

				EmailService.sendEmailAsync(user.getEmail(), subject, htmlBody);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static SentNotification getNotification(int orderId) {
		return NOTIFICATION_STORE.get(orderId);
	}

	public static class SentNotification {

		public final int orderId;
		public final String phone;
		public final String email;
		public final String smsMessage;
		public final String emailSubject;
		public final String htmlBody;
		public final long timestamp;

		public SentNotification(int orderId, String phone, String email, String smsMessage, String emailSubject,
				String htmlBody, long timestamp) {

			this.orderId = orderId;
			this.phone = phone;
			this.email = email;
			this.smsMessage = smsMessage;
			this.emailSubject = emailSubject;
			this.htmlBody = htmlBody;
			this.timestamp = timestamp;
		}
	}

	private static final Map<Integer, SentNotification> NOTIFICATION_STORE = new ConcurrentHashMap<>();

	private static String formatHtmlEmailReceipt(Order order, List<OrderItem> items, String restaurantName, User user) {

		MenuDAO menuDAO = new MenuDAOImpl();
		StringBuilder itemRows = new StringBuilder();

		if (items != null && !items.isEmpty()) {

			for (OrderItem item : items) {

				Menu menu = menuDAO.getMenu(item.getMenuId());

				String itemName = (menu != null && menu.getItemName() != null) ? menu.getItemName()
						: "Item #" + item.getMenuId();

				double price = (menu != null) ? menu.getPrice()
						: item.getTotalAmount() / Math.max(1, item.getQuantity());

				itemRows.append("<tr>").append("<td style='padding:10px 12px;" + "border-bottom:1px solid #f0e6da;'>")
						.append("<strong>").append(itemName).append("</strong></td>")

						.append("<td style='padding:10px 12px;"
								+ "border-bottom:1px solid #f0e6da;" + "text-align:center;'>")
						.append(item.getQuantity()).append("</td>")

						.append("<td style='padding:10px 12px;" + "border-bottom:1px solid #f0e6da;"
								+ "text-align:right;'>")
						.append("&#8377;").append(String.format("%.2f", price)).append("</td>")

						.append("<td style='padding:10px 12px;" + "border-bottom:1px solid #f0e6da;"
								+ "text-align:right;font-weight:bold;'>")
						.append("&#8377;").append(String.format("%.2f", item.getTotalAmount())).append("</td>")
						.append("</tr>");
			}

		} else {

			itemRows.append("<tr><td colspan='4' style='padding:10px 12px;"
					+ "text-align:center;color:#888;'>Food Order</td></tr>");
		}

		String cleanAddress = GeoUtil.displayAddress(order.getDeliveryAddress());

		/*
		 * IMPORTANT: This link opens OrderStatusController using /orderSuccess. The
		 * order ID is included so the controller can load this order.
		 */
		String trackingUrl = APP_BASE_URL + "/orderSuccess?orderId=" + order.getOrderId();

		return "<!DOCTYPE html>" + "<html><head><meta charset='UTF-8'></head>" + "<body style='margin:0;padding:20px;"
				+ "font-family:Arial,Helvetica,sans-serif;" + "background-color:#f7f3ec;color:#38251b;'>"

				+ "<div style='max-width:600px;margin:0 auto;" + "background:#ffffff;border-radius:16px;"
				+ "overflow:hidden;border:1px solid #eee1cd;'>"

				// Header
				+ "<div style='background:#f5a623;padding:28px 24px;" + "text-align:center;color:#ffffff;'>"
				+ "<div style='font-size:32px;'>&#127869;</div>" + "<h1 style='margin:8px 0 4px;font-size:26px;"
				+ "font-weight:800;'>QuickBite</h1>" + "<p style='margin:0;font-size:15px;'>"
				+ "Order Confirmed! Your feast is on its way." + "</p></div>"

				// Main content
				+ "<div style='padding:28px 24px;'>" + "<p style='font-size:16px;margin:0 0 16px;'>Hello " + "<strong>"
				+ user.getUsername() + "</strong>,</p>"

				+ "<p style='font-size:14px;color:#665243;" + "line-height:1.6;margin:0 0 20px;'>"
				+ "Thank you for dining with QuickBite! Your order "
				+ "has been placed successfully and is being prepared by " + "<strong>" + restaurantName + "</strong>."
				+ "</p>"

				// Order ID and payment method
				+ "<div style='background:#fff8ee;border:1px solid #fedba9;"
				+ "border-radius:10px;padding:14px 18px;margin-bottom:24px;'>"
				+ "<div><span style='font-size:12px;color:#8c6a46;"
				+ "text-transform:uppercase;font-weight:700;'>Order ID</span>"
				+ "<br><strong style='font-size:17px;color:#d97706;'>" + "#QB-" + order.getOrderId() + "</strong></div>"
				+ "<div style='margin-top:10px;'><span style='font-size:12px;"
				+ "color:#8c6a46;text-transform:uppercase;font-weight:700;'>" + "Payment Method</span><br>"
				+ "<strong style='font-size:15px;color:#38251b;'>" + order.getPaymentMode() + "</strong></div></div>"

				// Ordered items
				+ "<table style='width:100%;border-collapse:collapse;" + "font-size:14px;margin-bottom:20px;'>"
				+ "<thead><tr style='background:#fbf5ee;color:#6b4d32;" + "font-size:12px;text-transform:uppercase;'>"
				+ "<th style='padding:10px 12px;text-align:left;'>Item</th>"
				+ "<th style='padding:10px 12px;text-align:center;'>Qty</th>"
				+ "<th style='padding:10px 12px;text-align:right;'>Price</th>"
				+ "<th style='padding:10px 12px;text-align:right;'>Total</th>" + "</tr></thead>" + "<tbody>" + itemRows
				+ "</tbody>" + "<tfoot>" + "<tr><td colspan='3' style='padding:8px 12px;"
				+ "text-align:right;color:#776554;'>Delivery Fee:</td>"
				+ "<td style='padding:8px 12px;text-align:right;" + "color:#776554;'>&#8377;40.00</td></tr>"
				+ "<tr style='font-size:16px;font-weight:800;" + "background:#fffbf5;'>"
				+ "<td colspan='3' style='padding:12px;text-align:right;"
				+ "border-top:2px solid #ecd8c2;'>Grand Total:</td>" + "<td style='padding:12px;text-align:right;"
				+ "border-top:2px solid #ecd8c2;color:#b45309;'>" + "&#8377;"
				+ String.format("%.2f", order.getTotalAmount()) + "</td></tr>" + "</tfoot></table>"

				// Delivery details
				+ "<div style='background:#f9f9fb;border:1px solid #e5e7eb;"
				+ "border-radius:10px;padding:14px 18px;margin-bottom:24px;" + "font-size:13px;color:#4b5563;'>"
				+ "<div>&#128205; <strong>Delivery Address:</strong> " + cleanAddress + "</div>"
				+ "<div style='margin-top:6px;'>&#9201; " + "<strong>Estimated Delivery:</strong> 30 - 40 minutes</div>"
				+ "</div>"

				// Live tracking button
				+ "<div style='text-align:center;margin:28px 0 10px;'>" + "<a href='" + trackingUrl + "'"
				+ " style='background:#f5a623;color:#ffffff;" + "text-decoration:none;padding:12px 28px;"
				+ "border-radius:25px;font-weight:700;font-size:15px;" + "display:inline-block;'>"
				+ "Track Order Live &rarr;</a></div>"

				+ "</div>"

				// Footer
				+ "<div style='background:#faf6f0;border-top:1px solid #eee1cd;"
				+ "padding:18px 24px;text-align:center;font-size:12px;" + "color:#9c8472;'>"
				+ "<p style='margin:0;'>QuickBite Online Food Delivery" + " &bull; Taste the joy delivered fresh</p>"
				+ "<p style='margin:4px 0 0;'>Questions about your order?" + " Reach out at support@quickbite.com</p>"
				+ "</div></div></body></html>";
	}
}
