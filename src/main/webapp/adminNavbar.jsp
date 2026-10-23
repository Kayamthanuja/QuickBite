<%@ page import="com.tap.model.User"%>

<%
User adminUser = (User) session.getAttribute("user");
String adminContextPath = request.getContextPath();

String adminDisplayName =
    (adminUser != null && adminUser.getUsername() != null)
        ? adminUser.getUsername()
        : "Admin";
%>

<nav class="qb-admin-navbar">

    <a class="qb-admin-brand"
        href="<%=adminContextPath%>/adminDashboard">

        <span class="qb-admin-avatar">&#128081;</span>

        <span class="qb-admin-brand-name">
            QuickBite <strong>Admin</strong>
        </span>

        <span class="qb-admin-badge">ADMIN</span>
    </a>

    <div class="qb-admin-nav-actions">

        <a class="qb-admin-profile-link"
            href="<%=adminContextPath%>/adminProfile">

            <span class="qb-admin-avatar">&#128100;</span>

            <span class="qb-admin-profile-name">
                <strong><%=adminDisplayName%></strong>
                <small>Administrator</small>
            </span>
        </a>

        <a class="qb-admin-logout"
            href="<%=adminContextPath%>/logout?from=admin">
            Logout
        </a>

    </div>
</nav>