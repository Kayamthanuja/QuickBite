package com.tap.controller;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.DAOImpl.UserDAOImpl;
import com.tap.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/signup")
public class SignupController extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		// Get form data
		String username = req.getParameter("name");
		String email = req.getParameter("email");
		String phone = req.getParameter("phone");
		String password = req.getParameter("password");
		String confirmPassword = req.getParameter("confirmPassword");
		String address = req.getParameter("address");

		/*
		 * Basic validation Check whether required fields are null or empty
		 */
		if (username == null || username.trim().isEmpty() || email == null || email.trim().isEmpty() || phone == null
				|| phone.trim().isEmpty() || password == null || password.trim().isEmpty() || confirmPassword == null
				|| confirmPassword.trim().isEmpty() || address == null || address.trim().isEmpty()) {

			req.setAttribute("signupError", "Please fill in all the required fields.");

			RequestDispatcher rd = req.getRequestDispatcher("Signup.jsp");

			rd.forward(req, resp);

			return;
		}

		/*
		 * Remove unnecessary spaces from input
		 */
		username = username.trim();
		email = email.trim();
		phone = phone.trim();
		password = password.trim();
		confirmPassword = confirmPassword.trim();
		address = address.trim();

		/*
		 * Check password confirmation
		 */
		if (!password.equals(confirmPassword)) {

			req.setAttribute("signupError", "Passwords do not match.");

			RequestDispatcher rd = req.getRequestDispatcher("Signup.jsp");

			rd.forward(req, resp);

			return;
		}

		/*
		 * Create UserDAO object
		 */
		UserDAOImpl userDAO = new UserDAOImpl();

		/*
		 * Check whether email already exists
		 */
		User existingUser = userDAO.getUserByEmail(email);

		if (existingUser != null) {

			req.setAttribute("signupError", "An account with this email already exists.");

			RequestDispatcher rd = req.getRequestDispatcher("Signup.jsp");

			rd.forward(req, resp);

			return;
		}

		/*
		 * Create new User object
		 */
		User user = new User();

		user.setUsername(username);
		
		String en_password = BCrypt.hashpw(password, BCrypt.gensalt()); 
		user.setPassword(en_password);
		
		user.setEmail(email);
		
		user.setPhone(phone);
		
		user.setAddress(address);

		String roleParam = req.getParameter("role");
		String assignedRole = "customer";
		String redirectRole = "customer";

		if (roleParam != null) {
			String r = roleParam.trim().toLowerCase();
			if ("admin".equals(r)) {
				assignedRole = "admin";
				redirectRole = "admin";
			} else if ("delivery".equals(r) || "delivery partner".equals(r) || "delivery agent".equals(r)) {
				assignedRole = "delivery agent";
				redirectRole = "delivery";
			}
		}

		user.setRole(assignedRole);

		/*
		 * Add user to database
		 */
		userDAO.addUser(user);

		/*
		 * Registration successful Redirect to login page with matching portal tab
		 */
		resp.sendRedirect(req.getContextPath() + "/login?role=" + redirectRole + "&signup=success");
	}
}