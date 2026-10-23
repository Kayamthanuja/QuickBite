package com.tap.controller;

import java.io.IOException;
import java.security.SecureRandom;

import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.User;
import com.tap.util.EmailOtpService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/otpLogin")
public class OtpLoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final long OTP_VALIDITY = 5 * 60 * 1000L;
    private static final int MAX_ATTEMPTS = 5;

    private final UserDAOImpl userDAO = new UserDAOImpl();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        String email = req.getParameter("email");

        email = email == null ? "" : email.trim();

        String targetRole = req.getParameter("targetRole");
        targetRole = targetRole == null
                ? ""
                : targetRole.trim().toLowerCase();

        if (!"admin".equals(targetRole)
                && !"customer".equals(targetRole)) {

            sendJson(resp, false, "Please select a valid login option.");
            return;
        }

        if (email.isBlank()) {
            sendJson(resp, false, "Please enter your email address.");
            return;
        }

        if ("send".equalsIgnoreCase(action)) {
            sendOtp(req, resp, email, targetRole);
        } else if ("verify".equalsIgnoreCase(action)) {
            verifyOtp(req, resp, email, targetRole);
        } else {
            sendJson(resp, false, "Invalid OTP request.");
        }
    }

    private void sendOtp(HttpServletRequest req,
                         HttpServletResponse resp,
                         String email,
                         String targetRole)
            throws IOException {

        User user = userDAO.getUserByEmail(email);

        if (user == null || user.getRole() == null) {
            sendJson(resp, false,
                    "No account was found for this email address.");
            return;
        }

        String databaseRole = user.getRole().trim();

        if (!databaseRole.equalsIgnoreCase(targetRole)) {
            sendJson(resp, false,
                    "This account cannot use the selected login option.");
            return;
        }

        String otp = String.format("%06d", random.nextInt(1000000));

        try {
            EmailOtpService.sendOtp(user.getEmail(), otp);

            HttpSession session = req.getSession(true);

            session.setAttribute("loginOtp", otp);
            session.setAttribute("loginOtpEmail", email);
            session.setAttribute("loginOtpRole", targetRole);
            session.setAttribute("loginOtpExpiry",
                    System.currentTimeMillis() + OTP_VALIDITY);
            session.setAttribute("loginOtpAttempts", 0);

            sendJson(resp, true,
                    "OTP sent to your registered email address.");

        } catch (Exception e) {
            getServletContext().log("Failed to send login OTP.", e);

            sendJson(resp, false,
                    "Unable to send OTP right now. Please try again.");
        }
    }

    private void verifyOtp(HttpServletRequest req,
                           HttpServletResponse resp,
                           String email,
                           String targetRole)
            throws IOException {

        HttpSession session = req.getSession(false);

        if (session == null) {
            sendJson(resp, false,
                    "Your OTP session has expired. Please request a new OTP.");
            return;
        }

        Object savedOtp = session.getAttribute("loginOtp");
        Object savedEmail = session.getAttribute("loginOtpEmail");
        Object savedRole = session.getAttribute("loginOtpRole");
        Object expiryObject = session.getAttribute("loginOtpExpiry");
        Object attemptsObject = session.getAttribute("loginOtpAttempts");

        if (savedOtp == null
                || savedEmail == null
                || savedRole == null
                || expiryObject == null) {

            sendJson(resp, false,
                    "Please request an OTP before verifying.");
            return;
        }

        if (!email.equalsIgnoreCase(savedEmail.toString())
                || !targetRole.equalsIgnoreCase(savedRole.toString())) {

            sendJson(resp, false,
                    "The email or login option does not match your OTP request.");
            return;
        }

        long expiry = (Long) expiryObject;

        if (System.currentTimeMillis() > expiry) {
            clearOtp(session);

            sendJson(resp, false,
                    "OTP expired. Please request a new OTP.");
            return;
        }

        int attempts = attemptsObject instanceof Integer
                ? (Integer) attemptsObject
                : 0;

        if (attempts >= MAX_ATTEMPTS) {
            clearOtp(session);

            sendJson(resp, false,
                    "Too many attempts. Please request a new OTP.");
            return;
        }

        String enteredOtp = req.getParameter("otp");

        if (enteredOtp == null
                || !savedOtp.toString().equals(enteredOtp.trim())) {

            attempts++;
            session.setAttribute("loginOtpAttempts", attempts);

            if (attempts >= MAX_ATTEMPTS) {
                clearOtp(session);

                sendJson(resp, false,
                        "Too many attempts. Please request a new OTP.");
            } else {
                sendJson(resp, false,
                        "Incorrect OTP. Please try again.");
            }

            return;
        }

        // Recheck the account and role before completing login.
        User user = userDAO.getUserByEmail(email);

        if (user == null
                || user.getRole() == null
                || !user.getRole().trim().equalsIgnoreCase(targetRole)) {

            clearOtp(session);

            sendJson(resp, false,
                    "The account could not be verified for this login option.");
            return;
        }

        clearOtp(session);

        // Prevent session fixation after successful authentication.
        req.changeSessionId();
        session.setAttribute("user", user);

        if ("admin".equalsIgnoreCase(user.getRole().trim())) {
            resp.sendRedirect(req.getContextPath() + "/adminDashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/restaurant");
        }
    }

    private void clearOtp(HttpSession session) {
        session.removeAttribute("loginOtp");
        session.removeAttribute("loginOtpEmail");
        session.removeAttribute("loginOtpRole");
        session.removeAttribute("loginOtpExpiry");
        session.removeAttribute("loginOtpAttempts");
    }

    private void sendJson(HttpServletResponse resp,
                          boolean success,
                          String message)
            throws IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String escapedMessage = message
                .replace("\\", "\\\\")
                .replace("\"", "\\\"");

        resp.getWriter().write(
                "{\"success\":" + success
                + ",\"message\":\"" + escapedMessage + "\"}");
    }
}