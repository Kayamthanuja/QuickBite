
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="com.tap.model.Cart" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="java.util.Locale" %>

<%
    String cp = request.getContextPath();

    Cart cart = (Cart) session.getAttribute("cart");
    boolean cartEmpty = cart == null || cart.getItems().isEmpty();

    double itemTotal = cartEmpty ? 0.0 : cart.getTotalAmount();
    double deliveryFee = cartEmpty ? 0.0 : 40.00;
    double platformFee = cartEmpty ? 0.0 : 5.00;

    String appliedCoupon = (String) session.getAttribute("appliedCoupon");
    String couponMessage = (String) session.getAttribute("couponMessage");
    String couponInput = (String) session.getAttribute("couponInput");
    String cartMessage = (String) session.getAttribute("cartMessage");

    if (couponInput == null) {
        couponInput = "";
    }

    double couponDiscount = 0.0;

    if (!cartEmpty && appliedCoupon != null) {
        if ("QUICK50".equalsIgnoreCase(appliedCoupon)
                && itemTotal > 200.00) {
            couponDiscount = 50.00;
        } else if ("WELCOME50".equalsIgnoreCase(appliedCoupon)
                && itemTotal > 150.00) {
            couponDiscount = Math.min(itemTotal * 0.50, 100.00);
        } else if ("TASTE20".equalsIgnoreCase(appliedCoupon)
                && itemTotal > 0) {
            couponDiscount = itemTotal * 0.20;
        }
    }

    double totalPayable = Math.max(0.0,
            itemTotal + deliveryFee + platformFee - couponDiscount);

    session.removeAttribute("couponMessage");
    session.removeAttribute("cartMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Your Cart | Quick Bite</title>

    <link rel="stylesheet"
          href="<%=cp%>/CSS/common.css">
    <link rel="stylesheet"
          href="<%=cp%>/CSS/navbar.css">
    <link rel="stylesheet"
          href="<%=cp%>/CSS/cart.css">
    <link rel="stylesheet"
          href="<%=cp%>/CSS/footer.css">
</head>

<body>

<%@ include file="navbar.jsp" %>

<main class="cart-page-container container">

    <div class="cart-page-title">
        <h2>Your Cart</h2>
        <p>Review your selected items before proceeding.</p>
    </div>

    <% if (cartMessage != null && !cartMessage.trim().isEmpty()) { %>
        <div class="cart-notice">
            <%= cartMessage %>
        </div>
    <% } %>

    <% if (cartEmpty) { %>

        <section class="empty-cart">
            <div class="empty-icon-circle">&#128722;</div>
            <h2>Your Cart is Empty</h2>
            <p>You haven't added any items to your cart yet.</p>

            <a href="<%=cp%>/restaurant" class="continue-btn">
                Browse Restaurants
            </a>
        </section>

    <% } else { %>

        <div class="cart-container">

            <!-- LEFT: CART ITEMS -->
            <section class="cart-items">

                <!-- Clear Cart text directly above the food items -->
                <div class="cart-items-toolbar">
                    <span class="cart-items-heading">
                        Your Selected Items
                    </span>

                    <form action="<%=cp%>/cart"
                          method="post"
                          class="clear-cart-form"
                          onsubmit="return confirmClearCart();">

                        <input type="hidden" name="action" value="clear">

                        <button type="submit" class="clear-cart-btn">
                            &#128465; Clear Cart
                        </button>
                    </form>
                </div>

                <% for (CartItem cartItem : cart.getItems()) { %>

                    <article class="cart-card">

                        <img class="cart-image"
                             src="<%=cartItem.getMenu().getImagePath()%>"
                             alt="<%=cartItem.getMenu().getItemName()%>"
                             loading="lazy"
                             onerror="this.style.display='none';">

                        <div class="item-details">
                            <h3><%=cartItem.getMenu().getItemName()%></h3>

                            <p class="description">
                                <%=cartItem.getMenu().getDescription() != null
                                    ? cartItem.getMenu().getDescription()
                                    : "Delicious food prepared fresh for you."%>
                            </p>

                            <p class="item-price">
                                &#8377;<%=String.format(Locale.US, "%.2f",
                                    cartItem.getMenu().getPrice())%>
                            </p>
                        </div>

                        <div class="quantity">
                            <span class="quantity-label">Quantity</span>

                            <div class="quantity-controls">

                                <form action="<%=cp%>/cart"
                                      method="post"
                                      class="quantity-form">

                                    <input type="hidden"
                                           name="action" value="update">
                                    <input type="hidden"
                                           name="menuId"
                                           value="<%=cartItem.getMenu().getMenuId()%>">
                                    <input type="hidden"
                                           name="quantity"
                                           value="<%=cartItem.getQuantity() - 1%>">

                                    <button type="submit"
                                            class="quantity-btn"
                                            aria-label="Decrease quantity">−</button>
                                </form>

                                <span class="quantity-value">
                                    <%=cartItem.getQuantity()%>
                                </span>

                                <form action="<%=cp%>/cart"
                                      method="post"
                                      class="quantity-form">

                                    <input type="hidden"
                                           name="action" value="update">
                                    <input type="hidden"
                                           name="menuId"
                                           value="<%=cartItem.getMenu().getMenuId()%>">
                                    <input type="hidden"
                                           name="quantity"
                                           value="<%=cartItem.getQuantity() + 1%>">

                                    <button type="submit"
                                            class="quantity-btn"
                                            aria-label="Increase quantity">+</button>
                                </form>

                            </div>
                        </div>

                        <div class="subtotal">
                            <span class="subtotal-label">Subtotal</span>
                            <span class="subtotal-value">
                                &#8377;<%=String.format(Locale.US, "%.2f",
                                    cartItem.getSubTotal())%>
                            </span>
                        </div>

                    </article>

                <% } %>

            </section>

            <!-- RIGHT: COUPONS AND BILL DETAILS -->
            <aside class="summary">

                <section class="coupon-card">
                    <div class="coupon-heading">
                        <h3>
                            <span class="coupon-heading-icon">&#127991;</span>
                            Coupons &amp; Offers
                        </h3>
                        <span class="coupon-heading-note">
                            Save more on your food
                        </span>
                    </div>

                    <form action="<%=cp%>/cart"
                          method="post"
                          class="coupon-form">

                        <input type="hidden" name="action" value="applyCoupon">

                        <input type="text"
                               name="couponCode"
                               class="coupon-input"
                               placeholder="Enter coupon code"
                               value="<%=appliedCoupon != null
                                   ? appliedCoupon : couponInput%>"
                               aria-label="Coupon code"
                               maxlength="30"
                               required>

                        <button type="submit" class="coupon-apply-btn">
                            Apply
                        </button>
                    </form>

                    <% if (appliedCoupon != null && couponDiscount > 0) { %>
                        <div class="coupon-success">
                            <div class="coupon-success-text">
                                <strong>
                                    <%=appliedCoupon%>
                                    <span class="applied-label">APPLIED</span>
                                </strong>
                                <p>
                                    You saved &#8377;<%=String.format(
                                        Locale.US, "%.2f", couponDiscount)%>
                                    with this coupon.
                                </p>
                            </div>

                            <form action="<%=cp%>/cart" method="post">
                                <input type="hidden"
                                       name="action" value="removeCoupon">
                                <button type="submit"
                                        class="coupon-remove-btn">
                                    Remove
                                </button>
                            </form>
                        </div>
                    <% } %>

                    <% if (couponMessage != null
                            && !couponMessage.trim().isEmpty()) { %>
                        <p class="coupon-message">
                            <%=couponMessage%>
                        </p>
                    <% } %>

                    <div class="suggested-coupons">
                        <p class="suggested-title">SUGGESTED COUPONS</p>

                        <form action="<%=cp%>/cart"
                              method="post" class="suggested-coupon">
                            <input type="hidden" name="action" value="applyCoupon">
                            <input type="hidden" name="couponCode" value="QUICK50">
                            <span class="suggested-coupon-icon">&#8377;</span>
                            <span class="suggested-coupon-details">
                                <strong>QUICK50</strong>
                                <small>Flat &#8377;50 off on orders over &#8377;200</small>
                            </span>
                            <button type="submit">APPLY</button>
                        </form>

                        <form action="<%=cp%>/cart"
                              method="post" class="suggested-coupon">
                            <input type="hidden" name="action" value="applyCoupon">
                            <input type="hidden" name="couponCode" value="WELCOME50">
                            <span class="suggested-coupon-icon">%</span>
                            <span class="suggested-coupon-details">
                                <strong>WELCOME50</strong>
                                <small>50% off up to &#8377;100 on orders over &#8377;150</small>
                            </span>
                            <button type="submit">APPLY</button>
                        </form>

                        <form action="<%=cp%>/cart"
                              method="post" class="suggested-coupon">
                            <input type="hidden" name="action" value="applyCoupon">
                            <input type="hidden" name="couponCode" value="TASTE20">
                            <span class="suggested-coupon-icon">20%</span>
                            <span class="suggested-coupon-details">
                                <strong>TASTE20</strong>
                                <small>20% off on orders above zero</small>
                            </span>
                            <button type="submit">APPLY</button>
                        </form>
                    </div>
                </section>

                <section class="bill-details">
                    <h3>Bill Details</h3>

                    <div class="bill-items">
                        <% for (CartItem summaryItem : cart.getItems()) { %>
                            <div class="bill-item-row">
                                <span class="bill-item-name">
                                    <%=summaryItem.getMenu().getItemName()%>
                                    <span class="bill-item-quantity">
                                        × <%=summaryItem.getQuantity()%>
                                    </span>
                                </span>

                                <span class="bill-item-price">
                                    &#8377;<%=String.format(Locale.US, "%.2f",
                                        summaryItem.getSubTotal())%>
                                </span>
                            </div>
                        <% } %>
                    </div>

                    <div class="summary-divider"></div>

                    <div class="summary-row">
                        <span>Item total</span>
                        <span>&#8377;<%=String.format(Locale.US, "%.2f", itemTotal)%></span>
                    </div>

                    <% if (couponDiscount > 0) { %>
                        <div class="summary-row coupon-discount-row">
                            <span>Coupon discount (<%=appliedCoupon%>)</span>
                            <span>-&#8377;<%=String.format(Locale.US, "%.2f",
                                couponDiscount)%></span>
                        </div>
                    <% } %>

                    <div class="summary-row">
                        <span>Delivery fee</span>
                        <span>&#8377;<%=String.format(Locale.US, "%.2f", deliveryFee)%></span>
                    </div>

                    <div class="summary-row">
                        <span>Platform fee</span>
                        <span>&#8377;<%=String.format(Locale.US, "%.2f", platformFee)%></span>
                    </div>

                    <div class="summary-divider"></div>

                    <div class="summary-total">
                        <span>Total payable</span>
                        <span class="total-price">
                            &#8377;<%=String.format(Locale.US, "%.2f", totalPayable)%>
                        </span>
                    </div>

                    <p class="bill-note">
                        Taxes, if applicable, will be shown at checkout.
                    </p>

                    <form action="<%=cp%>/checkout" method="get">
                        <button type="submit" class="checkout-btn">
                            Proceed to Checkout &#8594;
                        </button>
                    </form>

                    <a href="<%=cp%>/menu?restaurantId=<%=cart.getRestaurantId()%>"
                       class="continue-btn">
                        Add More Items
                    </a>
                </section>

            </aside>
        </div>

    <% } %>

</main>

<%@ include file="footer.jsp" %>

<script src="<%=cp%>/JS/cart.js"></script>

</body>
</html>
