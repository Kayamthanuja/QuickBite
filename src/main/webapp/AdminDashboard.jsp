<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.model.Order" %>
<%@ page import="com.tap.model.Restaurant" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.User" %>

<%
User user = (User) session.getAttribute("user");
String contextPath = request.getContextPath();

List<Order> orders = (List<Order>) request.getAttribute("orders");
List<Restaurant> restaurants = (List<Restaurant>) request.getAttribute("restaurants");
List<Menu> menus = (List<Menu>) request.getAttribute("menus");
List<User> users = (List<User>) request.getAttribute("users");
List<User> deliveryPartners = (List<User>) request.getAttribute("deliveryPartners");

Double totalRevenue = (Double) request.getAttribute("totalRevenue");
if (totalRevenue == null) totalRevenue = 0.0;

Integer activeRestaurantsCount = (Integer) request.getAttribute("activeRestaurantsCount");
if (activeRestaurantsCount == null) activeRestaurantsCount = 0;

Integer pendingOrdersCount = (Integer) request.getAttribute("pendingOrdersCount");
if (pendingOrdersCount == null) pendingOrdersCount = 0;

int totalRestaurantsCount = restaurants == null ? 0 : restaurants.size();
int inactiveRestaurantsCount = totalRestaurantsCount - activeRestaurantsCount;

int totalMenuItems = menus == null ? 0 : menus.size();
int availableMenuItems = 0;

if (menus != null) {
    for (Menu m : menus) {
        if (m.isAvailable()) availableMenuItems++;
    }
}
int unavailableMenuItems = totalMenuItems - availableMenuItems;

// Role counters for Users section
int totalUsersCount = (users == null) ? 0 : users.size();
int customerCount = 0;
int deliveryPartnerCount = 0;
int adminCount = 0;

