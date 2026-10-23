<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login | QuickBite</title>

<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/common.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/navbar.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/login.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/footer.css">

<style>
.login-methods {
    display: flex;
    gap: 10px;
    margin: 18px 0;
    position: relative;
    z-index: 5;
}

.login-method-btn {
    flex: 1;
    padding: 11px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background: #fff;
    color: #3b2418;
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
}

.login-method-btn.active {
    background: #f5a623 !important;
    color: #3b2418 !important;
    border-color: #f5a623 !important;
}

.login-method-btn:hover {
    border-color: #f5a623;
}

.hidden-panel {
    display: none !important;
}

.otp-info-banner {
    margin: 12px 0;
    padding: 12px;
    border-radius: 8px;
    font-size: 14px;
}

.otp-info-banner.success {
    background: #def7ec;
    color: #03543f;
    border: 1px solid #bcf0da;
}

.otp-info-banner.error {
    background: #fde8e8;
    color: #9b1c1c;
    border: 1px solid #f8b4b4;
}

.resend-otp-btn {
    display: block;
    margin: 14px auto 0;
    border: none;
    background: transparent;
    cursor: pointer;
    color: #e89512;
    font-weight: 600;
}

.login-btn:disabled,
.resend-otp-btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
}

.forgot-password-row {
    display: flex;
    justify-content: flex-end;
    margin: -5px 0 16px;
}

.forgot-password-row a {
    color: #e89512;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
}

.forgot-password-row a:hover {
    color: #c87908;
    text-decoration: underline;
}

.account-role-options {
    display: flex;
    gap: 10px;
    margin-top: 16px;
}

.account-role-btn {
    flex: 1;
    min-height: 42px;
    padding: 10px;
    border: 1px solid #f0dfcb;
    border-radius: 9px;
    background: #fff;
    color: #3b2418;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
}

.account-role-btn:hover {
    border-color: #f5a623;
}

.account-role-btn.active {
    background: #f5a623;
    border-color: #f5a623;
    color: #3b2418;
}

[data-theme="dark"] .account-role-btn {
    background: #15181e;
    border-color: #2c323b;
    color: #f0f3f6;
}

[data-theme="dark"] .account-role-btn.active {
    background: #f5a623;
    border-color: #f5a623;
    color: #3b2418;
}

.account-role-btn:focus-visible,
.login-method-btn:focus-visible {
    outline: 2px solid #f5a623;
    outline-offset: 3px;
}

@media (max-width: 380px) {
    .account-role-options {
        flex-direction: column;
    }
}
</style>
</head>

<body>

<%@ include file="navbar.jsp"%>

