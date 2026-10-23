<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Login | QuickBite</title>

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/common.css">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/navbar.css">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/login.css?v=<%=System.currentTimeMillis()%>">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/CSS/footer.css">

</head>

<body>

	<%@ include file="navbar.jsp"%>

	<main class="login-container">

		<div class="login-card-split">

			<!-- Left Food Presentation Panel -->
			<div class="login-image-panel" id="loginImagePanel">
				<div class="brand-badge">🍽️ QuickBite</div>
				<h2 id="leftPanelTitle">Welcome Back!</h2>
				<p id="leftPanelSubtitle">Indulge your taste buds at QuickBite, where every flavor
					tells a delicious story. Welcome to a culinary journey like no
					other!</p>
			</div>

			<!-- Right Form Panel -->
			<div class="login-form-panel">

				<!-- Standard Login View (Email / Phone OTP) -->
				<div id="standardLoginView">
					<div class="login-header">
						<h2 id="formTitle">Login to QuickBite</h2>
						<p id="formSubtitle">Use email &amp; password or login with OTP on your phone</p>
					</div>

					<%
					String error = request.getParameter("error");
					String activeTab = "otp".equals(request.getParameter("tab")) ? "otp" : "email";
					String resetParam = request.getParameter("reset");
					String signupParam = request.getParameter("signup");
					%>

					<%
					if ("invalid".equals(error)) {
					%>
					<div class="error-message">⚠️ Invalid email or password. Please check your details and try again.</div>
					<%
					} else if ("otpInvalid".equals(error)) {
					%>
					<div class="error-message">⚠️ Invalid or expired OTP. Please enter the correct code or request a new one.</div>
					<%
					}
					%>

					<%
					if ("success".equals(signupParam)) {
					%>
					<div class="error-message" style="background-color: #def7ec; border-color: #bcf0da; color: #03543f;">
						✓ Account created successfully! Please sign in with your credentials.
					</div>
					<%
					} else if ("success".equals(resetParam)) {
					%>
					<div class="error-message" style="background-color: #def7ec; border-color: #bcf0da; color: #03543f;">
						✓ Password reset successfully! Please sign in with your new password.
					</div>
					<%
					}
					%>

					<div class="login-tabs" role="tablist" id="authMethodTabs">
						<button type="button" class="login-tab <%=!"otp".equals(activeTab) ? "active" : ""%>"
							id="tabEmailBtn" onclick="switchLoginTab('email')">Email &amp; Password</button>
						<button type="button" class="login-tab <%="otp".equals(activeTab) ? "active" : ""%>"
							id="tabOtpBtn" onclick="switchLoginTab('otp')">Phone OTP</button>
					</div>

					<!-- Email / Password Form -->
					<form action="<%=request.getContextPath()%>/login" method="post"
						class="login-form <%=!"otp".equals(activeTab) ? "" : "hidden-panel"%>"
						id="emailLoginForm">

						<div class="form-group">
							<label for="email" id="emailLabel">Email Address</label>
							<input type="email" id="email" name="email" placeholder="enter your email" required autocomplete="username">
						</div>

						<div class="form-group">
							<label for="password">Password</label>
							<input type="password" id="password" name="password" placeholder="enter your password" required autocomplete="current-password">
						</div>

						<div class="form-help-row">
							<a href="javascript:void(0)" class="forgot-link" onclick="toggleResetPassword(true)">
								Forgot Password?
							</a>
						</div>

						<button type="submit" class="login-btn" id="emailSubmitBtn">Login →</button>
					</form>

					<!-- Phone OTP Form -->
					<div id="otpLoginPanel" class="<%= "otp".equals(activeTab) ? "" : "hidden-panel"%>">

						<div id="otpInfoBanner" class="otp-info-banner hidden-panel"></div>

						<div class="form-group" id="phoneGroup">
							<label for="otpPhone">Phone Number</label>
							<input type="tel" id="otpPhone" name="phone" placeholder="10-digit mobile number"
								pattern="[0-9]{10}" maxlength="10" inputmode="numeric">
						</div>

						<button type="button" class="login-btn" id="sendOtpBtn" onclick="sendOtp()">Send OTP →</button>

						<form action="<%=request.getContextPath()%>/otpLogin" method="post"
							class="login-form otp-verify-form hidden-panel" id="otpVerifyForm">

							<input type="hidden" name="action" value="verify">
							<input type="hidden" name="phone" id="otpPhoneHidden">

							<div class="form-group">
								<label for="otpCode">Enter 6-Digit OTP</label>
								<input type="text" id="otpCode" name="otp" placeholder="6-digit OTP" maxlength="6"
									pattern="[0-9]{6}" inputmode="numeric" required>
							</div>

							<button type="submit" class="login-btn" id="verifyOtpBtn">Verify &amp; Login →</button>

							<button type="button" class="resend-otp-btn" onclick="sendOtp()">Resend OTP</button>
						</form>
					</div>

					<div class="register-text" id="registerSection">
						<span>Don't have an account?</span>
						<a href="<%=request.getContextPath()%>/Signup.jsp" class="register-link">Sign Up as Customer</a>
					</div>
				</div>

				<!-- Reset Password Panel (Email OTP flow) -->
				<div id="resetPasswordPanel" class="hidden-panel">
					<div class="login-header">
						<h2>Reset Password</h2>
						<p>Verify your registered email address with an OTP code to create a new password</p>
					</div>

					<div id="resetAlertBanner" class="otp-info-banner hidden-panel"></div>

					<!-- Step 1: Enter Email -->
					<div id="resetStep1">
						<div class="form-group">
							<label for="resetEmailInput">Registered Email Address</label>
							<input type="email" id="resetEmailInput" placeholder="name@example.com" required>
						</div>

						<button type="button" class="login-btn" id="btnSendResetOtp" onclick="sendResetOtp()">
							Send Reset Code →
						</button>
					</div>

					<!-- Step 2: Enter OTP & New Password -->
					<div id="resetStep2" class="hidden-panel">
						<div class="form-group">
							<label for="resetOtpCodeInput">6-Digit OTP Code</label>
							<input type="text" id="resetOtpCodeInput" placeholder="Enter 6-digit OTP" maxlength="6"
								pattern="[0-9]{6}" inputmode="numeric" required>
						</div>

						<div class="form-group">
							<label for="resetNewPassInput">New Password</label>
							<input type="password" id="resetNewPassInput" placeholder="At least 6 characters" minlength="6" required>
						</div>

						<div class="form-group">
							<label for="resetConfirmPassInput">Confirm New Password</label>
							<input type="password" id="resetConfirmPassInput" placeholder="Re-enter new password" minlength="6" required>
						</div>

						<button type="button" class="login-btn" id="btnSubmitReset" onclick="submitPasswordReset()">
							Update Password →
						</button>

						<button type="button" class="resend-otp-btn" onclick="sendResetOtp()">Resend Code</button>
					</div>

					<div class="register-text" style="margin-top: 20px;">
						<a href="javascript:void(0)" class="register-link" onclick="toggleResetPassword(false)">
							← Back to Login
						</a>
					</div>
				</div>

			</div>

		</div>

	</main>

	<%@ include file="footer.jsp"%>

	<script>
		const contextPath = "<%=request.getContextPath()%>";

		function switchLoginTab(tab) {
			const emailForm = document.getElementById("emailLoginForm");
			const otpPanel = document.getElementById("otpLoginPanel");
			const emailBtn = document.getElementById("tabEmailBtn");
			const otpBtn = document.getElementById("tabOtpBtn");

			if (tab === "otp") {
				emailForm.classList.add("hidden-panel");
				otpPanel.classList.remove("hidden-panel");
				emailBtn.classList.remove("active");
				otpBtn.classList.add("active");
			} else {
				otpPanel.classList.add("hidden-panel");
				emailForm.classList.remove("hidden-panel");
				otpBtn.classList.remove("active");
				emailBtn.classList.add("active");
			}
		}

		function autofillOtp(code) {
			const input = document.getElementById("otpCode");
			if (input) {
				input.value = code;
				input.focus();
			}
		}

		function autofillResetOtp(code) {
			const input = document.getElementById("resetOtpCodeInput");
			if (input) {
				input.value = code;
				input.focus();
			}
		}

		/* Phone OTP Login */
		async function sendOtp() {
			const phoneInput = document.getElementById("otpPhone");
			const phone = (phoneInput.value || "").replace(/\D/g, "");
			const banner = document.getElementById("otpInfoBanner");
			const sendBtn = document.getElementById("sendOtpBtn");

			if (!/^\d{10}$/.test(phone)) {
				banner.className = "otp-info-banner error";
				banner.textContent = "Please enter a valid 10-digit mobile number.";
				banner.classList.remove("hidden-panel");
				return;
			}

			sendBtn.disabled = true;
			sendBtn.textContent = "Sending OTP...";

			try {
				const body = new URLSearchParams();
				body.append("action", "send");
				body.append("phone", phone);

				const response = await fetch(contextPath + "/otpLogin", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});

				const data = await response.json();

				if (!data.success) {
					banner.className = "otp-info-banner error";
					banner.textContent = data.message || "Unable to send OTP.";
					banner.classList.remove("hidden-panel");
					return;
				}

				document.getElementById("otpPhoneHidden").value = phone;
				document.getElementById("otpVerifyForm").classList.remove("hidden-panel");
				sendBtn.classList.add("hidden-panel");

				banner.className = "otp-info-banner success";
				
				let bannerHtml = "<div>✓ " + (data.message || "OTP generated successfully.") + "</div>";
				if (data.otp) {
					bannerHtml += "<div class='demo-otp-badge'>"
						+ "<span>Test OTP: <strong style='font-size: 15px; color:#b45309;'>" + data.otp + "</strong></span>"
						+ "<button type='button' class='btn-autofill' onclick=\"autofillOtp('" + data.otp + "')\">⚡ Autofill Code</button>"
						+ "</div>";
					autofillOtp(data.otp);
				}
				banner.innerHTML = bannerHtml;
				banner.classList.remove("hidden-panel");

				const codeInput = document.getElementById("otpCode");
				if (codeInput && !data.otp) {
					codeInput.value = "";
					codeInput.focus();
				}
			} catch (err) {
				banner.className = "otp-info-banner error";
				banner.textContent = "Network error. Please try again.";
				banner.classList.remove("hidden-panel");
			} finally {
				sendBtn.disabled = false;
				sendBtn.textContent = "Send OTP →";
			}
		}

		/* Reset Password (Email OTP) Flow */
		function toggleResetPassword(showReset) {
			const stdView = document.getElementById("standardLoginView");
			const resetView = document.getElementById("resetPasswordPanel");
			const alertBanner = document.getElementById("resetAlertBanner");
			alertBanner.classList.add("hidden-panel");

			if (showReset) {
				stdView.classList.add("hidden-panel");
				resetView.classList.remove("hidden-panel");
				document.getElementById("resetStep1").classList.remove("hidden-panel");
				document.getElementById("resetStep2").classList.add("hidden-panel");
				const emailField = document.getElementById("resetEmailInput");
				if (emailField) {
					const mainEmail = document.getElementById("email");
					if (mainEmail && mainEmail.value) {
						emailField.value = mainEmail.value;
					}
					emailField.focus();
				}
			} else {
				resetView.classList.add("hidden-panel");
				stdView.classList.remove("hidden-panel");
			}
		}

		async function sendResetOtp() {
			const emailInput = document.getElementById("resetEmailInput");
			const email = (emailInput.value || "").trim();
			const banner = document.getElementById("resetAlertBanner");
			const btn = document.getElementById("btnSendResetOtp");

			if (!email || !email.includes("@")) {
				banner.className = "otp-info-banner error";
				banner.textContent = "Please enter a valid registered email address.";
				banner.classList.remove("hidden-panel");
				return;
			}

			btn.disabled = true;
			btn.textContent = "Sending Code...";

			try {
				const body = new URLSearchParams();
				body.append("action", "sendOtp");
				body.append("email", email);

				const resp = await fetch(contextPath + "/resetPassword", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});

				const data = await resp.json();

				if (!data.success) {
					banner.className = "otp-info-banner error";
					banner.textContent = data.message || "Failed to send reset OTP.";
					banner.classList.remove("hidden-panel");
					return;
				}

				banner.className = "otp-info-banner success";
				let bannerHtml = "<div>✓ " + (data.message || "OTP sent to your email.") + "</div>";
				if (data.otp) {
					bannerHtml += "<div class='demo-otp-badge'>"
						+ "<span>Test OTP: <strong style='font-size: 15px; color:#b45309;'>" + data.otp + "</strong></span>"
						+ "<button type='button' class='btn-autofill' onclick=\"autofillResetOtp('" + data.otp + "')\">⚡ Autofill Code</button>"
						+ "</div>";
					autofillResetOtp(data.otp);
				}
				banner.innerHTML = bannerHtml;
				banner.classList.remove("hidden-panel");

				document.getElementById("resetStep1").classList.add("hidden-panel");
				document.getElementById("resetStep2").classList.remove("hidden-panel");

			} catch (err) {
				banner.className = "otp-info-banner error";
				banner.textContent = "Network error. Please try again.";
				banner.classList.remove("hidden-panel");
			} finally {
				btn.disabled = false;
				btn.textContent = "Send Reset Code →";
			}
		}

		async function submitPasswordReset() {
			const email = (document.getElementById("resetEmailInput").value || "").trim();
			const otp = (document.getElementById("resetOtpCodeInput").value || "").trim();
			const newPassword = document.getElementById("resetNewPassInput").value;
			const confirmPassword = document.getElementById("resetConfirmPassInput").value;
			const banner = document.getElementById("resetAlertBanner");
			const btn = document.getElementById("btnSubmitReset");

			if (!otp || otp.length < 6) {
				banner.className = "otp-info-banner error";
				banner.textContent = "Please enter the 6-digit OTP code sent to your email.";
				banner.classList.remove("hidden-panel");
				return;
			}

			if (!newPassword || newPassword.length < 6) {
				banner.className = "otp-info-banner error";
				banner.textContent = "New password must be at least 6 characters long.";
				banner.classList.remove("hidden-panel");
				return;
			}

			if (newPassword !== confirmPassword) {
				banner.className = "otp-info-banner error";
				banner.textContent = "Passwords do not match. Please re-enter.";
				banner.classList.remove("hidden-panel");
				return;
			}

			btn.disabled = true;
			btn.textContent = "Updating Password...";

			try {
				const body = new URLSearchParams();
				body.append("action", "verifyAndReset");
				body.append("ajax", "true");
				body.append("email", email);
				body.append("otp", otp);
				body.append("newPassword", newPassword);
				body.append("confirmPassword", confirmPassword);

				const resp = await fetch(contextPath + "/resetPassword", {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded" },
					body: body.toString()
				});

				const data = await resp.json();

				if (!data.success) {
					banner.className = "otp-info-banner error";
					banner.textContent = data.message || "Failed to reset password.";
					banner.classList.remove("hidden-panel");
					return;
				}

				// Reset succeeded: redirect to login with success flash
				window.location.href = contextPath + "/login?reset=success";

			} catch (err) {
				banner.className = "otp-info-banner error";
				banner.textContent = "Network error. Please try again.";
				banner.classList.remove("hidden-panel");
			} finally {
				btn.disabled = false;
				btn.textContent = "Update Password →";
			}
		}

		// Check if URL has ?tab=reset to open reset password immediately
		document.addEventListener("DOMContentLoaded", function() {
			const params = new URLSearchParams(window.location.search);
			if (params.get("tab") === "reset") {
				toggleResetPassword(true);
			}
		});
	</script>

</body>
</html>
