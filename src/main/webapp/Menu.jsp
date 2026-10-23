<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Locale" %>

<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.Cart" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.Restaurant" %>

<%
String contextPath = request.getContextPath();

List<Menu> menuList = (List<Menu>) request.getAttribute("menuList");

if (menuList == null) {
    menuList = (List<Menu>) request.getAttribute("menus");
}

if (menuList == null) {
    menuList = (List<Menu>) request.getAttribute("menuItems");
}

if (menuList == null) {
    menuList = new ArrayList<Menu>();
}

Restaurant restaurant = (Restaurant) request.getAttribute("restaurant");

String restaurantName =
    (restaurant != null && restaurant.getName() != null)
    ? restaurant.getName()
    : "Restaurant Menu";

Cart cart = (Cart) session.getAttribute("cart");

// Read and remove a one-time cart message.
String cartMessage = (String) session.getAttribute("cartMessage");
session.removeAttribute("cartMessage");

int cartCount = 0;
double cartTotal = 0.0;

StringBuilder cartSummaryText = new StringBuilder();

if (cart != null && cart.getCartItems() != null
        && !cart.getCartItems().isEmpty()) {

    boolean first = true;

    for (Map.Entry<Integer, CartItem> entry
            : cart.getCartItems().entrySet()) {

        CartItem item = entry.getValue();

        if (item == null) {
            continue;
        }

        cartCount += item.getQuantity();
        cartTotal += item.getSubTotal();

        if (!first) {
            cartSummaryText.append(", ");
        }

        first = false;

        String cartItemName = "Food item";
        if (item.getMenu() != null && item.getMenu().getItemName() != null) {
            cartItemName = item.getMenu().getItemName();
        }

        cartSummaryText.append(cartItemName)
                       .append(" x")
                       .append(item.getQuantity());
    }
}

/* Read filter parameters */
String searchParam = request.getParameter("search") != null
    ? request.getParameter("search").trim()
    : "";

String sortParam = request.getParameter("sortOption") != null
    ? request.getParameter("sortOption")
    : "default";

String prefParam = request.getParameter("prefOption") != null
    ? request.getParameter("prefOption")
    : "all";

/* Validate filter values */
if (!"default".equals(sortParam)
        && !"low-high".equals(sortParam)
        && !"high-low".equals(sortParam)) {
    sortParam = "default";
}

if (!"all".equals(prefParam)
        && !"veg".equals(prefParam)
        && !"non-veg".equals(prefParam)) {
    prefParam = "all";
}

/* Read restaurant ID */
int restaurantId = 0;

try {
    restaurantId = Integer.parseInt(
        request.getParameter("restaurantId") != null
            ? request.getParameter("restaurantId")
            : "0"
    );
} catch (Exception e) {
    restaurantId = restaurant != null
        ? restaurant.getRestaurantId()
        : 0;
}

/*
 * FUNCTIONAL FILTERING
 * Search by name/description and filter by veg/non-veg.
 * Use the same keyword-based classification as the food badge.
 */
List<Menu> filteredMenuList = new ArrayList<Menu>();

String searchLower = searchParam.toLowerCase(Locale.ROOT);

for (Menu menu : menuList) {

    if (menu == null) {
        continue;
    }

    String itemName = menu.getItemName() != null
        ? menu.getItemName()
        : "";

    String description = menu.getDescription() != null
        ? menu.getDescription()
        : "";

    String searchableText =
        (itemName + " " + description).toLowerCase(Locale.ROOT);

    boolean nonVeg = searchableText.matches(
        "(?s).*\\b(chicken|mutton|fish|prawn|prawns|seafood|bacon|meat|non-veg|non veg|tikka|kabab|kebab|omelette|omelet|anda|egg|eggs)\\b.*"
    );

    boolean matchesPreference =
        "all".equals(prefParam)
        || ("veg".equals(prefParam) && !nonVeg)
        || ("non-veg".equals(prefParam) && nonVeg);

    boolean matchesSearch =
        searchLower.isEmpty()
        || searchableText.contains(searchLower);

    if (matchesPreference && matchesSearch) {
        filteredMenuList.add(menu);
    }
}

