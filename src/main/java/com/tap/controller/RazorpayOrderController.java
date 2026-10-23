package com.tap.controller;

import java.io.IOException;
import java.io.PrintWriter;

import com.tap.model.Cart;
import com.tap.model.User;
import com.tap.util.RazorpayConfig;
import com.tap.util.RazorpayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/razorpay/createOrder")
public class RazorpayOrderController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false,\"message\":\"Please login first.\"}");
            return;
        }

        if (!RazorpayConfig.isConfigured()) {
            out.print(
                "{\"success\":false,\"message\":\"Razorpay keys are not configured. Update RazorpayConfig.java with your Test Key ID and Secret.\"}"
            );
            return;
        }

        Cart cart = (Cart) session.getAttribute("cart");

        if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Your cart is empty.\"}");
            return;
        }

        String address = req.getParameter("address");
        String city = req.getParameter("city");
        String pincode = req.getParameter("pincode");
        String paymentMethod = req.getParameter("paymentMethod");

        if (address == null || address.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Delivery address is required.\"}");
            return;
        }

        if (pincode == null || !pincode.trim().matches("\\d{6}")) {
            out.print("{\"success\":false,\"message\":\"Please enter a valid 6-digit PIN code.\"}");
            return;
        }

        double totalAmount = cart.getTotalAmount() + 40;

        int amountPaise = (int) Math.round(totalAmount * 100);

        User user = (User) session.getAttribute("user");

        String receipt = "qb_" + user.getUserId() + "_" + System.currentTimeMillis();

        try {

            String razorpayOrderId =
                    RazorpayService.createOrder(amountPaise, receipt);

            if (razorpayOrderId == null || razorpayOrderId.trim().isEmpty()) {
                out.print(
                    "{\"success\":false,\"message\":\"Unable to create Razorpay order. Please check your Razorpay configuration.\"}"
                );
                return;
            }

            String lat = req.getParameter("latitude");
            String lng = req.getParameter("longitude");

            String cityPart =
                    (city != null && !city.trim().isEmpty())
                    ? city.trim()
                    : "Bangalore";

            String deliveryAddress =
                    address.trim() + ", " + cityPart + " - " + pincode.trim();

            if (lat != null && !lat.trim().isEmpty()
                    && lng != null && !lng.trim().isEmpty()) {

                deliveryAddress +=
                        " [lat:" + lat.trim() + ", lng:" + lng.trim() + "]";
            }

            session.setAttribute(
                    "pendingDeliveryAddress",
                    deliveryAddress
            );

            session.setAttribute(
                    "pendingDestLat",
                    lat
            );

            session.setAttribute(
                    "pendingDestLng",
                    lng
            );

            session.setAttribute(
                    "pendingPaymentMethod",
                    paymentMethod != null && !paymentMethod.trim().isEmpty()
                    ? paymentMethod.trim()
                    : "UPI"
            );

            session.setAttribute(
                    "pendingRazorpayOrderId",
                    razorpayOrderId
            );

            session.setAttribute(
                    "pendingTotalAmount",
                    totalAmount
            );

            String customerName =
                    user.getUsername() != null
                    ? user.getUsername()
                    : "";

            String customerEmail =
                    user.getEmail() != null
                    ? user.getEmail()
                    : "";

            String customerPhone =
                    user.getPhone() != null
                    ? user.getPhone()
                    : "";

            out.print("{"
                    + "\"success\":true,"
                    + "\"keyId\":\"" + escape(RazorpayConfig.KEY_ID) + "\","
                    + "\"orderId\":\"" + escape(razorpayOrderId) + "\","
                    + "\"amount\":" + amountPaise + ","
                    + "\"currency\":\"" + escape(RazorpayConfig.CURRENCY) + "\","
                    + "\"company\":\"" + escape(RazorpayConfig.COMPANY_NAME) + "\","
                    + "\"customerName\":\"" + escape(customerName) + "\","
                    + "\"customerEmail\":\"" + escape(customerEmail) + "\","
                    + "\"customerPhone\":\"" + escape(customerPhone) + "\""
                    + "}");

        } catch (Exception e) {

            e.printStackTrace();

            out.print(
                "{\"success\":false,\"message\":\"Payment gateway error. Please try again.\"}"
            );
        }
    }

    private static String escape(String value) {

        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", " ")
                .replace("\r", "");
    }
}