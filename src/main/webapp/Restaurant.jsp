<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Restaurant" %>
<%@ page import="com.tap.model.Cart" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.DAOImpl.RestaurantDAOImpl" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Restaurants | QuickBite</title>

    <link rel="stylesheet"
        href="<%= request.getContextPath() %>/CSS/common.css">

    <link rel="stylesheet"
        href="<%= request.getContextPath() %>/CSS/navbar.css">

    <!-- Keep restaurant.css after the other stylesheets -->
    <link rel="stylesheet"
        href="<%= request.getContextPath() %>/CSS/restaurant.css?v=<%=System.currentTimeMillis()%>">

    <link rel="stylesheet"
        href="<%= request.getContextPath() %>/CSS/footer.css">
</head>

<body>

    <%@ include file="navbar.jsp" %>

    <!-- HERO SECTION -->
    <section class="hero-section">
        <div class="hero-overlay"></div>

        <div class="hero-content">

            <div class="hero-badge">
                🍽️ Welcome to QuickBite
            </div>

            <h1 class="hero-title">
                Discover Restaurants<br>
                <span class="hero-highlight">You'll Love.</span>
            </h1>

            <p class="hero-subtitle">
                Explore delicious food from your favourite restaurants.
                Find your next favourite meal and order with ease.
            </p>

            <div class="hero-search-wrapper">
                <div class="search-input-box">
                    <span class="search-icon">🔍</span>

                    <input type="text"
                        id="restaurantSearchInput"
                        placeholder="Search restaurants or cuisines..."
                        aria-label="Search restaurants or cuisines">

                    <button type="button"
                        class="search-filter-btn"
                        onclick="filterRestaurants()">
                        Search
                    </button>
                </div>

                <div class="hero-cta-group">
                    <a href="#restaurantListing"
                        class="btn-primary-explore">
                        Explore Restaurants →
                    </a>

                    <div class="active-kitchens-status">
                        <span class="status-dot-pulse"></span>
                        Good food, good mood
                    </div>
                </div>
            </div>

        </div>
    </section>

    <!-- CATEGORY FILTERS -->
    <section class="filters-section">
        <div class="container">
            <div class="category-pills">

                <button type="button"
                    class="pill active"
                    onclick="filterByCuisine('all', this)">
                    🍽️ All Restaurants
                </button>

                <button type="button"
                    class="pill"
                    onclick="filterByCuisine('south indian', this)">
                    🥞 South Indian
                </button>

                <button type="button"
                    class="pill"
                    onclick="filterByCuisine('andhra', this)">
                    🌶️ Andhra
                </button>

                <button type="button"
                    class="pill"
                    onclick="filterByCuisine('biryani', this)">
                    🍛 Biryani
                </button>

                <button type="button"
                    class="pill"
                    onclick="filterByCuisine('north indian', this)">
                    🍲 North Indian
                </button>

                <button type="button"
                    class="pill"
                    onclick="filterByCuisine('cafe', this)">
                    ☕ Cafes
                </button>

            </div>
        </div>
    </section>

    <!-- RESTAURANT LIST -->
    <main class="container main-content" id="restaurantListing">

        <div class="section-heading-row">
            <div>
                <h2 class="section-title">Popular Restaurants</h2>
                <p class="section-subtitle">
                    Explore our restaurants and discover something delicious.
                </p>
            </div>
        </div>

        <%
            List<Restaurant> restaurants =
                (List<Restaurant>) request.getAttribute("restaurants");

            if (restaurants != null && !restaurants.isEmpty()) {
        %>

        <div class="restaurant-grid" id="restaurantGrid">

            <%
                for (Restaurant restaurant : restaurants) {

                    String restaurantName = restaurant.getName();
                    if (restaurantName == null || restaurantName.trim().isEmpty()) {
                        restaurantName = "Restaurant";
                    }

                    String cuisine = restaurant.getCuisineType();
                    if (cuisine == null || cuisine.trim().isEmpty()) {
                        cuisine = "Various dishes";
                    }

                    String address = restaurant.getAddress();
                    if (address == null || address.trim().isEmpty()) {
                        address = "Address unavailable";
                    }

                    String deliveryTime = restaurant.getDeliveryTime();
                    if (deliveryTime == null || deliveryTime.trim().isEmpty()) {
                        deliveryTime = "Delivery time varies";
                    }

                    String imagePath = restaurant.getImagePath();
                    if (imagePath == null || imagePath.trim().isEmpty()) {
                        imagePath =
                            "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80";
                    }

                    String searchName = restaurantName.toLowerCase();
                    String searchCuisine = cuisine.toLowerCase();
            %>

            <article class="restaurant-card"
                data-name="<%= searchName %>"
                data-cuisine="<%= searchCuisine %>">

                <!-- RESTAURANT IMAGE -->
                <div class="card-image-wrapper">

                    <img
                        class="restaurant-image"
                        src="<%= imagePath %>"
                        alt="<%= restaurantName %>"
                        loading="lazy"
                        onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80';">

                    <div class="card-floating-pill">
                        🍴 <%= cuisine %>
                    </div>

                    <div class="card-photo-overlay-info">
                        <span>⏱️ <%= deliveryTime %></span>
                    </div>

                </div>

                <!-- RESTAURANT DETAILS -->
                <div class="restaurant-content">

                    <div class="title-rating-row">
                        <h3 class="restaurant-name">
                            <%= restaurantName %>
                        </h3>

                        <span class="rating-badge">
                            ★ <%= restaurant.getRating() %>
                        </span>
                    </div>

                    <div class="cuisine">
                        <%= cuisine %>
                    </div>

                    <div class="meta-row">

                        <div class="address-text">
                            📍 <%= address %>
                        </div>

                        <div class="live-status">
                            <% if (restaurant.isActive()) { %>
                                <span class="status-open">● Open</span>
                            <% } else { %>
                                <span class="status-closed">● Closed</span>
                            <% } %>
                        </div>

                    </div>

                    <!-- PASS THE SELECTED RESTAURANT ID TO MenuController -->
                    <a class="view-menu-btn"
                        href="<%= request.getContextPath() %>/menu?restaurantId=<%= restaurant.getRestaurantId() %>">
                        View Menu →
                    </a>

                </div>
            </article>

            <%
                }
            %>

        </div>

        <div class="no-restaurants"
            id="noSearchResults"
            style="display: none;">

            <div class="empty-icon-circle">🍽️</div>

            <h2>No Matching Restaurants</h2>

            <p>
                Try another restaurant name or cuisine.
            </p>
        </div>

        <%
            } else {
        %>

        <div class="no-restaurants">

            <div class="empty-icon-circle">🍲</div>

            <h2>No Restaurants Available</h2>

            <p>
                No restaurants were found. Please try again later.
            </p>

            <a class="btn-refresh"
                href="<%= request.getContextPath() %>/restaurant">
                Refresh Restaurants
            </a>

        </div>

        <%
            }
        %>

    </main>

    <%
        Cart restCart = (Cart) session.getAttribute("cart");
        int restCartCount = 0;
        double restCartTotal = 0.0;
        String restCartRestaurantName = "";
        StringBuilder restCartSummary = new StringBuilder();

        if (restCart != null && restCart.getCartItems() != null && !restCart.getCartItems().isEmpty()) {
            for (CartItem item : restCart.getCartItems().values()) {
                if (item != null) {
                    restCartCount += item.getQuantity();
                    if (restCartSummary.length() > 0) {
                        restCartSummary.append(", ");
                    }
                    String iname = (item.getMenu() != null && item.getMenu().getItemName() != null)
                            ? item.getMenu().getItemName() : "Item";
                    restCartSummary.append(iname).append(" × ").append(item.getQuantity());
                }
            }
            restCartTotal = restCart.getTotalAmount();
            if (restCart.getRestaurantId() > 0) {
                try {
                    Restaurant rObj = new RestaurantDAOImpl().getRestaurant(restCart.getRestaurantId());
                    if (rObj != null && rObj.getName() != null) {
                        restCartRestaurantName = rObj.getName();
                    }
                } catch (Exception ignored) {}
            }
        }
    %>

    <!-- Sticky / Floating Cart Bar for Restaurant Page -->
    <% if (restCartCount > 0) { %>
    <div id="restaurantFloatingCartBar" class="floating-cart-bar">
        <div class="cart-bar-left">
            <div class="cart-bar-icon">🛒</div>
            <div class="cart-bar-info">
                <span class="cart-count-text">
                    ORDERING FROM <strong><%=restCartRestaurantName.isEmpty() ? "Selected Restaurant" : restCartRestaurantName%></strong> &bull; <span><%=restCartCount%></span> ITEM(S)
                </span>
                <span class="cart-items-summary">
                    <%=restCartSummary.toString()%>
                </span>
            </div>
        </div>

        <div class="cart-bar-right">
            <div class="cart-bar-price">
                <span class="cart-price-sublabel">Total:</span>
                <span class="cart-price-val">&#8377;<%=String.format(java.util.Locale.ROOT, "%.2f", restCartTotal)%></span>
            </div>
            <button type="button" class="btn-preview-cart" onclick="openRestCartPreview()">
                PREVIEW
            </button>
            <a href="<%=request.getContextPath()%>/cart" class="btn-checkout">
                VIEW CART &amp; CHECKOUT &rarr;
            </a>
        </div>
    </div>

    <!-- Cart Preview Modal for Restaurant Page -->
    <div id="restCartPreviewModal" class="cart-preview-modal" style="display: none;">
        <div class="preview-modal-content">
            <div class="preview-modal-header">
                <div>
                    <h3 style="margin: 0 0 4px 0; font-size: 18px; color: #36291a;">Your Active Cart</h3>
                    <p style="margin: 0; font-size: 13px; color: #8c8275;">
                        From: <strong><%=restCartRestaurantName.isEmpty() ? "Restaurant" : restCartRestaurantName%></strong>
                    </p>
                </div>
                <button type="button" class="btn-close-modal" onclick="closeRestCartPreview()">&times;</button>
            </div>
            <div class="preview-modal-body">
                <div class="preview-items-list" style="max-height: 250px; overflow-y: auto;">
                    <%
                    for (CartItem it : restCart.getCartItems().values()) {
                        if (it == null) continue;
                        String iname = (it.getMenu() != null && it.getMenu().getItemName() != null)
                                ? it.getMenu().getItemName() : "Item";
                    %>
                    <div class="preview-item-row" style="display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #efe8dd; font-size: 14px;">
                        <span><strong><%=iname%></strong> &times; <%=it.getQuantity()%></span>
                        <span>&#8377;<%=String.format(java.util.Locale.ROOT, "%.2f", it.getSubTotal())%></span>
                    </div>
                    <% } %>
                </div>
                <div class="preview-total-row" style="display: flex; justify-content: space-between; margin-top: 14px; padding-top: 10px; border-top: 2px solid #36291a; font-size: 16px;">
                    <span>Total Amount</span>
                    <strong>&#8377;<%=String.format(java.util.Locale.ROOT, "%.2f", restCartTotal)%></strong>
                </div>
            </div>
            <div style="padding: 14px 20px; border-top: 1px solid #efe3d0; display: flex; justify-content: space-between; align-items: center; background: #fffdf7; border-radius: 0 0 12px 12px;">
                <% if (restCart.getRestaurantId() > 0) { %>
                <a href="<%=request.getContextPath()%>/menu?restaurantId=<%=restCart.getRestaurantId()%>" style="color: #d97706; font-size: 13px; font-weight: 600; text-decoration: none;">
                    &larr; Return to Menu
                </a>
                <% } else { %>
                <span></span>
                <% } %>
                <a href="<%=request.getContextPath()%>/cart" class="btn-checkout" style="display: inline-block; text-decoration: none; padding: 10px 20px;">
                    Proceed to Cart &rarr;
                </a>
            </div>
        </div>
    </div>

    <script>
        function openRestCartPreview() {
            var modal = document.getElementById("restCartPreviewModal");
            if (modal) modal.style.display = "flex";
        }
        function closeRestCartPreview() {
            var modal = document.getElementById("restCartPreviewModal");
            if (modal) modal.style.display = "none";
        }
        window.addEventListener("click", function(e) {
            var modal = document.getElementById("restCartPreviewModal");
            if (modal && e.target === modal) {
                closeRestCartPreview();
            }
        });
    </script>
    <% } %>

    <%@ include file="footer.jsp" %>

    <!-- SEARCH AND CATEGORY FILTERS -->
    <script>
        function filterRestaurants() {
            const input =
                document.getElementById("restaurantSearchInput");

            const searchText = input.value.trim().toLowerCase();

            const cards =
                document.querySelectorAll(".restaurant-card");

            const noResults =
                document.getElementById("noSearchResults");

            let visibleCount = 0;

            cards.forEach(function(card) {
                const name = card.dataset.name || "";
                const cuisine = card.dataset.cuisine || "";

                const matches =
                    name.includes(searchText) ||
                    cuisine.includes(searchText);

                card.style.display = matches ? "" : "none";

                if (matches) {
                    visibleCount++;
                }
            });

            if (noResults) {
                noResults.style.display =
                    visibleCount === 0 ? "block" : "none";
            }
        }

        function filterByCuisine(cuisine, button) {
            const cards =
                document.querySelectorAll(".restaurant-card");

            const noResults =
                document.getElementById("noSearchResults");

            const searchInput =
                document.getElementById("restaurantSearchInput");

            searchInput.value = "";

            document.querySelectorAll(".category-pills .pill")
                .forEach(function(pill) {
                    pill.classList.remove("active");
                });

            button.classList.add("active");

            let visibleCount = 0;

            cards.forEach(function(card) {
                const cardCuisine = card.dataset.cuisine || "";

                const matches =
                    cuisine === "all" ||
                    cardCuisine.includes(cuisine);

                card.style.display = matches ? "" : "none";

                if (matches) {
                    visibleCount++;
                }
            });

            if (noResults) {
                noResults.style.display =
                    visibleCount === 0 ? "block" : "none";
            }
        }

        document.addEventListener("DOMContentLoaded", function() {
            const searchInput =
                document.getElementById("restaurantSearchInput");

            if (searchInput) {
                searchInput.addEventListener("input", filterRestaurants);
            }

            // High-speed prefetch and instant visual feedback for View Menu clicks
            document.querySelectorAll(".view-menu-btn").forEach(function(btn) {
                btn.addEventListener("mouseenter", function() {
                    const href = this.getAttribute("href");
                    if (href && !document.querySelector('link[href="' + href + '"]')) {
                        const link = document.createElement("link");
                        link.rel = "prefetch";
                        link.href = href;
                        document.head.appendChild(link);
                    }
                });

                btn.addEventListener("click", function() {
                    this.innerHTML = "Opening Menu... ⏳";
                    this.style.opacity = "0.8";
                });
            });
        });
    </script>

</body>
</html>