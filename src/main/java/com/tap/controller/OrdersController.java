
package com.tap.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.tap.DAO.OrderDAO;
import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.OrderItemDAOImpl;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.Restaurant;
import com.tap.model.Menu;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orders")
public class OrdersController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;
    private OrderItemDAOImpl orderItemDAO;
    private RestaurantDAOImpl restaurantDAO;
    private MenuDAOImpl menuDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAOImpl();
        orderItemDAO = new OrderItemDAOImpl();
        restaurantDAO = new RestaurantDAOImpl();
        menuDAO = new MenuDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User loggedInUser = (User) session.getAttribute("user");

        try {
            int targetUserId = loggedInUser.getUserId();
            String requestedUserId = request.getParameter("userId");

            /*
             * Customers can only view their own orders.
             * An admin may specify another user's ID.
             */
            if (requestedUserId != null && !requestedUserId.trim().isEmpty()) {
                String role = loggedInUser.getRole();

                if (role == null || !role.equalsIgnoreCase("admin")) {
                    response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You are not allowed to view another user's orders."
                    );
                    return;
                }

                try {
                    targetUserId = Integer.parseInt(requestedUserId);
                    if (targetUserId <= 0) {
                        response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Invalid user ID."
                        );
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid user ID."
                    );
                    return;
                }
            }

            List<Order> orders = orderDAO.getAllOrdersByUserID(targetUserId);

            if (orders == null) {
                orders = new ArrayList<>();
            }

            Map<Integer, Restaurant> restaurantByOrderId = new HashMap<>();
            Map<Integer, List<OrderItem>> orderItemsByOrderId =
                    new LinkedHashMap<>();
            Map<Integer, Menu> menuById = new HashMap<>();

            for (Order order : orders) {
                Restaurant restaurant =
                        restaurantDAO.getRestaurant(order.getRestaurantId());

                restaurantByOrderId.put(order.getOrderId(), restaurant);

                List<OrderItem> items =
                        orderItemDAO.getAllOrderItemsByOrderID(
                                order.getOrderId());

                if (items == null) {
                    items = new ArrayList<>();
                }

                orderItemsByOrderId.put(order.getOrderId(), items);

                for (OrderItem item : items) {
                    int menuId = item.getMenuId();

                    if (!menuById.containsKey(menuId)) {
                        Menu menu = menuDAO.getMenu(menuId);
                        menuById.put(menuId, menu);
                    }
                }
            }

            request.setAttribute("orders", orders);
            request.setAttribute("restaurantByOrderId",
                    restaurantByOrderId);
            request.setAttribute("orderItemsByOrderId",
                    orderItemsByOrderId);
            request.setAttribute("menuById", menuById);

            // Allows the JSP to identify whose history is being displayed.
            request.setAttribute("viewedUserId", targetUserId);
            request.setAttribute("isAdminOrderView",
                    "admin".equalsIgnoreCase(loggedInUser.getRole())
                    && requestedUserId != null);

            request.getRequestDispatcher("/Orders.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Unable to load order history.", e);
        }
    }
}
