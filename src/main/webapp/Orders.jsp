<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.util.*,
    java.text.SimpleDateFormat,
    com.tap.model.Order,
    com.tap.model.OrderItem,
    com.tap.model.Restaurant,
    com.tap.model.Menu"%>

<%!private String resolveImage(String path, String contextPath) {
		if (path == null || path.trim().isEmpty())
			return "";
		path = path.trim();
		if (path.startsWith("http://") || path.startsWith("https://") || path.startsWith("data:"))
			return path;
		if (path.startsWith(contextPath + "/"))
			return path;
		if (path.startsWith("/"))
			return contextPath + path;
		return contextPath + "/" + path;
	}

	private String safeText(String value) {
		return value == null || value.trim().isEmpty() ? "Not available" : value;
	}

	private String statusClass(String status) {
		if (status == null)
			return "status-placed";
		String value = status.trim().toLowerCase();
		if (value.contains("deliver"))
			return "status-delivered";
		else if (value.contains("cancel"))
			return "status-cancelled";
		else if (value.contains("way") || value.contains("transit"))
			return "status-on-way";
		else if (value.contains("prepar") || value.contains("process"))
			return "status-preparing";
		return "status-placed";
	}%>

<%
String contextPath = request.getContextPath();
List<Order> orders = (List<Order>) request.getAttribute("orders");
Map<Integer, Restaurant> restaurantByOrderId = (Map<Integer, Restaurant>) request.getAttribute("restaurantByOrderId");
Map<Integer, List<OrderItem>> orderItemsByOrderId = (Map<Integer, List<OrderItem>>) request
		.getAttribute("orderItemsByOrderId");
Map<Integer, Menu> menuById = (Map<Integer, Menu>) request.getAttribute("menuById");

if (orders == null)
	orders = new ArrayList<>();
else {
	// Sort orders so newest/highest orderId appears at the top
	orders.sort((o1, o2) -> Integer.compare(o2.getOrderId(), o1.getOrderId()));
}

if (restaurantByOrderId == null)
	restaurantByOrderId = new HashMap<>();
if (orderItemsByOrderId == null)
	orderItemsByOrderId = new HashMap<>();
if (menuById == null)
	menuById = new HashMap<>();

SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Orders | Quick Bite</title>
<link rel="stylesheet" href="<%=contextPath%>/CSS/common.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/navbar.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/orders.css">
<link rel="stylesheet" href="<%=contextPath%>/CSS/footer.css">
</head>
<body class="orders-page">

	<%@ include file="navbar.jsp"%>

	<main class="orders-container">
		<nav class="breadcrumb">
			<a href="<%=contextPath%>/restaurant">Home</a> <span>/</span> <strong>My
				Orders</strong>
		</nav>

		<section class="orders-heading">
			<div>
				<span class="eyebrow">YOUR QUICK BITE JOURNEY</span>
				<h1>My Orders</h1>
				<p>Track your orders and revisit your favourite meals.</p>
			</div>
			<div class="orders-count">
				<span class="count-number"><%=orders.size()%></span> <span>Orders
					placed</span>
			</div>
		</section>

		<section class="order-history">
			<div class="section-heading">
				<h2>Order History</h2>
				<span>Your previous and current orders</span>
			</div>

			<%
			if (orders.isEmpty()) {
			%>

			<div class="no-orders">
				<div class="empty-icon-circle">🛍️</div>

				<h2>No orders yet</h2>

				<p>Looks like you haven't ordered anything yet. Explore our
					restaurants and find something delicious!</p>

				<a class="shop-now-btn" href="<%=contextPath%>/restaurant">
					Explore Restaurants <span>&rarr;</span>
				</a>
			</div>

			<%
			} else {
			%>

			<%
			for (Order order : orders) {
				Restaurant restaurant = restaurantByOrderId.get(order.getOrderId());
				List<OrderItem> items = orderItemsByOrderId.get(order.getOrderId());
				if (items == null)
					items = new ArrayList<>();

				String restaurantName = restaurant == null ? "Restaurant" : safeText(restaurant.getName());
				String restaurantImage = restaurant == null ? "" : resolveImage(restaurant.getImagePath(), contextPath);
				String status = safeText(order.getStatus());
				String paymentMode = safeText(order.getPaymentMode());
				String orderDate = order.getOrderDate() == null ? "Date unavailable" : dateFormat.format(order.getOrderDate());
			%>

			<article class="order-card">
				<div class="order-card-header">
					<div class="restaurant-info">
						<div class="restaurant-image">
							<%
							if (!restaurantImage.isEmpty()) {
							%>
							<img src="<%=restaurantImage%>" alt="<%=restaurantName%>"
								onerror="this.style.display='none'">
							<%
							} else {
							%>
							<span class="restaurant-image-fallback">🍽️</span>
							<%
							}
							%>
						</div>

						<div class="restaurant-heading">
							<div class="title-row">
								<h3><%=restaurantName%></h3>
								<span class="order-id-pill">#QB-<%=order.getOrderId()%></span>
							</div>

							<div class="meta-row">
								<span class="restaurant-location">📍 <%=order.getDeliveryAddress() != null ? order.getDeliveryAddress() : "Location unavailable"%></span>
								<span class="meta-dot">•</span> <span class="order-date">🕒
									<%=orderDate%></span>
							</div>
						</div>
					</div>

					<div class="order-status <%=statusClass(status)%>">
						<span class="status-dot"></span>
						<%=status.toUpperCase()%>
					</div>
				</div>

				<div class="order-card-content">
					<div class="ordered-items">
						<%
						if (items.isEmpty()) {
						%>
						<div class="items-unavailable">
							<strong>Order items unavailable</strong>
							<p>Item details could not be found for this order.</p>
						</div>
						<%
						} else {
						%>
						<%
						for (OrderItem item : items) {
							Menu menu = menuById.get(item.getMenuId());
							String itemName = menu == null ? "Food item" : safeText(menu.getItemName());
							String itemImage = menu == null ? "" : resolveImage(menu.getImagePath(), contextPath);
						%>
						<div class="ordered-item">
							<div class="food-image">
								<%
								if (!itemImage.isEmpty()) {
								%>
								<img src="<%=itemImage%>" alt="<%=itemName%>"
									onerror="this.style.display='none'">
								<%
								} else {
								%>
								<span class="food-image-fallback">🍲</span>
								<%
								}
								%>
							</div>
							<div class="food-details">
								<h4><%=itemName%></h4>
								<p>
									Qty:
									<%=item.getQuantity()%></p>
							</div>
							<div class="food-line-total">
								&#8377;<%=String.format(java.util.Locale.US, "%.2f", item.getTotalAmount())%>
							</div>
						</div>
						<%
						}
						%>
						<%
						}
						%>
					</div>
				</div>

				<div class="order-payment-summary">
					<div class="payment-info">
						<span class="summary-label">PAYMENT METHOD</span> <strong>💳
							<%=paymentMode%></strong>
					</div>
					<div class="amount-info">
						<span class="summary-label">ORDER STATUS</span> <strong><%=status%></strong>
					</div>
				</div>

				<div class="order-card-footer">
					<div class="total-paid">
						<span class="payment-caption">TOTAL ORDER AMOUNT</span> <strong>&#8377;<%=String.format(java.util.Locale.US, "%.2f", order.getTotalAmount())%></strong>
					</div>

					<div class="order-actions">
						<%
						if (status.toLowerCase().contains("deliver") || status.toLowerCase().contains("place")) {
						%>
						<%
						}
						%>
						<a class="view-details-btn"
							href="<%=contextPath%>/orderDetails?orderId=<%=order.getOrderId()%>">
							View Order Details <span>&rarr;</span>
						</a>
					</div>
				</div>
			</article>
			<%
			}
			%>
			<%
			}
			%>
		</section>
	</main>

	<%@ include file="footer.jsp"%>
</body>
</html>