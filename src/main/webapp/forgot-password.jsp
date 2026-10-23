
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String cp = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password | QuickBite</title>

    <link rel="stylesheet" href="<%=cp%>/CSS/common.css">
    <link rel="stylesheet" href="<%=cp%>/CSS/navbar.css">
    <link rel="stylesheet" href="<%=cp%>/CSS/footer.css">

    <style>
        .reset-card {
            box-sizing: border-box;
            max-width: 430px;
            margin: 55px auto;
            padding: 30px;
            background: #fff;
            border: 1px solid #efe3d5;
            border-radius: 16px;
            box-shadow: 0 8px 26px rgba(45, 31, 16, .08);
        }

        .reset-card h2 {
            margin: 0 0 10px;
            color: #2d1f10;
            text-align: center;
        }

        .reset-card .intro {
            margin: 0 0 24px;
            color: #776b60;
            text-align: center;
            line-height: 1.6;
            font-size: 14px;
        }

        .reset-card label {
            display: block;
            margin: 14px 0 7px;
            color: #2d1f10;
            font-weight: 600;
            font-size: 14px;
        }

        .reset-card input {
            box-sizing: border-box;
            width: 100%;
            padding: 12px;
            border: 1px solid #efe3d5;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
        }

        .reset-card input:focus {
            border-color: #f39c12;
            box-shadow: 0 0 0 3px rgba(243, 156, 18, .13);
        }

        .reset-btn {
            display: block;
            box-sizing: border-box;
            width: 100%;
            margin-top: 20px;
            padding: 13px;
            border: none;
            border-radius: 8px;
            background: #f39c12;
            color: #fff;
            font-size: 14px;
            font-weight: 700;
            text-align: center;
            text-decoration: none;
            cursor: pointer;
        }

        .reset-btn:hover {
            background: #e89108;
        }

        .reset-btn:disabled {
            opacity: .65;
            cursor: not-allowed;
        }

        .reset-message {
            display: none;
            margin: 15px 0;
            padding: 12px;
            border-radius: 8px;
            font-size: 14px;
            line-height: 1.5;
            overflow-wrap: anywhere;
        }

        .reset-message.success {
            display: block;
            background: #def7ec;
            color: #03543f;
        }

        .reset-message.error {
            display: block;
            background: #fde8e8;
            color: #9b1c1c;
        }

        .reset-back {
            display: block;
            margin-top: 20px;
            text-align: center;
            color: #b86d00;
            text-decoration: none;
            font-size: 14px;
        }

        .reset-back:hover {
            text-decoration: underline;
        }

        .reset-step[hidden] {
            display: none !important;
        }

        @media (max-width: 500px) {
            .reset-card {
                margin: 30px 16px;
                padding: 23px;
            }
        }
    </style>
</head>

