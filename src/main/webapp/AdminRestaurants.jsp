
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.tap.model.Restaurant"%>

<%!
    private String escapeJs(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\")
                    .replace("'", "\\'")
                    .replace("\"", "\\\"")
                    .replace("\r", " ")
                    .replace("\n", " ")
                    .replace("<", "\\u003C")
                    .replace(">", "\\u003E");
    }
%>

<%
    String contextPath = request.getContextPath();

    List<Restaurant> restaurants =
        (List<Restaurant>) request.getAttribute("restaurants");

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Manage Restaurants | QuickBite</title>

    <link rel="stylesheet"
          href="<%=contextPath%>/CSS/adminNavbar.css?v=3">

    <link rel="stylesheet"
          href="<%=contextPath%>/CSS/adminRestaurants.css?v=2">
</head>

<body>

<%@ include file="adminNavbar.jsp" %>

<main class="restaurant-admin-page">

    <!-- Restaurant summary -->
    <section class="restaurant-summary">
        <div>
            <p class="summary-label">Total Restaurants</p>

            <h2 id="restaurantCount">
                <%= restaurants == null ? 0 : restaurants.size() %>
            </h2>
        </div>

        <span class="summary-icon">&#127869;</span>
    </section>

    <!-- Page heading -->
    <div class="page-heading">
        <div>
            <h1>Manage Restaurants</h1>
            <p>Add, update, and manage your restaurant outlets.</p>
        </div>

        <button type="button"
                class="button primary"
                onclick="openAddModal()">
            + Add Restaurant
        </button>
    </div>

    <!-- Notifications -->
    <div id="noticeArea" aria-live="polite">

        <% if ("add".equals(success)) { %>
            <div class="notice success">
                Restaurant added successfully.
            </div>
        <% } else if ("update".equals(success)) { %>
            <div class="notice success">
                Restaurant updated successfully.
            </div>
        <% } else if ("toggleStatus".equals(success)) { %>
            <div class="notice success">
                Restaurant status updated successfully.
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="notice error">
                <% if ("invalid".equals(error)) { %>
                    Please check the restaurant details and try again.
                <% } else { %>
                    Something went wrong. Please try again.
                <% } %>
            </div>
        <% } %>

    </div>

    <!-- Restaurant table -->
    <section class="restaurant-table-card">

        <div class="table-heading">
            <div>
                <h2>All Restaurants</h2>
                <p>View and manage restaurant details.</p>
            </div>
        </div>

        <div class="table-scroll">

            <table class="restaurant-table">

                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Restaurant</th>
                        <th>Cuisine</th>
                        <th>Delivery</th>
                        <th>Rating</th>
                        <th>Address</th>
                        <th>Status</th>
                        <th>Actions</th>
                        <th>Edit</th>
                    </tr>
                </thead>

                <tbody id="restaurantTableBody">

                    <% if (restaurants != null && !restaurants.isEmpty()) { %>

                        <% for (Restaurant restaurant : restaurants) {

                            String restaurantName = restaurant.getName() == null
                                ? "" : restaurant.getName();

                            String cuisine = restaurant.getCuisineType() == null
                                ? "" : restaurant.getCuisineType();

                            String delivery = restaurant.getDeliveryTime() == null
                                ? "" : restaurant.getDeliveryTime();

                            String address = restaurant.getAddress() == null
                                ? "" : restaurant.getAddress();

                            String imagePath = restaurant.getImagePath() == null
                                ? "" : restaurant.getImagePath();

                            boolean active = restaurant.isActive();

                            String statusText = active ? "Active" : "Closed";
                        %>

                        <tr data-restaurant-id="<%=restaurant.getRestaurantId()%>">

                            <!-- ID -->
                            <td>
                                #<%=restaurant.getRestaurantId()%>
                            </td>

                            <!-- Restaurant image and name -->
                            <td>
                                <div class="restaurant-identity">

                                    <% if (!imagePath.trim().isEmpty()) { %>

                                        <img
                                            class="restaurant-image"
                                            src="<%=imagePath%>"
                                            alt="<%=restaurantName%>"
                                            onerror="this.style.display='none';">

                                    <% } else { %>

                                        <div class="restaurant-image-placeholder">
                                            &#127869;
                                        </div>

                                    <% } %>

                                    <div>
                                        <div class="restaurant-name">
                                            <%=restaurantName%>
                                        </div>

                                        <small><%=address%></small>
                                    </div>

                                </div>
                            </td>

                            <!-- Cuisine -->
                            <td>
                                <%=cuisine%>
                            </td>

                            <!-- Delivery time -->
                            <td>
                                &#128337; <%=delivery%>
                            </td>

                            <!-- Rating -->
                            <td>
                                <span class="rating">
                                    &#9733; <%=restaurant.getRating()%>
                                </span>
                            </td>

                            <!-- Address -->
                            <td>
                                <%=address%>
                            </td>

                            <!-- Status -->
                            <td>
                                <span class="status-badge <%=active ? "active" : "closed"%>">
                                    <%=statusText%>
                                </span>
                            </td>

                            <!-- Activate / Deactivate -->
                            <td>
                                <form class="ajax-toggle-form"
                                      action="<%=contextPath%>/admin/restaurants"
                                      method="post">

                                    <input type="hidden"
                                           name="action"
                                           value="toggleStatus">

                                    <input type="hidden"
                                           name="restaurantId"
                                           value="<%=restaurant.getRestaurantId()%>">

                                    <button type="submit"
                                            class="<%=active ? "deactivate-button" : "activate-button"%>">

                                        <%=active ? "Deactivate" : "Activate"%>

                                    </button>

                                </form>
                            </td>

                            <!-- NEW: Edit column -->
                            <td>
                                <button
                                    type="button"
                                    class="edit-button"
                                    onclick="openEditModal(
                                        '<%=restaurant.getRestaurantId()%>',
                                        '<%=escapeJs(restaurantName)%>',
                                        '<%=escapeJs(cuisine)%>',
                                        '<%=escapeJs(delivery)%>',
                                        '<%=restaurant.getRating()%>',
                                        '<%=escapeJs(address)%>',
                                        '<%=escapeJs(imagePath)%>',
                                        '<%=active ? "active" : "closed"%>'
                                    )">

                                    Edit
                                </button>
                            </td>

                        </tr>

                        <% } %>

                    <% } else { %>

                        <tr>
                            <td colspan="9" class="empty-table">
                                No restaurants found.
                            </td>
                        </tr>

                    <% } %>

                </tbody>

            </table>

        </div>
    </section>

