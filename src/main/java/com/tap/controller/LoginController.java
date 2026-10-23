package com.tap.controller;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.DAO.UserDAO;
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

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		String email = req.getParameter("email");
		String password = req.getParameter("password");

		UserDAO userDAO = new UserDAOImpl();

		User user = userDAO.getUserByEmail(email);

		String targetRole = req.getParameter("targetRole");

		// Check whether user exists
		if (user != null) {

			// Check whether password is correct
			if (BCrypt.checkpw(password, user.getPassword())) {

				// Validate target role if explicitly selected
				if ("admin".equalsIgnoreCase(targetRole) && !user.isAdmin()) {
					resp.sendRedirect(req.getContextPath() + "/login?error=notAdmin&role=admin");
					return;
				}
				if ("delivery".equalsIgnoreCase(targetRole) && !user.isDeliveryPartner()) {
					resp.sendRedirect(req.getContextPath() + "/login?error=notDelivery&role=delivery");
					return;
				}

				// Create session and store logged-in user
				HttpSession session = req.getSession();
				session.setAttribute("user", user);

				// Role-based destination
				if (user.isAdmin()) {
					resp.sendRedirect(req.getContextPath() + "/adminDashboard");
				} else if (user.isDeliveryPartner()) {
					resp.sendRedirect(req.getContextPath() + "/deliveryDashboard");
				} else {
					resp.sendRedirect(req.getContextPath() + "/restaurant");
				}

			} else {
				// Wrong password - return to login page
				String query = "?error=invalid" + (targetRole != null ? "&role=" + targetRole : "");
				resp.sendRedirect(req.getContextPath() + "/login" + query);
			}

		} else {
			// Wrong email - return to login page
			String query = "?error=invalid" + (targetRole != null ? "&role=" + targetRole : "");
			resp.sendRedirect(req.getContextPath() + "/login" + query);
		}
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		// Display Login.jsp
		req.getRequestDispatcher("Login.jsp").forward(req, resp);
	}
}