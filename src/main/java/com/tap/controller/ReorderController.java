
package com.tap.controller;

import java.io.IOException;
import java.util.List;

import com.tap.DAO.OrderDAO;
import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.OrderItemDAOImpl;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.model.Cart;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/reorder")
public class ReorderController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("user") == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		User user = (User) session.getAttribute("user");

		int orderId;

		try {
			orderId = Integer.parseInt(request.getParameter("orderId"));

			if (orderId <= 0) {
				throw new NumberFormatException();
			}
		} catch (NumberFormatException e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID.");
			return;
		}

		try {
			// Verify that this order belongs to the logged-in user.
			OrderDAO orderDAO = new OrderDAOImpl();
			List<Order> userOrders = orderDAO.getAllOrdersByUserID(user.getUserId());

			Order selectedOrder = null;

			if (userOrders != null) {
				for (Order order : userOrders) {
					if (order.getOrderId() == orderId) {
						selectedOrder = order;
						break;
					}
				}
			}

			if (selectedOrder == null) {
				response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found.");
				return;
			}

			// Retrieve all items from the selected order.
			OrderItemDAOImpl orderItemDAO = new OrderItemDAOImpl();

			List<OrderItem> orderItems = orderItemDAO.getAllOrderItemsByOrderID(orderId);

			if (orderItems == null || orderItems.isEmpty()) {
				session.setAttribute("cartMessage", "No items were found in this previous order.");

				response.sendRedirect(request.getContextPath() + "/cart");
				return;
			}

			MenuDAOImpl menuDAO = new MenuDAOImpl();

			// Start a fresh cart for this previous order's restaurant.
			Cart cart = new Cart(selectedOrder.getRestaurantId());

			for (OrderItem item : orderItems) {

				Menu menu = menuDAO.getMenu(item.getMenuId());

				if (menu == null || !menu.isAvailable()) {
					continue;
				}

				// Do not restore an item belonging to another restaurant.
				if (menu.getRestaurantId() != selectedOrder.getRestaurantId()) {
					continue;
				}

				int quantity = item.getQuantity();

				if (quantity <= 0) {
					continue;
				}

				// Cart.addItem() adds one unit per call.
				for (int i = 0; i < quantity; i++) {
					cart.addItem(menu);
				}
			}

			if (cart.getItems().isEmpty()) {
				session.setAttribute("cartMessage", "The items from this order are currently unavailable.");
			} else {
				session.setAttribute("cart", cart);

				// Clear any coupon from the previous cart.
				session.removeAttribute("appliedCoupon");
				session.removeAttribute("couponInput");
				session.removeAttribute("couponMessage");

				session.setAttribute("cartMessage", "Your previous order has been added to the cart.");
			}

			response.sendRedirect(request.getContextPath() + "/cart");

		} catch (Exception e) {
			throw new ServletException("Unable to reorder the selected order.", e);
		}
	}
}
