package com.tap.controller;

import java.io.IOException;
import java.sql.Timestamp;

import com.tap.DAOImpl.OrderDAOImpl;
import com.tap.DAOImpl.OrderItemDAOImpl;
import com.tap.model.Cart;
import com.tap.model.CartItem;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session =
                req.getSession(false);

        if (session == null
                || session.getAttribute("user") == null) {

            resp.sendRedirect(
                    req.getContextPath() + "/login"
            );

            return;
        }

        User user =
                (User) session.getAttribute("user");

        Cart cart =
                (Cart) session.getAttribute("cart");

        if (cart == null
                || cart.getItems() == null
                || cart.getItems().isEmpty()) {

            resp.sendRedirect(
                    req.getContextPath() + "/cart"
            );

            return;
        }

        req.setAttribute("user", user);
        req.setAttribute("cart", cart);

        req.setAttribute(
                "checkoutError",
                req.getParameter("error")
        );

        RequestDispatcher rd =
                req.getRequestDispatcher(
                        "Checkout.jsp"
                );

        rd.forward(req, resp);
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session =
                req.getSession(false);

        if (session == null
                || session.getAttribute("user") == null) {

            resp.sendRedirect(
                    req.getContextPath() + "/login"
            );

            return;
        }

        User user =
                (User) session.getAttribute("user");

        Cart cart =
                (Cart) session.getAttribute("cart");

        if (cart == null
                || cart.getItems() == null
                || cart.getItems().isEmpty()) {

            resp.sendRedirect(
                    req.getContextPath() + "/cart"
            );

            return;
        }

        String address =
                req.getParameter("address");

        String city =
                req.getParameter("city");

        String pincode =
                req.getParameter("pincode");

        String paymentMethod =
                req.getParameter("paymentMethod");

        String lat =
                req.getParameter("latitude");

        String lng =
                req.getParameter("longitude");

        if (address == null
                || address.trim().isEmpty()) {

            resp.sendRedirect(
                    req.getContextPath()
                    + "/checkout?error=invalidAddress"
            );

            return;
        }

        if (pincode == null
                || !pincode.trim().matches("\\d{6}")) {

            resp.sendRedirect(
                    req.getContextPath()
                    + "/checkout?error=invalidPincode"
            );

            return;
        }

        if (paymentMethod == null
                || paymentMethod.trim().isEmpty()) {

            resp.sendRedirect(
                    req.getContextPath()
                    + "/checkout?error=invalidPayment"
            );

            return;
        }

        /*
         * Online payments must go through Razorpay.
         * The normal /checkout POST must not create
         * an online order directly.
         */
        if (isOnlinePayment(paymentMethod)) {

            resp.sendRedirect(
                    req.getContextPath()
                    + "/checkout?error=useOnlinePay"
            );

            return;
        }

        String cityPart =
                (city != null && !city.trim().isEmpty())
                ? city.trim()
                : "Bangalore";

        String deliveryAddress =
                address.trim()
                + ", "
                + cityPart
                + " - "
                + pincode.trim();

        if (lat != null
                && !lat.trim().isEmpty()
                && lng != null
                && !lng.trim().isEmpty()) {

            deliveryAddress +=
                    " [lat:"
                    + lat.trim()
                    + ", lng:"
                    + lng.trim()
                    + "]";
        }

        int restaurantId =
                cart.getRestaurantId();

        if (restaurantId <= 0
                && !cart.getItems().isEmpty()) {

            restaurantId =
                    cart.getItems()
                            .iterator()
                            .next()
                            .getMenu()
                            .getRestaurantId();

            cart.setRestaurantId(restaurantId);
        }

        double totalAmount =
                cart.getTotalAmount() + 40;

        Order order =
                new Order();

        order.setUserId(
                user.getUserId()
        );

        order.setRestaurantId(
                restaurantId
        );

        order.setOrderDate(
                new Timestamp(
                        System.currentTimeMillis()
                )
        );

        order.setTotalAmount(
                totalAmount
        );

        order.setStatus(
                "PLACED"
        );

        order.setPaymentMode(
                paymentMethod
        );

        order.setDeliveryAddress(
                deliveryAddress
        );

        order.setDeliveryPartnerId(3);

        order.setRiderLat(12.9754);
        order.setRiderLng(77.6045);

        if (lat != null
                && !lat.trim().isEmpty()
                && lng != null
                && !lng.trim().isEmpty()) {

            try {

                order.setDestLat(
                        Double.parseDouble(lat.trim())
                );

                order.setDestLng(
                        Double.parseDouble(lng.trim())
                );

            } catch (Exception e) {

                order.setDestLat(12.9630);
                order.setDestLng(77.6380);
            }

        } else {

            order.setDestLat(12.9630);
            order.setDestLng(77.6380);
        }

        OrderDAOImpl orderDAO =
                new OrderDAOImpl();

        int orderId =
                orderDAO.addOrder(order);

        if (orderId <= 0) {

            resp.sendRedirect(
                    req.getContextPath()
                    + "/checkout?error=orderFailed"
            );

            return;
        }

        order.setOrderId(orderId);

        OrderItemDAOImpl orderItemDAO =
                new OrderItemDAOImpl();

        java.util.List<OrderItem> savedItems =
                new java.util.ArrayList<>();

        for (CartItem cartItem :
                cart.getItems()) {

            OrderItem orderItem =
                    new OrderItem();

            orderItem.setOrderId(
                    orderId
            );

            orderItem.setMenuId(
                    cartItem.getMenu().getMenuId()
            );

            orderItem.setQuantity(
                    cartItem.getQuantity()
            );

            orderItem.setTotalAmount(
                    cartItem.getSubTotal()
            );

            orderItemDAO.addOrderItem(
                    orderItem
            );

            savedItems.add(orderItem);
        }

        session.removeAttribute("cart");

        session.setAttribute(
                "lastOrderId",
                orderId
        );

        com.tap.util.OrderNotificationService.notifyOrder(
                order,
                savedItems,
                user
        );

        resp.sendRedirect(
                req.getContextPath()
                + "/orderSuccess"
        );
    }

    private static boolean isOnlinePayment(
            String paymentMethod) {

        if (paymentMethod == null) {
            return false;
        }

        String method =
                paymentMethod.trim().toUpperCase();

        return "UPI".equals(method)
                || "CARD".equals(method)
                || "GPAY".equals(method)
                || "PHONEPE".equals(method)
                || "PAYTM".equals(method);
    }
}