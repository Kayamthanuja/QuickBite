
<%@ page import="com.tap.model.User, com.tap.model.OrderHistory, java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<OrderHistory> ordersList =
        (List<OrderHistory>) request.getAttribute("ordersList");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | Quick Bite</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/CSS/common.css?v=4">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/CSS/navbar.css?v=3">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/CSS/profile.css?v=12">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/CSS/footer.css?v=3">
</head>

<body>

<jsp:include page="navbar.jsp" />

<main class="profile-page">
    <div class="profile-container">

        <!-- Sidebar -->
        <aside class="profile-sidebar">

            <div class="profile-user">
                <div class="profile-avatar">
                    <%= user.getUsername() != null
                        && !user.getUsername().isEmpty()
                        ? user.getUsername().substring(0, 1).toUpperCase()
                        : "U" %>
                </div>

                <h2 id="sidebarUsername"><%= user.getUsername() %></h2>
                <p id="sidebarEmail"><%= user.getEmail() %></p>
            </div>

            <nav class="profile-menu">
                <button type="button" class="profile-tab active"
                        onclick="showTab('personalTab', this)">
                    <span class="tab-icon">👤</span>
                    Personal Profile
                </button>

                <button type="button" class="profile-tab"
                        onclick="showTab('addressTab', this)">
                    <span class="tab-icon">📍</span>
                    Manage Address
                </button>

                <button type="button" class="profile-tab"
                        onclick="showTab('ordersTab', this)">
                    <span class="tab-icon">🛍️</span>
                    Orders &amp; History
                </button>

                <button type="button" class="profile-tab"
                        onclick="showTab('supportTab', this)">
                    <span class="tab-icon">🎧</span>
                    Help &amp; Support
                </button>
            </nav>

        </aside>

        <!-- Main Content -->
        <section class="profile-content">

            <!-- Personal Profile -->
            <div id="personalTab" class="profile-section active">

                <div class="profile-section-header">
                    <div>
                        <h1>Personal Profile</h1>
                        <p>Manage your personal information.</p>
                    </div>

                    <button type="button" class="edit-profile-btn"
                            onclick="openEditModal()">
                        Edit Profile
                    </button>
                </div>

                <div class="profile-details">

                    <div class="detail-item">
                        <label>Full Name</label>
                        <p id="displayUsername"><%= user.getUsername() %></p>
                    </div>

                    <div class="detail-item">
                        <label>Email Address</label>
                        <p id="displayEmail"><%= user.getEmail() %></p>
                    </div>

                    <div class="detail-item">
                        <label>Phone Number</label>
                        <p id="displayPhone"><%= user.getPhone() != null
                            && !user.getPhone().isEmpty()
                            ? user.getPhone() : "Not provided" %></p>
                    </div>

                    <div class="detail-item">
                        <label>Address</label>
                        <p id="displayAddress"><%= user.getAddress() != null
                            && !user.getAddress().trim().isEmpty()
                            ? user.getAddress() : "No address added" %></p>
                    </div>

                </div>
            </div>

            <!-- Manage Address -->
            <div id="addressTab" class="profile-section">

                <div class="profile-section-header">
                    <div>
                        <h1>Manage Address</h1>
                        <p>Your saved delivery address.</p>
                    </div>
                </div>

                <div class="address-card">
                    <h3>📍 Delivery Address</h3>

                    <p id="displayAddressCard"><%= user.getAddress() != null
                        && !user.getAddress().trim().isEmpty()
                        ? user.getAddress() : "No delivery address saved yet." %></p>

                    <button type="button" class="edit-profile-btn"
                            onclick="openEditModal()">
                        Update Address
                    </button>
                </div>

            </div>

            <!-- Orders & History -->
            <div id="ordersTab" class="profile-section">

                <div class="profile-section-header">
                    <div>
                        <h1>Orders &amp; History</h1>
                        <p>View your previous orders.</p>
                    </div>
                </div>

                <div class="orders-list">

                    <%
                        if (ordersList != null && !ordersList.isEmpty()) {
                            for (OrderHistory ord : ordersList) {
                    %>

                    <div class="order-card">

                        <div class="order-card-header">
                            <div>
                                <h3 class="restaurant-name-highlight">
                                    <%= ord.getRestaurantName() != null
                                        ? ord.getRestaurantName()
                                        : "Restaurant" %>
                                </h3>
                            </div>

                            <span class="order-status">
                                <%= ord.getStatus() != null
                                    ? ord.getStatus() : "Pending" %>
                            </span>
                        </div>

                        <div class="order-card-body">

                            <div class="order-items">
                                <label>Items</label>
                                <p><%= ord.getItems() != null
                                    && !ord.getItems().trim().isEmpty()
                                    ? ord.getItems() : "Item details unavailable" %></p>
                            </div>

                            <div class="order-total">
                                <label>Total Amount</label>
                                <p>₹<%= String.format("%.2f",
                                    ord.getTotalAmount()) %></p>
                            </div>

                        </div>

                        <div class="order-card-footer">
                            <a href="<%= request.getContextPath() %>/orderDetails?orderId=<%= ord.getOrderId() %>"
                               class="view-details-link">
                                View Order Details &rarr;
                            </a>
                        </div>

                    </div>

                    <%
                            }
                        } else {
                    %>

                    <div class="empty-orders">
                        <h3>No Orders Yet</h3>
                        <p>Your placed orders will appear here.</p>

                        <a href="<%= request.getContextPath() %>/restaurant"
                           class="edit-profile-btn">
                            Explore Restaurants
                        </a>
                    </div>

                    <%
                        }
                    %>

                </div>
            </div>

            <!-- Help & Support -->
            <div id="supportTab" class="profile-section">

                <div class="profile-section-header">
                    <div>
                        <h1>Help &amp; Support</h1>
                        <p>We're here to help you with your Quick Bite experience.</p>
                    </div>
                </div>

                <div class="support-card">
                    <h3>📞 Contact Us</h3>
                    <p>
                        <a href="tel:+919876543210">+91 98765 43210</a>
                    </p>
                </div>

      <!--          <div class="support-card">
                    <h3>📱 Phone Support</h3>
                    <p>
                        <a href="tel:+919876543210">+91 98765 43210</a>
                    </p>
                </div> -->  

                <div class="support-card">
                    <h3>✉️ Email Support</h3>
                    <p>
                        <a href="mailto:support@quickbite.com">
                            support@quickbite.com
                        </a>
                    </p>
                </div>

            </div>

        </section>
    </div>
