package com.tap.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.DAO.OrderDAO;
import com.tap.DAO.RestaurantDAO;
import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.Order;
import com.tap.model.Restaurant;
import com.tap.model.User;
import com.tap.util.GeoUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/deliveryDashboard", "/delivery/dashboard" })
public class DeliveryDashboardController extends HttpServlet {

	private OrderDAO orderDAO;
	private RestaurantDAO restaurantDAO;
	private UserDAO userDAO;

	@Override
	public void init() {
		orderDAO = new OrderDAOImpl();
		restaurantDAO = new RestaurantDAOImpl();
		userDAO = new UserDAOImpl();
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("user") == null) {
			resp.sendRedirect(req.getContextPath() + "/login?error=deliveryRequired");
			return;
		}

		User currentUser = (User) session.getAttribute("user");
		if (!currentUser.isDeliveryPartner() && !currentUser.isAdmin()) {
			resp.sendRedirect(req.getContextPath() + "/restaurant?error=unauthorized");
			return;
		}

		// Orders assigned to this delivery partner
		List<Order> partnerOrders = orderDAO.getOrdersByDeliveryPartner(currentUser.getUserId());
		List<Order> activeAssigned = new ArrayList<>();
		List<Order> completedOrders = new ArrayList<>();

		if (partnerOrders != null) {
			for (Order o : partnerOrders) {
				String st = o.getStatus() != null ? o.getStatus().toUpperCase() : "";
				if (st.contains("DELIVER") || st.contains("CANCEL")) {
					completedOrders.add(o);
				} else {
					activeAssigned.add(o);
				}
			}
		}

		// Available unassigned orders that need a rider
		List<Order> unassignedOrders = orderDAO.getUnassignedActiveOrders();

		// Lookup map for Restaurants & Customer Users
		Map<Integer, Restaurant> restaurantMap = new HashMap<>();
		Map<Integer, User> customerMap = new HashMap<>();

		for (Restaurant r : restaurantDAO.getAllRestaurants()) {
			restaurantMap.put(r.getRestaurantId(), r);
		}

		for (User u : userDAO.getAllUsers()) {
			customerMap.put(u.getUserId(), u);
		}

		// Earnings: ₹50 per delivery
		double deliveryFeePerOrder = 50.0;
		double totalEarnings = completedOrders.size() * deliveryFeePerOrder;

		req.setAttribute("partner", currentUser);
		req.setAttribute("activeOrders", activeAssigned);
		req.setAttribute("unassignedOrders", unassignedOrders);
		req.setAttribute("completedOrders", completedOrders);
		req.setAttribute("restaurantMap", restaurantMap);
		req.setAttribute("customerMap", customerMap);
		req.setAttribute("totalEarnings", totalEarnings);
		req.setAttribute("completedCount", completedOrders.size());

		req.getRequestDispatcher("/DeliveryDashboard.jsp").forward(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("user") == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		User currentUser = (User) session.getAttribute("user");
		if (!currentUser.isDeliveryPartner() && !currentUser.isAdmin()) {
			resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Delivery partner access only.");
			return;
		}

		String action = req.getParameter("action");
		boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
				|| "application/json".equalsIgnoreCase(req.getHeader("Accept"))
				|| "true".equalsIgnoreCase(req.getParameter("ajax"));

		try {
			if ("acceptOrder".equalsIgnoreCase(action)) {
				int orderId = Integer.parseInt(req.getParameter("orderId"));
				orderDAO.assignDeliveryPartner(orderId, currentUser.getUserId());
				orderDAO.updateStatus(orderId, "OUT FOR DELIVERY");

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"orderId\":" + orderId + ",\"status\":\"OUT FOR DELIVERY\"}");
					return;
				}

			} else if ("startDelivery".equalsIgnoreCase(action)) {
				int orderId = Integer.parseInt(req.getParameter("orderId"));
				orderDAO.updateStatus(orderId, "OUT FOR DELIVERY");

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"orderId\":" + orderId + ",\"status\":\"OUT FOR DELIVERY\"}");
					return;
				}

			} else if ("markDelivered".equalsIgnoreCase(action)) {
				int orderId = Integer.parseInt(req.getParameter("orderId"));
				orderDAO.updateStatus(orderId, "DELIVERED");

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"orderId\":" + orderId + ",\"status\":\"DELIVERED\"}");
					return;
				}

			} else if ("updateLocation".equalsIgnoreCase(action)) {
				int orderId = Integer.parseInt(req.getParameter("orderId"));
				double lat = Double.parseDouble(req.getParameter("lat"));
				double lng = Double.parseDouble(req.getParameter("lng"));
				orderDAO.updateRiderLocation(orderId, lat, lng);

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"orderId\":" + orderId + ",\"lat\":" + lat + ",\"lng\":" + lng + "}");
					return;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			if (isAjax) {
				resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
				resp.setContentType("application/json");
				resp.getWriter().print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
				return;
			}
		}

		resp.sendRedirect(req.getContextPath() + "/deliveryDashboard");
	}
}
