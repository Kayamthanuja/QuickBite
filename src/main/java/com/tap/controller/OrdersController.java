
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

        User user = (User) session.getAttribute("user");

        try {
            int userId = user.getUserId();

            List<Order> orders = orderDAO.getAllOrdersByUserID(userId);

            if (orders == null) {
                orders = new ArrayList<>();
            }

            Map<Integer, Restaurant> restaurantByOrderId =
                    new HashMap<>();

            Map<Integer, List<OrderItem>> orderItemsByOrderId =
                    new LinkedHashMap<>();

            Map<Integer, Menu> menuById = new HashMap<>();

            for (Order order : orders) {

                // Load restaurant information for this order.
                Restaurant restaurant =
                        restaurantDAO.getRestaurant(order.getRestaurantId());

                restaurantByOrderId.put(
                        order.getOrderId(), restaurant);

                // Load all items belonging to this order.
                List<OrderItem> items =
                        orderItemDAO.getAllOrderItemsByOrderID(
                                order.getOrderId());

                if (items == null) {
                    items = new ArrayList<>();
                }

                orderItemsByOrderId.put(order.getOrderId(), items);

                // Load food details for each ordered item.
                for (OrderItem item : items) {

                    int menuId = item.getMenuId();

                    if (!menuById.containsKey(menuId)) {
                        Menu menu = menuDAO.getMenu(menuId);
                        menuById.put(menuId, menu);
                    }
                }
            }

            request.setAttribute("orders", orders);
            request.setAttribute(
                    "restaurantByOrderId", restaurantByOrderId);
            request.setAttribute(
                    "orderItemsByOrderId", orderItemsByOrderId);
            request.setAttribute("menuById", menuById);

            request.getRequestDispatcher("/Orders.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to load order history.", e);
        }
    }
}
