
package com.tap.controller;

import java.io.IOException;

import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		String contextPath = req.getContextPath();
		String logoutFrom = req.getParameter("from");

		HttpSession session = req.getSession(false);

		boolean adminLogout = "admin".equalsIgnoreCase(logoutFrom);

		if (session != null) {
			User loggedInUser = (User) session.getAttribute("user");

			// Also identify an admin if the request does not specify its source.
			if (loggedInUser != null && loggedInUser.isAdmin()) {
				adminLogout = true;
			}

			session.invalidate();
		}

		if (adminLogout) {
			resp.sendRedirect(contextPath + "/Login.jsp");
		} else {
			resp.sendRedirect(contextPath + "/restaurant");
		}
	}
}
