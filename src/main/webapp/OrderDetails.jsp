
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.*,
    com.tap.model.Order,
    com.tap.model.OrderItem,
    com.tap.model.Menu,
    com.tap.model.Restaurant,
    com.tap.model.User" %>

<%!
    private String resolveImage(String path, String contextPath) {
        if (path == null || path.trim().isEmpty())
            return "";

        path = path.trim();

        if (path.startsWith("http://") ||
            path.startsWith("https://") ||
            path.startsWith("data:"))
            return path;

        if (path.startsWith(contextPath + "/"))
            return path;

        if (path.startsWith("/"))
            return contextPath + path;

        return contextPath + "/" + path;
    }
%>

<%
    String contextPath = request.getContextPath();

    Order order = (Order) request.getAttribute("order");

    List<OrderItem> orderItems =
        (List<OrderItem>) request.getAttribute("orderItems");

    Map<Integer, Menu> menuById =
        (Map<Integer, Menu>) request.getAttribute("menuById");

    Restaurant restaurant = (Restaurant) request.getAttribute("restaurant");
    User deliveryPartner = (User) request.getAttribute("deliveryPartner");

    String restaurantName =
        (String) request.getAttribute("restaurantName");

    if (restaurantName == null || restaurantName.trim().isEmpty()) {
        restaurantName = (restaurant != null && restaurant.getName() != null)
            ? restaurant.getName() : "Restaurant Name Unavailable";
    }

    String partnerName = (deliveryPartner != null && deliveryPartner.getUsername() != null)
        ? deliveryPartner.getUsername() : "Amit Kumar";

    String partnerPhone = (deliveryPartner != null && deliveryPartner.getPhone() != null && !deliveryPartner.getPhone().trim().isEmpty())
        ? deliveryPartner.getPhone() : "+91 98451 23456";

    if (menuById == null)
        menuById = new HashMap<>();

    if (orderItems == null)
        orderItems = new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Order Details & Live Tracking | QuickBite</title>

    <!-- Library for client-side PDF download -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <!-- Leaflet CSS & JS for Interactive Map -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

    <link rel="stylesheet" href="<%=contextPath%>/CSS/common.css">
    <link rel="stylesheet" href="<%=contextPath%>/CSS/navbar.css">
    <link rel="stylesheet"
        href="<%=contextPath%>/CSS/orderDetails.css?v=<%=System.currentTimeMillis()%>">
    <link rel="stylesheet" href="<%=contextPath%>/CSS/footer.css">
</head>

