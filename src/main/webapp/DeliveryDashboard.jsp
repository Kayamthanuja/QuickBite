<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Locale"%>
<%@ page import="com.tap.model.Order"%>
<%@ page import="com.tap.model.Restaurant"%>
<%@ page import="com.tap.model.User"%>
<%@ page import="com.tap.util.GeoUtil"%>

<%
User partner = (User) request.getAttribute("partner");
String contextPath = request.getContextPath();

List<Order> activeOrders = (List<Order>) request.getAttribute("activeOrders");
List<Order> unassignedOrders = (List<Order>) request.getAttribute("unassignedOrders");
List<Order> completedOrders = (List<Order>) request.getAttribute("completedOrders");

Map<Integer, Restaurant> restaurantMap = (Map<Integer, Restaurant>) request.getAttribute("restaurantMap");
Map<Integer, User> customerMap = (Map<Integer, User>) request.getAttribute("customerMap");

Double totalEarnings = (Double) request.getAttribute("totalEarnings");
if (totalEarnings == null) totalEarnings = 0.0;

Integer completedCount = (Integer) request.getAttribute("completedCount");
if (completedCount == null) completedCount = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Delivery Partner Console | QuickBite</title>

<link rel="stylesheet" href="<%=contextPath%>/CSS/common.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/navbar.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/deliveryDashboard.css?v=<%=System.currentTimeMillis()%>">
<link rel="stylesheet" href="<%=contextPath%>/CSS/footer.css">
</head>