<body>

    <%@ include file="navbar.jsp"%>

    <main class="reset-card">
        <h2 id="pageTitle">Reset Your Password</h2>

        <p class="intro" id="pageIntro">
            Recover your QuickBite account securely using your registered email.
        </p>

        <div id="resetMessage"
             class="reset-message"
             role="status"
             aria-live="polite"></div>

        <!-- Step 1: Request OTP -->
        <section id="emailStep" class="reset-step">
            <form id="emailForm">
                <label for="resetEmail">Registered Email</label>
                <input type="email"
                       id="resetEmail"
                       maxlength="254"
                       autocomplete="email"
                       placeholder="Enter your registered email"
                       required>

                <button type="submit" class="reset-btn" id="sendBtn">
                    Send OTP
                </button>
            </form>
        </section>

        <!-- Step 2: Verify OTP -->
        <section id="otpStep" class="reset-step" hidden>
            <form id="otpForm">
                <label for="resetOtp">6-Digit OTP</label>
                <input type="text"
                       id="resetOtp"
                       inputmode="numeric"
                       pattern="[0-9]{6}"
                       maxlength="6"
                       autocomplete="one-time-code"
                       placeholder="Enter the OTP sent to your email"
                       required>

                <button type="submit" class="reset-btn" id="verifyBtn">
                    Verify OTP
                </button>
            </form>

            <button type="button" class="reset-btn" id="resendBtn">
                Resend OTP
            </button>
        </section>

        <!-- Step 3: Reset password -->
        <section id="passwordStep" class="reset-step" hidden>
            <form id="passwordForm">
                <label for="newPassword">New Password</label>
                <input type="password"
                       id="newPassword"
                       minlength="8"
                       maxlength="72"
                       autocomplete="new-password"
                       placeholder="Enter new password"
                       required>

                <label for="confirmPassword">Confirm New Password</label>
                <input type="password"
                       id="confirmPassword"
                       minlength="8"
                       maxlength="72"
                       autocomplete="new-password"
                       placeholder="Re-enter new password"
                       required>

                <button type="submit" class="reset-btn" id="updateBtn">
                    Update Password
                </button>
            </form>
        </section>

        <!-- Step 4: Success -->
        <section id="successStep" class="reset-step" hidden>
            <a class="reset-btn" href="<%=request.getContextPath()%>/Login.jsp"">
                Go to Login
            </a>
        </section>

        <a class="reset-back" id="backToLogin" href="<%=cp%>/Login.jsp">
            &#8592; Back to Login
        </a>
    </main>

    <%@ include file="footer.jsp"%>

    <script>
    (function () {
        "use strict";

        const base = "<%=cp%>";

        const email = document.getElementById("resetEmail");
        const otp = document.getElementById("resetOtp");
        const newPassword = document.getElementById("newPassword");
        const confirmPassword = document.getElementById("confirmPassword");

        const message = document.getElementById("resetMessage");
        const pageTitle = document.getElementById("pageTitle");
        const pageIntro = document.getElementById("pageIntro");

        const emailStep = document.getElementById("emailStep");
        const otpStep = document.getElementById("otpStep");
        const passwordStep = document.getElementById("passwordStep");
        const successStep = document.getElementById("successStep");
        const backToLogin = document.getElementById("backToLogin");

        let verified = false;

        function showStep(step) {
            emailStep.hidden = step !== "email";
            otpStep.hidden = step !== "otp";
            passwordStep.hidden = step !== "password";
            successStep.hidden = step !== "success";

            if (step === "success") {
                pageTitle.textContent = "Password Updated!";
                pageIntro.textContent =
                    "Your QuickBite account password has been changed successfully.";
                backToLogin.hidden = true;
            } else {
                pageTitle.textContent = "Reset Your Password";
                pageIntro.textContent =
                    "Recover your QuickBite account securely using your registered email.";
                backToLogin.hidden = false;
            }
        }

        function showMessage(text, type) {
            message.textContent = text;
            message.className = "reset-message " + type;
        }

        async function postAction(action, values) {
            const body = new URLSearchParams();
            body.set("action", action);

            Object.keys(values).forEach(function (key) {
                body.set(key, values[key]);
            });

            const response = await fetch(base + "/forgotPassword", {
                method: "POST",
                headers: {
                    "Content-Type":
                        "application/x-www-form-urlencoded;charset=UTF-8"
                },
                body: body.toString()
            });

            let data;

            try {
                data = await response.json();
            } catch (error) {
                throw new Error(
                    "The server returned an unexpected response. Check the controller and server logs."
                );
            }

            if (!response.ok || !data.success) {
                throw new Error(
                    data.message || "Request failed. Please try again."
                );
            }

            return data;
        }

        async function sendOtp() {
            const address = email.value.trim().toLowerCase();

            if (!email.checkValidity()) {
                email.reportValidity();
                return;
            }

            const sendBtn = document.getElementById("sendBtn");
            const resendBtn = document.getElementById("resendBtn");

            sendBtn.disabled = true;
            resendBtn.disabled = true;

            try {
                await postAction("send", { email: address });

                email.value = address;
                otp.value = "";
                showStep("otp");

                showMessage(
                    "If this email is registered, an OTP will be sent. Check your inbox and spam folder.",
                    "success"
                );
            } catch (error) {
                showMessage(error.message, "error");
            } finally {
                sendBtn.disabled = false;
                resendBtn.disabled = false;
            }
        }

        document.getElementById("emailForm").addEventListener(
            "submit", function (event) {
                event.preventDefault();
                sendOtp();
            }
        );

        document.getElementById("resendBtn").addEventListener(
            "click", sendOtp
        );

        document.getElementById("otpForm").addEventListener(
            "submit", async function (event) {
                event.preventDefault();

                const enteredOtp = otp.value.trim();

                if (!/^[0-9]{6}$/.test(enteredOtp)) {
                    showMessage("Enter the complete 6-digit OTP.", "error");
                    return;
                }

                const verifyBtn = document.getElementById("verifyBtn");
                verifyBtn.disabled = true;

                try {
                    await postAction("verify", {
                        email: email.value.trim().toLowerCase(),
                        otp: enteredOtp
                    });

                    verified = true;
                    showStep("password");

                    showMessage(
                        "Email verified. Enter your new password below.",
                        "success"
                    );
                } catch (error) {
                    showMessage(error.message, "error");
                } finally {
                    verifyBtn.disabled = false;
                }
            }
        );

        document.getElementById("passwordForm").addEventListener(
            "submit", async function (event) {
                event.preventDefault();

                if (!verified) {
                    showMessage("Please verify your OTP first.", "error");
                    return;
                }

                if (newPassword.value.length < 8 ||
                    newPassword.value.length > 72) {
                    showMessage(
                        "Password must contain between 8 and 72 characters.",
                        "error"
                    );
                    return;
                }

                if (newPassword.value !== confirmPassword.value) {
                    showMessage(
                        "New password and confirm password do not match.",
                        "error"
                    );
                    confirmPassword.focus();
                    return;
                }

                const updateBtn = document.getElementById("updateBtn");
                updateBtn.disabled = true;

                try {
                    await postAction("reset", {
                        email: email.value.trim().toLowerCase(),
                        newPassword: newPassword.value,
                        confirmPassword: confirmPassword.value
                    });

                    verified = false;
                    newPassword.value = "";
                    confirmPassword.value = "";
                    otp.value = "";

                    showStep("success");

                    showMessage(
                        "Password updated successfully. You can now log in using your new password.",
                        "success"
                    );
                } catch (error) {
                    showMessage(error.message, "error");
                } finally {
                    updateBtn.disabled = false;
                }
            }
        );
    })();
    </script>

</body>
</html>
