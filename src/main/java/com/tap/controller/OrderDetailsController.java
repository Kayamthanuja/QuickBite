
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

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orderDetails")
public class OrderDetailsController extends HttpServlet {

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
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String orderIdParameter = req.getParameter("orderId");

        if (orderIdParameter == null ||
            orderIdParameter.trim().isEmpty()) {

            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        int orderId;

        try {
            orderId = Integer.parseInt(orderIdParameter);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        Order order = orderDAO.getOrder(orderId);

        if (order == null || order.getUserId() != user.getUserId()) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        List<OrderItem> orderItems =
                orderItemDAO.getAllOrderItemsByOrderID(orderId);

        // Fetch menu details for each ordered item.
        Map<Integer, Menu> menuById = new HashMap<>();

        if (orderItems != null) {
            for (OrderItem item : orderItems) {
                Menu menu = menuDAO.getMenu(item.getMenuId());

                if (menu != null) {
                    menuById.put(item.getMenuId(), menu);
                }
            }
        }

        // Find the restaurant details
        int restaurantId = order.getRestaurantId();
        if (restaurantId <= 0 && !menuById.isEmpty()) {
            Menu firstMenu = menuById.values().iterator().next();
            restaurantId = firstMenu.getRestaurantId();
        }

        Restaurant restaurant = null;
        if (restaurantId > 0) {
            restaurant = restaurantDAO.getRestaurant(restaurantId);
        }

        String restaurantName = (restaurant != null) ? restaurant.getName() : "Restaurant Name Unavailable";

        // Assign delivery partner
        User deliveryPartner = null;
        try {
            int agentId = (orderId % 2 == 0) ? 3 : 7;
            deliveryPartner = userDAO.getUser(agentId);
            if (deliveryPartner == null) {
                deliveryPartner = userDAO.getUser(3);
            }
        } catch (Exception ignored) {
        }
        if (deliveryPartner == null) {
            deliveryPartner = new User();
            deliveryPartner.setUsername("Amit Kumar");
            deliveryPartner.setPhone("+91 98451 23456");
        }

        req.setAttribute("order", order);
        req.setAttribute("orderItems", orderItems);
        req.setAttribute("menuById", menuById);
        req.setAttribute("restaurant", restaurant);
        req.setAttribute("restaurantName", restaurantName);
        req.setAttribute("deliveryPartner", deliveryPartner);

        req.getRequestDispatcher("OrderDetails.jsp")
           .forward(req, resp);
    }
}
