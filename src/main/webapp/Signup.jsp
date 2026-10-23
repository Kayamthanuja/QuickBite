<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Create Account | QuickBite</title>

<!-- Common CSS -->
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/common.css">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/navbar.css">

<!-- Signup CSS with cache busting -->
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/signup.css?v=<%=System.currentTimeMillis()%>">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/footer.css">

</head>

<body>

	<!-- Common Navigation Bar -->
	<%@ include file="navbar.jsp"%>

	<!-- Signup Section with Food Background -->
	<main class="signup-container">

		<div class="signup-card-split">

			<!-- Left Image Panel (Matching Login Page Style) -->
			<div class="signup-image-panel">
				<div class="brand-badge">🍽️ QuickBite</div>
				<h2>Join QuickBite Today!</h2>
				<p>Create an account to explore top restaurants, unlock
					exclusive deals, and get your favorite dishes delivered straight to
					your door.</p>
			</div>

			<!-- Right Form Panel -->
			<div class="signup-form-panel">

				<!-- Signup Header -->
				<div class="signup-header">
					<h2 id="signupHeaderTitle">Create Account</h2>
					<p id="signupHeaderSubtitle">Sign up now and start ordering delicious food from top restaurants</p>
				</div>

				<!-- Error Message -->
				<%
				String signupError = (String) request.getAttribute("signupError");

				if (signupError != null) {
				%>

				<div class="error-message">
					⚠️
					<%=signupError%>
				</div>

				<%
				}
				%>

				<!-- Signup Form -->
				<form action="<%=request.getContextPath()%>/signup" method="post"
					class="signup-form">

					<input type="hidden" name="role" id="signupRoleInput" value="customer">

					<!-- Full Name -->
					<div class="form-group">
						<label for="name"> Full Name </label> <input type="text" id="name"
							name="name" placeholder="Enter your full name" required>
					</div>

					<!-- Email & Phone Row -->
					<div class="form-row">
						<div class="form-group">
							<label for="email"> Email </label> <input type="email" id="email"
								name="email" placeholder="Enter your email" required>
						</div>

						<div class="form-group">
							<label for="phone"> Phone Number </label> <input type="tel"
								id="phone" name="phone" placeholder="10-digit number"
								pattern="[0-9]{10}" maxlength="10" required>
						</div>
					</div>

					<!-- Password & Confirm Password Row -->
					<div class="form-row">
						<div class="form-group">
							<label for="password"> Password </label> <input type="password"
								id="password" name="password" placeholder="Create password"
								required>
						</div>

						<div class="form-group">
							<label for="confirmPassword"> Confirm Password </label> <input
								type="password" id="confirmPassword" name="confirmPassword"
								placeholder="Re-enter password" required>
						</div>
					</div>

					<!-- Address -->
					<div class="form-group">
						<label for="address"> Delivery Address </label>
						<textarea id="address" name="address"
							placeholder="Enter full house address, street name, etc."
							rows="2" required></textarea>
					</div>

					<!-- City and Pincode -->
					<div class="form-row">
						<div class="form-group">
							<label for="city"> City </label> <input type="text" id="city"
								name="city" placeholder="Enter city" required>
						</div>

						<div class="form-group">
							<label for="pincode"> Pincode </label> <input type="text"
								id="pincode" name="pincode" placeholder="6-digit pincode"
								pattern="[0-9]{6}" maxlength="6" required>
						</div>
					</div>

					<!-- Create Account Button -->
					<button type="submit" class="signup-btn">Create Account →</button>

				</form>

				<!-- Login Link -->
				<div class="login-text">
					<span>Already have an account?</span>
					<a href="<%=request.getContextPath()%>/login" class="login-link" id="loginBackLink">
						Login 
					</a>
				</div>

			</div>

		</div>

	</main>

	<!-- Common Footer -->
	<%@ include file="footer.jsp"%>

</body>

</html>