</main>

<!-- Edit Profile Modal -->
<div id="editProfileModal" class="profile-modal">

    <div class="profile-modal-content">

        <button type="button" class="modal-close"
                onclick="closeEditModal()">&times;</button>

        <h2>Edit Profile</h2>
        <p>Update your personal details below.</p>

        <form id="editProfileForm" action="<%= request.getContextPath() %>/profile"
              method="post">

            <div class="form-group">
                <label for="username">Full Name</label>
                <input type="text" id="username" name="username"
                       value="<%= user.getUsername() != null
                           ? user.getUsername() : "" %>" required>
            </div>

            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email"
                       value="<%= user.getEmail() != null
                           ? user.getEmail() : "" %>" required>
            </div>

            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="text" id="phone" name="phone"
                       value="<%= user.getPhone() != null
                           ? user.getPhone() : "" %>" required>
            </div>

            <div class="form-group">
                <label for="address">Delivery Address</label>
                <textarea id="address" name="address"
                          rows="3" required><%= user.getAddress() != null
                              ? user.getAddress() : "" %></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="cancel-btn"
                        onclick="closeEditModal()">
                    Cancel
                </button>

                <button type="submit" class="save-profile-btn">
                    Save Changes
                </button>
            </div>

        </form>
    </div>
</div>

<!-- Floating In-Page Toast Notification (Replaces blocking alert, keeps profile page visible) -->
<div id="profileToast" class="profile-toast-notification">
    <div class="toast-icon" id="toastIcon">✓</div>
    <div class="toast-content">
        <strong id="toastTitle">Profile Updated</strong>
        <p id="toastMessage">Your personal details have been saved successfully.</p>
    </div>
    <button type="button" class="toast-close" onclick="hideProfileToast()">&times;</button>
</div>

<jsp:include page="footer.jsp" />

