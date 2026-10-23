package com.tap.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.DAO.MenuDAO;
import com.tap.DAO.OrderDAO;
import com.tap.DAO.OrderItemDAO;
import com.tap.DAO.RestaurantDAO;
import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.OrderItemDAOImpl;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.Restaurant;
import com.tap.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orderSuccess")
public class OrderStatusController extends HttpServlet {

	private OrderDAO orderDAO;
	private OrderItemDAO orderItemDAO;
	private MenuDAO menuDAO;
	private RestaurantDAO restaurantDAO;
	private UserDAO userDAO;

	@Override
	public void init() {
		orderDAO = new OrderDAOImpl();
		orderItemDAO = new OrderItemDAOImpl();
		menuDAO = new MenuDAOImpl();
		restaurantDAO = new RestaurantDAOImpl();
		userDAO = new UserDAOImpl();
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		HttpSession session = req.getSession(false);

		// Check whether user is logged in
		if (session == null || session.getAttribute("user") == null) {
			resp.sendRedirect(req.getContextPath() + "/login");
			return;
		}

		// Get the last placed order ID
		Object orderIdObject = session.getAttribute("lastOrderId");

		if (orderIdObject == null) {
			// Try checking query param
			String qId = req.getParameter("orderId");
			if (qId != null && !qId.isBlank()) {
				try {
					orderIdObject = Integer.parseInt(qId.trim());
				} catch (Exception ignored) {
				}
			}
		}

		if (orderIdObject == null) {
			resp.sendRedirect(req.getContextPath() + "/restaurant");
			return;
		}

		int orderId = (Integer) orderIdObject;

		Order order = orderDAO.getOrder(orderId);
		Restaurant restaurant = null;
		User deliveryPartner = null;

		List<OrderItem> orderItems = null;
		Map<Integer, Menu> menuById = new HashMap<>();

		if (order != null) {
			if (order.getRestaurantId() > 0) {
				restaurant = restaurantDAO.getRestaurant(order.getRestaurantId());
			}

			int partnerId = (order.getDeliveryPartnerId() != null && order.getDeliveryPartnerId() > 0)
					? order.getDeliveryPartnerId()
					: 3;
			deliveryPartner = userDAO.getUser(partnerId);

			orderItems = orderItemDAO.getAllOrderItemsByOrderID(orderId);
			if (orderItems != null) {
				for (OrderItem item : orderItems) {
					Menu menu = menuDAO.getMenu(item.getMenuId());
					if (menu != null) {
						menuById.put(item.getMenuId(), menu);
					}
				}
			}
		}

		if (deliveryPartner == null) {
			deliveryPartner = new User();
			deliveryPartner.setUsername("Amit Kumar");
			deliveryPartner.setPhone("+91 98451 23456");
		}

		// Send attributes to JSP
		req.setAttribute("orderId", orderId);
		req.setAttribute("order", order);
		req.setAttribute("restaurant", restaurant);
		req.setAttribute("deliveryPartner", deliveryPartner);
		req.setAttribute("orderItems", orderItems);
		req.setAttribute("menuById", menuById);

		// Open OrderStatus.jsp
		RequestDispatcher rd = req.getRequestDispatcher("OrderStatus.jsp");
		rd.forward(req, resp);
	}
}