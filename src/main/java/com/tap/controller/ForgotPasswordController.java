
package com.tap.controller;

import java.io.IOException;
import java.security.SecureRandom;

import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.User;
import com.tap.util.EmailOtpService;

import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/forgotPassword")
public class ForgotPasswordController extends HttpServlet {

	private static final long OTP_VALIDITY_MS = 5 * 60 * 1000L;
	private static final SecureRandom RANDOM = new SecureRandom();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		resp.setContentType("application/json");
		resp.setCharacterEncoding("UTF-8");

		String action = req.getParameter("action");

		try {
			if ("send".equalsIgnoreCase(action)) {
				sendOtp(req, resp);
			} else if ("verify".equalsIgnoreCase(action)) {
				verifyOtp(req, resp);
			} else if ("reset".equalsIgnoreCase(action)) {
				resetPassword(req, resp);
			} else {
				writeJson(resp, false, "Invalid request.");
			}
		} catch (RuntimeException e) {
			getServletContext().log("Password reset operation failed.", e);
			writeJson(resp, false, "Unable to complete the request. Please try again.");
		}
	}

	private void sendOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		String email = normalizeEmail(req.getParameter("email"));

		if (!isValidEmail(email)) {
			writeJson(resp, false, "Please enter a valid email address.");
			return;
		}

		HttpSession session = req.getSession();

		clearResetOtp(session);
		session.removeAttribute("resetVerifiedEmail");

		UserDAO dao = new UserDAOImpl();
		User user = dao.getUserByEmail(email);

		// Do not disclose whether an account exists.
		if (user == null) {
			writeJson(resp, true, "If the email is registered, a password-reset OTP will be sent.");
			return;
		}

		String otp = String.format("%06d", RANDOM.nextInt(1_000_000));

		try {
			EmailOtpService.sendOtp(user.getEmail(), otp);
		} catch (MessagingException | RuntimeException e) {
			getServletContext().log("Unable to send password-reset OTP.", e);
			writeJson(resp, false, "Unable to send the OTP. Please try again.");
			return;
		}

		session.setAttribute("resetOtpEmail", email);
		session.setAttribute("resetOtpValue", otp);
		session.setAttribute("resetOtpExpiry", System.currentTimeMillis() + OTP_VALIDITY_MS);
		session.setAttribute("resetOtpAttempts", 0);

		writeJson(resp, true, "If the email is registered, a password-reset OTP will be sent.");
	}

	private void verifyOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		String email = normalizeEmail(req.getParameter("email"));
		String enteredOtp = req.getParameter("otp");

		HttpSession session = req.getSession(false);

		if (session == null || !isValidEmail(email) || enteredOtp == null || !enteredOtp.trim().matches("\\d{6}")) {
			writeJson(resp, false, "Invalid or expired OTP. Request a new OTP.");
			return;
		}

		String savedEmail = (String) session.getAttribute("resetOtpEmail");
		String savedOtp = (String) session.getAttribute("resetOtpValue");
		Object expiryObject = session.getAttribute("resetOtpExpiry");
		Object attemptsObject = session.getAttribute("resetOtpAttempts");

		if (savedEmail == null || savedOtp == null || !(expiryObject instanceof Long)) {
			clearResetOtp(session);
			writeJson(resp, false, "OTP expired or unavailable. Request a new OTP.");
			return;
		}

		long expiry = (Long) expiryObject;
		int attempts = attemptsObject instanceof Integer ? (Integer) attemptsObject : 0;

		if (System.currentTimeMillis() > expiry) {
			clearResetOtp(session);
			writeJson(resp, false, "OTP expired. Request a new OTP.");
			return;
		}

		if (!savedEmail.equals(email)) {
			writeJson(resp, false, "Invalid OTP or email.");
			return;
		}

		if (attempts >= 5) {
			clearResetOtp(session);
			writeJson(resp, false, "Too many attempts. Request a new OTP.");
			return;
		}

		if (!savedOtp.equals(enteredOtp.trim())) {
			session.setAttribute("resetOtpAttempts", attempts + 1);
			writeJson(resp, false, "Incorrect OTP. Please try again.");
			return;
		}

		UserDAO dao = new UserDAOImpl();
		User user = dao.getUserByEmail(email);
		
		if (user == null) {
		    getServletContext().log(
		        "Forgot password: No user found for email: " + email
		    );
		} else {
		    getServletContext().log(
		        "Forgot password: User found. Role: " + user.getRole()
		    );
		}

		clearResetOtp(session);

		if (user == null) {
			session.removeAttribute("resetVerifiedEmail");
			writeJson(resp, false, "Unable to verify this account. Request a new OTP.");
			return;
		}

		// Only the server-side session can authorize the password reset.
		session.setAttribute("resetVerifiedEmail", email);
		session.setAttribute("resetVerifiedExpiry", System.currentTimeMillis() + 5 * 60 * 1000L);

		writeJson(resp, true, "Email verified. You can now set a new password.");
	}

	private void resetPassword(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		String email = normalizeEmail(req.getParameter("email"));
		String password = req.getParameter("newPassword");
		String confirmPassword = req.getParameter("confirmPassword");

		HttpSession session = req.getSession(false);

		if (session == null) {
			writeJson(resp, false, "Session expired. Please verify your OTP again.");
			return;
		}

		String verifiedEmail = (String) session.getAttribute("resetVerifiedEmail");
		Object verifiedExpiryObject = session.getAttribute("resetVerifiedExpiry");

		if (verifiedEmail == null || !verifiedEmail.equals(email) || !(verifiedExpiryObject instanceof Long)
				|| System.currentTimeMillis() > (Long) verifiedExpiryObject) {

			session.removeAttribute("resetVerifiedEmail");
			session.removeAttribute("resetVerifiedExpiry");
			writeJson(resp, false, "Please verify a fresh OTP before resetting your password.");
			return;
		}

		if (password == null || confirmPassword == null || password.length() < 8 || password.length() > 72) {
			writeJson(resp, false, "Password must contain between 8 and 72 characters.");
			return;
		}

		if (!password.equals(confirmPassword)) {
			writeJson(resp, false, "Passwords do not match.");
			return;
		}

		UserDAO dao = new UserDAOImpl();
		User user = dao.getUserByEmail(email);

		if (user == null) {
			session.removeAttribute("resetVerifiedEmail");
			session.removeAttribute("resetVerifiedExpiry");
			writeJson(resp, false, "Unable to reset this account's password.");
			return;
		}

		String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

		// This DAO method must update the password column using the email.
		dao.updatePassword(email, hashedPassword);

		session.removeAttribute("resetVerifiedEmail");
		session.removeAttribute("resetVerifiedExpiry");
		clearResetOtp(session);

		writeJson(resp, true, "Password updated successfully.");
	}

	private static void clearResetOtp(HttpSession session) {
		session.removeAttribute("resetOtpEmail");
		session.removeAttribute("resetOtpValue");
		session.removeAttribute("resetOtpExpiry");
		session.removeAttribute("resetOtpAttempts");
	}

	private static String normalizeEmail(String email) {
		return email == null ? "" : email.trim().toLowerCase();
	}

	private static boolean isValidEmail(String email) {
		return email.length() <= 254 && email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
	}

	private static void writeJson(HttpServletResponse resp, boolean success, String message) throws IOException {

		String safe = message.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n");

		resp.getWriter().write("{\"success\":" + success + ",\"message\":\"" + safe + "\"}");
	}
}
