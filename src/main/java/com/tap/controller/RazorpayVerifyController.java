package com.tap.controller;

import java.io.IOException;
import java.sql.Timestamp;

import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.OrderItemDAOImpl;
import com.tap.model.Cart;
import com.tap.model.CartItem;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.User;
import com.tap.util.RazorpayService;
import com.tap.util.SmsService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/razorpay/verify")
public class RazorpayVerifyController extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("user") == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		String razorpayOrderId = req.getParameter("razorpay_order_id");
		String razorpayPaymentId = req.getParameter("razorpay_payment_id");
		String razorpaySignature = req.getParameter("razorpay_signature");

		String expectedOrderId = (String) session.getAttribute("pendingRazorpayOrderId");

		if (razorpayOrderId == null || razorpayPaymentId == null || razorpaySignature == null
				|| expectedOrderId == null || !expectedOrderId.equals(razorpayOrderId)
				|| !RazorpayService.verifyPaymentSignature(razorpayOrderId, razorpayPaymentId, razorpaySignature)) {

			resp.sendRedirect(req.getContextPath() + "/checkout?error=paymentFailed");
			return;
		}

		User user = (User) session.getAttribute("user");
		Cart cart = (Cart) session.getAttribute("cart");

		if (cart == null || cart.getItems().isEmpty()) {
			resp.sendRedirect(req.getContextPath() + "/cart");
			return;
		}

		String deliveryAddress = (String) session.getAttribute("pendingDeliveryAddress");
		String paymentMethod = (String) session.getAttribute("pendingPaymentMethod");
		Double totalAmountObj = (Double) session.getAttribute("pendingTotalAmount");

		if (deliveryAddress == null || totalAmountObj == null) {
			resp.sendRedirect(req.getContextPath() + "/checkout?error=orderFailed");
			return;
		}

		int restaurantId = cart.getRestaurantId();
		if (restaurantId <= 0 && !cart.getItems().isEmpty()) {
			restaurantId = cart.getItems().iterator().next().getMenu().getRestaurantId();
			cart.setRestaurantId(restaurantId);
		}

		Order order = new Order();
		order.setUserId(user.getUserId());
		order.setRestaurantId(restaurantId);
		order.setOrderDate(new Timestamp(System.currentTimeMillis()));
		order.setTotalAmount(totalAmountObj);
		order.setStatus("PLACED");
		order.setPaymentMode(paymentMethod != null ? paymentMethod : "ONLINE (Razorpay)");
		order.setDeliveryAddress(deliveryAddress);

		// Set delivery partner and GPS tracking coordinates
		order.setDeliveryPartnerId(3); // Default active rider
		order.setRiderLat(12.9754);
		order.setRiderLng(77.6045);

		String latStr = (String) session.getAttribute("pendingDestLat");
		String lngStr = (String) session.getAttribute("pendingDestLng");
		if (latStr != null && !latStr.isBlank() && lngStr != null && !lngStr.isBlank()) {
			try {
				order.setDestLat(Double.parseDouble(latStr.trim()));
				order.setDestLng(Double.parseDouble(lngStr.trim()));
			} catch (Exception ignored) {
				order.setDestLat(12.9630);
				order.setDestLng(77.6380);
			}
		} else {
			order.setDestLat(12.9630);
			order.setDestLng(77.6380);
		}

		OrderDAOImpl orderDAO = new OrderDAOImpl();
		int orderId = orderDAO.addOrder(order);

		if (orderId <= 0) {
			resp.sendRedirect(req.getContextPath() + "/checkout?error=orderFailed");
			return;
		}

		order.setOrderId(orderId);
		OrderItemDAOImpl orderItemDAO = new OrderItemDAOImpl();
		java.util.List<OrderItem> savedItems = new java.util.ArrayList<>();

		for (CartItem cartItem : cart.getItems()) {
			OrderItem orderItem = new OrderItem();
			orderItem.setOrderId(orderId);
			orderItem.setMenuId(cartItem.getMenu().getMenuId());
			orderItem.setQuantity(cartItem.getQuantity());
			orderItem.setTotalAmount(cartItem.getSubTotal());
			orderItemDAO.addOrderItem(orderItem);
			savedItems.add(orderItem);
		}

		session.removeAttribute("cart");
		session.removeAttribute("pendingDeliveryAddress");
		session.removeAttribute("pendingDestLat");
		session.removeAttribute("pendingDestLng");
		session.removeAttribute("pendingPaymentMethod");
		session.removeAttribute("pendingRazorpayOrderId");
		session.removeAttribute("pendingTotalAmount");
		session.setAttribute("lastOrderId", orderId);

		// Send notification with all ordered items
		com.tap.util.OrderNotificationService.notifyOrder(order, savedItems, user);

		resp.sendRedirect(req.getContextPath() + "/orderSuccess");
	}
}
