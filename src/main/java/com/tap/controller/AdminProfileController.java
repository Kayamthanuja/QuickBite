
package com.tap.controller;

import java.io.IOException;
import java.util.regex.Pattern;

import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/adminProfile")
public class AdminProfileController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAOImpl();

    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private User getLoggedInAdmin(HttpServletRequest request) {

        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        User sessionUser = (User) session.getAttribute("user");

        if (sessionUser == null
                || sessionUser.getRole() == null
                || !"admin".equalsIgnoreCase(sessionUser.getRole())) {
            return null;
        }

        return userDAO.getUser(sessionUser.getUserId());
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User admin = getLoggedInAdmin(request);

        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        request.setAttribute("adminProfile", admin);

        request.getRequestDispatcher("/AdminProfile.jsp")
            .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User admin = getLoggedInAdmin(request);

        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        username = username != null ? username.trim() : "";
        email = email != null ? email.trim() : "";
        phone = phone != null ? phone.trim() : "";
        address = address != null ? address.trim() : "";

        if (username.isEmpty() || email.isEmpty()) {
            forwardWithError(request, response, admin,
                username, email, phone, address,
                "Full name and email address are required.");
            return;
        }

        if (!EMAIL_PATTERN.matcher(email).matches()) {
            forwardWithError(request, response, admin,
                username, email, phone, address,
                "Please enter a valid email address.");
            return;
        }

        if (username.length() > 100
                || email.length() > 150
                || phone.length() > 20
                || address.length() > 500) {

            forwardWithError(request, response, admin,
                username, email, phone, address,
                "One or more fields exceed the allowed length.");
            return;
        }

        // Update only the editable profile fields.
        // User ID, role, and password remain unchanged.
        admin.setUsername(username);
        admin.setEmail(email);
        admin.setPhone(phone);
        admin.setAddress(address);

        try {
            userDAO.updateUser(admin);

            // Refresh the session copy so the navbar displays the new name.
            request.getSession().setAttribute("user", admin);

            response.sendRedirect(
                request.getContextPath() + "/adminProfile?updated=true");
        } catch (RuntimeException e) {
            log("Unable to update admin profile.", e);

            forwardWithError(request, response, admin,
                username, email, phone, address,
                "Unable to save your profile right now. Please try again.");
        }
    }

    private void forwardWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            User admin,
            String username,
            String email,
            String phone,
            String address,
            String message)
            throws ServletException, IOException {

        // Preserve the user's entered values when validation fails.
        admin.setUsername(username);
        admin.setEmail(email);
        admin.setPhone(phone);
        admin.setAddress(address);

        request.setAttribute("adminProfile", admin);
        request.setAttribute("errorMessage", message);

        request.getRequestDispatcher("/AdminProfile.jsp")
            .forward(request, response);
    }
}