/* FUNCTIONAL PRICE SORTING */
if ("low-high".equals(sortParam)) {

    Collections.sort(filteredMenuList, new Comparator<Menu>() {
        @Override
        public int compare(Menu first, Menu second) {
            return Double.compare(first.getPrice(), second.getPrice());
        }
    });

} else if ("high-low".equals(sortParam)) {

    Collections.sort(filteredMenuList, new Comparator<Menu>() {
        @Override
        public int compare(Menu first, Menu second) {
            return Double.compare(second.getPrice(), first.getPrice());
        }
    });
}

/* Use filtered and sorted results in the original UI */
menuList = filteredMenuList;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>QuickBite | <%=restaurantName%> Menu</title>

<link rel="stylesheet" href="<%=contextPath%>/CSS/common.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/navbar.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/menu.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/footer.css">
</head>

<body class="menu-page-body">

    <%@ include file="navbar.jsp"%>

    <!-- Restaurant conflict popup (supports both SSR and instant AJAX) -->
    <div id="restaurantConflict" class="conflict-popup-overlay" style="<%=cartMessage != null && !cartMessage.isEmpty() ? "display:flex;" : "display:none;"%>">
        <div class="conflict-popup">
            <div class="conflict-popup-icon">!</div>
            <h2>Different Restaurant</h2>
            <p id="conflictMessageText"><%=cartMessage != null && !cartMessage.isEmpty() ? cartMessage : "You cannot add items from another restaurant. Please clear your cart first."%></p>
            <button type="button" class="conflict-popup-close" onclick="closeConflictPopup()">Okay, got it</button>
        </div>
    </div>

    <!-- Restaurant heading -->
    <section class="restaurant-hero">
        <div class="hero-card">
            <h1><%=restaurantName%></h1>
            <p>
                Explore the delicious menu at
                <%=restaurantName%>. Choose your favourites and order them fresh.
            </p>
        </div>
    </section>

    <main class="menu-main-container">

        <!-- Search and filter form -->
        <form action="<%=contextPath%>/menu" method="get"
            class="toolbar-form">

            <input type="hidden" name="restaurantId"
                value="<%=restaurantId%>">

            <div class="menu-header-row">

                <div>
                    <h2>Recommended for you</h2>
                </div>

                <div class="toolbar-controls">

                    <div class="search-box">
                        <svg width="16" height="16" viewBox="0 0 24 24"
                            fill="none" stroke="#7e7870" stroke-width="2"
                            stroke-linecap="round" stroke-linejoin="round">

                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>

                        <input type="search" name="search"
                            value="<%=searchParam%>"
                            placeholder="Search dishes..."
                            aria-label="Search dishes">
                    </div>

                    <div class="filter-dropdown-wrapper">

                        <input type="checkbox" id="filter-toggle"
                            class="filter-toggle-checkbox">

                        <label for="filter-toggle"
                            class="filter-dropdown-btn">
                            Filters &amp; Sort <span>▼</span>
                        </label>

                        <div class="filter-dropdown-menu">

                            <div class="dropdown-header">
                                <span class="dropdown-label">Sort By</span>

                                <a href="<%=contextPath%>/menu?restaurantId=<%=restaurantId%>"
                                    class="reset-link-btn">Reset</a>
                            </div>

                            <div class="dropdown-group">

                                <label>
                                    <input type="radio" name="sortOption"
                                        value="default"
                                        <%="default".equals(sortParam) ? "checked" : ""%>>
                                    Recommended
                                </label>

                                <label>
                                    <input type="radio" name="sortOption"
                                        value="low-high"
                                        <%="low-high".equals(sortParam) ? "checked" : ""%>>
                                    Price: Low to High
                                </label>

                                <label>
                                    <input type="radio" name="sortOption"
                                        value="high-low"
                                        <%="high-low".equals(sortParam) ? "checked" : ""%>>
                                    Price: High to Low
                                </label>

                            </div>

                            <div class="dropdown-divider"></div>

                            <div class="dropdown-group">

                                <span class="dropdown-label">Food Preference</span>

                                <label>
                                    <input type="radio" name="prefOption"
                                        value="all"
                                        <%="all".equals(prefParam) ? "checked" : ""%>>
                                    All Items
                                </label>

                                <label>
                                    <input type="radio" name="prefOption"
                                        value="veg"
                                        <%="veg".equals(prefParam) ? "checked" : ""%>>
                                    Pure Veg
                                </label>

                                <label>
                                    <input type="radio" name="prefOption"
                                        value="non-veg"
                                        <%="non-veg".equals(prefParam) ? "checked" : ""%>>
                                    Non-Veg
                                </label>

                            </div>

                            <div class="dropdown-divider"></div>

                            <button type="submit" class="btn-apply-filters">
                                Apply
                            </button>

                        </div>
                    </div>
                </div>
            </div>
        </form>

        <p class="items-count-text">
            Showing <%=menuList.size()%> menu items
        </p>

        <!-- Menu cards -->
        <section id="menuGrid" class="menu-grid">

            <%
            if (!menuList.isEmpty()) {

                for (Menu menu : menuList) {

                    int menuId = menu.getMenuId();

                    String itemName = menu.getItemName() != null
                        ? menu.getItemName()
                        : "Food item";

                    String description = menu.getDescription() != null
                        ? menu.getDescription()
                        : "";

                    String imagePath = menu.getImagePath() != null
                        ? menu.getImagePath()
                        : "";

                    double price = menu.getPrice();
                    boolean available = menu.isAvailable();

                    int quantity = 0;

                    if (cart != null && cart.getCartItems() != null) {
                        CartItem cartItem = cart.getCartItems().get(menuId);

                        if (cartItem != null) {
                            quantity = cartItem.getQuantity();
                        }
                    }

                    String searchableText =
                        (itemName + " " + description)
                        .toLowerCase(Locale.ROOT);

                    boolean nonVeg = searchableText.matches(
                        "(?s).*\\b(chicken|mutton|fish|prawn|prawns|seafood|bacon|meat|non-veg|non veg|tikka|kabab|kebab|omelette|omelet|anda|egg|eggs)\\b.*"
                    );

                    String foodType = nonVeg ? "non-veg" : "veg";
            %>

            <article class="food-card <%=!available ? "card-disabled" : ""%>">

                <div class="food-card-img-container">

                    <%
                    if (!imagePath.trim().isEmpty()) {
                    %>
                    <img src="<%=imagePath%>" alt="<%=itemName%>" loading="lazy">
                    <%
                    } else {
                    %>
                    <div class="img-placeholder"></div>
                    <%
                    }
                    %>

                    <div class="type-dot-badge <%=foodType%>"
                        title="<%=nonVeg ? "Non-Vegetarian" : "Vegetarian"%>">
                        <span class="dot"></span>
                    </div>

                </div>

                <div class="food-card-body">

                    <h3><%=itemName%></h3>

                    <%
                    if (!description.trim().isEmpty()) {
                    %>
                    <p class="description"><%=description%></p>
                    <%
                    }
                    %>

                    <div class="card-footer">

                        <span class="price">
                            ₹<%=String.format(Locale.ROOT, "%.2f", price)%>
                        </span>

                        <%
                        if (available) {
                        %>

                        <div class="cart-action-container" id="cartAction-<%=menuId%>">
                            <button type="button" class="btn-add-cart" id="addBtn-<%=menuId%>"
                                style="<%=quantity > 0 ? "display:none;" : ""%>"
                                onclick="ajaxCartAction(<%=menuId%>, 'add', 1)">
                                ADD +
                            </button>

                            <div class="quantity-stepper-box" id="stepper-<%=menuId%>"
                                style="<%=quantity == 0 ? "display:none;" : "display:flex;"%>">
                                <button type="button" class="stepper-btn" onclick="ajaxCartStep(<%=menuId%>, -1)">−</button>
                                <span class="stepper-val" id="qty-val-<%=menuId%>"><%=quantity%></span>
                                <button type="button" class="stepper-btn" onclick="ajaxCartStep(<%=menuId%>, 1)">+</button>
                            </div>
                        </div>

                        <%
                        } else {
                        %>

                        <button class="btn-unavailable" disabled>
                            Unavailable
                        </button>

                        <%
                        }
                        %>

                    </div>
                </div>
            </article>

            <%
                }

            } else {
            %>

            <div class="no-results">
                <h3>No dishes match your request</h3>
                <p>Try searching for something else or resetting the filters.</p>
            </div>

            <%
            }
            %>

        </section>
    </main>

    <!-- Floating cart bar (instant AJAX reactive) -->
    <div id="floatingCartBar" class="floating-cart-bar" style="<%=cartCount > 0 ? "display:flex;" : "display:none;"%>">

        <div class="cart-bar-left">
            <div class="cart-bar-icon">🍴</div>

            <div class="cart-bar-info">
                <span class="cart-count-text" id="cartCountLabel">
                    YOUR CART · <span id="cartCountVal"><%=cartCount%></span> ITEM(S)
                </span>

                <span class="cart-items-summary" id="cartBarSummary">
                    <%=cartSummaryText.toString()%>
                </span>
            </div>
        </div>

        <div class="cart-bar-right">
            <button type="button" class="btn-preview-cart" onclick="openCartPreview()">
                PREVIEW CART
            </button>

            <a href="<%=contextPath%>/cart" class="btn-checkout">
                VIEW &amp; CHECKOUT CART →
            </a>
        </div>
    </div>

    <!-- Cart preview modal -->
    <div id="cartPreviewModal" class="cart-preview-modal" style="display: none;">
        <div class="preview-modal-content">
            <div class="preview-modal-header">
                <h3>Your Cart Items</h3>
                <button type="button" class="btn-close-modal" onclick="closeCartPreview()">×</button>
            </div>

            <div class="preview-modal-body">
                <div id="previewItemsList">
                    <%
                    if (cart != null && cart.getCartItems() != null) {
                        for (Map.Entry<Integer, CartItem> entry : cart.getCartItems().entrySet()) {
                            CartItem item = entry.getValue();
                            if (item == null) continue;
                            String previewName = (item.getMenu() != null && item.getMenu().getItemName() != null)
                                    ? item.getMenu().getItemName() : "Food item";
                    %>
                    <div class="preview-item-row" id="prev-item-<%=entry.getKey()%>">
                        <span><strong><%=previewName%></strong> × <span id="prev-qty-<%=entry.getKey()%>"><%=item.getQuantity()%></span></span>
                        <span>₹<%=String.format(Locale.ROOT, "%.2f", item.getSubTotal())%></span>
                    </div>
                    <%
                        }
                    }
                    %>
                </div>

                <div class="preview-total-row">
                    <span>Total Amount</span>
                    <strong id="previewTotalAmount">
                        ₹<%=String.format(Locale.ROOT, "%.2f", cartTotal)%>
                    </strong>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="footer.jsp"%>

    <!-- Instant AJAX Cart & Client-Side Search Script (No Page Refreshes) -->
    <script>
        const QUICK_BITE_CONTEXT = "<%=contextPath%>";

        function closeConflictPopup() {
            const popup = document.getElementById("restaurantConflict");
            if (popup) {
                popup.style.display = "none";
            }
        }

        function showConflictPopup(message) {
            const popup = document.getElementById("restaurantConflict");
            const msgEl = document.getElementById("conflictMessageText");
            if (msgEl && message) {
                msgEl.textContent = message;
            }
            if (popup) {
                popup.style.display = "flex";
            }
        }

        function openCartPreview() {
            const modal = document.getElementById("cartPreviewModal");
            if (modal) modal.style.display = "flex";
        }

        function closeCartPreview() {
            const modal = document.getElementById("cartPreviewModal");
            if (modal) modal.style.display = "none";
        }

        async function ajaxCartAction(menuId, action, quantity) {
            const addBtn = document.getElementById("addBtn-" + menuId);
            const stepper = document.getElementById("stepper-" + menuId);
            const qtyVal = document.getElementById("qty-val-" + menuId);

            // Optimistic UI update
            if (addBtn) addBtn.style.display = "none";
            if (stepper) stepper.style.display = "flex";
            if (qtyVal) qtyVal.textContent = String(quantity);

            try {
                const params = new URLSearchParams();
                params.append("action", action);
                params.append("menuId", String(menuId));
                params.append("quantity", String(quantity));
                params.append("ajax", "true");
                params.append("source", "menu");

                const response = await fetch(QUICK_BITE_CONTEXT + "/cart", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded",
                        "Accept": "application/json",
                        "X-Requested-With": "XMLHttpRequest"
                    },
                    body: params.toString()
                });

                const data = await response.json();

                if (!data.success) {
                    // Revert optimistic UI
                    if (addBtn) addBtn.style.display = "";
                    if (stepper) stepper.style.display = "none";
                    if (qtyVal) qtyVal.textContent = "0";

                    if (data.conflict) {
                        showConflictPopup(data.message || "You cannot add items from another restaurant.");
                    } else {
                        alert(data.message || "Could not update cart.");
                    }
                    return;
                }

                updateCartDisplay(data);

            } catch (err) {
                console.error("Cart update error:", err);
                if (addBtn) addBtn.style.display = "";
                if (stepper) stepper.style.display = "none";
            }
        }

        async function ajaxCartStep(menuId, delta) {
            const qtyVal = document.getElementById("qty-val-" + menuId);
            const addBtn = document.getElementById("addBtn-" + menuId);
            const stepper = document.getElementById("stepper-" + menuId);

            const current = parseInt(qtyVal ? qtyVal.textContent : "0", 10) || 0;
            const newQty = Math.max(0, current + delta);

            // Optimistic UI update
            if (newQty <= 0) {
                if (stepper) stepper.style.display = "none";
                if (addBtn) addBtn.style.display = "";
                if (qtyVal) qtyVal.textContent = "0";
            } else {
                if (qtyVal) qtyVal.textContent = String(newQty);
            }

            try {
                const action = (newQty <= 0) ? "remove" : "update";
                const params = new URLSearchParams();
                params.append("action", action);
                params.append("menuId", String(menuId));
                params.append("quantity", String(newQty));
                params.append("ajax", "true");
                params.append("source", "menu");

                const response = await fetch(QUICK_BITE_CONTEXT + "/cart", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded",
                        "Accept": "application/json",
                        "X-Requested-With": "XMLHttpRequest"
                    },
                    body: params.toString()
                });

                const data = await response.json();

                if (data.success !== false) {
                    updateCartDisplay(data);
                } else {
                    if (qtyVal) qtyVal.textContent = String(current);
                }
            } catch (err) {
                console.error("Cart step error:", err);
                if (qtyVal) qtyVal.textContent = String(current);
            }
        }

        function updateCartDisplay(data) {
            if (!data) return;

            const totalQty = data.totalQuantity || 0;
            const totalAmt = data.totalAmount || 0;
            const floatingBar = document.getElementById("floatingCartBar");
            const cartCountVal = document.getElementById("cartCountVal");
            const cartBarSummary = document.getElementById("cartBarSummary");
            const prevTotal = document.getElementById("previewTotalAmount");
            const prevList = document.getElementById("previewItemsList");

            // Update floating cart bar
            if (floatingBar) {
                floatingBar.style.display = (totalQty > 0) ? "flex" : "none";
            }
            if (cartCountVal) {
                cartCountVal.textContent = String(totalQty);
            }

            // Update navbar cart count
            const navCounts = document.querySelectorAll(".nav-cart-count");
            navCounts.forEach(el => {
                el.textContent = String(data.items ? data.items.length : totalQty);
                el.style.display = (totalQty > 0) ? "inline-block" : "none";
            });

            // Update preview items & summary
            if (Array.isArray(data.items)) {
                let summaryParts = [];
                if (prevList) prevList.innerHTML = "";

                data.items.forEach(it => {
                    summaryParts.push(it.name + " x" + it.quantity);
                    if (prevList) {
                        const row = document.createElement("div");
                        row.className = "preview-item-row";
                        row.innerHTML = "<span><strong>" + it.name + "</strong> × " + it.quantity + "</span>"
                            + "<span>₹" + Number(it.subtotal).toFixed(2) + "</span>";
                        prevList.appendChild(row);
                    }
                });

                if (cartBarSummary) {
                    cartBarSummary.textContent = summaryParts.join(", ");
                }
            }

            if (prevTotal) {
                prevTotal.textContent = "₹" + Number(totalAmt).toFixed(2);
            }
        }

        // Instant Live Dish Search & Veg/Non-Veg Filter (No page reload)
        document.addEventListener("DOMContentLoaded", function() {
            const searchInput = document.querySelector('input[name="search"]');
            if (searchInput) {
                searchInput.addEventListener("input", function() {
                    const q = searchInput.value.trim().toLowerCase();
                    const cards = document.querySelectorAll(".food-card");
                    let visible = 0;
                    cards.forEach(card => {
                        const title = (card.querySelector("h3") ? card.querySelector("h3").textContent : "").toLowerCase();
                        const desc = (card.querySelector(".description") ? card.querySelector(".description").textContent : "").toLowerCase();
                        const match = !q || title.includes(q) || desc.includes(q);
                        card.style.display = match ? "" : "none";
                        if (match) visible++;
                    });

                    const countText = document.querySelector(".items-count-text");
                    if (countText) {
                        countText.textContent = "Showing " + visible + " menu items";
                    }
                });
            }
        });
    </script>
</body>
</html>