</main>


<!-- ADD RESTAURANT MODAL -->
<div class="modal-overlay" id="addModal">

    <div class="restaurant-modal">

        <div class="modal-heading">
            <h2>Add New Restaurant</h2>

            <button type="button"
                    class="close-button"
                    onclick="closeAddModal()">
                &times;
            </button>
        </div>

        <form class="ajax-restaurant-form"
              action="<%=contextPath%>/admin/restaurants"
              method="post">

            <input type="hidden" name="action" value="add">

            <div class="form-grid">

                <div class="form-field">
                    <label for="addName">Restaurant Name</label>
                    <input type="text"
                           id="addName"
                           name="name"
                           required>
                </div>

                <div class="form-field">
                    <label for="addCuisine">Cuisine Type</label>
                    <input type="text"
                           id="addCuisine"
                           name="cuisineType"
                           required>
                </div>

                <div class="form-field">
                    <label for="addDelivery">Delivery Time</label>
                    <input type="text"
                           id="addDelivery"
                           name="deliveryTime"
                           placeholder="30-40 mins"
                           required>
                </div>

                <div class="form-field">
                    <label for="addRating">Rating</label>
                    <input type="number"
                           id="addRating"
                           name="rating"
                           min="0"
                           max="5"
                           step="0.1"
                           value="4.0"
                           required>
                </div>

                <div class="form-field full-width">
                    <label for="addAddress">Address</label>
                    <input type="text"
                           id="addAddress"
                           name="address"
                           required>
                </div>

                <div class="form-field full-width">
                    <label for="addImagePath">Restaurant Image URL</label>
                    <input type="url"
                           id="addImagePath"
                           name="imagePath"
                           placeholder="https://example.com/restaurant.jpg">
                </div>

                <!-- NEW: Status field -->
                <div class="form-field full-width">
                    <label for="addStatus">Status</label>

                    <select id="addStatus" name="status" required>
                        <option value="active" selected>Active</option>
                        <option value="closed">Closed</option>
                    </select>
                </div>

            </div>

            <div class="modal-actions">
                <button type="button"
                        class="button"
                        onclick="closeAddModal()">
                    Cancel
                </button>

                <button type="submit" class="button primary">
                    Add Restaurant
                </button>
            </div>

        </form>

    </div>
</div>


<!-- EDIT RESTAURANT MODAL -->
<div class="modal-overlay" id="editModal">

    <div class="restaurant-modal">

        <div class="modal-heading">
            <h2>Edit Restaurant</h2>

            <button type="button"
                    class="close-button"
                    onclick="closeEditModal()">
                &times;
            </button>
        </div>

        <form class="ajax-restaurant-form"
              action="<%=contextPath%>/admin/restaurants"
              method="post">

            <input type="hidden" name="action" value="update">

            <input type="hidden"
                   id="editRestaurantId"
                   name="restaurantId">

            <div class="form-grid">

                <div class="form-field">
                    <label for="editName">Restaurant Name</label>
                    <input type="text"
                           id="editName"
                           name="name"
                           required>
                </div>

                <div class="form-field">
                    <label for="editCuisine">Cuisine Type</label>
                    <input type="text"
                           id="editCuisine"
                           name="cuisineType"
                           required>
                </div>

                <div class="form-field">
                    <label for="editDelivery">Delivery Time</label>
                    <input type="text"
                           id="editDelivery"
                           name="deliveryTime"
                           required>
                </div>

                <div class="form-field">
                    <label for="editRating">Rating</label>
                    <input type="number"
                           id="editRating"
                           name="rating"
                           min="0"
                           max="5"
                           step="0.1"
                           required>
                </div>

                <div class="form-field full-width">
                    <label for="editAddress">Address</label>
                    <input type="text"
                           id="editAddress"
                           name="address"
                           required>
                </div>

                <div class="form-field full-width">
                    <label for="editImagePath">Restaurant Image URL</label>
                    <input type="url"
                           id="editImagePath"
                           name="imagePath">
                </div>

                <!-- NEW: Edit status field -->
                <div class="form-field full-width">
                    <label for="editStatus">Status</label>

                    <select id="editStatus" name="status" required>
                        <option value="active">Active</option>
                        <option value="closed">Closed</option>
                    </select>
                </div>

            </div>

            <div class="modal-actions">
                <button type="button"
                        class="button"
                        onclick="closeEditModal()">
                    Cancel
                </button>

                <button type="submit" class="button primary">
                    Save Changes
                </button>
            </div>

        </form>

    </div>