<script>
    function showTab(tabId, clickedButton) {
        document.querySelectorAll(".profile-section").forEach(function(section) {
            section.classList.remove("active");
        });

        document.querySelectorAll(".profile-tab").forEach(function(button) {
            button.classList.remove("active");
        });

        document.getElementById(tabId).classList.add("active");
        clickedButton.classList.add("active");
    }

    function openEditModal() {
        document.getElementById("editProfileModal").style.display = "flex";
    }

    function closeEditModal() {
        document.getElementById("editProfileModal").style.display = "none";
    }

    window.addEventListener("click", function(event) {
        var modal = document.getElementById("editProfileModal");
        if (event.target === modal) {
            closeEditModal();
        }
    });

    let toastTimer = null;
    function showProfileToast(title, message, type) {
        const toast = document.getElementById("profileToast");
        const titleEl = document.getElementById("toastTitle");
        const msgEl = document.getElementById("toastMessage");
        const iconEl = document.getElementById("toastIcon");

        if (!toast) return;

        if (titleEl) titleEl.textContent = title;
        if (msgEl) msgEl.textContent = message;

        if (type === "error") {
            toast.classList.add("error");
            if (iconEl) iconEl.textContent = "✕";
        } else {
            toast.classList.remove("error");
            if (iconEl) iconEl.textContent = "✓";
        }

        toast.style.display = "flex";

        if (toastTimer) clearTimeout(toastTimer);
        toastTimer = setTimeout(function() {
            hideProfileToast();
        }, 4500);
    }

    function hideProfileToast() {
        const toast = document.getElementById("profileToast");
        if (toast) toast.style.display = "none";
    }

    // Instant AJAX Submission for Profile Edit (No page reload, zero blank screen)
    document.addEventListener("DOMContentLoaded", function() {
        const editForm = document.getElementById("editProfileForm");
        if (editForm) {
            editForm.addEventListener("submit", async function(e) {
                e.preventDefault();
                const saveBtn = this.querySelector(".save-profile-btn");
                const originalText = saveBtn ? saveBtn.textContent : "Save Changes";
                if (saveBtn) {
                    saveBtn.disabled = true;
                    saveBtn.textContent = "Saving...";
                }

                const formData = new FormData(this);
                formData.append("ajax", "true");

                try {
                    const response = await fetch(this.action, {
                        method: "POST",
                        headers: {
                            "X-Requested-With": "XMLHttpRequest"
                        },
                        body: new URLSearchParams(formData)
                    });

                    const data = await response.json();
                    if (data.success) {
                        if (data.username) {
                            const u1 = document.getElementById("displayUsername");
                            if (u1) u1.textContent = data.username;
                            const u2 = document.getElementById("sidebarUsername");
                            if (u2) u2.textContent = data.username;
                        }
                        if (data.email) {
                            const e1 = document.getElementById("displayEmail");
                            if (e1) e1.textContent = data.email;
                            const e2 = document.getElementById("sidebarEmail");
                            if (e2) e2.textContent = data.email;
                        }
                        if (data.phone) {
                            const p1 = document.getElementById("displayPhone");
                            if (p1) p1.textContent = data.phone;
                        }
                        if (data.address) {
                            const a1 = document.getElementById("displayAddress");
                            if (a1) a1.textContent = data.address;
                            const a2 = document.getElementById("displayAddressCard");
                            if (a2) a2.textContent = data.address;
                        }

                        closeEditModal();
                        showProfileToast("Profile updated successfully!", "Your details were updated in real-time.", "success");
                    } else {
                        showProfileToast("Update Failed", data.message || "Unable to save profile.", "error");
                    }
                } catch (err) {
                    // Fallback to normal form submit if fetch fails
                    this.submit();
                    return;
                } finally {
                    if (saveBtn) {
                        saveBtn.disabled = false;
                        saveBtn.textContent = originalText;
                    }
                }
            });
        }

        // Check URL parameters for status when loaded after redirect (smooth in-page toast, no alert)
        const profileParams = new URLSearchParams(window.location.search);
        if (profileParams.get("status") === "success") {
            showProfileToast("Profile updated successfully!", "Your personal information has been saved.", "success");
            window.history.replaceState({}, document.title, window.location.pathname);
        } else if (profileParams.get("status") === "error") {
            showProfileToast("Update Failed", "Unable to update profile. Please verify your details and try again.", "error");
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    });
</script>

</body>
</html>

