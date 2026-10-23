package com.tap.controller;

import java.io.IOException;
import java.io.PrintWriter;

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
import jakarta.servlet.http.HttpSession;

@WebServlet("/otpLogin")
public class OtpLoginController extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		String action = req.getParameter("action");

		if ("send".equalsIgnoreCase(action)) {
			sendOtp(req, resp);
		} else if ("verify".equalsIgnoreCase(action)) {
			verifyOtp(req, resp);
		} else {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
		}
	}

	private void sendOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		resp.setContentType("application/json");
		resp.setCharacterEncoding("UTF-8");

		String phone = OtpService.normalizePhone(req.getParameter("phone"));
		PrintWriter out = resp.getWriter();

		if (!OtpService.isValidPhone(phone)) {
			out.print("{\"success\":false,\"message\":\"Enter a valid 10-digit phone number.\"}");
			return;
		}

		UserDAO userDAO = new UserDAOImpl();
		User user = userDAO.getUserByPhone(phone);

		if (user == null) {
			out.print("{\"success\":false,\"message\":\"No account found with this number. Please sign up first.\"}");
			return;
		}

		SendResult result = OtpService.sendOtp(phone);
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

	private void verifyOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String phone = OtpService.normalizePhone(req.getParameter("phone"));
		String otp = req.getParameter("otp");

		if (!OtpService.isValidPhone(phone) || otp == null || otp.trim().isEmpty()) {
			resp.sendRedirect(req.getContextPath() + "/login?error=otpInvalid&tab=otp");
			return;
		}

		if (!OtpService.verify(phone, otp)) {
			resp.sendRedirect(req.getContextPath() + "/login?error=otpInvalid&tab=otp");
			return;
		}

		UserDAO userDAO = new UserDAOImpl();
		User user = userDAO.getUserByPhone(phone);

		if (user == null) {
			resp.sendRedirect(req.getContextPath() + "/login?error=otpInvalid&tab=otp");
			return;
		}

		HttpSession session = req.getSession();
		session.setAttribute("user", user);

		String targetRole = req.getParameter("targetRole");
		if ("delivery".equalsIgnoreCase(targetRole) && !user.isDeliveryPartner()) {
			resp.sendRedirect(req.getContextPath() + "/login?error=notDelivery&role=delivery&tab=otp");
			return;
		}

		if (user.isAdmin()) {
			resp.sendRedirect(req.getContextPath() + "/adminDashboard");
		} else if (user.isDeliveryPartner()) {
			resp.sendRedirect(req.getContextPath() + "/deliveryDashboard");
		} else {
			resp.sendRedirect(req.getContextPath() + "/restaurant");
		}
	}

	private static String escape(String value) {
		if (value == null) {
			return "";
		}
		return value.replace("\\", "\\\\").replace("\"", "\\\"");
	}
}