</div>


<script>
    const restaurantEndpoint =
        "<%=contextPath%>/admin/restaurants";


    function openAddModal() {
        document.getElementById("addModal").classList.add("show");
    }

    function closeAddModal() {
        document.getElementById("addModal").classList.remove("show");
    }

    function openEditModal(
        id,
        name,
        cuisine,
        delivery,
        rating,
        address,
        imagePath,
        status
    ) {
        document.getElementById("editRestaurantId").value = id;
        document.getElementById("editName").value = name;
        document.getElementById("editCuisine").value = cuisine;
        document.getElementById("editDelivery").value = delivery;
        document.getElementById("editRating").value = rating;
        document.getElementById("editAddress").value = address;
        document.getElementById("editImagePath").value = imagePath;
        document.getElementById("editStatus").value = status;

        document.getElementById("editModal").classList.add("show");
    }

    function closeEditModal() {
        document.getElementById("editModal").classList.remove("show");
    }


    function showNotice(message, isSuccess) {
        const noticeArea = document.getElementById("noticeArea");
        noticeArea.textContent = "";

        const notice = document.createElement("div");
        notice.className = isSuccess
            ? "notice success"
            : "notice error";

        notice.textContent = message;
        noticeArea.appendChild(notice);
    }


    async function refreshRestaurantTable() {
        const response = await fetch(restaurantEndpoint, {
            method: "GET",
            headers: {
                "X-Requested-With": "XMLHttpRequest"
            }
        });

        if (!response.ok) {
            throw new Error("Could not refresh restaurant list.");
        }

        const html = await response.text();
        const parsedDocument = new DOMParser().parseFromString(
            html,
            "text/html"
        );

        const newBody = parsedDocument.getElementById(
            "restaurantTableBody"
        );

        const currentBody = document.getElementById(
            "restaurantTableBody"
        );

        const newCount = parsedDocument.getElementById(
            "restaurantCount"
        );

        const currentCount = document.getElementById(
            "restaurantCount"
        );

        if (newBody && currentBody) {
            currentBody.innerHTML = newBody.innerHTML;
        }

        if (newCount && currentCount) {
            currentCount.textContent = newCount.textContent;
        }
    }


    async function submitAjaxForm(form) {
        const submitButton = form.querySelector(
            'button[type="submit"]'
        );

        if (submitButton) {
            submitButton.disabled = true;
        }

        try {
            const response = await fetch(form.action, {
                method: "POST",
                body: new FormData(form),
                headers: {
                    "X-Requested-With": "XMLHttpRequest"
                }
            });

            const result = await response.json();

            if (!response.ok || !result.success) {
                showNotice(
                    result.message || "Operation failed. Please try again.",
                    false
                );
                return;
            }

            await refreshRestaurantTable();

            if (form.classList.contains("ajax-toggle-form")) {
                showNotice(result.message, true);
            } else {
                const action = form.querySelector(
                    'input[name="action"]'
                ).value;

                if (action === "add") {
                    closeAddModal();
                    form.reset();
                } else {
                    closeEditModal();
                }

                showNotice(result.message, true);
            }

        } catch (error) {
            showNotice(
                "The request could not be completed. Check the controller and server logs.",
                false
            );
        } finally {
            if (submitButton) {
                submitButton.disabled = false;
            }
        }
    }


    document.addEventListener("submit", function(event) {
        const form = event.target;

        if (
            form.matches(".ajax-restaurant-form") ||
            form.matches(".ajax-toggle-form")
        ) {
            event.preventDefault();

            if (
                form.classList.contains("ajax-toggle-form") &&
                !confirm("Do you want to change this restaurant's status?")
            ) {
                return;
            }

            submitAjaxForm(form);
        }
    });


    document.querySelectorAll(".modal-overlay").forEach(function(modal) {
        modal.addEventListener("click", function(event) {
            if (event.target === modal) {
                modal.classList.remove("show");
            }
        });
    });


    document.addEventListener("keydown", function(event) {
        if (event.key === "Escape") {
            closeAddModal();
            closeEditModal();
        }
    });
</script>

</body>
</html>