if (users != null) {
    for (User u : users) {
        String r = (u.getRole() == null) ? "CUSTOMER" : u.getRole().toUpperCase(Locale.ROOT);
        if (r.contains("ADMIN")) {
            adminCount++;
        } else if (r.contains("DELIVER") || r.contains("AGENT")) {
            deliveryPartnerCount++;
        } else {
            customerCount++;
        }
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard | QuickBite</title>

<link rel="stylesheet" href="<%=contextPath%>/CSS/common.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/adminNavbar.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/adminDashboard.css?v=<%=System.currentTimeMillis()%>">
<link rel="stylesheet" href="<%=contextPath%>/CSS/footer.css">
</head>

<body class="admin-body">

<%@ include file="adminNavbar.jsp" %>



<main class="container admin-main">

    <!-- DASHBOARD STATISTICS -->
    <section class="admin-stats-grid">
        <div class="admin-stat-card">
            <div class="admin-stat-icon">💰</div>
            <div>
                <div class="stat-label">Total Revenue</div>
                <div class="stat-value">₹<%=String.format(Locale.ROOT, "%,.2f", totalRevenue)%></div>
            </div>
        </div>

        <div class="admin-stat-card">
            <div class="admin-stat-icon">📦</div>
            <div>
                <div class="stat-label">Total Orders</div>
                <div class="stat-value"><%=orders == null ? 0 : orders.size()%></div>
            </div>
        </div>

        <div class="admin-stat-card">
            <div class="admin-stat-icon">⏳</div>
            <div>
                <div class="stat-label">Active / In-Kitchen</div>
                <div class="stat-value"><%=pendingOrdersCount%></div>
            </div>
        </div>

        <div class="admin-stat-card">
            <div class="admin-stat-icon">🏪</div>
            <div>
                <div class="stat-label">Active Restaurants</div>
                <div class="stat-value" id="activeRestaurantStat"><%=activeRestaurantsCount%></div>
            </div>
        </div>

        <div class="admin-stat-card">
            <div class="admin-stat-icon">🛵</div>
            <div>
                <div class="stat-label">Delivery Fleet</div>
                <div class="stat-value"><%=deliveryPartners == null ? 0 : deliveryPartners.size()%></div>
            </div>
        </div>
    </section>

    <nav class="admin-tabs-nav">
        <button type="button" class="admin-tab-btn active" id="tabOrdersBtn" onclick="switchAdminTab('orders')">
            📋 Orders (<%=orders == null ? 0 : orders.size()%>)
        </button>
        <button type="button" class="admin-tab-btn" id="tabRestaurantsBtn" onclick="switchAdminTab('restaurants')">
            🍽️ Restaurants (<span id="restaurantTabCount"><%=totalRestaurantsCount%></span>)
        </button>
        <button type="button" class="admin-tab-btn" id="tabMenusBtn" onclick="switchAdminTab('menus')">
            📜 Menu Items (<span id="menuTabCount"><%=totalMenuItems%></span>)
        </button>
        <button type="button" class="admin-tab-btn" id="tabUsersBtn" onclick="switchAdminTab('users')">
            &#128100; Users (<span id="userTabCount"><%=totalUsersCount%></span>)
        </button>
    </nav>

    <!-- ORDERS SECTION -->
    <section class="admin-card admin-tab-visible" id="adminOrdersSection">
        <div class="admin-card-header">
            <h2 class="admin-card-title">Live Orders &amp; Dispatch</h2>
        </div>

        <div class="admin-table-wrapper">
            <table class="admin-table orders-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>User ID</th>
                        <th>Date</th>
                        <th>Total</th>
                        <th>Payment</th>
                        <th>Delivery Address</th>
                        <th>Status</th>
                        <th>Update Status</th>
                    </tr>
                </thead>
                <tbody>
                <% if (orders != null && !orders.isEmpty()) {
                    for (Order ord : orders) {
                        String st = ord.getStatus() == null ? "PLACED" : ord.getStatus().toUpperCase(Locale.ROOT);
                        String pillClass = "placed";
                        if (st.contains("PREPAR")) pillClass = "preparing";
                        else if (st.contains("WAY") || st.contains("OUT")) pillClass = "out-for-delivery";
                        else if (st.contains("DELIVER")) pillClass = "delivered";
                        else if (st.contains("CANCEL")) pillClass = "cancelled";
                %>
                    <tr id="order-row-<%=ord.getOrderId()%>">
                        <td><strong>QB-<%=ord.getOrderId()%></strong></td>
                        <td>#<%=ord.getUserId()%></td>
                        <td><%=ord.getOrderDate() != null ? ord.getOrderDate().toString() : "Recent"%></td>
                        <td><strong>₹<%=String.format(Locale.ROOT, "%.2f", ord.getTotalAmount())%></strong></td>
                        <td><%=ord.getPaymentMode() != null ? ord.getPaymentMode() : "COD"%></td>
                        <td><%=ord.getDeliveryAddress() != null ? ord.getDeliveryAddress() : "Bangalore"%></td>
                        <td><span class="status-pill <%=pillClass%>" id="pill-<%=ord.getOrderId()%>"><%=st%></span></td>
                        <td>
                            <select class="status-select" onchange="updateOrderStatus(<%=ord.getOrderId()%>,this.value)">
                                <option value="PLACED" <%= "PLACED".equals(st) ? "selected" : "" %>>Placed</option>
                                <option value="PREPARING" <%= "PREPARING".equals(st) ? "selected" : "" %>>Preparing</option>
                                <option value="OUT FOR DELIVERY" <%= "OUT FOR DELIVERY".equals(st) ? "selected" : "" %>>Out for Delivery</option>
                                <option value="DELIVERED" <%= "DELIVERED".equals(st) ? "selected" : "" %>>Delivered</option>
                                <option value="CANCELLED" <%= "CANCELLED".equals(st) ? "selected" : "" %>>Cancelled</option>
                            </select>
                        </td>
                    </tr>
                <% } } else { %>
                    <tr><td colspan="8">No orders recorded yet.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- RESTAURANTS SECTION -->
    <section class="admin-card admin-tab-hidden" id="adminRestaurantsSection">
        <div class="admin-card-header">
            <h2 class="admin-card-title">Restaurant Outlets</h2>
            <button type="button" class="action-btn-sm add" onclick="openAddRestaurantModal()">+ Add Restaurant</button>
        </div>

        <div class="admin-stats-grid section-stats-grid">
            <div class="admin-stat-card">
                <div class="admin-stat-icon">🏪</div>
                <div>
                    <div class="stat-label">Total Restaurants</div>
                    <div class="stat-value" id="totalRestaurantCount"><%=totalRestaurantsCount%></div>
                </div>
            </div>
            <div class="admin-stat-card">
                <div class="admin-stat-icon">✅</div>
                <div>
                    <div class="stat-label">Active Restaurants</div>
                    <div class="stat-value" id="activeRestaurantCount"><%=activeRestaurantsCount%></div>
                </div>
            </div>
            <div class="admin-stat-card">
                <div class="admin-stat-icon">⛔</div>
                <div>
                    <div class="stat-label">Inactive Restaurants</div>
                    <div class="stat-value" id="inactiveRestaurantCount"><%=inactiveRestaurantsCount%></div>
                </div>
            </div>
        </div>

        <div class="admin-table-wrapper">
            <table class="admin-table restaurant-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Restaurant</th>
                        <th>Cuisine</th>
                        <th>Delivery Time</th>
                        <th>Rating</th>
                        <th>Address</th>
                        <th>State</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% if (restaurants != null && !restaurants.isEmpty()) {
                    for (Restaurant r : restaurants) {
                        String restaurantImage = r.getImagePath() == null ? "" : r.getImagePath().trim();
                %>
                    <tr id="restaurant-row-<%=r.getRestaurantId()%>">
                        <td><%=r.getRestaurantId()%></td>
                        <td>
                            <div class="restaurant-cell">
                                <img class="admin-restaurant-image"
                                     src="<%=restaurantImage%>"
                                     alt="<%=r.getName()%>"
                                     width="58"
                                     height="58"
                                     loading="lazy"
                                     decoding="async"
                                     onerror="this.onerror=null;this.style.display='none';this.nextElementSibling.style.display='flex';">
                                <div class="admin-image-fallback" style="<%=restaurantImage.isEmpty() ? "" : "display:none"%>">🍽️</div>
                                <strong><%=r.getName()%></strong>
                            </div>
                        </td>
                        <td><%=r.getCuisineType()%></td>
                        <td><%=r.getDeliveryTime()%></td>
                        <td>⭐ <%=r.getRating()%></td>
                        <td><%=r.getAddress()%></td>
                        <td>
                            <span class="status-pill <%=r.isActive() ? "delivered" : "cancelled"%>"
                                  id="rest-badge-<%=r.getRestaurantId()%>">
                                <%=r.isActive() ? "OPEN" : "CLOSED"%>
                            </span>
                        </td>
                        <td>
                            <div class="restaurant-actions">
                                <button type="button"
                                        class="action-btn-sm <%=r.isActive() ? "toggle-off" : "toggle-on"%>"
                                        id="rest-btn-<%=r.getRestaurantId()%>"
                                        onclick="toggleRestaurantActive(<%=r.getRestaurantId()%>)">
                                    <%=r.isActive() ? "Close Outlet" : "Open Outlet"%>
                                </button>
                                <a class="action-btn-sm"
                                   href="<%=contextPath%>/menu?restaurantId=<%=r.getRestaurantId()%>">View Menu</a>
                            </div>
                        </td>
                    </tr>
                <% } } else { %>
                    <tr><td colspan="8">No restaurants found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- MENU ITEMS SECTION -->
    <section class="admin-card admin-tab-hidden" id="adminMenusSection">
        <div class="admin-card-header">
            <h2 class="admin-card-title">Dish Catalog &amp; Pricing</h2>
            <button type="button" class="action-btn-sm add" onclick="openAddMenuModal()">+ Add Dish</button>
        </div>

        <div class="admin-stats-grid section-stats-grid">
            <div class="admin-stat-card">
                <div class="admin-stat-icon">🍲</div>
                <div>
                    <div class="stat-label">Total Menu Items</div>
                    <div class="stat-value" id="totalMenuItems"><%=totalMenuItems%></div>
                </div>
            </div>
            <div class="admin-stat-card">
                <div class="admin-stat-icon">✅</div>
                <div>
                    <div class="stat-label">Available</div>
                    <div class="stat-value" id="availableMenuItems"><%=availableMenuItems%></div>
                </div>
            </div>
            <div class="admin-stat-card">
                <div class="admin-stat-icon">⛔</div>
                <div>
                    <div class="stat-label">Unavailable</div>
                    <div class="stat-value" id="unavailableMenuItems"><%=unavailableMenuItems%></div>
                </div>
            </div>
        </div>

        <div class="admin-table-wrapper">
            <table class="admin-table menu-table">
                <thead>
                    <tr>
                        <th>Dish ID</th>
                        <th>Dish</th>
                        <th>Restaurant</th>
                        <th>Price</th>
                        <th>Availability</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="menuTableBody">
                <% if (menus != null && !menus.isEmpty()) {
                    for (Menu m : menus) {
                        String restaurantName = "";
                        if (restaurants != null) {
                            for (Restaurant restaurant : restaurants) {
                                if (restaurant.getRestaurantId() == m.getRestaurantId()) {
                                    restaurantName = restaurant.getName();
                                    break;
                                }
                            }
                        }
                        String imagePath = m.getImagePath() == null ? "" : m.getImagePath().trim();
                %>
                    <tr id="menu-row-<%=m.getMenuId()%>"
                        data-menu-id="<%=m.getMenuId()%>"
                        data-restaurant-id="<%=m.getRestaurantId()%>"
                        data-item-name="<%=m.getItemName() == null ? "" : m.getItemName().replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace(">","&gt;")%>"
                        data-description="<%=m.getDescription() == null ? "" : m.getDescription().replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace(">","&gt;")%>"
                        data-image-path="<%=imagePath.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace(">","&gt;")%>"
                        data-restaurant-name="<%=restaurantName.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace(">","&gt;")%>"
                        data-price="<%=m.getPrice()%>"
                        data-available="<%=m.isAvailable()%>">

                        <td><strong>#<%=m.getMenuId()%></strong></td>

                        <td>
                            <div class="menu-cell">
                                <img class="admin-menu-image"
                                     src="<%=imagePath%>"
                                     alt="<%=m.getItemName()%>"
                                     width="58"
                                     height="58"
                                     loading="lazy"
                                     decoding="async"
                                     onerror="this.onerror=null;this.style.display='none';this.nextElementSibling.style.display='flex';">
                                <div class="admin-image-fallback" style="<%=imagePath.isEmpty() ? "" : "display:none"%>">🍲</div>
                                <div class="menu-text">
                                    <strong class="menu-name"><%=m.getItemName()%></strong>
                                    <div class="menu-description"><%=m.getDescription() == null ? "" : m.getDescription()%></div>
                                </div>
                            </div>
                        </td>

                        <td class="menu-restaurant">#<%=m.getRestaurantId()%> <%=restaurantName%></td>
                        <td class="menu-price">₹<%=String.format(Locale.ROOT, "%.2f", m.getPrice())%></td>

                        <td class="availability-cell">
                            <div class="availability-flex-box">
                                <span class="status-pill <%=m.isAvailable() ? "delivered" : "cancelled"%>"
                                      id="menu-badge-<%=m.getMenuId()%>">
                                    <%=m.isAvailable() ? "AVAILABLE" : "UNAVAILABLE"%>
                                </span>
                                <button type="button"
                                        class="action-btn-sm availability-toggle <%=m.isAvailable() ? "toggle-off" : "toggle-on"%>"
                                        id="menu-btn-<%=m.getMenuId()%>"
                                        onclick="toggleMenuAvailable(<%=m.getMenuId()%>)">
                                    <%=m.isAvailable() ? "Mark Unavailable" : "Mark Available"%>
                                </button>
                            </div>
                        </td>

                        <td class="menu-actions">
                            <button type="button" class="action-btn-sm edit-menu-btn"
                                    onclick="openEditMenuModal(<%=m.getMenuId()%>)">Edit</button>
                            <button type="button" class="action-btn-sm menu-delete-btn"
                                    onclick="deleteMenuItem(<%=m.getMenuId()%>)">Delete</button>
                        </td>
                    </tr>
                <% } } else { %>
                    <tr id="empty-menu-row"><td colspan="6">No menu items found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- USERS SECTION (WITH 4-CARD ROLE BREAKDOWN) -->
    <section class="admin-tab-hidden" id="adminUsersSection">
        <div class="user-dir-header">
            <div>
                <h2 class="user-dir-main-title">Manage Users</h2>
                <p class="user-dir-desc">View and manage your QuickBite customer accounts and team members.</p>
            </div>

        </div>

        <!-- 4 Stat Cards Matching Restaurants/Menus Format -->
        <div class="admin-stats-grid users-role-grid">
            <div class="admin-stat-card">
                <div class="admin-stat-icon">&#128100;</div>
                <div>
                    <div class="stat-label">Total Users</div>
                    <div class="stat-value" id="cardTotalUsers"><%=totalUsersCount%></div>
                </div>
            </div>

            <div class="admin-stat-card">
                <div class="admin-stat-icon">🛍️</div>
                <div>
                    <div class="stat-label">Customers</div>
                    <div class="stat-value" id="cardCustomerCount"><%=customerCount%></div>
                </div>
            </div>

            <div class="admin-stat-card">
                <div class="admin-stat-icon">🛵</div>
                <div>
                    <div class="stat-label">Delivery Agents</div>
                    <div class="stat-value" id="cardDeliveryCount"><%=deliveryPartnerCount%></div>
                </div>
            </div>

            <div class="admin-stat-card">
                <div class="admin-stat-icon">👑</div>
                <div>
                    <div class="stat-label">Admins</div>
                    <div class="stat-value" id="cardAdminCount"><%=adminCount%></div>
                </div>
            </div>
        </div>

        <div class="user-directory-card">
            <div class="user-directory-header">
                <h3 class="user-directory-title">Customer Directory</h3>
                <p class="user-directory-subtitle">Customer account information</p>
            </div>

            <div class="user-search-bar">
                <input type="text" 
                       id="userSearchInput" 
                       class="user-search-input" 
                       placeholder="Search username, email, or phone..." 
                       onkeyup="filterUsersTable()">
                <button type="button" class="btn-user-search" onclick="filterUsersTable()">Search</button>
                <button type="button" class="btn-user-clear" onclick="clearUserFilter()">Clear</button>
            </div>

            <div class="admin-table-wrapper">
                <table class="users-styled-table" id="usersTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Address</th>
                            <th>Role</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (users != null && !users.isEmpty()) {
                        for (User u : users) {
                            String role = u.getRole() == null ? "CUSTOMER" : u.getRole().toUpperCase(Locale.ROOT);
                            String roleClass = "customer";
                            String roleKey = "customer";
                            if (role.contains("ADMIN")) {
                                roleClass = "admin";
                                roleKey = "admin";
                            } else if (role.contains("DELIVER") || role.contains("AGENT")) {
                                roleClass = "delivery";
                                roleKey = "delivery";
                            }
                    %>
                        <tr class="user-table-row" id="user-row-<%=u.getUserId()%>" data-role="<%=roleKey%>">
                            <td><strong>#<%=u.getUserId()%></strong></td>
                            <td class="user-col-username"><strong><%=u.getUsername()%></strong></td>
                            <td class="user-col-email"><%=u.getEmail()%></td>
                            <td class="user-col-phone"><%=u.getPhone() == null || u.getPhone().trim().isEmpty() ? "—" : u.getPhone()%></td>
                            <td><%=u.getAddress() == null || u.getAddress().trim().isEmpty() ? "—" : u.getAddress()%></td>
                            <td><span class="user-role-badge <%=roleClass%>"><%=role%></span></td>
                            <td>
                                <div class="user-actions">
                                    <button type="button" class="user-del-btn" onclick="deleteUserRow(<%=u.getUserId()%>)">Delete</button>
                                    <a href="<%=contextPath%>/orders?userId=<%=u.getUserId()%>" class="user-orders-btn">View Orders</a>
                                </div>
                            </td>
                        </tr>
                    <% } } else { %>
                        <tr id="empty-user-row"><td colspan="7" style="text-align: center; color: #8c7e75; padding: 24px;">No customer records found.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</main>

<!-- ADD RESTAURANT MODAL -->
<div id="addRestaurantModal" class="admin-modal-overlay" style="display:none">
    <div class="admin-modal-card">
        <div class="admin-modal-header">
            <h3>Add New Restaurant</h3>
            <button type="button" class="admin-modal-close" onclick="closeAddRestaurantModal()">×</button>
        </div>
        <form action="<%=contextPath%>/adminDashboard" method="post">
            <input type="hidden" name="action" value="addRestaurant">
            <div class="admin-form-group"><label>Restaurant Name *</label><input name="name" required></div>
            <div class="admin-form-grid">
                <div class="admin-form-group"><label>Cuisine *</label><input name="cuisineType" required></div>
                <div class="admin-form-group"><label>Delivery Time</label><input name="deliveryTime" value="30-40 mins" required></div>
            </div>
            <div class="admin-form-group"><label>Address *</label><textarea name="address" required rows="2"></textarea></div>
            <div class="admin-form-grid">
                <div class="admin-form-group"><label>Rating</label><input type="number" name="rating" step="0.1" min="1" max="5" value="4.5"></div>
                <div class="admin-form-group"><label>Image URL</label><input type="url" name="imagePath"></div>
            </div>
            <div class="admin-modal-actions">
                <button type="button" class="admin-nav-btn secondary" onclick="closeAddRestaurantModal()">Cancel</button>
                <button type="submit" class="admin-nav-btn primary">Save Restaurant</button>
            </div>
        </form>
    </div>
</div>

<!-- ADD MENU MODAL -->
<div id="addMenuModal" class="admin-modal-overlay" style="display:none">
    <div class="admin-modal-card">
        <div class="admin-modal-header">
            <h3>Add New Dish</h3>
            <button type="button" class="admin-modal-close" onclick="closeAddMenuModal()">×</button>
        </div>
        <form action="<%=contextPath%>/adminDashboard" method="post">
            <input type="hidden" name="action" value="addMenu">
            <div class="admin-form-group">
                <label>Restaurant *</label>
                <select name="restaurantId" required>
                    <% if (restaurants != null) for (Restaurant r : restaurants) { %>
                        <option value="<%=r.getRestaurantId()%>"><%=r.getName()%> (#<%=r.getRestaurantId()%>)</option>
                    <% } %>
                </select>
            </div>
            <div class="admin-form-group"><label>Dish Name *</label><input name="itemName" required></div>
            <div class="admin-form-grid">
                <div class="admin-form-group"><label>Price (₹) *</label><input type="number" name="price" min="0.01" step="0.01" required></div>
                <div class="admin-form-group"><label>Image URL</label><input type="url" name="imagePath"></div>
            </div>
            <div class="admin-form-group"><label>Description</label><textarea name="description" rows="2"></textarea></div>
            <div class="admin-form-group">
                <label>Availability</label>
                <select name="isAvailable">
                    <option value="true">Available</option>
                    <option value="false">Unavailable</option>
                </select>
            </div>
            <div class="admin-modal-actions">
                <button type="button" class="admin-nav-btn secondary" onclick="closeAddMenuModal()">Cancel</button>
                <button type="submit" class="admin-nav-btn primary">Add Dish</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT MENU MODAL -->
<div id="editMenuModal" class="admin-modal-overlay" style="display:none">
    <div class="admin-modal-card">
        <div class="admin-modal-header">
            <h3>Edit Menu Item</h3>
            <button type="button" class="admin-modal-close" onclick="closeEditMenuModal()">×</button>
        </div>
        <form id="editMenuForm">
            <input type="hidden" name="action" value="updateMenu">
            <input type="hidden" name="ajax" value="true">
            <input type="hidden" name="menuId" id="editMenuId">

            <div class="admin-form-group">
                <label>Restaurant *</label>
                <select name="restaurantId" id="editRestaurantId" required>
                    <% if (restaurants != null) for (Restaurant r : restaurants) { %>
                        <option value="<%=r.getRestaurantId()%>"><%=r.getName()%> (#<%=r.getRestaurantId()%>)</option>
                    <% } %>
                </select>
            </div>
            <div class="admin-form-group"><label>Dish Name *</label><input name="itemName" id="editItemName" required></div>
            <div class="admin-form-grid">
                <div class="admin-form-group"><label>Price (₹) *</label><input type="number" name="price" id="editPrice" min="0.01" step="0.01" required></div>
                <div class="admin-form-group"><label>Image URL</label><input type="url" name="imagePath" id="editImagePath"></div>
            </div>
            <div class="admin-form-group"><label>Description</label><textarea name="description" id="editDescription" rows="3"></textarea></div>
            <div class="admin-form-group">
                <label>Availability</label>
                <select name="isAvailable" id="editIsAvailable">
                    <option value="true">Available</option>
                    <option value="false">Unavailable</option>
                </select>
            </div>
            <div class="admin-modal-actions">
                <button type="button" class="admin-nav-btn secondary" onclick="closeEditMenuModal()">Cancel</button>
                <button type="submit" id="saveMenuButton" class="admin-nav-btn primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<div id="adminToast" class="admin-toast" role="status"></div>

<%@ include file="footer.jsp" %>

<script>
const contextPath = "<%=contextPath%>";

const tabs = ["orders", "restaurants", "menus", "users"];
const tabCache = {};

function initTabCache() {
    tabs.forEach(function(t) {
        tabCache[t] = {
            section: document.getElementById("admin" + t.charAt(0).toUpperCase() + t.slice(1) + "Section"),
            button: document.getElementById("tab" + t.charAt(0).toUpperCase() + t.slice(1) + "Btn")
        };
    });
}

function switchAdminTab(targetTab) {
    if (!tabCache["orders"]) initTabCache();

    for (let i = 0; i < tabs.length; i++) {
        const t = tabs[i];
        const item = tabCache[t];
        const isTarget = (t === targetTab);

        if (item && item.section) {
            if (isTarget) {
                item.section.classList.remove("admin-tab-hidden");
                item.section.classList.add("admin-tab-visible");
            } else {
                item.section.classList.remove("admin-tab-visible");
                item.section.classList.add("admin-tab-hidden");
            }
        }

        if (item && item.button) {
            item.button.classList.toggle("active", isTarget);
        }
    }

    try {
        sessionStorage.setItem("activeAdminTab", targetTab);
    } catch (e) {}
}

/* User Directory Search Function */
function filterUsersTable() {
    const q = (document.getElementById("userSearchInput").value || "").toLowerCase().trim();
    const rows = document.querySelectorAll("#usersTable tbody tr.user-table-row");
    let matchCount = 0;

    rows.forEach(function(row) {
        const u = row.querySelector(".user-col-username")?.textContent.toLowerCase() || "";
        const e = row.querySelector(".user-col-email")?.textContent.toLowerCase() || "";
        const p = row.querySelector(".user-col-phone")?.textContent.toLowerCase() || "";

        if (u.includes(q) || e.includes(q) || p.includes(q)) {
            row.style.display = "";
            matchCount++;
        } else {
            row.style.display = "none";
        }
    });

    const emptyRow = document.getElementById("empty-user-row");
    if (emptyRow) {
        emptyRow.style.display = matchCount === 0 ? "" : "none";
    }
}

function clearUserFilter() {
    const input = document.getElementById("userSearchInput");
    if (input) {
        input.value = "";
        filterUsersTable();
    }
}

/* Delete user from the database, then update the directory and counters. */
async function deleteUserRow(userId) {
    if (!confirm("Are you sure you want to permanently delete user #" + userId + "?")) return;

    const targetRow = document.getElementById("user-row-" + userId);
    if (!targetRow) {
        showToast("User row was not found. Refresh the page and try again.", false);
        return;
    }

    const deleteButton = targetRow.querySelector(".user-del-btn");
    if (deleteButton) {
        deleteButton.disabled = true;
        deleteButton.textContent = "Deleting...";
    }

    try {
        await postAdminAction({
            action: "deleteUser",
            userId: userId,
            ajax: "true"
        });

        const role = targetRow.getAttribute("data-role");
        targetRow.remove();

        const totalCard = document.getElementById("cardTotalUsers");
        if (totalCard) {
            const newTotal = Math.max(0, (parseInt(totalCard.textContent, 10) || 0) - 1);
            totalCard.textContent = newTotal;
            const tabCounter = document.getElementById("userTabCount");
            if (tabCounter) tabCounter.textContent = newTotal;
        }

        if (role === "admin") {
            const card = document.getElementById("cardAdminCount");
            if (card) card.textContent = Math.max(0, (parseInt(card.textContent, 10) || 0) - 1);
        } else if (role === "delivery") {
            const card = document.getElementById("cardDeliveryCount");
            if (card) card.textContent = Math.max(0, (parseInt(card.textContent, 10) || 0) - 1);
        } else {
            const card = document.getElementById("cardCustomerCount");
            if (card) card.textContent = Math.max(0, (parseInt(card.textContent, 10) || 0) - 1);
        }

        const tbody = document.querySelector("#usersTable tbody");
        const remainingRows = tbody ? tbody.querySelectorAll("tr.user-table-row") : [];
        let emptyRow = document.getElementById("empty-user-row");

        if (remainingRows.length === 0 && tbody) {
            if (!emptyRow) {
                emptyRow = document.createElement("tr");
                emptyRow.id = "empty-user-row";
                emptyRow.innerHTML = '<td colspan="7" style="text-align:center;color:#8c7e75;padding:24px;">No customer records found.</td>';
                tbody.appendChild(emptyRow);
            }
            emptyRow.style.display = "";
        }

        showToast("User #" + userId + " deleted successfully.", true);
    } catch (error) {
        showToast(error.message || "Could not delete this user.", false);
        if (deleteButton) {
            deleteButton.disabled = false;
            deleteButton.textContent = "Delete";
        }
    }
}

function showToast(message, success) {
    const toast = document.getElementById("adminToast");
    toast.textContent = message;
    toast.className = "admin-toast " + (success ? "success" : "error") + " visible";
    clearTimeout(showToast.timer);
    showToast.timer = setTimeout(function() {
        toast.classList.remove("visible");
    }, 3500);
}

function openAddRestaurantModal() {
    document.getElementById("addRestaurantModal").style.display = "flex";
}
function closeAddRestaurantModal() {
    document.getElementById("addRestaurantModal").style.display = "none";
}
function openAddMenuModal() {
    document.getElementById("addMenuModal").style.display = "flex";
}
function closeAddMenuModal() {
    document.getElementById("addMenuModal").style.display = "none";
}
function closeEditMenuModal() {
    document.getElementById("editMenuModal").style.display = "none";
}

async function postAdminAction(values) {
    const body = new URLSearchParams();
    Object.keys(values).forEach(function(key) {
        body.append(key, values[key]);
    });

    const response = await fetch(contextPath + "/adminDashboard", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
            "X-Requested-With": "XMLHttpRequest",
            "Accept": "application/json"
        },
        body: body.toString()
    });

    let result;
    try {
        result = await response.json();
    } catch (e) {
        throw new Error("The server returned an invalid response. Check the server console.");
    }

    if (!response.ok || !result.success) {
        throw new Error(result.message || "The operation failed.");
    }
    return result;
}

function updateMenuStats() {
    const rows = Array.from(document.querySelectorAll("#menuTableBody tr[data-menu-id]"));
    let available = 0;

    rows.forEach(function(row) {
        if (row.dataset.available === "true") available++;
    });

    const total = rows.length;
    document.getElementById("totalMenuItems").textContent = total;
    document.getElementById("availableMenuItems").textContent = available;
    document.getElementById("unavailableMenuItems").textContent = total - available;
    document.getElementById("menuTabCount").textContent = total;
}

function updateRestaurantStats() {
    const rows = Array.from(document.querySelectorAll("#adminRestaurantsSection tbody tr[id^='restaurant-row-']"));
    const active = rows.filter(function(row) {
        const badge = row.querySelector(".status-pill");
        return badge && badge.textContent.trim() === "OPEN";
    }).length;

    document.getElementById("totalRestaurantCount").textContent = rows.length;
    document.getElementById("activeRestaurantCount").textContent = active;
    document.getElementById("inactiveRestaurantCount").textContent = rows.length - active;
    document.getElementById("restaurantTabCount").textContent = rows.length;
    document.getElementById("activeRestaurantStat").textContent = active;
}

function openEditMenuModal(menuId) {
    const row = document.getElementById("menu-row-" + menuId);
    if (!row) return;

    document.getElementById("editMenuId").value = menuId;
    document.getElementById("editRestaurantId").value = row.dataset.restaurantId;
    document.getElementById("editItemName").value = row.dataset.itemName || "";
    document.getElementById("editDescription").value = row.dataset.description || "";
    document.getElementById("editImagePath").value = row.dataset.imagePath || "";
    document.getElementById("editPrice").value = row.dataset.price || "";
    document.getElementById("editIsAvailable").value = row.dataset.available;

    document.getElementById("editMenuModal").style.display = "flex";
}

document.getElementById("editMenuForm").addEventListener("submit", async function(event) {
    event.preventDefault();

    const button = document.getElementById("saveMenuButton");
    button.disabled = true;
    button.textContent = "Saving...";

    try {
        const values = Object.fromEntries(new FormData(this).entries());
        const result = await postAdminAction(values);
        const row = document.getElementById("menu-row-" + result.menuId);

        if (!row) throw new Error("The menu row was not found. Refresh the page.");

        row.dataset.restaurantId = result.restaurantId;
        row.dataset.itemName = result.itemName || "";
        row.dataset.description = result.description || "";
        row.dataset.imagePath = result.imagePath || "";
        row.dataset.restaurantName = result.restaurantName || "";
        row.dataset.price = result.price;
        row.dataset.available = String(result.isAvailable);

        row.querySelector(".menu-name").textContent = result.itemName || "";
        row.querySelector(".menu-description").textContent = result.description || "";
        row.querySelector(".menu-restaurant").textContent =
            "#" + result.restaurantId + " " + (result.restaurantName || "");
        row.querySelector(".menu-price").textContent = "₹" + Number(result.price).toFixed(2);

        const image = row.querySelector(".admin-menu-image");
        const fallback = image ? image.nextElementSibling : null;
        if (image) {
            image.onerror = function() {
                image.onerror = null;
                image.style.display = "none";
                if (fallback) fallback.style.display = "flex";
            };
            if (result.imagePath) {
                image.style.display = "block";
                image.src = result.imagePath;
            } else {
                image.style.display = "none";
                if (fallback) fallback.style.display = "flex";
            }
        }
        if (fallback && result.imagePath) fallback.style.display = "none";

        const badge = document.getElementById("menu-badge-" + result.menuId);
        badge.textContent = result.isAvailable ? "AVAILABLE" : "UNAVAILABLE";
        badge.className = "status-pill " + (result.isAvailable ? "delivered" : "cancelled");

        const toggle = document.getElementById("menu-btn-" + result.menuId);
        toggle.textContent = result.isAvailable ? "Mark Unavailable" : "Mark Available";
        toggle.className = "action-btn-sm availability-toggle " +
            (result.isAvailable ? "toggle-off" : "toggle-on");

        updateMenuStats();
        closeEditMenuModal();
        showToast("Menu item updated successfully.", true);
    } catch (error) {
        showToast(error.message, false);
    } finally {
        button.disabled = false;
        button.textContent = "Save Changes";
    }
});

async function deleteMenuItem(menuId) {
    if (!confirm("Delete this menu item permanently? This action cannot be undone.")) return;

    try {
        await postAdminAction({action: "deleteMenu", menuId: menuId, ajax: "true"});

        const row = document.getElementById("menu-row-" + menuId);
        if (row) row.remove();

        const body = document.getElementById("menuTableBody");
        if (!body.querySelector("tr[data-menu-id]")) {
            body.innerHTML = '<tr id="empty-menu-row"><td colspan="6">No menu items found.</td></tr>';
        }

        updateMenuStats();
        showToast("Menu item deleted successfully.", true);
    } catch (error) {
        showToast(error.message || "Could not delete this menu item.", false);
    }
}

async function toggleMenuAvailable(menuId) {
    const button = document.getElementById("menu-btn-" + menuId);
    button.disabled = true;

    try {
        const result = await postAdminAction({
            action: "toggleMenu",
            menuId: menuId,
            ajax: "true"
        });

        const row = document.getElementById("menu-row-" + menuId);
        row.dataset.available = String(result.isAvailable);

        const badge = document.getElementById("menu-badge-" + menuId);
        badge.textContent = result.isAvailable ? "AVAILABLE" : "UNAVAILABLE";
        badge.className = "status-pill " + (result.isAvailable ? "delivered" : "cancelled");

        button.textContent = result.isAvailable ? "Mark Unavailable" : "Mark Available";
        button.className = "action-btn-sm availability-toggle " +
            (result.isAvailable ? "toggle-off" : "toggle-on");

        updateMenuStats();
        showToast("Menu availability updated.", true);
    } catch (error) {
        showToast(error.message, false);
    } finally {
        button.disabled = false;
    }
}

async function toggleRestaurantActive(restaurantId) {
    const button = document.getElementById("rest-btn-" + restaurantId);
    button.disabled = true;

    try {
        const result = await postAdminAction({
            action: "toggleRestaurant",
            restaurantId: restaurantId,
            ajax: "true"
        });

        const badge = document.getElementById("rest-badge-" + restaurantId);
        badge.textContent = result.isActive ? "OPEN" : "CLOSED";
        badge.className = "status-pill " + (result.isActive ? "delivered" : "cancelled");

        button.textContent = result.isActive ? "Close Outlet" : "Open Outlet";
        button.className = "action-btn-sm " + (result.isActive ? "toggle-off" : "toggle-on");

        updateRestaurantStats();
        showToast("Restaurant status updated.", true);
    } catch (error) {
        showToast(error.message, false);
    } finally {
        button.disabled = false;
    }
}

async function updateOrderStatus(orderId, status) {
    try {
        await postAdminAction({
            action: "updateOrderStatus",
            orderId: orderId,
            status: status,
            ajax: "true"
        });

        const pill = document.getElementById("pill-" + orderId);
        pill.textContent = status;
        pill.className = "status-pill " +
            (status.includes("PREPAR") ? "preparing" :
            status.includes("OUT") ? "out-for-delivery" :
            status.includes("DELIVER") ? "delivered" :
            status.includes("CANCEL") ? "cancelled" : "placed");

        showToast("Order status updated.", true);
    } catch (error) {
        showToast(error.message, false);
    }
}

document.addEventListener("DOMContentLoaded", function() {
    initTabCache();
    try {
        const savedTab = sessionStorage.getItem("activeAdminTab");
        if (savedTab && tabs.includes(savedTab)) {
            switchAdminTab(savedTab);
        }
    } catch (e) {}
});
</script>

</body>
</html>
