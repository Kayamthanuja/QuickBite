 package com.tap.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutController extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		// Get the current session
		HttpSession session = req.getSession(false);

		// If a session exists, invalidate it
		if (session != null) {
			session.invalidate();
		}

		// Redirect user to login page
		resp.sendRedirect(req.getContextPath() + "/restaurant");
	}
}