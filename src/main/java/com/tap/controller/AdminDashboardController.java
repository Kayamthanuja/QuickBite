package com.tap.controller;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

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

    private static final long serialVersionUID = 1L;

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

    private boolean isAdmin(HttpServletRequest req,
            HttpServletResponse resp) throws IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath()
                    + "/login?error=adminRequired");
            return false;
        }

        Object sessionUser = session.getAttribute("user");

        if (!(sessionUser instanceof User)
                || !((User) sessionUser).isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Admin privileges required.");
            return false;
        }

        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) {
            return;
        }

        List<Order> allOrders = orderDAO.getAllOrders();
        List<Restaurant> allRestaurants =
                restaurantDAO.getAllRestaurants();
        List<Menu> allMenus = menuDAO.getAllMenus();
        List<User> allUsers = userDAO.getAllUsers();

        List<User> deliveryPartners =
                userDAO.getUsersByRole("delivery agent");

        if (deliveryPartners == null || deliveryPartners.isEmpty()) {
            deliveryPartners =
                    userDAO.getUsersByRole("delivery partner");
        }

        double totalRevenue = 0.0;
        int activeRestaurantsCount = 0;
        int pendingOrdersCount = 0;

        if (allOrders != null) {
            for (Order order : allOrders) {
                totalRevenue += order.getTotalAmount();

                String status = order.getStatus() == null
                        ? ""
                        : order.getStatus().toUpperCase(Locale.ROOT);

                if (!status.contains("DELIVER")
                        && !status.contains("CANCEL")) {
                    pendingOrdersCount++;
                }
            }
        }

        if (allRestaurants != null) {
            for (Restaurant restaurant : allRestaurants) {
                if (restaurant.isActive()) {
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
        req.setAttribute("activeRestaurantsCount",
                activeRestaurantsCount);
        req.setAttribute("pendingOrdersCount", pendingOrdersCount);

        req.getRequestDispatcher("/AdminDashboard.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) {
            return;
        }

        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        String action = req.getParameter("action");

        boolean isAjax =
                "XMLHttpRequest".equalsIgnoreCase(
                        req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null
                        && req.getHeader("Accept")
                                .toLowerCase(Locale.ROOT)
                                .contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));

        try {
            if ("deleteUser".equalsIgnoreCase(action)) {

                int userId = parsePositiveInt(req, "userId");

                if (currentUser.getUserId() == userId) {
                    throw new IllegalArgumentException(
                            "You cannot delete your own admin account.");
                }

                User userToDelete = null;
                List<User> allUsers = userDAO.getAllUsers();

                if (allUsers != null) {
                    for (User user : allUsers) {
                        if (user.getUserId() == userId) {
                            userToDelete = user;
                            break;
                        }
                    }
                }

                if (userToDelete == null) {
                    throw new IllegalArgumentException(
                            "User not found or already deleted.");
                }

                userDAO.deleteUser(userId);

                if (isAjax) {
                    sendJson(resp, 200,
                            "{\"success\":true,\"userId\":"
                                    + userId + "}");
                    return;
                }

            } else if ("updateOrderStatus".equalsIgnoreCase(action)) {

                int orderId = parsePositiveInt(req, "orderId");
                String status = required(req, "status")
                        .toUpperCase(Locale.ROOT);

                orderDAO.updateStatus(orderId, status);

                if (isAjax) {
                    sendJson(resp, 200,
                            "{\"success\":true,\"orderId\":"
                                    + orderId + "}");
                    return;
                }

            } else if ("assignPartner".equalsIgnoreCase(action)) {

                int orderId = parsePositiveInt(req, "orderId");
                int partnerId = parsePositiveInt(req, "partnerId");

                orderDAO.assignDeliveryPartner(orderId, partnerId);

                if (isAjax) {
                    sendJson(resp, 200,
                            "{\"success\":true,\"orderId\":"
                                    + orderId + ",\"partnerId\":"
                                    + partnerId + "}");
                    return;
                }

            } else if ("toggleRestaurant".equalsIgnoreCase(action)) {

                int restaurantId =
                        parsePositiveInt(req, "restaurantId");

                Restaurant restaurant =
                        restaurantDAO.getRestaurant(restaurantId);

                if (restaurant == null) {
                    throw new IllegalArgumentException(
                            "Restaurant not found.");
                }

                restaurant.setActive(!restaurant.isActive());
                restaurantDAO.updateRestaurant(restaurant);

                if (isAjax) {
                    sendJson(resp, 200,
                            "{\"success\":true,\"restaurantId\":"
                                    + restaurantId
                                    + ",\"isActive\":"
                                    + restaurant.isActive() + "}");
                    return;
                }

            } else if ("addRestaurant".equalsIgnoreCase(action)) {

                Restaurant restaurant = new Restaurant();

                restaurant.setName(required(req, "name"));
                restaurant.setCuisineType(defaultValue(
                        req.getParameter("cuisineType"),
                        "Multi-Cuisine"));
                restaurant.setDeliveryTime(defaultValue(
                        req.getParameter("deliveryTime"),
                        "30-40 mins"));
                restaurant.setAddress(defaultValue(
                        req.getParameter("address"),
                        "Bangalore"));
                restaurant.setRating(
                        parseRating(req.getParameter("rating")));

                String imagePath = req.getParameter("imagePath");

                restaurant.setImagePath(
                        imagePath == null || imagePath.isBlank()
                                ? "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80"
                                : imagePath.trim());

                String status = req.getParameter("status");
                restaurant.setActive(
                        !"deactivated".equalsIgnoreCase(status)
                        && !"closed".equalsIgnoreCase(status));

                restaurant.setAdminUserId(currentUser.getUserId());
                restaurantDAO.addRestaurant(restaurant);

            } else if ("updateRestaurant".equalsIgnoreCase(action)) {

                int restaurantId =
                        parsePositiveInt(req, "restaurantId");

                Restaurant restaurant =
                        restaurantDAO.getRestaurant(restaurantId);

                if (restaurant == null) {
                    throw new IllegalArgumentException(
                            "Restaurant not found.");
                }

                restaurant.setName(required(req, "name"));
                restaurant.setCuisineType(defaultValue(
                        req.getParameter("cuisineType"),
                        "Multi-Cuisine"));
                restaurant.setDeliveryTime(defaultValue(
                        req.getParameter("deliveryTime"),
                        "30-40 mins"));
                restaurant.setAddress(defaultValue(
                        req.getParameter("address"),
                        "Bangalore"));
                restaurant.setRating(
                        parseRating(req.getParameter("rating")));

                String imagePath = req.getParameter("imagePath");

                if (imagePath != null) {
                    restaurant.setImagePath(imagePath.trim());
                }

                String status = req.getParameter("status");
                restaurant.setActive(
                        "active".equalsIgnoreCase(status)
                        || "open".equalsIgnoreCase(status));

                restaurantDAO.updateRestaurant(restaurant);

            } else if ("toggleMenu".equalsIgnoreCase(action)) {

                int menuId = parsePositiveInt(req, "menuId");
                Menu menu = menuDAO.getMenu(menuId);

                if (menu == null) {
                    throw new IllegalArgumentException(
                            "Menu item not found.");
                }

                menu.setAvailable(!menu.isAvailable());
                menuDAO.updateMenu(menu);

                if (isAjax) {
                    sendJson(resp, 200,
                            "{\"success\":true,\"menuId\":"
                                    + menuId + ",\"isAvailable\":"
                                    + menu.isAvailable() + "}");
                    return;
                }

            } else if ("addMenu".equalsIgnoreCase(action)) {

                int restaurantId =
                        parsePositiveInt(req, "restaurantId");

                Restaurant restaurant =
                        restaurantDAO.getRestaurant(restaurantId);

                if (restaurant == null) {
                    throw new IllegalArgumentException(
                            "Selected restaurant does not exist.");
                }

                Menu menu = new Menu();
                menu.setRestaurantId(restaurantId);
                menu.setItemName(required(req, "itemName"));
                menu.setDescription(defaultValue(
                        req.getParameter("description"), ""));
                menu.setPrice(parsePositivePrice(req, "price"));
                menu.setAvailable(Boolean.parseBoolean(
                        defaultValue(
                                req.getParameter("isAvailable"),
                                "true")));

                String imagePath = req.getParameter("imagePath");
                menu.setImagePath(
                        imagePath == null || imagePath.isBlank()
                                ? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80"
                                : imagePath.trim());

                menuDAO.addMenu(menu);

            } else if ("updateMenu".equalsIgnoreCase(action)) {

                int menuId = parsePositiveInt(req, "menuId");
                int restaurantId =
                        parsePositiveInt(req, "restaurantId");

                Menu menu = menuDAO.getMenu(menuId);

                if (menu == null) {
                    throw new IllegalArgumentException(
                            "Menu item not found.");
                }

                Restaurant restaurant =
                        restaurantDAO.getRestaurant(restaurantId);

                if (restaurant == null) {
                    throw new IllegalArgumentException(
                            "Selected restaurant does not exist.");
                }

                String itemName = required(req, "itemName");
                double price = parsePositivePrice(req, "price");
                String description = defaultValue(
                        req.getParameter("description"), "");
                String imagePath = defaultValue(
                        req.getParameter("imagePath"), "");

                String availability = required(req, "isAvailable");

                if (!"true".equalsIgnoreCase(availability)
                        && !"false".equalsIgnoreCase(availability)) {
                    throw new IllegalArgumentException(
                            "Choose a valid availability status.");
                }

                menu.setRestaurantId(restaurantId);
                menu.setItemName(itemName);
                menu.setDescription(description);
                menu.setPrice(price);
                menu.setImagePath(imagePath);
                menu.setAvailable(
                        Boolean.parseBoolean(availability));

                menuDAO.updateMenu(menu);

                if (isAjax) {
                    String json = "{\"success\":true,"
                            + "\"menuId\":" + menu.getMenuId() + ","
                            + "\"restaurantId\":"
                            + menu.getRestaurantId() + ","
                            + "\"restaurantName\":\""
                            + escapeJson(restaurant.getName()) + "\","
                            + "\"itemName\":\""
                            + escapeJson(menu.getItemName()) + "\","
                            + "\"description\":\""
                            + escapeJson(menu.getDescription()) + "\","
                            + "\"imagePath\":\""
                            + escapeJson(menu.getImagePath()) + "\","
                            + "\"price\":" + menu.getPrice() + ","
                            + "\"isAvailable\":"
                            + menu.isAvailable() + "}";

                    sendJson(resp, 200, json);
                    return;
                }

            } else if ("deleteMenu".equalsIgnoreCase(action)) {

                int menuId = parsePositiveInt(req, "menuId");
                Menu menu = menuDAO.getMenu(menuId);

                if (menu == null) {
                    throw new IllegalArgumentException(
                            "Menu item not found or already deleted.");
                }

                menuDAO.deleteMenu(menuId);

                if (isAjax) {
                    sendJson(resp, 200,
                            "{\"success\":true,\"menuId\":"
                                    + menuId + "}");
                    return;
                }

            } else {
                throw new IllegalArgumentException(
                        "Unknown admin action.");
            }

        } catch (Exception e) {
            e.printStackTrace();

            String message = e.getMessage();

            if (message == null || message.isBlank()) {
                message = "Could not complete the requested action.";
            }

            if (isAjax) {
                sendJson(resp, 400,
                        "{\"success\":false,\"message\":\""
                                + escapeJson(message) + "\"}");
                return;
            }

            req.getSession().setAttribute("adminError",
                    "Could not complete the requested action.");
        }

        resp.sendRedirect(req.getContextPath() + "/adminDashboard");
    }

    private void sendJson(HttpServletResponse resp,
            int status, String json) throws IOException {

        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(json);
    }

    private String required(HttpServletRequest req, String name) {
        String value = req.getParameter(name);

        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(
                    name + " is required.");
        }

        return value.trim();
    }

    private String defaultValue(String value, String fallback) {
        return value == null || value.isBlank()
                ? fallback
                : value.trim();
    }

    private int parsePositiveInt(HttpServletRequest req, String name) {
        String value = required(req, name);

        try {
            int number = Integer.parseInt(value);

            if (number <= 0) {
                throw new IllegalArgumentException(
                        name + " must be a positive number.");
            }

            return number;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    name + " must be a valid number.");
        }
    }

    private double parsePositivePrice(HttpServletRequest req,
            String name) {

        String value = required(req, name);

        try {
            double price = Double.parseDouble(value);

            if (!Double.isFinite(price) || price <= 0) {
                throw new IllegalArgumentException(
                        "Price must be greater than zero.");
            }

            return price;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Enter a valid price.");
        }
    }

    private double parseRating(String value) {
        try {
            double rating = Double.parseDouble(value);

            if (!Double.isFinite(rating)
                    || rating < 1.0 || rating > 5.0) {
                return 4.5;
            }

            return rating;
        } catch (Exception e) {
            return 4.5;
        }
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder result = new StringBuilder();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            switch (c) {
                case '"':
                    result.append("\\\"");
                    break;
                case '\\':
                    result.append("\\\\");
                    break;
                case '\b':
                    result.append("\\b");
                    break;
                case '\f':
                    result.append("\\f");
                    break;
                case '\n':
                    result.append("\\n");
                    break;
                case '\r':
                    result.append("\\r");
                    break;
                case '\t':
                    result.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        result.append(String.format(
                                "\\u%04x", (int) c));
                    } else {
                        result.append(c);
                    }
            }
        }

        return result.toString();
    }
}