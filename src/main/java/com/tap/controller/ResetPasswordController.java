package com.tap.controller;

import java.io.IOException;
import java.io.PrintWriter;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.DAO.UserDAO;
import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.User;
import com.tap.util.OtpService;
import com.tap.util.OtpService.SendResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/resetPassword")
public class ResetPasswordController extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		resp.sendRedirect(req.getContextPath() + "/login?tab=reset");
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		String action = req.getParameter("action");

		if ("sendOtp".equalsIgnoreCase(action)) {
			handleSendOtp(req, resp);
		} else if ("reset".equalsIgnoreCase(action) || "verifyAndReset".equalsIgnoreCase(action)) {
			handleResetPassword(req, resp);
		} else {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
		}
	}

	private void handleSendOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		resp.setContentType("application/json");
		resp.setCharacterEncoding("UTF-8");
		PrintWriter out = resp.getWriter();

		String email = req.getParameter("email");
		if (email == null || email.trim().isEmpty() || !email.contains("@")) {
			out.print("{\"success\":false,\"message\":\"Please enter a valid email address.\"}");
			return;
		}

		String cleanEmail = email.trim();
		UserDAO userDAO = new UserDAOImpl();
		User user = userDAO.getUserByEmail(cleanEmail);

		if (user == null) {
			out.print("{\"success\":false,\"message\":\"No QuickBite account found with this email address.\"}");
			return;
		}

		SendResult result = OtpService.sendEmailOtp(cleanEmail, "Password Reset");
		if (!result.success) {
			out.print("{\"success\":false,\"message\":\"" + escape(result.message) + "\"}");
			return;
		}

		StringBuilder json = new StringBuilder();
		json.append("{\"success\":true,\"message\":\"").append(escape(result.message)).append("\"");
		if (result.otpCode != null) {
			json.append(",\"otp\":\"").append(escape(result.otpCode)).append("\"");
		}
		json.append("}");
		out.print(json.toString());
	}

	private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String email = req.getParameter("email");
		String otp = req.getParameter("otp");
		String newPassword = req.getParameter("newPassword");
		String confirmPassword = req.getParameter("confirmPassword");
		boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
				|| "application/json".equalsIgnoreCase(req.getContentType())
				|| "true".equalsIgnoreCase(req.getParameter("ajax"));

		String errorMessage = null;

		if (email == null || email.trim().isEmpty()) {
			errorMessage = "Email address is required.";
		} else if (otp == null || otp.trim().isEmpty()) {
			errorMessage = "Please enter the 6-digit OTP code.";
		} else if (newPassword == null || newPassword.trim().length() < 6) {
			errorMessage = "New password must be at least 6 characters long.";
		} else if (!newPassword.equals(confirmPassword)) {
			errorMessage = "Passwords do not match. Please re-enter.";
		} else if (!OtpService.verifyEmailOtp(email.trim(), otp.trim())) {
			errorMessage = "Invalid or expired OTP code. Please request a new one.";
		}

		if (errorMessage != null) {
			if (isAjax) {
				resp.setContentType("application/json");
				resp.setCharacterEncoding("UTF-8");
				resp.getWriter().print("{\"success\":false,\"message\":\"" + escape(errorMessage) + "\"}");
			} else {
				resp.sendRedirect(req.getContextPath() + "/login?error=resetFailed&msg="
						+ java.net.URLEncoder.encode(errorMessage, java.nio.charset.StandardCharsets.UTF_8)
						+ "&tab=reset&email=" + java.net.URLEncoder.encode(email != null ? email : "", java.nio.charset.StandardCharsets.UTF_8));
			}
			return;
		}

		String cleanEmail = email.trim();
		UserDAO userDAO = new UserDAOImpl();
		String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
		boolean updated = userDAO.updatePassword(cleanEmail, hashedPassword);

		if (!updated) {
			String failMsg = "Failed to update password in database. Please try again.";
			if (isAjax) {
				resp.setContentType("application/json");
				resp.getWriter().print("{\"success\":false,\"message\":\"" + escape(failMsg) + "\"}");
			} else {
				resp.sendRedirect(req.getContextPath() + "/login?error=resetFailed&tab=reset");
			}
			return;
		}

		System.out.println("[QuickBite Auth] Password successfully reset for: " + cleanEmail);

		if (isAjax) {
			resp.setContentType("application/json");
			resp.getWriter().print("{\"success\":true,\"message\":\"Password reset successfully! Please login with your new password.\"}");
		} else {
			resp.sendRedirect(req.getContextPath() + "/login?reset=success");
		}
	}

	private static String escape(String value) {
		if (value == null) {
			return "";
		}
		return value.replace("\\", "\\\\").replace("\"", "\\\"");
	}
}
