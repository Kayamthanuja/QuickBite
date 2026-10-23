package com.tap.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import com.tap.DAO.MenuDAO;
import com.tap.DAO.OrderDAO;
import com.tap.DAO.RestaurantDAO;
import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.Restaurant;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/adminDashboard", "/admin/dashboard" })
public class AdminDashboardController extends HttpServlet {

	private OrderDAO orderDAO;
	private RestaurantDAO restaurantDAO;
	private MenuDAO menuDAO;
	private UserDAO userDAO;

	@Override
	public void init() {
		orderDAO = new OrderDAOImpl();
		restaurantDAO = new RestaurantDAOImpl();
		menuDAO = new MenuDAOImpl();
		userDAO = new UserDAOImpl();
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("user") == null) {
			resp.sendRedirect(req.getContextPath() + "/login?error=adminRequired");
			return;
		}

		User currentUser = (User) session.getAttribute("user");
		if (!currentUser.isAdmin()) {
			resp.sendRedirect(req.getContextPath() + "/restaurant?error=unauthorized");
			return;
		}

		List<Order> allOrders = orderDAO.getAllOrders();
		List<Restaurant> allRestaurants = restaurantDAO.getAllRestaurants();
		List<Menu> allMenus = menuDAO.getAllMenus();
		List<User> allUsers = userDAO.getAllUsers();
		List<User> deliveryPartners = userDAO.getUsersByRole("delivery agent");
		if (deliveryPartners == null || deliveryPartners.isEmpty()) {
			deliveryPartners = userDAO.getUsersByRole("delivery partner");
		}

		// Calculate KPIs
		double totalRevenue = 0.0;
		int activeRestaurantsCount = 0;
		int pendingOrdersCount = 0;

		if (allOrders != null) {
			for (Order order : allOrders) {
				totalRevenue += order.getTotalAmount();
				String s = order.getStatus() != null ? order.getStatus().toUpperCase() : "";
				if (!s.contains("DELIVER") && !s.contains("CANCEL")) {
					pendingOrdersCount++;
				}
			}
		}

		if (allRestaurants != null) {
			for (Restaurant r : allRestaurants) {
				if (r.isActive()) {
					activeRestaurantsCount++;
				}
			}
		}

		req.setAttribute("orders", allOrders);
		req.setAttribute("restaurants", allRestaurants);
		req.setAttribute("menus", allMenus);
		req.setAttribute("users", allUsers);
		req.setAttribute("deliveryPartners", deliveryPartners);
		req.setAttribute("totalRevenue", totalRevenue);
		req.setAttribute("activeRestaurantsCount", activeRestaurantsCount);
		req.setAttribute("pendingOrdersCount", pendingOrdersCount);

		req.getRequestDispatcher("/AdminDashboard.jsp").forward(req, resp);
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
		if (!currentUser.isAdmin()) {
			resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin privileges required.");
			return;
		}

		String action = req.getParameter("action");
		boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
				|| "application/json".equalsIgnoreCase(req.getHeader("Accept"))
				|| "true".equalsIgnoreCase(req.getParameter("ajax"));

		try {
			if ("updateOrderStatus".equalsIgnoreCase(action)) {
				int orderId = Integer.parseInt(req.getParameter("orderId"));
				String newStatus = req.getParameter("status");
				if (newStatus != null && !newStatus.isBlank()) {
					orderDAO.updateStatus(orderId, newStatus.trim().toUpperCase());
				}

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"orderId\":" + orderId + ",\"status\":\"" + newStatus + "\"}");
					return;
				}

			} else if ("assignPartner".equalsIgnoreCase(action)) {
				int orderId = Integer.parseInt(req.getParameter("orderId"));
				int partnerId = Integer.parseInt(req.getParameter("partnerId"));
				orderDAO.assignDeliveryPartner(orderId, partnerId);

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"orderId\":" + orderId + ",\"partnerId\":" + partnerId + "}");
					return;
				}

			} else if ("toggleRestaurant".equalsIgnoreCase(action)) {
				int restaurantId = Integer.parseInt(req.getParameter("restaurantId"));
				Restaurant r = restaurantDAO.getRestaurant(restaurantId);
				if (r != null) {
					r.setActive(!r.isActive());
					restaurantDAO.updateRestaurant(r);
				}

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"restaurantId\":" + restaurantId + ",\"isActive\":" + (r != null && r.isActive()) + "}");
					return;
				}

			} else if ("addRestaurant".equalsIgnoreCase(action)) {
				String name = req.getParameter("name");
				String cuisine = req.getParameter("cuisineType");
				String deliveryTime = req.getParameter("deliveryTime");
				String address = req.getParameter("address");
				String imagePath = req.getParameter("imagePath");
				double rating = 4.5;
				try {
					rating = Double.parseDouble(req.getParameter("rating"));
				} catch (Exception ignored) {
				}

				Restaurant newRest = new Restaurant();
				newRest.setName(name);
				newRest.setCuisineType(cuisine != null ? cuisine : "Multi-Cuisine");
				newRest.setDeliveryTime(deliveryTime != null ? deliveryTime : "30-40 mins");
				newRest.setAddress(address != null ? address : "Bangalore");
				newRest.setRating(rating);
				newRest.setActive(true);
				newRest.setAdminUserId(currentUser.getUserId());
				newRest.setImagePath(imagePath != null && !imagePath.isBlank()
						? imagePath
						: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80");

				restaurantDAO.addRestaurant(newRest);

			} else if ("toggleMenu".equalsIgnoreCase(action)) {
				int menuId = Integer.parseInt(req.getParameter("menuId"));
				Menu m = menuDAO.getMenu(menuId);
				if (m != null) {
					m.setAvailable(!m.isAvailable());
					menuDAO.updateMenu(m);
				}

				if (isAjax) {
					resp.setContentType("application/json");
					resp.getWriter().print("{\"success\":true,\"menuId\":" + menuId + ",\"isAvailable\":" + (m != null && m.isAvailable()) + "}");
					return;
				}

			} else if ("addMenu".equalsIgnoreCase(action)) {
				int restaurantId = Integer.parseInt(req.getParameter("restaurantId"));
				String itemName = req.getParameter("itemName");
				String description = req.getParameter("description");
				double price = Double.parseDouble(req.getParameter("price"));
				String imagePath = req.getParameter("imagePath");

				Menu newMenu = new Menu();
				newMenu.setRestaurantId(restaurantId);
				newMenu.setItemName(itemName);
				newMenu.setDescription(description != null ? description : "");
				newMenu.setPrice(price);
				newMenu.setAvailable(true);
				newMenu.setImagePath(imagePath != null && !imagePath.isBlank()
						? imagePath
						: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80");

				menuDAO.addMenu(newMenu);
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

		resp.sendRedirect(req.getContextPath() + "/adminDashboard");
	}
}