<body>

    <%@ include file="navbar.jsp" %>

    <main class="order-details-container container">

        <!-- Page Header -->
        <div class="order-details-header">
            <div>
                <h1>Order Details & Live Tracking</h1>
                <p>
                    Order #QB-<%=order != null ? order.getOrderId() : ""%>
                    • Live status and complete order summary
                </p>
            </div>

            <%
                if (order != null) {
            %>
                <button type="button"
                    class="download-invoice-btn"
                    onclick="downloadInvoicePDF()">
                    <span>📥</span> Download Invoice
                </button>
            <%
                }
            %>
        </div>

        <%
            if (order != null) {

                String rawStatus = order.getStatus() != null
                    ? order.getStatus().trim().toLowerCase()
                    : "placed";

                String status = rawStatus.toUpperCase();

                String statusClass = "status-placed";

                if (rawStatus.contains("deliver")) {
                    statusClass = "status-delivered";
                } else if (rawStatus.contains("cancel")) {
                    statusClass = "status-cancelled";
                } else {
                    statusClass = "status-active";
                }

                boolean isActiveOrder =
                    rawStatus.contains("place") ||
                    rawStatus.contains("prepar") ||
                    rawStatus.contains("way") ||
                    rawStatus.contains("transit") ||
                    rawStatus.contains("pending");
        %>

        <!-- =====================================
             LIVE TRACKING & DELIVERY PARTNER SECTION
             ===================================== -->
        <section class="live-tracking-card">
            <div class="tracking-card-header">
                <div class="tracking-title-wrap">
                    <span class="live-pulse-badge"><span class="pulse-dot"></span> LIVE TRACKING</span>
                    <h2>Estimated Delivery</h2>
                </div>
                <div class="eta-pill">
                    <span class="eta-label">Arriving in</span>
                    <strong class="eta-time" id="etaTimeDisplay">22 mins</strong>
                </div>
            </div>

            <!-- Delivery Tracker Steps -->
            <div class="delivery-stepper">
                <div class="step-item completed">
                    <div class="step-icon">✓</div>
                    <span class="step-label">Order Placed</span>
                </div>
                <div class="step-bar completed"></div>
                <div class="step-item completed">
                    <div class="step-icon">🍳</div>
                    <span class="step-label">Preparing Food</span>
                </div>
                <div class="step-bar active"></div>
                <div class="step-item active">
                    <div class="step-icon">🛵</div>
                    <span class="step-label">Out for Delivery</span>
                </div>
                <div class="step-bar"></div>
                <div class="step-item">
                    <div class="step-icon">🏡</div>
                    <span class="step-label">Delivered</span>
                </div>
            </div>

            <!-- Interactive Leaflet Map Container -->
            <div class="map-wrapper">
                <div id="liveOrderMap" class="leaflet-map-container"></div>
                <div class="map-overlay-info">
                    <span class="driver-indicator">🛵 Driver is 1.4 km away • En route to your address</span>
                </div>
            </div>

            <!-- Delivery Partner Details Card -->
            <div class="delivery-partner-card">
                <div class="partner-avatar-wrap">
                    <div class="partner-avatar">🛵</div>
                    <span class="online-status-dot"></span>
                </div>
                <div class="partner-details">
                    <div class="partner-top-row">
                        <h3><%=partnerName%></h3>
                        <span class="partner-badge">Super Hero</span>
                        <span class="partner-rating">★ 4.9 <small>(1,240+ deliveries)</small></span>
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
                        <span>📞</span> Call Partner
                    </a>
                    <button type="button" class="partner-contact-btn chat-partner-btn" onclick="openChatAlert('<%=partnerName%>')">
                        <span>💬</span> Chat
                    </button>
                </div>
            </div>
        </section>

        <!-- Printable Invoice Area -->
        <div id="invoice-printable-area">

            <!-- Order Summary Card -->
            <section class="order-summary-card">
                <div class="order-summary-top">
                    <div>
                        <h2><%=restaurantName%></h2>

                        <p>
                            🕒
                            <%=order.getOrderDate() != null
                                ? order.getOrderDate()
                                : "Date unavailable"%>
                        </p>
                    </div>

                    <span class="details-status <%=statusClass%>">
                        <span class="status-dot"></span>
                        <%=status%>
                    </span>
                </div>

                <div class="order-information">
                    <div class="information-item">
                        <span class="information-label">Payment Method</span>
                        <span class="information-value">
                            💳
                            <%=order.getPaymentMode() != null
                                ? order.getPaymentMode()
                                : "COD"%>
                        </span>
                    </div>

                    <div class="information-item">
                        <span class="information-label">Delivery Address</span>
                        <span class="information-value">
                            📍
                            <%=order.getDeliveryAddress() != null
                                ? order.getDeliveryAddress()
                                : "Address Unavailable"%>
                        </span>
                    </div>
                </div>
            </section>

            <!-- Ordered Items Card -->
            <section class="items-card">
                <h2>Ordered Items</h2>

                <%
                    if (!orderItems.isEmpty()) {

                        for (OrderItem item : orderItems) {

                            Menu menu = menuById.get(item.getMenuId());

                            String itemName = menu != null
                                ? menu.getItemName()
                                : "Food Item #" + item.getMenuId();

                            String rawImg = menu != null
                                ? menu.getImagePath()
                                : "";

                            String itemImage =
                                resolveImage(rawImg, contextPath);
                %>

                <div class="order-item">
                    <div class="item-image-wrap">
                        <%
                            if (!itemImage.isEmpty()) {
                        %>
                            <img class="item-image"
                                src="<%=itemImage%>"
                                alt="<%=itemName%>"
                                onerror="this.style.display='none'">
                        <%
                            } else {
                        %>
                            <span class="item-fallback">🍲</span>
                        <%
                            }
                        %>
                    </div>

                    <div class="item-details">
                        <div class="item-name"><%=itemName%></div>

                        <div class="item-quantity">
                            Qty: <strong><%=item.getQuantity()%></strong>
                        </div>
                    </div>

                    <div class="item-price">
                        &#8377;<%=String.format(
                            Locale.US, "%.2f", item.getTotalAmount())%>
                    </div>
                </div>

                <%
                        }
                    } else {
                %>

                    <div class="no-items">
                        No items found for this order.
                    </div>

                <%
                    }
                %>

                <div class="bill-breakdown">
                    <div class="bill-row">
                        <span>Delivery Fee</span>
                        <span>&#8377;40.00</span>
                    </div>

                    <div class="bill-row total-row">
                        <span>Total Amount</span>
                        <strong class="total-price">
                            &#8377;<%=String.format(
                                Locale.US, "%.2f", order.getTotalAmount())%>
                        </strong>
                    </div>
                </div>
            </section>

        </div>
        <!-- End of printable area -->

        <!-- Action Buttons -->
        <div class="order-actions">

            <a href="<%=contextPath%>/orders" class="back-orders-btn">
                &larr; Back to Orders
            </a>

            <%
                if (rawStatus.contains("deliver") ||
                    rawStatus.contains("place")) {
            %>

                <a
                    href="<%=contextPath%>/reorder?orderId=<%=order.getOrderId()%>"
                    class="reorder-action-btn">
                    <span>🔄</span> Reorder
                </a>

            <%
                }
            %>

            <a href="<%=contextPath%>/restaurant"
                class="continue-shopping-btn">
                Explore More Restaurants &rarr;
            </a>

        </div>

        <%
            } else {
        %>

        <div class="items-card no-items-card">
            <h2>Order Not Found</h2>

            <p>
                Unable to retrieve the order details. Please check back later.
            </p>

            <a href="<%=contextPath%>/orders"
                class="continue-shopping-btn">
                Back to Orders
            </a>
        </div>

        <%
            }
        %>

    </main>

    <!-- PDF Invoice Download & Leaflet Map Simulation Script -->
    <script>
        function downloadInvoicePDF() {
            const element =
                document.getElementById('invoice-printable-area');

            if (!element) {
                alert('Invoice details could not be found.');
                return;
            }

            if (typeof html2pdf === 'undefined') {
                alert(
                    'PDF library could not be loaded. ' +
                    'Please check your internet connection and try again.'
                );
                return;
            }

            const opt = {
                margin: 10,
                filename: 'QuickBite-Invoice-QB-<%=order != null ? order.getOrderId() : "Order"%>.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true, backgroundColor: '#ffffff', scrollY: 0 },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' },
                pagebreak: { mode: ['css', 'legacy'] }
            };

            html2pdf().set(opt).from(element).save().catch(function(error) {
                console.error('Invoice PDF download failed:', error);
                alert('Unable to download the invoice. Please try again.');
            });
        }

        function openChatAlert(partnerName) {
            alert('QuickBite Live Chat: Connecting you with your delivery partner ' + partnerName + '...');
        }

        // Live Interactive Map with Scooter Simulation
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof L === 'undefined') {
                console.warn('Leaflet library is not available');
                return;
            }

            const mapContainer = document.getElementById('liveOrderMap');
            if (!mapContainer) return;

            // Bangalore coordinates:
            // Restaurant approx: Church Street / MG Road area [12.9754, 77.6045]
            // Customer delivery location approx: Indiranagar / Koramangala area [12.9630, 77.6380]
            const restCoords = [12.9754, 77.6045];
            const destCoords = [12.9630, 77.6380];
            const center = [(restCoords[0] + destCoords[0]) / 2, (restCoords[1] + destCoords[1]) / 2];

            const map = L.map('liveOrderMap', {
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
            L.marker(restCoords, { icon: restIcon }).addTo(map).bindPopup('<strong><%=restaurantName.replace("'", "\\'")%></strong><br>Food prepared and handed over to driver.');

            // Customer Destination Marker
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
            L.marker(destCoords, { icon: destIcon }).addTo(map).bindPopup('<strong>Delivery Location</strong><br><%=order != null && order.getDeliveryAddress() != null ? order.getDeliveryAddress().replace("'", "\\'") : "Bangalore"%>');

            // Realistic Route Waypoints
            const routeWaypoints = [
                restCoords,
                [12.9735, 77.6110],
                [12.9708, 77.6185],
                [12.9675, 77.6260],
                [12.9650, 77.6325],
                destCoords
            ];

            // Polyline styling
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

            // Scooter Marker with pulsating radar effect
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

            // Smooth interpolation animation along the route
            let segIdx = 0;
            let segT = 0;
            const etaEl = document.getElementById('etaTimeDisplay');

            setInterval(() => {
                segT += 0.04;
                if (segT >= 1) {
                    segT = 0;
                    segIdx++;
                    if (segIdx >= routeWaypoints.length - 1) {
                        segIdx = 0; // loop simulation
                    }
                }

                const p1 = routeWaypoints[segIdx];
                const p2 = routeWaypoints[segIdx + 1];

                const currentLat = p1[0] + (p2[0] - p1[0]) * segT;
                const currentLng = p1[1] + (p2[1] - p1[1]) * segT;

                scooterMarker.setLatLng([currentLat, currentLng]);

                if (etaEl) {
                    const remainingMins = Math.max(7, Math.round(22 - ((segIdx * 1.0 + segT) / (routeWaypoints.length - 1)) * 14));
                    etaEl.textContent = remainingMins + ' mins';
                }
            }, 300);
        });
    </script>

    <%@ include file="footer.jsp" %>

</body>
</html>
