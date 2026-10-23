<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Locale"%>
<%@ page import="com.tap.model.Order"%>
<%@ page import="com.tap.model.Restaurant"%>
<%@ page import="com.tap.model.Menu"%>
<%@ page import="com.tap.model.User"%>

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
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard | QuickBite</title>

<link rel="stylesheet" href="<%=contextPath%>/CSS/common.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/navbar.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/adminDashboard.css?v=<%=System.currentTimeMillis()%>">
<link rel="stylesheet" href="<%=contextPath%>/CSS/footer.css">
</head>

<body class="admin-body">

	<%@ include file="navbar.jsp"%>

	<!-- Header Banner -->
	<header class="admin-header">
		<div class="container admin-header-row">
			<div class="admin-title-area">
				<h1>
					👑 QuickBite Operations Console
					<span class="admin-badge">Administrator</span>
				</h1>
				<p>
					Welcome back, <strong><%=user != null ? user.getUsername() : "Admin"%></strong>!
					Manage live orders, restaurants, menus and delivery partners.
				</p>
			</div>

			<div class="admin-header-actions">
				<a href="<%=contextPath%>/restaurant" class="admin-nav-btn secondary">
					🍽️ View Customer Site
				</a>
				<button type="button" class="admin-nav-btn primary" onclick="openAddRestaurantModal()">
					+ Add Restaurant
				</button>
				<button type="button" class="admin-nav-btn primary" onclick="openAddMenuModal()">
					+ Add Dish
				</button>
			</div>
		</div>
	</header>

	<main class="container" style="padding-top: 25px; padding-bottom: 50px;">

		<!-- KPI Stats Grid -->
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
					<div class="stat-value"><%=orders != null ? orders.size() : 0%></div>
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
					<div class="stat-label">Active Kitchens</div>
					<div class="stat-value"><%=activeRestaurantsCount%></div>
				</div>
			</div>

			<div class="admin-stat-card">
				<div class="admin-stat-icon">🛵</div>
				<div>
					<div class="stat-label">Delivery Fleet</div>
					<div class="stat-value"><%=deliveryPartners != null ? deliveryPartners.size() : 0%></div>
				</div>
			</div>
		</section>

		<!-- Tabs Bar -->
		<nav class="admin-tabs-nav">
			<button type="button" class="admin-tab-btn active" id="tabOrdersBtn" onclick="switchAdminTab('orders')">
				📋 Orders Management (<%=orders != null ? orders.size() : 0%>)
			</button>
			<button type="button" class="admin-tab-btn" id="tabRestaurantsBtn" onclick="switchAdminTab('restaurants')">
				🍽️ Restaurants (<%=restaurants != null ? restaurants.size() : 0%>)
			</button>
			<button type="button" class="admin-tab-btn" id="tabMenusBtn" onclick="switchAdminTab('menus')">
				📜 Menu Items (<%=menus != null ? menus.size() : 0%>)
			</button>
			<button type="button" class="admin-tab-btn" id="tabUsersBtn" onclick="switchAdminTab('users')">
				👥 Users &amp; Partners (<%=users != null ? users.size() : 0%>)
			</button>
		</nav>

		<!-- 1. ORDERS TAB -->
		<section class="admin-card" id="adminOrdersSection">
			<div class="admin-card-header">
				<h2 class="admin-card-title">Live Orders &amp; Dispatch</h2>
				<span style="font-size: 13px; color: var(--admin-muted);">
					Update order status in real-time or assign delivery partners
				</span>
			</div>

			<div class="admin-table-wrapper">
				<table class="admin-table">
					<thead>
						<tr>
							<th>Order ID</th>
							<th>Date &amp; Time</th>
							<th>Total</th>
							<th>Payment</th>
							<th>Delivery Address</th>
							<th>Current Status</th>
							<th>Update Status</th>
							<th>Action</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (orders != null && !orders.isEmpty()) {
							for (Order ord : orders) {
								String st = ord.getStatus() != null ? ord.getStatus().toUpperCase() : "PLACED";
								String pillClass = "placed";
								if (st.contains("PREPAR")) pillClass = "preparing";
								else if (st.contains("WAY") || st.contains("OUT")) pillClass = "out-for-delivery";
								else if (st.contains("DELIVER")) pillClass = "delivered";
								else if (st.contains("CANCEL")) pillClass = "cancelled";
						%>
						<tr id="order-row-<%=ord.getOrderId()%>">
							<td><strong>#QB-<%=ord.getOrderId()%></strong></td>
							<td><%=ord.getOrderDate() != null ? ord.getOrderDate().toString().substring(0, Math.min(16, ord.getOrderDate().toString().length())) : "Recent"%></td>
							<td><strong>₹<%=String.format(Locale.ROOT, "%.2f", ord.getTotalAmount())%></strong></td>
							<td><%=ord.getPaymentMode() != null ? ord.getPaymentMode() : "COD"%></td>
							<td style="max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<%=ord.getDeliveryAddress()%>">
								<%=ord.getDeliveryAddress() != null ? ord.getDeliveryAddress() : "Bangalore"%>
							</td>
							<td>
								<span class="status-pill <%=pillClass%>" id="pill-<%=ord.getOrderId()%>"><%=st%></span>
							</td>
							<td>
								<select class="status-select" onchange="updateOrderStatus(<%=ord.getOrderId()%>, this.value)">
									<option value="PLACED" <%="PLACED".equals(st) ? "selected" : ""%>>Placed</option>
									<option value="PREPARING" <%="PREPARING".equals(st) ? "selected" : ""%>>Preparing</option>
									<option value="OUT FOR DELIVERY" <%="OUT FOR DELIVERY".equals(st) ? "selected" : ""%>>Out for Delivery</option>
									<option value="DELIVERED" <%="DELIVERED".equals(st) ? "selected" : ""%>>Delivered</option>
									<option value="CANCELLED" <%="CANCELLED".equals(st) ? "selected" : ""%>>Cancelled</option>
								</select>
							</td>
							<td>
								<a href="<%=contextPath%>/orderDetails?orderId=<%=ord.getOrderId()%>" class="action-btn-sm" style="background:#f0f0f0; text-decoration:none; color:#333;">
									👁️ View Map
								</a>
							</td>
						</tr>
						<%
							}
						} else {
						%>
						<tr>
							<td colspan="8" style="text-align:center; padding: 25px; color:#888;">No orders recorded yet.</td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>
		</section>

		<!-- 2. RESTAURANTS TAB -->
		<section class="admin-card" id="adminRestaurantsSection" style="display: none;">
			<div class="admin-card-header">
				<h2 class="admin-card-title">Restaurant Outlets</h2>
				<button type="button" class="action-btn-sm add" onclick="openAddRestaurantModal()">
					+ Add New Restaurant
				</button>
			</div>

			<div class="admin-table-wrapper">
				<table class="admin-table">
					<thead>
						<tr>
							<th>ID</th>
							<th>Restaurant</th>
							<th>Cuisine</th>
							<th>Delivery Time</th>
							<th>Rating</th>
							<th>Address</th>
							<th>Live State</th>
							<th>Toggle Open/Close</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (restaurants != null && !restaurants.isEmpty()) {
							for (Restaurant r : restaurants) {
						%>
						<tr>
							<td><strong>#<%=r.getRestaurantId()%></strong></td>
							<td>
								<strong><%=r.getName()%></strong>
							</td>
							<td><%=r.getCuisineType()%></td>
							<td>⏱️ <%=r.getDeliveryTime()%></td>
							<td>⭐ <%=r.getRating()%></td>
							<td style="max-width: 180px;"><%=r.getAddress()%></td>
							<td>
								<span class="status-pill <%=r.isActive() ? "delivered" : "cancelled"%>" id="rest-badge-<%=r.getRestaurantId()%>">
									<%=r.isActive() ? "● OPEN" : "● CLOSED"%>
								</span>
							</td>
							<td>
								<button type="button" class="action-btn-sm <%=r.isActive() ? "toggle-off" : "toggle-on"%>"
									id="rest-btn-<%=r.getRestaurantId()%>"
									onclick="toggleRestaurantActive(<%=r.getRestaurantId()%>)">
									<%=r.isActive() ? "Close Outlet" : "Open Outlet"%>
								</button>
								<a href="<%=contextPath%>/menu?restaurantId=<%=r.getRestaurantId()%>" class="action-btn-sm" style="background:#eee; text-decoration:none; color:#333; margin-left:6px;">
									View Menu
								</a>
							</td>
						</tr>
						<%
							}
						}
						%>
					</tbody>
				</table>
			</div>
		</section>

		<!-- 3. MENUS TAB -->
		<section class="admin-card" id="adminMenusSection" style="display: none;">
			<div class="admin-card-header">
				<h2 class="admin-card-title">Dish Catalog &amp; Pricing</h2>
				<button type="button" class="action-btn-sm add" onclick="openAddMenuModal()">
					+ Add New Dish
				</button>
			</div>

			<div class="admin-table-wrapper">
				<table class="admin-table">
					<thead>
						<tr>
							<th>Dish ID</th>
							<th>Item Name</th>
							<th>Rest. ID</th>
							<th>Price</th>
							<th>Availability</th>
							<th>Toggle Status</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (menus != null && !menus.isEmpty()) {
							for (Menu m : menus) {
						%>
						<tr>
							<td><strong>#<%=m.getMenuId()%></strong></td>
							<td>
								<strong><%=m.getItemName()%></strong>
								<div style="font-size:11px; color:#888;"><%=m.getDescription() != null ? m.getDescription() : ""%></div>
							</td>
							<td>#<%=m.getRestaurantId()%></td>
							<td><strong>₹<%=String.format(Locale.ROOT, "%.2f", m.getPrice())%></strong></td>
							<td>
								<span class="status-pill <%=m.isAvailable() ? "delivered" : "cancelled"%>" id="menu-badge-<%=m.getMenuId()%>">
									<%=m.isAvailable() ? "AVAILABLE" : "OUT OF STOCK"%>
								</span>
							</td>
							<td>
								<button type="button" class="action-btn-sm <%=m.isAvailable() ? "toggle-off" : "toggle-on"%>"
									id="menu-btn-<%=m.getMenuId()%>"
									onclick="toggleMenuAvailable(<%=m.getMenuId()%>)">
									<%=m.isAvailable() ? "Mark Unavailable" : "Mark Available"%>
								</button>
							</td>
						</tr>
						<%
							}
						}
						%>
					</tbody>
				</table>
			</div>
		</section>

		<!-- 4. USERS TAB -->
		<section class="admin-card" id="adminUsersSection" style="display: none;">
			<div class="admin-card-header">
				<h2 class="admin-card-title">Platform Users, Admins &amp; Delivery Partners</h2>
			</div>

			<div class="admin-table-wrapper">
				<table class="admin-table">
					<thead>
						<tr>
							<th>User ID</th>
							<th>Name</th>
							<th>Email</th>
							<th>Phone</th>
							<th>Role</th>
							<th>Address</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (users != null && !users.isEmpty()) {
							for (User u : users) {
								String r = u.getRole() != null ? u.getRole().toLowerCase() : "customer";
								String badgeClass = "placed";
								if (r.contains("admin")) badgeClass = "delivered";
								else if (r.contains("deliver") || r.contains("agent")) badgeClass = "out-for-delivery";
						%>
						<tr>
							<td><strong>#<%=u.getUserId()%></strong></td>
							<td><strong><%=u.getUsername()%></strong></td>
							<td><%=u.getEmail()%></td>
							<td><%=u.getPhone() != null ? u.getPhone() : "-"%></td>
							<td><span class="status-pill <%=badgeClass%>"><%=u.getRole()%></span></td>
							<td style="max-width: 200px;"><%=u.getAddress() != null ? u.getAddress() : "-"%></td>
						</tr>
						<%
							}
						}
						%>
					</tbody>
				</table>
			</div>
		</section>

	</main>

	<!-- ADD RESTAURANT MODAL -->
	<div id="addRestaurantModal" class="admin-modal-overlay" style="display: none;">
		<div class="admin-modal-card">
			<div class="admin-modal-header">
				<h3 style="margin: 0; font-size: 18px; font-weight: 800;">Add New Restaurant</h3>
				<button type="button" class="admin-modal-close" onclick="closeAddRestaurantModal()">×</button>
			</div>
			<form action="<%=contextPath%>/adminDashboard" method="post">
				<input type="hidden" name="action" value="addRestaurant">
				<div class="admin-form-group">
					<label>Restaurant Name *</label>
					<input type="text" name="name" required placeholder="e.g. Royal Biryani House">
				</div>
				<div class="admin-form-grid">
					<div class="admin-form-group">
						<label>Cuisine Type *</label>
						<input type="text" name="cuisineType" required placeholder="e.g. Biryani, South Indian">
					</div>
					<div class="admin-form-group">
						<label>Delivery Time *</label>
						<input type="text" name="deliveryTime" required value="30-40 mins">
					</div>
				</div>
				<div class="admin-form-group">
					<label>Full Address *</label>
					<textarea name="address" rows="2" required placeholder="e.g. 100 Feet Road, Indiranagar, Bangalore"></textarea>
				</div>
				<div class="admin-form-grid">
					<div class="admin-form-group">
						<label>Rating (1.0 - 5.0)</label>
						<input type="number" name="rating" step="0.1" min="1.0" max="5.0" value="4.5">
					</div>
					<div class="admin-form-group">
						<label>Image URL (Optional)</label>
						<input type="url" name="imagePath" placeholder="https://images.unsplash.com/...">
					</div>
				</div>
				<div style="margin-top: 20px; text-align: right;">
					<button type="button" class="admin-nav-btn secondary" style="color:#444;" onclick="closeAddRestaurantModal()">Cancel</button>
					<button type="submit" class="admin-nav-btn primary">Save Restaurant</button>
				</div>
			</form>
		</div>
	</div>

	<!-- ADD MENU ITEM MODAL -->
	<div id="addMenuModal" class="admin-modal-overlay" style="display: none;">
		<div class="admin-modal-card">
			<div class="admin-modal-header">
				<h3 style="margin: 0; font-size: 18px; font-weight: 800;">Add New Dish</h3>
				<button type="button" class="admin-modal-close" onclick="closeAddMenuModal()">×</button>
			</div>
			<form action="<%=contextPath%>/adminDashboard" method="post">
				<input type="hidden" name="action" value="addMenu">
				<div class="admin-form-group">
					<label>Select Restaurant *</label>
					<select name="restaurantId" required>
						<%
						if (restaurants != null) {
							for (Restaurant r : restaurants) {
						%>
						<option value="<%=r.getRestaurantId()%>"><%=r.getName()%> (#<%=r.getRestaurantId()%>)</option>
						<%
							}
						}
						%>
					</select>
				</div>
				<div class="admin-form-group">
					<label>Dish Name *</label>
					<input type="text" name="itemName" required placeholder="e.g. Butter Chicken Masala">
				</div>
				<div class="admin-form-grid">
					<div class="admin-form-group">
						<label>Price (₹) *</label>
						<input type="number" name="price" step="0.5" min="1" required placeholder="240.00">
					</div>
					<div class="admin-form-group">
						<label>Image URL (Optional)</label>
						<input type="url" name="imagePath" placeholder="https://images.unsplash.com/...">
					</div>
				</div>
				<div class="admin-form-group">
					<label>Description</label>
					<textarea name="description" rows="2" placeholder="Rich gravy cooked with tender chicken pieces..."></textarea>
				</div>
				<div style="margin-top: 20px; text-align: right;">
					<button type="button" class="admin-nav-btn secondary" style="color:#444;" onclick="closeAddMenuModal()">Cancel</button>
					<button type="submit" class="admin-nav-btn primary">Add to Menu</button>
				</div>
			</form>
		</div>
	</div>

	<%@ include file="footer.jsp"%>

	<script>
		const contextPath = "<%=contextPath%>";

		function switchAdminTab(tab) {
			const tabs = ["orders", "restaurants", "menus", "users"];
			tabs.forEach(t => {
				const section = document.getElementById("admin" + capitalize(t) + "Section");
				const btn = document.getElementById("tab" + capitalize(t) + "Btn");
				if (section) section.style.display = (t === tab) ? "block" : "none";
				if (btn) btn.classList.toggle("active", t === tab);
			});
		}

		function capitalize(s) {
			return s.charAt(0).toUpperCase() + s.slice(1);
		}

		async function updateOrderStatus(orderId, newStatus) {
			const pill = document.getElementById("pill-" + orderId);
			if (pill) {
				pill.textContent = "Updating...";
			}

			try {
				const body = new URLSearchParams();
				body.append("action", "updateOrderStatus");
				body.append("orderId", orderId);
				body.append("status", newStatus);
				body.append("ajax", "true");

				const res = await fetch(contextPath + "/adminDashboard", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});

				const data = await res.json();
				if (data.success) {
					pill.textContent = newStatus;
					pill.className = "status-pill " + getPillClass(newStatus);
				} else {
					alert("Could not update status.");
				}
			} catch (e) {
				console.error(e);
				alert("Network error updating status.");
			}
		}

		function getPillClass(st) {
			st = st.toUpperCase();
			if (st.includes("PREPAR")) return "preparing";
			if (st.includes("OUT") || st.includes("WAY")) return "out-for-delivery";
			if (st.includes("DELIVER")) return "delivered";
			if (st.includes("CANCEL")) return "cancelled";
			return "placed";
		}

		async function toggleRestaurantActive(restId) {
			const btn = document.getElementById("rest-btn-" + restId);
			const badge = document.getElementById("rest-badge-" + restId);
			btn.disabled = true;

			try {
				const body = new URLSearchParams();
				body.append("action", "toggleRestaurant");
				body.append("restaurantId", restId);
				body.append("ajax", "true");

				const res = await fetch(contextPath + "/adminDashboard", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});
				const data = await res.json();
				if (data.success) {
					if (data.isActive) {
						badge.textContent = "● OPEN";
						badge.className = "status-pill delivered";
						btn.textContent = "Close Outlet";
						btn.className = "action-btn-sm toggle-off";
					} else {
						badge.textContent = "● CLOSED";
						badge.className = "status-pill cancelled";
						btn.textContent = "Open Outlet";
						btn.className = "action-btn-sm toggle-on";
					}
				}
			} catch (e) {
				alert("Error toggling outlet status.");
			} finally {
				btn.disabled = false;
			}
		}

		async function toggleMenuAvailable(menuId) {
			const btn = document.getElementById("menu-btn-" + menuId);
			const badge = document.getElementById("menu-badge-" + menuId);
			btn.disabled = true;

			try {
				const body = new URLSearchParams();
				body.append("action", "toggleMenu");
				body.append("menuId", menuId);
				body.append("ajax", "true");

				const res = await fetch(contextPath + "/adminDashboard", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});
				const data = await res.json();
				if (data.success) {
					if (data.isAvailable) {
						badge.textContent = "AVAILABLE";
						badge.className = "status-pill delivered";
						btn.textContent = "Mark Unavailable";
						btn.className = "action-btn-sm toggle-off";
					} else {
						badge.textContent = "OUT OF STOCK";
						badge.className = "status-pill cancelled";
						btn.textContent = "Mark Available";
						btn.className = "action-btn-sm toggle-on";
					}
				}
			} catch (e) {
				alert("Error toggling item availability.");
			} finally {
				btn.disabled = false;
			}
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
	</script>

</body>
</html>
