package com.tap.util;

import java.util.List;
import java.util.Map;

import com.tap.DAO.MenuDAO;
import com.tap.DAO.RestaurantDAO;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.Restaurant;
import com.tap.model.User;

/**
 * Service to dispatch order confirmation notifications via SMS, Email, and in-app logs.
 * Includes complete item details, quantities, amounts, and tracking information.
 */
public final class OrderNotificationService {

	private OrderNotificationService() {
	}

	public static void notifyOrder(Order order, List<OrderItem> items, User user) {
		if (order == null || user == null) {
			return;
		}

		try {
			MenuDAO menuDAO = new MenuDAOImpl();
			RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

			Restaurant restaurant = restaurantDAO.getRestaurant(order.getRestaurantId());
			String restaurantName = (restaurant != null && restaurant.getName() != null)
					? restaurant.getName()
					: "QuickBite Kitchen";

			StringBuilder itemsSummary = new StringBuilder();
			if (items != null && !items.isEmpty()) {
				for (int i = 0; i < items.size(); i++) {
					OrderItem item = items.get(i);
					Menu menu = menuDAO.getMenu(item.getMenuId());
					String itemName = (menu != null && menu.getItemName() != null)
							? menu.getItemName()
							: "Item #" + item.getMenuId();

					if (i > 0) {
						itemsSummary.append(", ");
					}
					itemsSummary.append(itemName).append(" x ").append(item.getQuantity());
				}
			} else {
				itemsSummary.append("Food Order");
			}

			// Format SMS / Text alert
			String smsMessage = "QuickBite: Order #QB-" + order.getOrderId()
					+ " confirmed at " + restaurantName + "!"
					+ " Items: [" + itemsSummary.toString() + "]."
					+ " Total: Rs." + Math.round(order.getTotalAmount())
					+ ". Track your delivery live in app. Enjoy your meal!";

			// Send SMS if phone is provided
			if (user.getPhone() != null && !user.getPhone().isBlank()) {
				String normalizedPhone = OtpService.normalizePhone(user.getPhone());
				boolean sent = SmsService.sendText(normalizedPhone, smsMessage);
				if (sent) {
					System.out.println("[QuickBite Notification] SMS sent to " + normalizedPhone + ": " + smsMessage);
				} else {
					System.out.println("[QuickBite Notification Alert] Dispatched order confirmation for "
							+ normalizedPhone + " (Order #QB-" + order.getOrderId() + "): " + smsMessage);
				}
			}

			// Send HTML Email confirmation to user's registered email
			if (user.getEmail() != null && !user.getEmail().isBlank()) {
				String subject = "🍽️ QuickBite: Order #QB-" + order.getOrderId() + " Confirmed!";
				String htmlBody = formatHtmlEmailReceipt(order, items, restaurantName, user);
				EmailService.sendEmailAsync(user.getEmail(), subject, htmlBody);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static String formatHtmlEmailReceipt(Order order, List<OrderItem> items, String restaurantName, User user) {
		MenuDAO menuDAO = new MenuDAOImpl();
		StringBuilder itemRows = new StringBuilder();

		if (items != null && !items.isEmpty()) {
			for (OrderItem item : items) {
				Menu m = menuDAO.getMenu(item.getMenuId());
				String name = (m != null && m.getItemName() != null) ? m.getItemName() : ("Item #" + item.getMenuId());
				double price = (m != null) ? m.getPrice() : (item.getTotalAmount() / Math.max(1, item.getQuantity()));
				itemRows.append("<tr>")
						.append("<td style='padding: 10px 12px; border-bottom: 1px solid #f0e6da;'><strong>").append(name).append("</strong></td>")
						.append("<td style='padding: 10px 12px; border-bottom: 1px solid #f0e6da; text-align: center;'>").append(item.getQuantity()).append("</td>")
						.append("<td style='padding: 10px 12px; border-bottom: 1px solid #f0e6da; text-align: right;'>&#8377;").append(String.format("%.2f", price)).append("</td>")
						.append("<td style='padding: 10px 12px; border-bottom: 1px solid #f0e6da; text-align: right; font-weight: bold;'>&#8377;").append(String.format("%.2f", item.getTotalAmount())).append("</td>")
						.append("</tr>");
			}
		} else {
			itemRows.append("<tr><td colspan='4' style='padding: 10px 12px; text-align: center; color: #888;'>Food Order</td></tr>");
		}

		String cleanAddress = GeoUtil.displayAddress(order.getDeliveryAddress());

		return "<!DOCTYPE html>"
				+ "<html><head><meta charset='UTF-8'></head>"
				+ "<body style='margin:0; padding:20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif; background-color: #f7f3ec; color: #38251b;'>"
				+ "<div style='max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 18px rgba(0,0,0,0.08); border: 1px solid #eee1cd;'>"
				// Header
				+ "<div style='background: linear-gradient(135deg, #f5a623 0%, #e89512 100%); padding: 28px 24px; text-align: center; color: #ffffff;'>"
				+ "<div style='font-size: 32px;'>🍽️</div>"
				+ "<h1 style='margin: 8px 0 4px; font-size: 26px; font-weight: 800; letter-spacing: -0.5px;'>QuickBite</h1>"
				+ "<p style='margin: 0; font-size: 15px; font-weight: 500; opacity: 0.95;'>Order Confirmed! Your feast is on its way.</p>"
				+ "</div>"
				// Content
				+ "<div style='padding: 28px 24px;'>"
				+ "<p style='font-size: 16px; margin: 0 0 16px;'>Hello <strong>" + user.getUsername() + "</strong>,</p>"
				+ "<p style='font-size: 14px; color: #665243; line-height: 1.6; margin: 0 0 20px;'>"
				+ "Thank you for dining with QuickBite! Your order has been placed successfully and is being prepared by <strong>" + restaurantName + "</strong>."
				+ "</p>"
				// Order details badge
				+ "<div style='background: #fff8ee; border: 1px solid #fedba9; border-radius: 10px; padding: 14px 18px; margin-bottom: 24px; display: flex; justify-content: space-between;'>"
				+ "<div><span style='font-size: 12px; color: #8c6a46; text-transform: uppercase; font-weight: 700;'>Order ID</span><br><strong style='font-size: 17px; color: #d97706;'>#QB-" + order.getOrderId() + "</strong></div>"
				+ "<div style='text-align: right;'><span style='font-size: 12px; color: #8c6a46; text-transform: uppercase; font-weight: 700;'>Payment Method</span><br><strong style='font-size: 15px; color: #38251b;'>" + order.getPaymentMode() + "</strong></div>"
				+ "</div>"
				// Items table
				+ "<table style='width: 100%; border-collapse: collapse; font-size: 14px; margin-bottom: 20px;'>"
				+ "<thead><tr style='background: #fbf5ee; color: #6b4d32; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px;'>"
				+ "<th style='padding: 10px 12px; text-align: left; border-bottom: 2px solid #ecd8c2;'>Item</th>"
				+ "<th style='padding: 10px 12px; text-align: center; border-bottom: 2px solid #ecd8c2;'>Qty</th>"
				+ "<th style='padding: 10px 12px; text-align: right; border-bottom: 2px solid #ecd8c2;'>Price</th>"
				+ "<th style='padding: 10px 12px; text-align: right; border-bottom: 2px solid #ecd8c2;'>Total</th>"
				+ "</tr></thead>"
				+ "<tbody>" + itemRows.toString() + "</tbody>"
				+ "<tfoot>"
				+ "<tr><td colspan='3' style='padding: 8px 12px; text-align: right; color: #776554;'>Delivery Fee:</td><td style='padding: 8px 12px; text-align: right; color: #776554;'>&#8377;40.00</td></tr>"
				+ "<tr style='font-size: 16px; font-weight: 800; background: #fffbf5;'><td colspan='3' style='padding: 12px; text-align: right; border-top: 2px solid #ecd8c2;'>Grand Total:</td><td style='padding: 12px; text-align: right; border-top: 2px solid #ecd8c2; color: #b45309;'>&#8377;" + String.format("%.2f", order.getTotalAmount()) + "</td></tr>"
				+ "</tfoot></table>"
				// Delivery info
				+ "<div style='background: #f9f9fb; border: 1px solid #e5e7eb; border-radius: 10px; padding: 14px 18px; margin-bottom: 24px; font-size: 13px; color: #4b5563;'>"
				+ "<div>📍 <strong>Delivery Address:</strong> " + cleanAddress + "</div>"
				+ "<div style='margin-top: 6px;'>⏱️ <strong>Estimated Delivery:</strong> 30 - 40 minutes</div>"
				+ "</div>"
				// Button
				+ "<div style='text-align: center; margin: 28px 0 10px;'>"
				+ "<a href='http://localhost:8080/FoodWala/orderSuccess?orderId=" + order.getOrderId() + "' style='background: #f5a623; color: #ffffff; text-decoration: none; padding: 12px 28px; border-radius: 25px; font-weight: 700; font-size: 15px; display: inline-block; box-shadow: 0 4px 12px rgba(245, 166, 35, 0.35);'>Track Order Live &rarr;</a>"
				+ "</div>"
				+ "</div>"
				// Footer
				+ "<div style='background: #faf6f0; border-top: 1px solid #eee1cd; padding: 18px 24px; text-align: center; font-size: 12px; color: #9c8472;'>"
				+ "<p style='margin: 0;'>QuickBite Online Food Delivery &bull; Taste the joy delivered fresh</p>"
				+ "<p style='margin: 4px 0 0;'>Questions about your order? Reach out anytime at support@quickbite.com</p>"
				+ "</div></div></body></html>";
	}
}