<main class="login-container">
    <div class="login-card-split">

        <div class="login-image-panel">
            <div class="brand-badge">🍽️ QuickBite</div>
            <h2>Welcome Back!</h2>
            <p>
                Indulge your taste buds at QuickBite, where every flavor
                tells a delicious story. Welcome back to your food journey!
            </p>
        </div>

        <div class="login-form-panel">

            <div class="login-header">
                <h2 id="loginHeading">Login to QuickBite</h2>
                <p id="loginDescription">Choose how you want to log in.</p>
            </div>

            <%
                String error = request.getParameter("error");
                String signup = request.getParameter("signup");
                String role = request.getParameter("role");

                if (role == null) {
                    role = "";
                }

                boolean adminMode = "admin".equalsIgnoreCase(role);
            %>

            <% if ("invalidCredentials".equals(error)) { %>
                <div class="error-message">
                    Invalid email or password. Please try again.
                </div>
            <% } else if ("missing".equals(error)) { %>
                <div class="error-message">
                    Please enter your email and password.
                </div>
            <% } else if ("otpInvalid".equals(error)) { %>
                <div class="error-message">
                    Invalid OTP. Please check the code and try again.
                </div>
            <% } else if ("otpExpired".equals(error)) { %>
                <div class="error-message">
                    Your OTP has expired. Please request a new one.
                </div>
            <% } else if ("otpAttempts".equals(error)) { %>
                <div class="error-message">
                    Too many incorrect attempts. Request a new OTP.
                </div>
            <% } else if ("notAdmin".equals(error)) { %>
                <div class="error-message">
                    This account does not have administrator access.
                </div>
            <% } else if ("notDelivery".equals(error)) { %>
                <div class="error-message">
                    This account does not have delivery-partner access.
                </div>
            <% } else if ("notCustomer".equals(error)) { %>
                <div class="error-message">
                    Please use the correct login option for this account.
                </div>
            <% } else if ("wrongLoginOption".equals(error)) { %>
                <div class="error-message">
                    Please select the correct login option.
                </div>
            <% } else if ("configError".equals(error)) { %>
                <div class="error-message">
                    Admin login configuration is missing.
                    Please check the Tomcat environment variables.
                </div>
            <% } else if ("adminRequired".equals(error)) { %>
                <div class="error-message">
                    Please log in with an administrator account.
                </div>
            <% } else if ("success".equals(signup)) { %>
                <div class="error-message"
                     style="background:#def7ec;color:#03543f;">
                    Account created successfully! You can now log in.
                </div>
            <% } %>

            <div id="otpInfoBanner"
                 class="otp-info-banner hidden-panel"
                 role="status"
                 aria-live="polite"></div>

            <!-- Login method tabs: available for both roles -->
            <div class="login-methods" id="loginMethods">
                <button type="button"
                        id="passwordTab"
                        class="login-method-btn active">
                    Email &amp; Password
                </button>

                <button type="button"
                        id="otpTab"
                        class="login-method-btn">
                    Login with OTP
                </button>
            </div>

            <!-- Email and password login -->
            <form action="<%=request.getContextPath()%>/login"
                  method="post"
                  id="passwordForm"
                  class="login-form">

                <input type="hidden"
                       name="targetRole"
                       id="passwordTargetRole"
                       value="<%=adminMode ? "admin" : "customer"%>">

                <div class="form-group">
                    <label for="passwordEmail">Registered Email</label>
                    <input type="email"
                           id="passwordEmail"
                           name="email"
                           placeholder="Enter your registered email"
                           autocomplete="email"
                           maxlength="254"
                           required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password"
                           id="password"
                           name="password"
                           placeholder="Enter your password"
                           autocomplete="current-password"
                           required>
                </div>

                <div class="forgot-password-row">
                    <a href="<%=request.getContextPath()%>/forgot-password.jsp">
                        Forgot Password?
                    </a>
                </div>

                <button type="submit" class="login-btn">
                    Login →
                </button>
            </form>

            <!-- OTP request: available for both roles -->
            <div id="emailStep" class="hidden-panel">
                <div class="form-group">
                    <label for="otpEmail">Registered Email</label>
                    <input type="email"
                           id="otpEmail"
                           placeholder="Enter your registered email"
                           autocomplete="email"
                           maxlength="254">
                </div>

                <button type="button"
                        class="login-btn"
                        id="sendOtpBtn">
                    Send OTP →
                </button>
            </div>

            <!-- OTP verification: selected role is submitted to controller -->
            <form action="<%=request.getContextPath()%>/otpLogin"
                  method="post"
                  id="otpVerifyForm"
                  class="login-form hidden-panel">

                <input type="hidden" name="action" value="verify">

                <input type="hidden"
                       name="email"
                       id="verifiedEmail">

                <input type="hidden"
                       name="targetRole"
                       id="otpTargetRole"
                       value="<%=adminMode ? "admin" : "customer"%>">

                <div class="form-group">
                    <label for="otpCode">Enter 6-Digit OTP</label>
                    <input type="text"
                           id="otpCode"
                           name="otp"
                           placeholder="Enter the code sent to your email"
                           inputmode="numeric"
                           pattern="[0-9]{6}"
                           maxlength="6"
                           autocomplete="one-time-code"
                           required>
                </div>

                <button type="submit"
                        class="login-btn"
                        id="verifyOtpBtn">
                    Verify OTP &amp; Login →
                </button>

                <button type="button"
                        class="resend-otp-btn"
                        id="resendOtpBtn">
                    Resend OTP
                </button>
            </form>

            <div class="register-text" id="registerText">
                <span>Don't have an account?</span>
                <a href="<%=request.getContextPath()%>/Signup.jsp"
                   class="register-link">Sign Up</a>
            </div>

            <!-- Choose customer or admin login -->
            <div class="account-role-options">
                <button type="button"
                        id="customerRoleBtn"
                        class="account-role-btn <%=adminMode ? "" : "active"%>">
                    Login as Customer
                </button>

                <button type="button"
                        id="adminRoleBtn"
                        class="account-role-btn <%=adminMode ? "active" : ""%>">
                    Login as Admin
                </button>
            </div>

        </div>
    </div>
</main>

<%@ include file="footer.jsp"%>

