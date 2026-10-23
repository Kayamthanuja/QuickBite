
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.tap.model.User"%>

<%
    User admin = (User) request.getAttribute("adminProfile");
    String contextPath = request.getContextPath();

    if (admin == null) {
        response.sendRedirect(contextPath + "/adminProfile");
        return;
    }

    boolean updated = "true".equals(request.getParameter("updated"));
    String errorMessage = (String) request.getAttribute("errorMessage");

    String username = admin.getUsername() != null ? admin.getUsername() : "";
    String email = admin.getEmail() != null ? admin.getEmail() : "";
    String phone = admin.getPhone() != null ? admin.getPhone() : "";
    String address = admin.getAddress() != null ? admin.getAddress() : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile | QuickBite</title>

    <link rel="stylesheet"
        href="<%=contextPath%>/CSS/adminNavbar.css?v=3">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #fffaf2;
            color: #4b2e20;
            font-family: Arial, sans-serif;
        }

        .profile-page {
            width: min(1090px, 92%);
            margin: 44px auto 60px;
        }

        .profile-card {
            overflow: hidden;
            background: #ffffff;
            border: 1px solid #f0ddc8;
            border-radius: 19px;
            box-shadow: 0 8px 28px rgba(75, 45, 24, 0.07);
        }

        .profile-card-body {
            padding: 34px;
        }

        .profile-heading {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
            padding-bottom: 24px;
            margin-bottom: 28px;
            border-bottom: 1px solid #f0ddc8;
        }

        .profile-heading h1 {
            margin: 0 0 10px;
            font-size: 29px;
            color: #4b2e20;
        }

        .profile-heading p {
            margin: 0;
            color: #8c7665;
            line-height: 1.6;
        }

        .profile-edit-btn {
            padding: 13px 21px;
            border: 1px solid #ff9800;
            border-radius: 9px;
            background: #fff7eb;
            color: #4b2e20;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            white-space: nowrap;
            transition: background 0.2s, transform 0.2s;
        }

        .profile-edit-btn:hover {
            background: #ffead1;
            transform: translateY(-1px);
        }

        .profile-details-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
        }

        .profile-detail {
            padding: 21px;
            border: 1px solid #f0ddc8;
            border-radius: 12px;
            background: #fffdf9;
            min-width: 0;
        }

        .profile-detail-label {
            display: block;
            margin-bottom: 13px;
            color: #8c7665;
            font-size: 14px;
            font-weight: 600;
        }

        .profile-detail-value {
            color: #25180f;
            font-size: 16px;
            font-weight: 700;
            overflow-wrap: anywhere;
        }

        .profile-message {
            margin-bottom: 20px;
            padding: 13px 15px;
            border-radius: 9px;
            font-size: 14px;
        }

        .profile-message.success {
            background: #edf7ed;
            border: 1px solid #b8d9b8;
            color: #28652b;
        }

        .profile-message.error {
            background: #fff0e8;
            border: 1px solid #e9bda5;
            color: #8a3d20;
        }

        /* Edit Profile popup */
        .profile-modal-overlay {
            position: fixed;
            inset: 0;
            z-index: 1000;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background: rgba(45, 32, 23, 0.52);
            backdrop-filter: blur(3px);
        }

        .profile-modal-overlay.show {
            display: flex;
        }

        .profile-modal {
            position: relative;
            width: min(540px, 100%);
            max-height: 90vh;
            overflow-y: auto;
            padding: 34px;
            border-radius: 18px;
            background: #ffffff;
            box-shadow: 0 18px 55px rgba(45, 32, 23, 0.22);
            animation: profileModalIn 0.2s ease-out;
        }

        @keyframes profileModalIn {
            from {
                opacity: 0;
                transform: translateY(10px) scale(0.98);
            }

            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .profile-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 15px;
            margin-bottom: 25px;
        }

        .profile-modal-header h2 {
            margin: 0 0 8px;
            color: #4b2e20;
            font-size: 25px;
        }

        .profile-modal-header p {
            margin: 0;
            color: #8c7665;
            line-height: 1.5;
            font-size: 14px;
        }

        .profile-modal-close {
            padding: 0;
            border: none;
            background: transparent;
            color: #8c7665;
            font-size: 28px;
            line-height: 1;
            cursor: pointer;
        }

        .profile-modal-close:hover {
            color: #bd642c;
        }

        .profile-form {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .profile-field {
            display: flex;
            flex-direction: column;
            gap: 9px;
        }

        .profile-field label {
            color: #4b2e20;
            font-size: 14px;
            font-weight: 700;
        }

        .profile-field input,
        .profile-field textarea {
            width: 100%;
            padding: 14px;
            border: 1px solid #f0ddc8;
            border-radius: 9px;
            background: #fffdf9;
            color: #4b2e20;
            font: inherit;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .profile-field input:focus,
        .profile-field textarea:focus {
            border-color: #ff9800;
            box-shadow: 0 0 0 3px rgba(255, 152, 0, 0.13);
        }

        .profile-field textarea {
            min-height: 100px;
            resize: vertical;
        }

        .profile-modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 5px;
        }

        .profile-button {
            padding: 13px 20px;
            border: 1px solid #f0ddc8;
            border-radius: 9px;
            background: #f7f0e7;
            color: #4b2e20;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.2s, transform 0.2s;
        }

        .profile-button:hover {
            transform: translateY(-1px);
        }

        .profile-button.primary {
            border-color: #ff9800;
            background: #ff9800;
            color: #ffffff;
        }

        .profile-button.primary:hover {
            border-color: #f28c00;
            background: #f28c00;
        }

        .profile-button.secondary:hover {
            background: #eee3d5;
        }

        @media (max-width: 650px) {
            .profile-page {
                margin-top: 25px;
            }

            .profile-card-body {
                padding: 22px;
            }

            .profile-heading {
                flex-direction: column;
                align-items: stretch;
            }

            .profile-heading h1 {
                font-size: 25px;
            }

            .profile-edit-btn {
                align-self: flex-start;
            }

            .profile-details-grid {
                grid-template-columns: 1fr;
                gap: 13px;
            }

            .profile-detail {
                padding: 18px;
            }

            .profile-modal {
                padding: 24px 20px;
            }

            .profile-modal-actions {
                flex-direction: column-reverse;
            }

            .profile-button {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>

<body>

    <%@ include file="adminNavbar.jsp" %>

    <main class="profile-page">

        <% if (updated) { %>
            <div class="profile-message success">
                Your profile has been updated successfully.
            </div>
        <% } %>

        <% if (errorMessage != null) { %>
            <div class="profile-message error">
                <%=errorMessage%>
            </div>
        <% } %>

        <section class="profile-card">
            <div class="profile-card-body">

                <div class="profile-heading">
                    <div>
                        <h1>Personal Profile</h1>
                        <p>Manage your personal information.</p>
                    </div>

                    <button type="button"
                        class="profile-edit-btn"
                        onclick="openProfileModal()">
                        Edit Profile
                    </button>
                </div>

                <div class="profile-details-grid">

                    <div class="profile-detail">
                        <span class="profile-detail-label">Full Name</span>
                        <div class="profile-detail-value"><%=username%></div>
                    </div>

                    <div class="profile-detail">
                        <span class="profile-detail-label">Email Address</span>
                        <div class="profile-detail-value"><%=email%></div>
                    </div>

                    <div class="profile-detail">
                        <span class="profile-detail-label">Phone Number</span>
                        <div class="profile-detail-value">
                            <%=!phone.isEmpty() ? phone : "Not provided"%>
                        </div>
                    </div>

                    <div class="profile-detail">
                        <span class="profile-detail-label">Address</span>
                        <div class="profile-detail-value">
                            <%=!address.isEmpty() ? address : "Not provided"%>
                        </div>
                    </div>

                </div>
            </div>
        </section>
    </main>

    <!-- EDIT PROFILE POPUP -->
    <div class="profile-modal-overlay" id="profileModal"
        role="dialog" aria-modal="true" aria-labelledby="profileModalTitle">

        <div class="profile-modal">

            <div class="profile-modal-header">
                <div>
                    <h2 id="profileModalTitle">Edit Profile</h2>
                    <p>Update your personal details below.</p>
                </div>

                <button type="button"
                    class="profile-modal-close"
                    aria-label="Close popup"
                    onclick="closeProfileModal()">&#215;</button>
            </div>

            <form class="profile-form"
                action="<%=contextPath%>/adminProfile"
                method="post">

                <div class="profile-field">
                    <label for="editUsername">Full Name</label>
                    <input id="editUsername"
                        name="username"
                        type="text"
                        value="<%=username%>"
                        maxlength="100"
                        required>
                </div>

                <div class="profile-field">
                    <label for="editEmail">Email Address</label>
                    <input id="editEmail"
                        name="email"
                        type="email"
                        value="<%=email%>"
                        maxlength="150"
                        required>
                </div>

                <div class="profile-field">
                    <label for="editPhone">Phone Number</label>
                    <input id="editPhone"
                        name="phone"
                        type="tel"
                        value="<%=phone%>"
                        maxlength="20">
                </div>

                <div class="profile-field">
                    <label for="editAddress">Delivery Address</label>
                    <textarea id="editAddress"
                        name="address"
                        maxlength="500"><%=address%></textarea>
                </div>

                <div class="profile-modal-actions">
                    <button type="button"
                        class="profile-button secondary"
                        onclick="closeProfileModal()">
                        Cancel
                    </button>

                    <button type="submit"
                        class="profile-button primary">
                        Save Changes
                    </button>
                </div>

            </form>
        </div>
    </div>

    <script>
        const profileModal = document.getElementById("profileModal");

        function openProfileModal() {
            profileModal.classList.add("show");
            document.body.style.overflow = "hidden";

            const nameInput = document.getElementById("editUsername");
            if (nameInput) {
                nameInput.focus();
            }
        }

        function closeProfileModal() {
            profileModal.classList.remove("show");
            document.body.style.overflow = "";
        }

        profileModal.addEventListener("click", function(event) {
            if (event.target === profileModal) {
                closeProfileModal();
            }
        });

        document.addEventListener("keydown", function(event) {
            if (event.key === "Escape" &&
                profileModal.classList.contains("show")) {
                closeProfileModal();
            }
        });

        <% if (errorMessage != null) { %>
            openProfileModal();
        <% } %>
    </script>

</body>
</html>
