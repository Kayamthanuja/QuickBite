package com.tap.controller;

import java.io.IOException;

import com.tap.DAO.MenuDAO;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.model.Cart;
import com.tap.model.Menu;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cart")
public class CartController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String APPLIED_COUPON = "appliedCoupon"; 
    private static final String COUPON_MESSAGE = "couponMessage";
    private static final String COUPON_INPUT = "couponInput";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String action = request.getParameter("action");


        // Clear Cart action
        if ("clear".equalsIgnoreCase(action)) {
            session.removeAttribute("cart");
            session.removeAttribute(APPLIED_COUPON);
            session.removeAttribute(COUPON_INPUT);
            session.removeAttribute(COUPON_MESSAGE);

            session.setAttribute(
                "cartMessage",
                "Cart cleared successfully."
            );

            redirectToCart(request, response);
            return;
        }

        // Apply coupon
        if ("applyCoupon".equalsIgnoreCase(action)) {
            applyCoupon(request, response, session);
            return;
        }

        // Remove coupon
        if ("removeCoupon".equalsIgnoreCase(action)) {
            session.removeAttribute(APPLIED_COUPON);
            session.removeAttribute(COUPON_INPUT);
            session.setAttribute(COUPON_MESSAGE, "Coupon removed.");
            redirectToCart(request, response);
            return;
        }

        // Other cart actions require a valid menuId
        int menuId;
        try {
            menuId = Integer.parseInt(request.getParameter("menuId"));
            if (menuId <= 0) {
                throw new NumberFormatException();
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid menu item.");
            return;
        }

        Cart cart = (Cart) session.getAttribute("cart");

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "application/json".equalsIgnoreCase(request.getHeader("Accept"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"))
                || "menu".equalsIgnoreCase(request.getParameter("source"));

        try {
            // Add item
            if ("add".equalsIgnoreCase(action)) {
                MenuDAO menuDAO = new MenuDAOImpl();
                Menu menu = menuDAO.getMenu(menuId);

                if (menu == null || !menu.isAvailable()) {
                    if (isAjax) {
                        sendCartJsonResponse(response, cart, menuId, false, false, "This item is currently unavailable.");
                        return;
                    }
                    session.setAttribute("cartMessage", "This item is currently unavailable.");
                    redirectBack(request, response);
                    return;
                }

                int selectedRestaurantId = menu.getRestaurantId();

                if (cart == null || cart.getCartItems() == null || cart.getCartItems().isEmpty()) {
                    cart = new Cart(selectedRestaurantId);
                    session.setAttribute("cart", cart);
                }

                if (cart.getRestaurantId() != selectedRestaurantId && cart.getCartItems() != null && !cart.getCartItems().isEmpty()) {
                    if (isAjax) {
                        sendCartJsonResponse(response, cart, menuId, false, true, "You cannot add items from another restaurant. Please clear your cart first.");
                        return;
                    }
                    session.setAttribute("cartMessage", "You cannot add items from another restaurant. Please clear your cart first.");
                    redirectBack(request, response);
                    return;
                }

                boolean added = cart.addItem(menu);
                if (!added) {
                    if (isAjax) {
                        sendCartJsonResponse(response, cart, menuId, false, true, "You cannot add items from another restaurant. Please clear your cart first.");
                        return;
                    }
                    session.setAttribute("cartMessage", "You cannot add items from another restaurant. Please clear your cart first.");
                }
                session.setAttribute("cart", cart);

                if (isAjax) {
                    sendCartJsonResponse(response, cart, menuId, true, false, "Added " + menu.getItemName() + " to cart!");
                    return;
                }

            // Update quantity
            } else if ("update".equalsIgnoreCase(action)) {
                if (cart != null) {
                    int quantity;
                    try {
                        quantity = Integer.parseInt(request.getParameter("quantity"));
                    } catch (Exception e) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid quantity.");
                        return;
                    }

                    if (quantity < 0) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Quantity cannot be negative.");
                        return;
                    }

                    if (quantity == 0) {
                        cart.removeItem(menuId);
                    } else {
                        cart.updateQuantity(menuId, quantity);
                    }

                    session.setAttribute("cart", cart);
                    revalidateCoupon(session, cart);

                    if (isAjax) {
                        sendCartJsonResponse(response, cart, menuId, true, false, "Cart updated.");
                        return;
                    }
                } else {
                    if (isAjax) {
                        sendCartJsonResponse(response, null, menuId, true, false, "Cart is empty.");
                        return;
                    }
                }

            // Remove item
            } else if ("remove".equalsIgnoreCase(action)) {
                if (cart != null) {
                    cart.removeItem(menuId);
                    session.setAttribute("cart", cart);
                    revalidateCoupon(session, cart);

                    if (isAjax) {
                        sendCartJsonResponse(response, cart, menuId, true, false, "Item removed.");
                        return;
                    }
                } else {
                    if (isAjax) {
                        sendCartJsonResponse(response, null, menuId, true, false, "Cart is empty.");
                        return;
                    }
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid cart action.");
                return;
            }

        } catch (Exception e) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                sendCartJsonResponse(response, cart, menuId, false, false, "Error updating cart: " + e.getMessage());
                return;
            }
            throw new ServletException("Unable to update cart.", e);
        }

        redirectBack(request, response);
    }

    private void applyCoupon(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        String enteredCode = request.getParameter("couponCode");
        if (enteredCode == null) enteredCode = "";
        String code = enteredCode.trim().toUpperCase(java.util.Locale.ROOT);

        Cart cart = (Cart) session.getAttribute("cart");
        session.setAttribute(COUPON_INPUT, code);

        if (cart == null || cart.getItems().isEmpty()) {
            session.setAttribute(COUPON_MESSAGE, "Add items to your cart before applying a coupon.");
            redirectToCart(request, response);
            return;
        }

        double itemTotal = cart.getTotalAmount();
        if (getCouponDiscount(code, itemTotal) <= 0) {
            session.setAttribute(COUPON_MESSAGE, "Invalid coupon code or minimum order amount not met.");
            redirectToCart(request, response);
            return;
        }

        session.setAttribute(APPLIED_COUPON, code);
        session.removeAttribute(COUPON_MESSAGE);
        session.setAttribute(COUPON_INPUT, code);

        redirectToCart(request, response);
    }

    private double getCouponDiscount(String code, double itemTotal) {
        if ("QUICK50".equals(code) && itemTotal > 200.00) return 50.00;
        if ("WELCOME50".equals(code) && itemTotal > 150.00) return Math.min(itemTotal * 0.50, 100.00);
        if ("TASTE20".equals(code) && itemTotal > 0) return itemTotal * 0.20;
        return 0.00;
    }

    private void revalidateCoupon(HttpSession session, Cart cart) {
        String code = (String) session.getAttribute(APPLIED_COUPON);
        if (code == null) return;

        double itemTotal = cart.getTotalAmount();
        if (cart.getItems().isEmpty() || getCouponDiscount(code, itemTotal) <= 0) {
            session.removeAttribute(APPLIED_COUPON);
            session.removeAttribute(COUPON_INPUT);
            session.setAttribute(COUPON_MESSAGE, "Coupon removed because your cart no longer meets the minimum order requirement.");
        }
    }

    private void redirectToCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.trim().isEmpty()) {
            if (request.getSession().getAttribute("cartMessage") != null) {
                referer = referer.split("#")[0] + "#restaurantConflict";
            }
            response.sendRedirect(referer);
        } else {
            redirectToCart(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/Cart.jsp");
        dispatcher.forward(request, response);
    }

    private void sendCartJsonResponse(HttpServletResponse response, Cart cart, int menuId, boolean success, boolean conflict, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        int currentQty = 0;
        int totalQty = 0;
        double totalAmt = 0.0;
        StringBuilder itemsJson = new StringBuilder("[");

        if (cart != null && cart.getItems() != null) {
            totalAmt = cart.getTotalAmount();
            boolean first = true;
            for (com.tap.model.CartItem item : cart.getItems()) {
                if (item == null) continue;
                totalQty += item.getQuantity();
                if (item.getMenu() != null && item.getMenu().getMenuId() == menuId) {
                    currentQty = item.getQuantity();
                }
                if (!first) itemsJson.append(",");
                first = false;
                String iName = (item.getMenu() != null && item.getMenu().getItemName() != null)
                        ? item.getMenu().getItemName() : "Item";
                int mId = (item.getMenu() != null) ? item.getMenu().getMenuId() : 0;
                itemsJson.append("{")
                    .append("\"menuId\":").append(mId).append(",")
                    .append("\"name\":\"").append(escapeJson(iName)).append("\",")
                    .append("\"quantity\":").append(item.getQuantity()).append(",")
                    .append("\"subtotal\":").append(item.getSubTotal())
                    .append("}");
            }
        }
        itemsJson.append("]");

        String json = "{"
            + "\"success\":" + success + ","
            + "\"conflict\":" + conflict + ","
            + "\"menuId\":" + menuId + ","
            + "\"quantity\":" + currentQty + ","
            + "\"totalQuantity\":" + totalQty + ","
            + "\"totalAmount\":" + totalAmt + ","
            + "\"items\":" + itemsJson.toString() + ","
            + "\"message\":\"" + escapeJson(message != null ? message : "") + "\""
            + "}";

        response.getWriter().print(json);
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}