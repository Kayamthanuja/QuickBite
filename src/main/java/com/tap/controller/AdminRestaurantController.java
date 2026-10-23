
package com.tap.controller;

import java.io.IOException;
import java.util.List;

import com.tap.DAO.RestaurantDAO;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.model.Restaurant;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/restaurants")
public class AdminRestaurantController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    private User getLoggedInAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        User user = (User) session.getAttribute("user");

        if (user == null || user.getRole() == null
                || !"admin".equalsIgnoreCase(user.getRole())) {
            return null;
        }

        return user;
    }

    private boolean isAjax(HttpServletRequest request) {
        return "XMLHttpRequest".equalsIgnoreCase(
                request.getHeader("X-Requested-With"));
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User admin = getLoggedInAdmin(request);

        if (admin == null) {
            if (isAjax(request)) {
                sendJson(response,
                        HttpServletResponse.SC_UNAUTHORIZED,
                        false,
                        "Your session has expired. Please log in again.");
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/Login.jsp");
            }
            return;
        }

        List<Restaurant> restaurants = restaurantDAO.getAllRestaurants();

        request.setAttribute("restaurants", restaurants);

        request.getRequestDispatcher("/AdminRestaurants.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        boolean ajax = isAjax(request);
        User admin = getLoggedInAdmin(request);

        if (admin == null) {
            if (ajax) {
                sendJson(response,
                        HttpServletResponse.SC_UNAUTHORIZED,
                        false,
                        "Your session has expired. Please log in again.");
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/Login.jsp");
            }
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                addRestaurant(request, admin);

            } else if ("update".equals(action)) {
                updateRestaurant(request);

            } else if ("toggleStatus".equals(action)) {
                toggleStatus(request);

            } else {
                throw new IllegalArgumentException(
                        "Invalid restaurant action.");
            }

            if (ajax) {
                String message;

                if ("add".equals(action)) {
                    message = "Restaurant added successfully.";
                } else if ("update".equals(action)) {
                    message = "Restaurant updated successfully.";
                } else {
                    message = "Restaurant status updated successfully.";
                }

                sendJson(response, HttpServletResponse.SC_OK,
                        true, message);

            } else {
                response.sendRedirect(request.getContextPath()
                        + "/admin/restaurants?success=" + action);
            }

        } catch (IllegalArgumentException e) {
            if (ajax) {
                sendJson(response,
                        HttpServletResponse.SC_BAD_REQUEST,
                        false, e.getMessage());
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/admin/restaurants?error=invalid");
            }

        } catch (RuntimeException e) {
            log("Restaurant management operation failed.", e);

            if (ajax) {
                sendJson(response,
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        false,
                        "The operation could not be completed. Please try again.");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/admin/restaurants?error=failed");
            }
        }
    }

    private void addRestaurant(HttpServletRequest request, User admin) {
        Restaurant restaurant = new Restaurant();

        restaurant.setName(required(request, "name"));
        restaurant.setCuisineType(required(request, "cuisineType"));
        restaurant.setDeliveryTime(required(request, "deliveryTime"));
        restaurant.setAddress(required(request, "address"));
        restaurant.setRating(readRating(request));
        restaurant.setImagePath(optional(request, "imagePath"));

        // The Add Restaurant form must send status=active or status=closed.
        restaurant.setActive(readStatus(request));

        restaurant.setAdminUserId(admin.getUserId());

        restaurantDAO.addRestaurant(restaurant);
    }

    private void updateRestaurant(HttpServletRequest request) {
        int restaurantId = readId(request);

        Restaurant restaurant = restaurantDAO.getRestaurant(restaurantId);

        if (restaurant == null) {
            throw new IllegalArgumentException("Restaurant not found.");
        }

        restaurant.setName(required(request, "name"));
        restaurant.setCuisineType(required(request, "cuisineType"));
        restaurant.setDeliveryTime(required(request, "deliveryTime"));
        restaurant.setAddress(required(request, "address"));
        restaurant.setRating(readRating(request));
        restaurant.setImagePath(optional(request, "imagePath"));
        restaurant.setActive(readStatus(request));

        // Preserve the existing adminUserId.
        restaurantDAO.updateRestaurant(restaurant);
    }

    private void toggleStatus(HttpServletRequest request) {
        int restaurantId = readId(request);

        Restaurant restaurant = restaurantDAO.getRestaurant(restaurantId);

        if (restaurant == null) {
            throw new IllegalArgumentException("Restaurant not found.");
        }

        restaurant.setActive(!restaurant.isActive());
        restaurantDAO.updateRestaurant(restaurant);
    }

    private int readId(HttpServletRequest request) {
        try {
            int id = Integer.parseInt(
                    request.getParameter("restaurantId"));

            if (id <= 0) {
                throw new IllegalArgumentException(
                        "Invalid restaurant ID.");
            }

            return id;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Invalid restaurant ID.");
        }
    }

    private double readRating(HttpServletRequest request) {
        try {
            double rating = Double.parseDouble(
                    request.getParameter("rating"));

            if (!Double.isFinite(rating) || rating < 0 || rating > 5) {
                throw new IllegalArgumentException(
                        "Rating must be between 0 and 5.");
            }

            return rating;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid rating.");
        }
    }

    private boolean readStatus(HttpServletRequest request) {
        String status = request.getParameter("status");

        if ("active".equals(status)) {
            return true;
        }

        if ("closed".equals(status)) {
            return false;
        }

        throw new IllegalArgumentException(
                "Please select Active or Closed status.");
    }

    private String required(HttpServletRequest request, String name) {
        String value = request.getParameter(name);

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    name + " is required.");
        }

        return value.trim();
    }

    private String optional(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

    private void sendJson(HttpServletResponse response, int status,
            boolean success, String message) throws IOException {

        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        response.getWriter().write(
                "{\"success\":" + success
                + ",\"message\":\"" + escapeJson(message) + "\"}");
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
