<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="com.tap.model.Cart"%>
<%@ page import="com.tap.model.CartItem"%>
<%@ page import="com.tap.model.User"%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Checkout | QuickBite</title>

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/common.css">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/navbar.css">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/checkout.css?v=<%=System.currentTimeMillis()%>">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/footer.css">

<link rel="stylesheet"
	href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
	integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
	crossorigin="" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
	integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
	crossorigin=""></script>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>

</head>

<body>

	<%@ include file="navbar.jsp"%>

	<%
	Cart cart = (Cart) request.getAttribute("cart");
	User user = (User) request.getAttribute("user");
	String checkoutError = (String) request.getAttribute("checkoutError");
	String contextPath = request.getContextPath();
	%>

	<main class="checkout-container container">

		<div class="checkout-header">
			<h2>Checkout</h2>
			<p>Pick your delivery location on the map and choose how you want
				to pay.</p>
		</div>

		<%
		if (checkoutError != null) {
			String msg = "Something went wrong. Please try again.";
			if ("invalidPincode".equals(checkoutError))
				msg = "Please enter a valid 6-digit PIN code.";
			else if ("invalidAddress".equals(checkoutError))
				msg = "Please set your delivery address using the map or the address field.";
			else if ("invalidPayment".equals(checkoutError))
				msg = "Please select a payment method.";
			else if ("paymentFailed".equals(checkoutError))
				msg = "Online payment failed or was cancelled. You can try again or choose COD.";
			else if ("orderFailed".equals(checkoutError))
				msg = "Could not place the order. Please try again.";
			else if ("useOnlinePay".equals(checkoutError))
				msg = "For UPI / Card, use the Proceed to Payment button so Razorpay can open.";
		%>
		<div class="checkout-error-banner">⚠️ <%=msg%></div>
		<%
		}
		%>

		<%
		if (cart == null || cart.getItems().isEmpty()) {
		%>

		<div class="checkout-card empty-state-card">
			<div class="empty-icon-circle">🛒</div>
			<h3>Your cart is empty</h3>
			<p>Please add some items before proceeding to checkout.</p>
			<a href="<%=contextPath%>/restaurant" class="back-cart-btn">
				Browse Restaurants </a>
		</div>

		<%
		} else if (user == null) {
		%>

		<div class="checkout-card empty-state-card">
			<div class="empty-icon-circle">🔐</div>
			<h3>Please Login</h3>
			<p>Please login before proceeding to checkout.</p>
			<a href="<%=contextPath%>/login" class="place-order-btn"> Login
				to Continue </a>
		</div>

		<%
		} else {
		%>

		<form action="<%=contextPath%>/checkout" method="post"
			id="checkoutForm">

			<div class="checkout-content">

				<div class="checkout-left">

					<div class="checkout-card">

						<h3 class="card-title">📍 Delivery Details</h3>

						<div class="form-row">
							<div class="form-group">
								<label for="name"> Full Name </label> <input type="text"
									id="name" name="name"
									value="<%=user.getUsername() != null ? user.getUsername() : ""%>"
									readonly>
							</div>

							<div class="form-group">
								<label for="phone"> Phone Number </label> <input type="text"
									id="phone" name="phone"
									value="<%=user.getPhone() != null ? user.getPhone() : ""%>"
									readonly>
							</div>
						</div>

						<div class="map-picker-toolbar">
							<button type="button" class="map-action-btn" id="useMyLocationBtn">
								Use my current location
							</button>
							<span class="map-hint">Or drag the pin / click on the map
								to set delivery point</span>
						</div>

						<div id="addressMap" class="address-map"></div>

						<input type="hidden" id="latitude" name="latitude" value="">
						<input type="hidden" id="longitude" name="longitude" value="">

						<div class="form-group">
							<label for="address"> Delivery Address </label>
							<textarea id="address" name="address" rows="2" required
								placeholder="House / street will auto-fill from map; you can edit it"><%=user.getAddress() != null ? user.getAddress() : ""%></textarea>
						</div>

						<div class="form-row">
							<div class="form-group">
								<label for="city"> City </label> <input type="text" id="city"
									name="city" value="Bangalore" required>
							</div>

							<div class="form-group">
								<label for="pincode"> PIN Code </label> <input type="text"
									id="pincode" name="pincode" placeholder="Enter PIN code"
									pattern="[0-9]{6}" maxlength="6" required>
							</div>
						</div>

					</div>

					<div class="checkout-card">

						<h3 class="card-title">💳 Payment Method</h3>

						<div class="payment-option-group">
							<label class="payment-option" for="cod">
								<div class="option-header">
									<input type="radio" id="cod" name="paymentMethod" value="COD"
										checked onclick="togglePaymentDetails()"> <span
										class="payment-icon">💵</span> <span class="payment-label">Cash
										on Delivery (COD)</span>
								</div>
							</label>

							<div id="cod-details" class="payment-details-panel active">
								<p class="payment-note">Pay with cash or UPI directly to the
									delivery partner when the order arrives.</p>
							</div>
						</div>

						<div class="payment-option-group">
							<label class="payment-option" for="upi">
								<div class="option-header">
									<input type="radio" id="upi" name="paymentMethod" value="UPI"
										onclick="togglePaymentDetails()"> <span
										class="payment-icon">📱</span> <span class="payment-label">UPI
										(Google Pay, PhonePe, Paytm)</span>
								</div>
							</label>

							<div id="upi-details" class="payment-details-panel">
								<p class="payment-note">Choose your UPI app. On mobile,
									Razorpay will open that app. On desktop you can pay with UPI ID
									or QR.</p>
								<div class="upi-app-grid">
									<label class="upi-app-tile" for="upiGpay">
										<input type="radio" id="upiGpay" name="upiApp" value="GPAY" checked>
										<span class="upi-app-logo gpay">GPay</span>
										<span class="upi-app-name">Google Pay</span>
									</label>
									<label class="upi-app-tile" for="upiPhonepe">
										<input type="radio" id="upiPhonepe" name="upiApp" value="PHONEPE">
										<span class="upi-app-logo phonepe">Pe</span>
										<span class="upi-app-name">PhonePe</span>
									</label>
									<label class="upi-app-tile" for="upiPaytm">
										<input type="radio" id="upiPaytm" name="upiApp" value="PAYTM">
										<span class="upi-app-logo paytm">Paytm</span>
										<span class="upi-app-name">Paytm</span>
									</label>
								</div>
							</div>
						</div>

						<div class="payment-option-group">
							<label class="payment-option" for="card">
								<div class="option-header">
									<input type="radio" id="card" name="paymentMethod" value="CARD"
										onclick="togglePaymentDetails()"> <span
										class="payment-icon">💳</span> <span class="payment-label">Credit
										/ Debit Card (Razorpay)</span>
								</div>
							</label>

							<div id="card-details" class="payment-details-panel">
								<p class="payment-note">Card details are collected securely
									on Razorpay — never entered on this page.</p>
							</div>
						</div>

					</div>

				</div>

				<aside class="checkout-summary">

					<h3>Order Summary</h3>

					<div class="summary-items-list">
						<%
						for (CartItem cartItem : cart.getItems()) {
						%>

						<div class="summary-item">
							<span><%=cartItem.getMenu().getItemName()%> × <%=cartItem.getQuantity()%></span>
							<strong>&#8377;<%=cartItem.getSubTotal()%></strong>
						</div>

						<%
						}
						%>
					</div>

					<div class="summary-item border-top-row">
						<span>Delivery Fee</span> <strong>&#8377;40</strong>
					</div>

					<div class="checkout-total">
						<span>Total Payable</span> <span class="total-price">&#8377;<%=cart.getTotalAmount() + 40%></span>
					</div>

					<input type="hidden" name="totalAmount"
						value="<%=cart.getTotalAmount() + 40%>">

					<button type="submit" class="place-order-btn" id="placeOrderBtn">Proceed
						to Payment →</button>

					<a href="<%=contextPath%>/cart" class="back-cart-btn">Back to
						Cart</a>

				</aside>

			</div>

		</form>

		<%
		}
		%>

	</main>

	<script>
		const contextPath = "<%=contextPath%>";

		function togglePaymentDetails() {
			const codRadio = document.getElementById("cod");
			const upiRadio = document.getElementById("upi");
			const cardRadio = document.getElementById("card");

			document.getElementById("cod-details").classList.toggle("active", codRadio.checked);
			document.getElementById("upi-details").classList.toggle("active", upiRadio.checked);
			document.getElementById("card-details").classList.toggle("active", cardRadio.checked);
		}

		function selectedUpiApp() {
			const picked = document.querySelector('input[name="upiApp"]:checked');
			return picked ? picked.value : "GPAY";
		}

		function razorpayCheckoutOptions(data, method) {
			const preferCard = method === "CARD";
			return {
				key: data.keyId,
				amount: data.amount,
				currency: data.currency || "INR",
				name: data.company || "QuickBite",
				description: "QuickBite Food Order #" + (data.orderId || ""),
				order_id: data.orderId,
				prefill: {
					name: data.customerName || "",
					email: data.customerEmail || "",
					contact: data.customerPhone || "",
					method: preferCard ? "card" : "upi"
				},
				notes: {
					merchant_order: data.orderId
				},
				theme: { color: "#f5a623" },
				modal: {
					confirm_close: true
				}
			};
		}

		/* ---------- Map address picker ---------- */
		(function initAddressMap() {
			const mapEl = document.getElementById("addressMap");
			if (!mapEl || typeof L === "undefined") return;

			const defaultCenter = [12.9716, 77.5946];
			const map = L.map("addressMap").setView(defaultCenter, 14);

			L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
				attribution: "&copy; OpenStreetMap",
				maxZoom: 19
			}).addTo(map);

			const marker = L.marker(defaultCenter, { draggable: true }).addTo(map);

			function setLatLng(lat, lng) {
				document.getElementById("latitude").value = lat.toFixed(6);
				document.getElementById("longitude").value = lng.toFixed(6);
			}

			async function reverseGeocode(lat, lng) {
				setLatLng(lat, lng);
				try {
					const url = "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat="
						+ lat + "&lon=" + lng + "&addressdetails=1";
					const res = await fetch(url, {
						headers: { "Accept": "application/json" }
					});
					const data = await res.json();
					const addr = data.address || {};

					const parts = [
						addr.house_number,
						addr.road,
						addr.neighbourhood || addr.suburb,
						addr.city_district
					].filter(Boolean);

					if (parts.length) {
						document.getElementById("address").value = parts.join(", ");
					} else if (data.display_name) {
						document.getElementById("address").value = data.display_name;
					}

					if (addr.city || addr.town || addr.village) {
						document.getElementById("city").value = addr.city || addr.town || addr.village;
					}
					if (addr.postcode) {
						document.getElementById("pincode").value = String(addr.postcode).replace(/\D/g, "").slice(0, 6);
					}
				} catch (e) {
					console.warn("Reverse geocode failed", e);
				}
			}

			marker.on("dragend", function () {
				const pos = marker.getLatLng();
				reverseGeocode(pos.lat, pos.lng);
			});

			map.on("click", function (e) {
				marker.setLatLng(e.latlng);
				reverseGeocode(e.latlng.lat, e.latlng.lng);
			});

			document.getElementById("useMyLocationBtn").addEventListener("click", function () {
				if (!navigator.geolocation) {
					alert("Geolocation is not supported by your browser.");
					return;
				}
				navigator.geolocation.getCurrentPosition(function (pos) {
					const lat = pos.coords.latitude;
					const lng = pos.coords.longitude;
					marker.setLatLng([lat, lng]);
					map.setView([lat, lng], 16);
					reverseGeocode(lat, lng);
				}, function () {
					alert("Unable to get your location. Please allow location access or pick on the map.");
				}, { enableHighAccuracy: true, timeout: 10000 });
			});

			setTimeout(function () { map.invalidateSize(); }, 200);
		})();

		/* ---------- Checkout submit: COD vs Razorpay ---------- */
		document.getElementById("checkoutForm").addEventListener("submit", async function (e) {
			const method = document.querySelector('input[name="paymentMethod"]:checked').value;

			if (method === "COD") {
				return;
			}

			e.preventDefault();

			const address = document.getElementById("address").value.trim();
			const city = document.getElementById("city").value.trim();
			const pincode = document.getElementById("pincode").value.trim();

			if (!address || !/^\d{6}$/.test(pincode)) {
				alert("Please set delivery address and a valid 6-digit PIN code.");
				return;
			}

			if (typeof Razorpay === "undefined") {
				alert("Razorpay could not load. Check your internet connection.");
				return;
			}

			const btn = document.getElementById("placeOrderBtn");
			btn.disabled = true;
			btn.textContent = "Opening Razorpay...";

			try {
				const body = new URLSearchParams();
				body.append("address", address);
				body.append("city", city);
				body.append("pincode", pincode);
				const resolvedMethod = method === "UPI" ? selectedUpiApp() : method;
				body.append("paymentMethod", resolvedMethod);
				body.append("latitude", document.getElementById("latitude").value);
				body.append("longitude", document.getElementById("longitude").value);

				const res = await fetch(contextPath + "/razorpay/createOrder", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});

				const data = await res.json();

				if (!data.success) {
					alert(data.message || "Unable to start payment.");
					btn.disabled = false;
					btn.textContent = "Proceed to Payment →";
					return;
				}

				const options = razorpayCheckoutOptions(data, method);
				options.handler = function (response) {
					const form = document.createElement("form");
					form.method = "POST";
					form.action = contextPath + "/razorpay/verify";

					["razorpay_payment_id", "razorpay_order_id", "razorpay_signature"].forEach(function (key) {
						const input = document.createElement("input");
						input.type = "hidden";
						input.name = key;
						input.value = response[key];
						form.appendChild(input);
					});

					document.body.appendChild(form);
					form.submit();
				};
				options.modal = {
					ondismiss: function () {
						btn.disabled = false;
						btn.textContent = "Proceed to Payment →";
					}
				};

				const rzp = new Razorpay(options);
				rzp.on("payment.failed", function () {
					alert("Payment failed. Please try again or choose Cash on Delivery.");
					btn.disabled = false;
					btn.textContent = "Proceed to Payment →";
				});
				rzp.open();
			} catch (err) {
				console.error(err);
				alert("Payment could not be started. Please try again.");
				btn.disabled = false;
				btn.textContent = "Proceed to Payment →";
			}
		});
	</script>

	<%@ include file="footer.jsp"%>

</body>

</html>
