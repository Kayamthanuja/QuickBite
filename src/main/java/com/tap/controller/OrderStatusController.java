
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

    private static final long serialVersionUID = 1L;

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
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // Require the user to be logged in.
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        /*
         * First, read the order ID supplied in the email link.
         * This ensures that an older email opens its own order,
         * rather than whichever order was placed most recently.
         */
        Integer orderId = null;

        String queryOrderId = req.getParameter("orderId");

        if (queryOrderId != null && !queryOrderId.isBlank()) {
            try {
                orderId = Integer.parseInt(queryOrderId.trim());
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }
        }

        // If the URL has no order ID, fall back to the session.
        if (orderId == null) {
            Object lastOrderId = session.getAttribute("lastOrderId");

            if (lastOrderId instanceof Integer) {
                orderId = (Integer) lastOrderId;
            } else if (lastOrderId != null) {
                try {
                    orderId = Integer.parseInt(lastOrderId.toString());
                } catch (NumberFormatException e) {
                    resp.sendRedirect(req.getContextPath() + "/restaurant");
                    return;
                }
            }
        }

        if (orderId == null) {
            resp.sendRedirect(req.getContextPath() + "/restaurant");
            return;
        }

        Order order = orderDAO.getOrder(orderId);

        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        Restaurant restaurant = null;
        User deliveryPartner = null;

        List<OrderItem> orderItems =
                orderItemDAO.getAllOrderItemsByOrderID(orderId);

        Map<Integer, Menu> menuById = new HashMap<>();

        if (order.getRestaurantId() > 0) {
            restaurant =
                    restaurantDAO.getRestaurant(order.getRestaurantId());
        }

        int partnerId =
                (order.getDeliveryPartnerId() != null
                        && order.getDeliveryPartnerId() > 0)
                        ? order.getDeliveryPartnerId()
                        : 3;

        deliveryPartner = userDAO.getUser(partnerId);

        if (orderItems != null) {
            for (OrderItem item : orderItems) {
                Menu menu = menuDAO.getMenu(item.getMenuId());

                if (menu != null) {
                    menuById.put(item.getMenuId(), menu);
                }
            }
        }

        // Fallback delivery partner information.
        if (deliveryPartner == null) {
            deliveryPartner = new User();
            deliveryPartner.setUsername("Amit Kumar");
            deliveryPartner.setPhone("+91 98451 23456");
        }

        // Pass all order details to OrderStatus.jsp.
        req.setAttribute("orderId", orderId);
        req.setAttribute("order", order);
        req.setAttribute("restaurant", restaurant);
        req.setAttribute("deliveryPartner", deliveryPartner);
        req.setAttribute("orderItems", orderItems);
        req.setAttribute("menuById", menuById);

        RequestDispatcher dispatcher =
                req.getRequestDispatcher("/OrderStatus.jsp");

        dispatcher.forward(req, resp);
    }
}
