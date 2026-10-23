<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Restaurant" %>

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