
package com.tap.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.DAO.OrderDAO;
import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.OrderHistory;
import com.tap.model.User;

@WebServlet("/profile")
public class ProfileController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
        orderDAO = new OrderDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // Check whether the user is logged in.
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        User displayUser = sessionUser;

        // Fetch the latest user details from the database.
        try {
            User updatedUser = userDAO.getUser(sessionUser.getUserId());

            if (updatedUser != null) {
                displayUser = updatedUser;
                session.setAttribute("user", updatedUser);
            }
        } catch (Exception e) {
            log("Unable to retrieve user profile.", e);
        }

        // Make the user available to Profile.jsp.
        req.setAttribute("user", displayUser);

        // Fetch order history for the logged-in user.
        try {
            List<OrderHistory> ordersList =
                    orderDAO.getOrderHistoryByUserId(
                            sessionUser.getUserId());

            req.setAttribute("ordersList", ordersList);

        } catch (Exception e) {
            log("Unable to retrieve order history.", e);

            req.setAttribute("ordersList", null);
        }

        // Forward the request to the profile page.
        req.getRequestDispatcher("/Profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));

        HttpSession session = req.getSession(false);

        // Check whether the user is logged in.
        if (session == null || session.getAttribute("user") == null) {
            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");

        // Validate the required fields.
        if (username == null || username.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || address == null || address.trim().isEmpty()) {

            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"All profile fields are required.\"}");
            } else {
                resp.sendRedirect(
                        req.getContextPath() + "/profile?status=error");
            }
            return;
        }

        // Update the user's profile details.
        currentUser.setUsername(username.trim());
        currentUser.setEmail(email.trim());
        currentUser.setPhone(phone.trim());
        currentUser.setAddress(address.trim());

        try {
            userDAO.updateUser(currentUser);

            // Retrieve the saved user record.
            User updatedUser =
                    userDAO.getUser(currentUser.getUserId());

            if (updatedUser != null) {
                session.setAttribute("user", updatedUser);
            } else {
                session.setAttribute("user", currentUser);
                updatedUser = currentUser;
            }

            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                String json = "{"
                        + "\"success\":true,"
                        + "\"message\":\"Profile updated successfully!\","
                        + "\"username\":\"" + escapeJson(updatedUser.getUsername()) + "\","
                        + "\"email\":\"" + escapeJson(updatedUser.getEmail()) + "\","
                        + "\"phone\":\"" + escapeJson(updatedUser.getPhone()) + "\","
                        + "\"address\":\"" + escapeJson(updatedUser.getAddress()) + "\""
                        + "}";
                resp.getWriter().write(json);
            } else {
                resp.sendRedirect(
                        req.getContextPath() + "/profile?status=success");
            }

        } catch (Exception e) {
            log("Unable to update user profile.", e);

            if (isAjax) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"message\":\"Unable to update profile. Please try again.\"}");
            } else {
                resp.sendRedirect(
                        req.getContextPath() + "/profile?status=error");
            }
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\r", "\\r")
                  .replace("\n", "\\n");
    }
}
