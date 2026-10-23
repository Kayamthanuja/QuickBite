<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="com.tap.model.User"%>
<%@ page import="com.tap.model.Order"%>
<%@ page import="com.tap.model.OrderItem"%>
<%@ page import="com.tap.model.Menu"%>
<%@ page import="com.tap.model.Restaurant"%>
<%@ page import="com.tap.util.GeoUtil"%>

<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Order Placed &amp; Live Tracking | QuickBite</title>

	<!-- Canvas Confetti Library -->
	<script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>

	<!-- Leaflet CSS & JS for Interactive Map -->
	<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
		integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
	<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
		integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

	<!-- Common CSS -->
	<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/common.css">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/navbar.css">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/orderStatus.css?v=<%=System.currentTimeMillis()%>">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/orderDetails.css?v=<%=System.currentTimeMillis()%>">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/footer.css">
</head>

<body>

	<!-- Navigation Bar -->
	<%@ include file="navbar.jsp"%>

	<%
	User user = (User) session.getAttribute("user");
	Integer orderId = (Integer) request.getAttribute("orderId");
	Order order = (Order) request.getAttribute("order");
	Restaurant restaurant = (Restaurant) request.getAttribute("restaurant");
	User deliveryPartner = (User) request.getAttribute("deliveryPartner");
	List<OrderItem> orderItems = (List<OrderItem>) request.getAttribute("orderItems");
	Map<Integer, Menu> menuById = (Map<Integer, Menu>) request.getAttribute("menuById");

	String username = (user != null && user.getUsername() != null) ? user.getUsername() : "Customer";
	String userPhone = (user != null && user.getPhone() != null) ? user.getPhone() : "";
	String userEmail = (user != null && user.getEmail() != null) ? user.getEmail() : "";
	String address = (order != null && order.getDeliveryAddress() != null)
			? order.getDeliveryAddress()
			: (user != null && user.getAddress() != null ? user.getAddress() : "Bangalore");

	String restaurantName = (restaurant != null && restaurant.getName() != null)
			? restaurant.getName()
			: "QuickBite Kitchen";

	String partnerName = (deliveryPartner != null && deliveryPartner.getUsername() != null)
			? deliveryPartner.getUsername()
			: "Amit Kumar";

	String partnerPhone = (deliveryPartner != null && deliveryPartner.getPhone() != null && !deliveryPartner.getPhone().trim().isEmpty())
			? deliveryPartner.getPhone()
			: "+91 98451 23456";

	String status = (order != null && order.getStatus() != null) ? order.getStatus().toUpperCase() : "PLACED";
	String paymentMode = (order != null && order.getPaymentMode() != null) ? order.getPaymentMode() : "Cash on Delivery";
	double totalAmount = (order != null) ? order.getTotalAmount() : 0.0;
	%>

	<!-- =====================================
         CONFETTI CELEBRATION MODAL (Dismissable)
         ===================================== -->
	<div id="celebrationOverlay" class="celebration-overlay">
		<div class="celebration-modal-card">
			<div class="celebration-badge">
				<span>🎉</span> Order Confirmed!
			</div>

			<div class="celebration-icon-ring">
				<div class="celebration-checkmark">
					<svg viewBox="0 0 52 52" class="checkmark-svg">
						<circle class="checkmark-circle" cx="26" cy="26" r="23" fill="none" />
						<path class="checkmark-check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8" />
					</svg>
				</div>
			</div>

			<h2 class="celebration-title">Order Placed Successfully!</h2>
			<p class="celebration-subtitle">
				Thank you, <strong><%=username%></strong>! <strong><%=restaurantName%></strong> is preparing your delicious meal.
			</p>

			<div class="celebration-order-tag">
				<span>Order Reference</span>
				<strong>#QB-<%=orderId != null ? orderId : "---"%></strong>
			</div>

			<div class="celebration-actions">
				<button type="button" class="track-now-btn" onclick="dismissCelebrationModal()">
					<span>🛵</span> View Live Tracking Map Below &darr;
				</button>
				<a href="<%=request.getContextPath()%>/orderDetails?orderId=<%=orderId != null ? orderId : ""%>" class="view-receipt-link">
					View Detailed Invoice PDF &rarr;
				</a>
			</div>
		</div>
	</div>

	<!-- ==============================
         ORDER STATUS MAIN CONTAINER
         ============================== -->
	<main class="order-status-container container" style="flex-direction: column; align-items: center;">

		<!-- Success Confirmation Banner -->
		<div class="order-success-card" style="margin-bottom: 25px;">
			<div class="success-icon-wrapper">
				<div class="success-icon">✓</div>
				<div class="confetti-particle"></div>
				<div class="confetti-particle"></div>
				<div class="confetti-particle"></div>
				<div class="confetti-particle"></div>
			</div>

			<h1>Order Placed Successfully!</h1>
			<p class="success-message">
				Thank you for ordering with QuickBite, <strong><%=username%></strong>! Your kitchen has accepted the order.
			</p>

			<div class="order-id-box">
				<span>Order ID</span>
				<strong>#QB-<%=orderId != null ? orderId : "---"%></strong>
			</div>

			<!-- Status Steps -->
			<div class="status-section">
				<div class="status-line">
					<div class="status-step active">
						<div class="status-circle">✓</div>
						<span>Order Placed</span>
					</div>
					<div class="status-connector active-connector"></div>
					<div class="status-step active">
						<div class="status-circle">🍳</div>
						<span>Preparing</span>
					</div>
					<div class="status-connector active-connector"></div>
					<div class="status-step active">
						<div class="status-circle">🛵</div>
						<span>On the Way</span>
					</div>
					<div class="status-connector"></div>
					<div class="status-step">
						<div class="status-circle">🏡</div>
						<span>Delivered</span>
					</div>
				</div>
			</div>

			<!-- Notification confirmation banner -->
			<div class="order-notification-banner" style="background: #eaf8ee; border: 1px solid #c2ebd0; border-radius: 12px; padding: 14px 18px; margin: 20px 0 25px; display: flex; align-items: center; gap: 12px; text-align: left;">
				<span style="font-size: 26px;">📬</span>
				<div>
					<strong style="color: #196f3d; font-size: 14px; display: block;">Order Confirmation Dispatched!</strong>
					<span style="font-size: 13px; color: #2e7d32;">
						SMS &amp; Email confirmation with your complete itemized bill has been sent to
						<% if (!userPhone.isEmpty()) { %><strong><%=userPhone%></strong><% } %>
						<% if (!userEmail.isEmpty()) { %> and <strong><%=userEmail%></strong><% } %>.
					</span>
				</div>
			</div>

			<!-- Delivery Info Summary -->
			<div class="delivery-info">
				<div class="info-item">
					<span class="info-label">Delivery Address</span>
					<span class="info-value"><%=GeoUtil.displayAddress(address)%></span>
				</div>
				<div class="info-item">
					<span class="info-label">Payment Mode</span>
					<span class="info-value"><%=paymentMode%></span>
				</div>
				<div class="info-item">
					<span class="info-label">Order Total</span>
					<span class="info-value" style="color:#27ae60;">₹<%=String.format(java.util.Locale.ROOT, "%.2f", totalAmount)%></span>
				</div>
			</div>

			<!-- Ordered Items List -->
			<% if (orderItems != null && !orderItems.isEmpty()) { %>
			<div class="order-items-preview" style="margin-top: 25px; text-align: left; background: #fffcf7; border: 1px solid var(--qb-border); border-radius: 14px; padding: 20px;">
				<h3 style="margin: 0 0 15px; font-size: 16px; color: var(--qb-brown); display: flex; justify-content: space-between; align-items: center;">
					<span>🍽️ Items Ordered (<%=orderItems.size()%>)</span>
					<span style="font-size: 13px; font-weight: normal; color: var(--qb-muted);">Kitchen: <strong><%=restaurantName%></strong></span>
				</h3>
				<div class="items-list" style="display: flex; flex-direction: column; gap: 10px;">
					<% for (OrderItem item : orderItems) {
						Menu m = (menuById != null) ? menuById.get(item.getMenuId()) : null;
						String iName = (m != null && m.getItemName() != null) ? m.getItemName() : "Menu Item #" + item.getMenuId();
						double unitPrice = (m != null) ? m.getPrice() : (item.getTotalAmount() / Math.max(1, item.getQuantity()));
					%>
					<div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 8px; border-bottom: 1px dashed #eedbc5; font-size: 14px;">
						<div style="display: flex; align-items: center; gap: 10px;">
							<span style="background: var(--qb-orange); color: white; border-radius: 6px; padding: 2px 8px; font-weight: 700; font-size: 12px;"><%=item.getQuantity()%>x</span>
							<strong style="color: var(--qb-brown);"><%=iName%></strong>
						</div>
						<div style="font-weight: 700; color: var(--qb-brown);">
							₹<%=String.format(java.util.Locale.ROOT, "%.2f", item.getTotalAmount())%>
						</div>
					</div>
					<% } %>
				</div>
				<div style="display: flex; justify-content: space-between; margin-top: 12px; font-size: 13px; color: var(--qb-muted);">
					<span>Delivery Partner Fee</span>
					<span>₹40.00</span>
				</div>
			</div>
			<% } %>
		</div>

		<!-- =====================================
             LIVE TRACKING MAP SECTION (Zomato/Swiggy Style)
             ===================================== -->
		<section class="live-tracking-card" id="liveMapSection" style="width: 100%; max-width: 820px;">
			<div class="tracking-card-header">
				<div class="tracking-title-wrap">
					<span class="live-pulse-badge"><span class="pulse-dot"></span> LIVE GPS TRACKING</span>
					<h2>Delivery Partner is On the Way</h2>
				</div>
				<div class="eta-pill">
					<span class="eta-label">Estimated Delivery</span>
					<strong class="eta-time" id="liveEtaDisplay">18 mins</strong>
				</div>
			</div>

			<!-- Interactive Leaflet Map Container -->
			<div class="map-wrapper" style="margin-top: 15px;">
				<div id="liveOrderStatusMap" class="leaflet-map-container" style="height: 380px; width: 100%; border-radius: 14px;"></div>
				<div class="map-overlay-info">
					<span class="driver-indicator">🛵 Driver is en route • Live GPS updates every 2 seconds</span>
				</div>
			</div>

			<!-- Delivery Partner Details Card -->
			<div class="delivery-partner-card" style="margin-top: 18px;">
				<div class="partner-avatar-wrap">
					<div class="partner-avatar">🛵</div>
					<span class="online-status-dot"></span>
				</div>
				<div class="partner-details">
					<div class="partner-top-row">
						<h3><%=partnerName%></h3>
						<span class="partner-badge">Super Hero</span>
						<span class="partner-rating">★ 4.9 <small>(Verified Partner)</small></span>
					</div>
					<p class="partner-vehicle">🛵 TVS Jupiter • KA 05 MN 3829 • Silver</p>
					<div class="partner-badges">
						<span class="safety-badge">🛡️ 100% Vaccinated</span>
						<span class="temp-badge">🌡️ Temp: 98.2°F</span>
						<span class="safety-badge">😷 Mask Worn</span>
					</div>
				</div>
				<div class="partner-actions">
					<a href="tel:<%=partnerPhone%>" class="partner-contact-btn call-partner-btn">
						<span>📞</span> Call Driver
					</a>
					<button type="button" class="partner-contact-btn chat-partner-btn" onclick="alert('QuickBite Chat: Connected with <%=partnerName%>!')">
						<span>💬</span> Chat
					</button>
				</div>
			</div>

			<!-- Action Buttons -->
			<div class="order-actions" style="margin-top: 25px;">
				<a href="<%=request.getContextPath()%>/orderDetails?orderId=<%=orderId != null ? orderId : ""%>" class="primary-btn">
					📥 View Full Bill &amp; Download Invoice PDF
				</a>
				<a href="<%=request.getContextPath()%>/orders" class="secondary-btn">
					My Order History
				</a>
				<a href="<%=request.getContextPath()%>/restaurant" class="secondary-btn">
					Explore More Restaurants →
				</a>
			</div>
		</section>

	</main>

	<!-- =====================================
         SCRIPTS: Confetti & Live Map Route
         ===================================== -->
	<script>
		// Trigger Confetti Blast on page load
		function fireConfettiBlast() {
			if (typeof confetti === 'function') {
				const count = 200;
				const defaults = { origin: { y: 0.7 } };

				function fire(particleRatio, opts) {
					confetti(Object.assign({}, defaults, opts, {
						particleCount: Math.floor(count * particleRatio)
					}));
				}

				fire(0.25, { spread: 26, startVelocity: 55 });
				fire(0.2, { spread: 60 });
				fire(0.35, { spread: 100, decay: 0.91, scalar: 0.8 });
				fire(0.1, {
					spread: 120,
					startVelocity: 25,
					decay: 0.92,
					colors: ['#f5a623', '#27ae60', '#e74c3c', '#3498db', '#f1c40f']
				});
				fire(0.1, { spread: 120, startVelocity: 45 });
			}
		}

		function dismissCelebrationModal() {
			const overlay = document.getElementById('celebrationOverlay');
			if (overlay) {
				overlay.style.transition = 'opacity 0.3s ease';
				overlay.style.opacity = '0';
				overlay.style.pointerEvents = 'none';
				setTimeout(() => {
					overlay.style.display = 'none';
				}, 300);
			}
			const mapSec = document.getElementById('liveMapSection');
			if (mapSec) {
				mapSec.scrollIntoView({ behavior: 'smooth', block: 'start' });
			}
		}

		// Initialize Live Tracking Map
		window.addEventListener('DOMContentLoaded', () => {
			fireConfettiBlast();

			// Auto dismiss celebration after 4s without redirecting away from the live map!
			setTimeout(() => {
				dismissCelebrationModal();
			}, 4000);

			if (typeof L === 'undefined') {
				console.warn('Leaflet library is unavailable');
				return;
			}

			const mapContainer = document.getElementById('liveOrderStatusMap');
			if (!mapContainer) return;

			<%
			// Parse coordinates with priority: order.getDestLat() -> GeoUtil.parseLatLng(address) -> default Bangalore
			Double[] parsedDest = GeoUtil.parseLatLng(address);
			double dLat = (order != null && order.getDestLat() != null && order.getDestLat() != 0.0)
					? order.getDestLat()
					: ((parsedDest != null) ? parsedDest[0] : 12.9630);
			double dLng = (order != null && order.getDestLng() != null && order.getDestLng() != 0.0)
					? order.getDestLng()
					: ((parsedDest != null) ? parsedDest[1] : 77.6380);
			double rLat = (order != null && order.getRiderLat() != null && order.getRiderLat() != 0.0)
					? order.getRiderLat()
					: 12.9754;
			double rLng = (order != null && order.getRiderLng() != null && order.getRiderLng() != 0.0)
					? order.getRiderLng()
					: 77.6045;
			%>

			const restCoords = [<%=rLat%>, <%=rLng%>];
			const destCoords = [<%=dLat%>, <%=dLng%>];
			const center = [(restCoords[0] + destCoords[0]) / 2, (restCoords[1] + destCoords[1]) / 2];

			const map = L.map('liveOrderStatusMap', {
				center: center,
				zoom: 14,
				zoomControl: true,
				scrollWheelZoom: false
			});

			L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
				attribution: '&copy; OpenStreetMap contributors',
				maxZoom: 19
			}).addTo(map);

			// Restaurant Marker
			const restHtml = '<div class="custom-map-marker rest-marker">' +
				'<span class="marker-emoji">🍽️</span>' +
				'<span class="marker-tag"><%=restaurantName.replace("'", "\\'")%></span>' +
				'</div>';
			const restIcon = L.divIcon({
				className: 'custom-div-icon',
				html: restHtml,
				iconSize: [40, 40],
				iconAnchor: [20, 20]
			});
			L.marker(restCoords, { icon: restIcon }).addTo(map)
				.bindPopup('<strong><%=restaurantName.replace("'", "\\'")%></strong><br>Kitchen preparing food.');

			// Destination Marker
			const destHtml = '<div class="custom-map-marker dest-marker">' +
				'<span class="marker-emoji">🏠</span>' +
				'<span class="marker-tag">Your Location</span>' +
				'</div>';
			const destIcon = L.divIcon({
				className: 'custom-div-icon',
				html: destHtml,
				iconSize: [40, 40],
				iconAnchor: [20, 20]
			});
			L.marker(destCoords, { icon: destIcon }).addTo(map)
				.bindPopup('<strong>Delivery Location</strong><br><%=GeoUtil.displayAddress(address).replace("'", "\\'")%>');

			// Realistic intermediate delivery route points
			const routeWaypoints = [
				restCoords,
				[restCoords[0] - 0.002, restCoords[1] + 0.007],
				[restCoords[0] - 0.005, restCoords[1] + 0.014],
				[destCoords[0] + 0.004, destCoords[1] - 0.012],
				[destCoords[0] + 0.002, destCoords[1] - 0.005],
				destCoords
			];

			// Delivery Route Polyline
			L.polyline(routeWaypoints, {
				color: '#ffffff',
				weight: 8,
				opacity: 0.95,
				lineCap: 'round',
				lineJoin: 'round'
			}).addTo(map);

			const routeLine = L.polyline(routeWaypoints, {
				color: '#f5a623',
				weight: 5,
				opacity: 1,
				dashArray: '8, 8',
				lineCap: 'round',
				lineJoin: 'round'
			}).addTo(map);

			// Animated Scooter Marker with pulsating radar
			const scooterHtml = '<div class="scooter-marker-wrap">' +
				'<div class="scooter-pulse-ring"></div>' +
				'<div class="scooter-icon-circle">🛵</div>' +
				'</div>';
			const scooterIcon = L.divIcon({
				className: 'custom-scooter-icon',
				html: scooterHtml,
				iconSize: [44, 44],
				iconAnchor: [22, 22]
			});

			const scooterMarker = L.marker(routeWaypoints[1], { icon: scooterIcon }).addTo(map);

			map.fitBounds(routeLine.getBounds(), { padding: [45, 45] });
			setTimeout(() => { map.invalidateSize(); }, 300);

			// Smooth interpolation along the route
			let segIdx = 0;
			let segT = 0;
			const etaEl = document.getElementById('liveEtaDisplay');

			setInterval(() => {
				segT += 0.035;
				if (segT >= 1) {
					segT = 0;
					segIdx++;
					if (segIdx >= routeWaypoints.length - 1) {
						segIdx = 0; // loop continuous simulation
					}
				}

				const p1 = routeWaypoints[segIdx];
				const p2 = routeWaypoints[segIdx + 1];

				const currentLat = p1[0] + (p2[0] - p1[0]) * segT;
				const currentLng = p1[1] + (p2[1] - p1[1]) * segT;

				scooterMarker.setLatLng([currentLat, currentLng]);

				if (etaEl) {
					const progress = (segIdx + segT) / (routeWaypoints.length - 1);
					const remainingMins = Math.max(4, Math.round(18 - progress * 14));
					etaEl.textContent = remainingMins + ' mins';
				}
			}, 250);
		});
	</script>

	<!-- Footer -->
	<%@ include file="footer.jsp"%>

</body>
</html>