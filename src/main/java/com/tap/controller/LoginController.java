package com.tap.controller;

import java.io.IOException;
import java.util.Locale;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAOImpl userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse resp)
            throws ServletException, IOException {

        req.getRequestDispatcher("/Login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String email = normalizeEmail(req.getParameter("email"));
        String password = req.getParameter("password");
        String targetRole = normalizeRole(req.getParameter("targetRole"));

        if (email.isBlank() || password == null || password.isBlank()) {
            redirectError(req, resp, "missing", targetRole);
            return;
        }

        if (!isSupportedRole(targetRole)) {
            redirectError(req, resp, "wrongLoginOption", "customer");
            return;
        }

        User user = userDAO.getUserByEmail(email);

        if (user == null || user.getRole() == null) {
            redirectError(req, resp, "invalidCredentials", targetRole);
            return;
        }

        String databaseRole = user.getRole().trim();

        if ("admin".equals(targetRole)) {

            if (!"admin".equalsIgnoreCase(databaseRole)) {
                redirectError(req, resp, "wrongLoginOption", "admin");
                return;
            }

            String storedPassword = user.getPassword();

            if (!isPasswordCorrect(password, storedPassword)) {
                redirectError(req, resp, "invalidCredentials", "admin");
                return;
            }

        } else {

            if (!"customer".equalsIgnoreCase(databaseRole)) {
                redirectError(req, resp, "wrongLoginOption", "customer");
                return;
            }

            String storedPassword = user.getPassword();

            if (!isPasswordCorrect(password, storedPassword)) {
                redirectError(req, resp, "invalidCredentials", "customer");
                return;
            }
        }

        // Login successful
        HttpSession session = req.getSession(true);
        req.changeSessionId();
        session.setAttribute("user", user);

        if ("admin".equalsIgnoreCase(databaseRole)) {
            resp.sendRedirect(req.getContextPath() + "/adminDashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/restaurant");
        }
    }

    private boolean isPasswordCorrect(String enteredPassword,
                                      String storedPassword) {

        if (storedPassword == null || storedPassword.isBlank()) {
            return false;
        }

        // Support BCrypt-hashed passwords.
        if (storedPassword.startsWith("$2a$")
                || storedPassword.startsWith("$2b$")
                || storedPassword.startsWith("$2y$")) {

            try {
                return BCrypt.checkpw(enteredPassword, storedPassword);
            } catch (IllegalArgumentException e) {
                return false;
            }
        }

        // Support plain-text passwords if your database uses them.
        return storedPassword.equals(enteredPassword);
    }

    private String normalizeEmail(String email) {
        return email == null ? "" : email.trim();
    }

    private String normalizeRole(String role) {
        return role == null
                ? ""
                : role.trim().toLowerCase(Locale.ROOT);
    }

    private boolean isSupportedRole(String role) {
        return "admin".equals(role) || "customer".equals(role);
    }

    private void redirectError(HttpServletRequest req,
                               HttpServletResponse resp,
                               String error,
                               String role)
            throws IOException {

        resp.sendRedirect(
                req.getContextPath()
                + "/login?error=" + error
                + "&role=" + role);
    }
}