<script>
(function () {
    "use strict";

    const contextPath = "<%=request.getContextPath()%>";

    const passwordTab = document.getElementById("passwordTab");
    const otpTab = document.getElementById("otpTab");
    const loginMethods = document.getElementById("loginMethods");

    const passwordForm = document.getElementById("passwordForm");
    const emailStep = document.getElementById("emailStep");
    const otpVerifyForm = document.getElementById("otpVerifyForm");

    const otpEmail = document.getElementById("otpEmail");
    const verifiedEmail = document.getElementById("verifiedEmail");
    const otpInput = document.getElementById("otpCode");
    const banner = document.getElementById("otpInfoBanner");

    const sendBtn = document.getElementById("sendOtpBtn");
    const resendBtn = document.getElementById("resendOtpBtn");
    const verifyBtn = document.getElementById("verifyOtpBtn");

    const customerRoleBtn = document.getElementById("customerRoleBtn");
    const adminRoleBtn = document.getElementById("adminRoleBtn");

    const passwordTargetRole =
        document.getElementById("passwordTargetRole");
    const otpTargetRole =
        document.getElementById("otpTargetRole");

    const loginHeading = document.getElementById("loginHeading");
    const loginDescription =
        document.getElementById("loginDescription");
    const registerText = document.getElementById("registerText");

    let selectedRole =
        passwordTargetRole.value === "admin" ? "admin" : "customer";

    function showMessage(message, type) {
        banner.textContent = message;
        banner.className = "otp-info-banner " + type;
    }

    function hideMessage() {
        banner.textContent = "";
        banner.className = "otp-info-banner hidden-panel";
    }

    function resetOtpForm() {
        otpEmail.value = "";
        verifiedEmail.value = "";
        otpInput.value = "";

        emailStep.classList.add("hidden-panel");
        otpVerifyForm.classList.add("hidden-panel");

        sendBtn.disabled = false;
        resendBtn.disabled = false;
        verifyBtn.disabled = false;
        sendBtn.textContent = "Send OTP →";
    }

    function setRole(role) {
        selectedRole = role;

        passwordTargetRole.value = role;
        otpTargetRole.value = role;

        customerRoleBtn.classList.toggle(
            "active", role === "customer"
        );

        adminRoleBtn.classList.toggle(
            "active", role === "admin"
        );

        if (role === "admin") {
            loginHeading.textContent = "Admin Login to QuickBite";
            loginDescription.textContent =
                "Choose email and password or login with OTP.";

            // Keep both login methods visible for admin.
            loginMethods.classList.remove("hidden-panel");

            // Signup is only for customers.
            registerText.classList.add("hidden-panel");
        } else {
            loginHeading.textContent = "Login to QuickBite";
            loginDescription.textContent =
                "Choose how you want to log in.";

            loginMethods.classList.remove("hidden-panel");
            registerText.classList.remove("hidden-panel");
        }

        resetOtpForm();
        showLoginMethod("password");
        hideMessage();
    }

    function showLoginMethod(method) {
        const useOtp = method === "otp";

        passwordForm.classList.toggle("hidden-panel", useOtp);
        emailStep.classList.toggle("hidden-panel", !useOtp);
        otpVerifyForm.classList.add("hidden-panel");

        passwordTab.classList.toggle("active", !useOtp);
        otpTab.classList.toggle("active", useOtp);

        hideMessage();

        if (useOtp) {
            otpEmail.focus();
        }
    }

    customerRoleBtn.addEventListener("click", function () {
        setRole("customer");
    });

    adminRoleBtn.addEventListener("click", function () {
        setRole("admin");
    });

    passwordTab.addEventListener("click", function () {
        resetOtpForm();
        showLoginMethod("password");
    });

    otpTab.addEventListener("click", function () {
        showLoginMethod("otp");
    });

    async function sendOtp() {
        const email = otpEmail.value.trim().toLowerCase();

        if (!email || !otpEmail.checkValidity()) {
            otpEmail.reportValidity();
            return;
        }

        sendBtn.disabled = true;
        resendBtn.disabled = true;
        sendBtn.textContent = "Sending OTP...";

        try {
            const body = new URLSearchParams();

            body.append("action", "send");
            body.append("email", email);
            body.append("targetRole", selectedRole);

            const response = await fetch(contextPath + "/otpLogin", {
                method: "POST",
                headers: {
                    "Content-Type":
                        "application/x-www-form-urlencoded;charset=UTF-8"
                },
                body: body.toString()
            });

            const data = await response.json();

            if (!response.ok || !data.success) {
                showMessage(
                    data.message ||
                    "Unable to send OTP. Please try again.",
                    "error"
                );
                return;
            }

            verifiedEmail.value = email;
            otpTargetRole.value = selectedRole;
            otpInput.value = "";

            emailStep.classList.add("hidden-panel");
            otpVerifyForm.classList.remove("hidden-panel");

            showMessage(
                data.message ||
                "OTP sent successfully. Check your email, including Spam.",
                "success"
            );

            otpInput.focus();

        } catch (error) {
            console.error("OTP request failed:", error);

            showMessage(
                "Unable to contact the server. Please try again.",
                "error"
            );
        } finally {
            sendBtn.disabled = false;
            resendBtn.disabled = false;
            sendBtn.textContent = "Send OTP →";
        }
    }

    sendBtn.addEventListener("click", sendOtp);
    resendBtn.addEventListener("click", sendOtp);

    otpVerifyForm.addEventListener("submit", function (event) {
        if (!/^[0-9]{6}$/.test(otpInput.value.trim())) {
            event.preventDefault();

            showMessage(
                "Please enter the complete 6-digit OTP.",
                "error"
            );

            otpInput.focus();
            return;
        }

        // Ensure the selected role reaches OTPLoginController.
        otpTargetRole.value = selectedRole;
        verifiedEmail.value = verifiedEmail.value.trim().toLowerCase();

        verifyBtn.disabled = true;
        verifyBtn.textContent = "Verifying OTP...";
    });

    // Apply the initial role selected through the URL.
    setRole(selectedRole);
})();
</script>

</body>
</html>