<body class="delivery-body">

	<%@ include file="navbar.jsp"%>

	<!-- Header Banner -->
	<header class="delivery-header">
		<div class="container delivery-header-row">
			<div class="delivery-title-area">
				<h1>
					🛵 QuickBite Rider Hub
					<span class="delivery-status-badge">● Shift Online</span>
				</h1>
				<p>
					Partner: <strong><%=partner != null ? partner.getUsername() : "Delivery Partner"%></strong>
					• <%=partner != null && partner.getPhone() != null ? partner.getPhone() : ""%>
				</p>
			</div>

			<div>
				<a href="<%=contextPath%>/restaurant" class="customer-contact-btn" style="background: rgba(255,255,255,0.15); color:#fff; border: 1px solid rgba(255,255,255,0.25);">
					🍽️ Customer App
				</a>
				<a href="<%=contextPath%>/logout" class="customer-contact-btn" style="background: rgba(255,255,255,0.15); color:#fff; border: 1px solid rgba(255,255,255,0.25); margin-left: 8px;">
					Logout
				</a>
			</div>
		</div>
	</header>

	<main class="container" style="padding-top: 20px; padding-bottom: 50px;">

		<!-- Rider Shift Stats -->
		<section class="delivery-stats-grid">
			<div class="delivery-stat-card">
				<div class="delivery-stat-icon">🛵</div>
				<div>
					<div class="delivery-stat-label">Active Assigned</div>
					<div class="delivery-stat-val"><%=activeOrders != null ? activeOrders.size() : 0%></div>
				</div>
			</div>

			<div class="delivery-stat-card">
				<div class="delivery-stat-icon" style="background:#eff6ff; color:#2563eb;">🔔</div>
				<div>
					<div class="delivery-stat-label">Available Orders</div>
					<div class="delivery-stat-val"><%=unassignedOrders != null ? unassignedOrders.size() : 0%></div>
				</div>
			</div>

			<div class="delivery-stat-card">
				<div class="delivery-stat-icon">✅</div>
				<div>
					<div class="delivery-stat-label">Completed Orders</div>
					<div class="delivery-stat-val"><%=completedCount%></div>
				</div>
			</div>

			<div class="delivery-stat-card">
				<div class="delivery-stat-icon" style="background:#fef3c7; color:#d97706;">💰</div>
				<div>
					<div class="delivery-stat-label">Today's Payout</div>
					<div class="delivery-stat-val">₹<%=String.format(Locale.ROOT, "%.2f", totalEarnings)%></div>
				</div>
			</div>
		</section>

		<!-- Tabs -->
		<nav class="delivery-tabs-nav">
			<button type="button" class="delivery-tab-btn active" id="tabActiveBtn" onclick="switchDeliveryTab('active')">
				🛵 My Active Deliveries (<%=activeOrders != null ? activeOrders.size() : 0%>)
			</button>
			<button type="button" class="delivery-tab-btn" id="tabAvailableBtn" onclick="switchDeliveryTab('available')">
				🔔 Available Near Me (<%=unassignedOrders != null ? unassignedOrders.size() : 0%>)
			</button>
			<button type="button" class="delivery-tab-btn" id="tabCompletedBtn" onclick="switchDeliveryTab('completed')">
				📜 Completed History (<%=completedCount%>)
			</button>
		</nav>

		<!-- 1. ACTIVE DELIVERIES -->
		<section id="deliveryActiveSection" class="delivery-orders-list">
			<%
			if (activeOrders != null && !activeOrders.isEmpty()) {
				for (Order o : activeOrders) {
					Restaurant rest = restaurantMap != null ? restaurantMap.get(o.getRestaurantId()) : null;
					User cust = customerMap != null ? customerMap.get(o.getUserId()) : null;
					String restName = rest != null ? rest.getName() : "Restaurant #" + o.getRestaurantId();
					String restAddr = rest != null ? rest.getAddress() : "Bangalore";
					String custName = cust != null ? cust.getUsername() : "Customer";
					String custPhone = cust != null && cust.getPhone() != null ? cust.getPhone() : "";
					String status = o.getStatus() != null ? o.getStatus().toUpperCase() : "PLACED";
					boolean isOutForDelivery = status.contains("OUT") || status.contains("WAY");
			%>
			<article class="delivery-order-card" id="card-<%=o.getOrderId()%>">
				<div class="order-top-bar">
					<div>
						<span class="order-ref">Order #QB-<%=o.getOrderId()%></span>
						<span style="margin-left: 10px; font-size: 12px; color: var(--dp-muted);">
							Placed at: <%=o.getOrderDate() != null ? o.getOrderDate().toString().substring(0, Math.min(16, o.getOrderDate().toString().length())) : "Today"%>
						</span>
					</div>
					<div style="display:flex; align-items:center; gap:8px;">
						<span class="order-amount-pill"><%=o.getPaymentMode() != null ? o.getPaymentMode() : "COD"%>: ₹<%=String.format(Locale.ROOT, "%.2f", o.getTotalAmount())%></span>
						<span class="delivery-status-badge" style="background:<%=isOutForDelivery ? "#f5a623" : "#2563eb"%>;"><%=status%></span>
					</div>
				</div>

				<div class="order-locations-grid">
					<!-- Pickup Restaurant -->
					<div class="location-box">
						<div class="location-label">🍽️ 1. Pick Up From</div>
						<div class="location-name"><%=restName%></div>
						<div class="location-address">📍 <%=restAddr%></div>
					</div>

					<!-- Deliver to Customer -->
					<div class="location-box">
						<div class="location-label">🏡 2. Deliver To Customer</div>
						<div class="location-name"><%=custName%></div>
						<div class="location-address">📍 <%=GeoUtil.displayAddress(o.getDeliveryAddress())%></div>
					</div>
				</div>

				<div class="order-bottom-bar">
					<div style="display:flex; gap:8px; flex-wrap:wrap;">
						<% if (!custPhone.isBlank()) { %>
						<a href="tel:<%=custPhone%>" class="customer-contact-btn">
							📞 Call Customer (<%=custPhone%>)
						</a>
						<% } %>
						<a href="<%=contextPath%>/orderDetails?orderId=<%=o.getOrderId()%>" class="customer-contact-btn">
							🗺️ View Live Route Map
						</a>
					</div>

					<div style="display:flex; gap:10px;">
						<% if (!isOutForDelivery) { %>
						<button type="button" class="delivery-action-btn btn-start-delivery" onclick="startDeliveryAction(<%=o.getOrderId()%>)">
							🛵 Start Delivery (Out for Delivery)
						</button>
						<% } else { %>
						<button type="button" class="delivery-action-btn btn-mark-delivered" onclick="markDeliveredAction(<%=o.getOrderId()%>)">
							✅ Mark as Delivered
						</button>
						<% } %>
					</div>
				</div>
			</article>
			<%
				}
			} else {
			%>
			<div class="empty-delivery-state">
				<div style="font-size: 38px; margin-bottom: 10px;">🛵</div>
				<h3 style="margin: 0 0 6px; color: var(--dp-text);">No Active Deliveries Assigned</h3>
				<p style="margin: 0 0 15px;">Check the "Available Near Me" tab to accept an incoming food delivery order.</p>
				<button type="button" class="delivery-action-btn btn-accept-order" onclick="switchDeliveryTab('available')">
					View Available Orders →
				</button>
			</div>
			<%
			}
			%>
		</section>

		<!-- 2. AVAILABLE UNASSIGNED ORDERS -->
		<section id="deliveryAvailableSection" class="delivery-orders-list" style="display: none;">
			<%
			if (unassignedOrders != null && !unassignedOrders.isEmpty()) {
				for (Order o : unassignedOrders) {
					Restaurant rest = restaurantMap != null ? restaurantMap.get(o.getRestaurantId()) : null;
					User cust = customerMap != null ? customerMap.get(o.getUserId()) : null;
					String restName = rest != null ? rest.getName() : "Restaurant #" + o.getRestaurantId();
					String restAddr = rest != null ? rest.getAddress() : "Bangalore";
					String custName = cust != null ? cust.getUsername() : "Customer";
			%>
			<article class="delivery-order-card" id="avail-card-<%=o.getOrderId()%>">
				<div class="order-top-bar">
					<div>
						<span class="order-ref">Order #QB-<%=o.getOrderId()%></span>
						<span style="margin-left: 10px; font-size: 12px; color: var(--dp-muted);">
							Status: <strong><%=o.getStatus()%></strong>
						</span>
					</div>
					<div>
						<span class="order-amount-pill"><%=o.getPaymentMode()%> • ₹<%=String.format(Locale.ROOT, "%.2f", o.getTotalAmount())%></span>
					</div>
				</div>

				<div class="order-locations-grid">
					<div class="location-box">
						<div class="location-label">🍽️ Pickup Outlet</div>
						<div class="location-name"><%=restName%></div>
						<div class="location-address">📍 <%=restAddr%></div>
					</div>
					<div class="location-box">
						<div class="location-label">🏡 Drop Location</div>
						<div class="location-name"><%=custName%></div>
						<div class="location-address">📍 <%=GeoUtil.displayAddress(o.getDeliveryAddress())%></div>
					</div>
				</div>

				<div class="order-bottom-bar" style="justify-content: flex-end;">
					<button type="button" class="delivery-action-btn btn-accept-order" onclick="acceptDeliveryOrder(<%=o.getOrderId()%>)">
						⚡ Accept &amp; Start Delivery (+₹50 payout)
					</button>
				</div>
			</article>
			<%
				}
			} else {
			%>
			<div class="empty-delivery-state">
				<div style="font-size: 38px; margin-bottom: 10px;">☕</div>
				<h3 style="margin: 0 0 6px; color: var(--dp-text);">No Unassigned Orders Right Now</h3>
				<p style="margin: 0;">New orders placed by customers will automatically show up here for delivery acceptance.</p>
			</div>
			<%
			}
			%>
		</section>

		<!-- 3. COMPLETED HISTORY -->
		<section id="deliveryCompletedSection" class="delivery-orders-list" style="display: none;">
			<%
			if (completedOrders != null && !completedOrders.isEmpty()) {
				for (Order o : completedOrders) {
					Restaurant rest = restaurantMap != null ? restaurantMap.get(o.getRestaurantId()) : null;
					String restName = rest != null ? rest.getName() : "Restaurant #" + o.getRestaurantId();
			%>
			<article class="delivery-order-card" style="opacity: 0.9;">
				<div class="order-top-bar">
					<div>
						<span class="order-ref">#QB-<%=o.getOrderId()%></span>
						<span style="margin-left: 8px; color: var(--dp-green); font-weight:800; font-size:12px;">● DELIVERED</span>
						<span style="margin-left: 10px; font-size: 12px; color: var(--dp-muted);"><%=o.getOrderDate() != null ? o.getOrderDate().toString().substring(0, Math.min(16, o.getOrderDate().toString().length())) : ""%></span>
					</div>
					<div>
						<span class="order-amount-pill" style="background:#dcfce7; color:#15803d;">Earned ₹50.00</span>
					</div>
				</div>
				<div style="font-size: 13px; color: #4b5563;">
					From: <strong><%=restName%></strong> • Delivered to: <%=GeoUtil.displayAddress(o.getDeliveryAddress())%>
				</div>
			</article>
			<%
				}
			} else {
			%>
			<div class="empty-delivery-state">
				<div style="font-size: 38px; margin-bottom: 10px;">🏁</div>
				<h3 style="margin: 0 0 6px; color: var(--dp-text);">No Completed Deliveries Yet</h3>
				<p style="margin: 0;">Your delivered orders and payouts will be listed here.</p>
			</div>
			<%
			}
			%>
		</section>

	</main>

	<%@ include file="footer.jsp"%>

	<script>
		const contextPath = "<%=contextPath%>";

		function switchDeliveryTab(tab) {
			const tabs = ["active", "available", "completed"];
			tabs.forEach(t => {
				const section = document.getElementById("delivery" + capitalize(t) + "Section");
				const btn = document.getElementById("tab" + capitalize(t) + "Btn");
				if (section) section.style.display = (t === tab) ? "flex" : "none";
				if (btn) btn.classList.toggle("active", t === tab);
			});
		}

		function capitalize(s) {
			return s.charAt(0).toUpperCase() + s.slice(1);
		}

		async function acceptDeliveryOrder(orderId) {
			if (!confirm("Accept order #QB-" + orderId + " and start delivery?")) return;

			try {
				const body = new URLSearchParams();
				body.append("action", "acceptOrder");
				body.append("orderId", orderId);
				body.append("ajax", "true");

				const res = await fetch(contextPath + "/deliveryDashboard", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});
				const data = await res.json();
				if (data.success) {
					window.location.reload();
				} else {
					alert("Unable to accept order.");
				}
			} catch (e) {
				alert("Network error.");
			}
		}

		async function startDeliveryAction(orderId) {
			try {
				const body = new URLSearchParams();
				body.append("action", "startDelivery");
				body.append("orderId", orderId);
				body.append("ajax", "true");

				const res = await fetch(contextPath + "/deliveryDashboard", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});
				const data = await res.json();
				if (data.success) {
					window.location.reload();
				}
			} catch (e) {
				alert("Network error.");
			}
		}

		async function markDeliveredAction(orderId) {
			if (!confirm("Confirm order #QB-" + orderId + " is safely delivered to the customer?")) return;

			try {
				const body = new URLSearchParams();
				body.append("action", "markDelivered");
				body.append("orderId", orderId);
				body.append("ajax", "true");

				const res = await fetch(contextPath + "/deliveryDashboard", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});
				const data = await res.json();
				if (data.success) {
					window.location.reload();
				}
			} catch (e) {
				alert("Network error.");
			}
		}
	</script>

</body>
</html>
