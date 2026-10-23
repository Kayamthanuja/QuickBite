<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.tap.model.Cart" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.User" %>

<script>
    /* Immediate theme application to prevent Flash of Unstyled Content (FOUC) */
    (function() {
        try {
            const savedTheme = localStorage.getItem('qb-theme') || 
                (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
            document.documentElement.setAttribute('data-theme', savedTheme);
        } catch (e) {}
    })();
</script>

<%
    Cart navCart = (Cart) session.getAttribute("cart");

    // Count distinct food items, not their quantities.
    int navCartCount = 0;

    if (navCart != null && navCart.getCartItems() != null) {
        for (CartItem item : navCart.getCartItems().values()) {
            if (item != null) {
                navCartCount++;
            }
        }
    }
%>

<header class="navbar">

    <a class="logo"
       href="<%=request.getContextPath()%>/restaurant">
        <span class="logo-icon">&#10022;</span>
        <span>QuickBite</span>
    </a>

    <nav class="nav-links">

        <a href="<%=request.getContextPath()%>/restaurant">
            Restaurants
        </a>

        <a class="nav-cart-link"
           href="<%=request.getContextPath()%>/cart">
            <span>Cart</span>

            <% if (navCartCount > 0) { %>
                <span class="nav-cart-count"><%=navCartCount%></span>
            <% } %>
        </a>

        <a href="<%=request.getContextPath()%>/orders">
            Orders
        </a>

        <!-- Dark / Light Mode Switcher Button -->
        <button type="button"
                id="themeToggleBtn"
                class="theme-toggle-btn"
                onclick="toggleQuickBiteTheme()"
                aria-label="Toggle Dark / Light Theme"
                title="Toggle Dark / Light Theme">
            <span class="theme-icon-sun" id="sunIcon" style="display:none;">☀️</span>
            <span class="theme-icon-moon" id="moonIcon">🌙</span>
        </button>

        <%
            Object loggedInUserObj = session.getAttribute("user");
            User loggedInUser = (loggedInUserObj instanceof User) ? (User) loggedInUserObj : null;

            if (loggedInUser != null) {
        %>

            <div class="profile-menu">

                <button type="button"
                        class="profile-icon"
                        aria-label="User profile">

                    <svg xmlns="http://www.w3.org/2000/svg"
                         viewBox="0 0 24 24"
                         fill="currentColor"
                         class="user-svg-icon">

                        <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>

                    </svg>
                </button>

                <div class="profile-dropdown">
                    <a href="<%=request.getContextPath()%>/profile">
                        👤 Profile
                    </a>

                    <a href="<%=request.getContextPath()%>/orders">
                        📦 My Orders
                    </a>

                    <a href="<%=request.getContextPath()%>/logout">
                        🚪 Logout
                    </a>
                </div>

            </div>

        <%
            } else {
        %>

            <a class="login-link"
               href="<%=request.getContextPath()%>/login">
                Login
            </a>

        <%
            }
        %>

    </nav>

</header>

<script>
    function toggleQuickBiteTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        const nextTheme = currentTheme === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', nextTheme);
        try {
            localStorage.setItem('qb-theme', nextTheme);
        } catch (e) {}
        updateThemeToggleIcons(nextTheme);
    }

    function updateThemeToggleIcons(theme) {
        const sun = document.getElementById('sunIcon');
        const moon = document.getElementById('moonIcon');
        const btn = document.getElementById('themeToggleBtn');
        if (btn) {
            btn.setAttribute('title', theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode');
        }
        if (sun && moon) {
            if (theme === 'dark') {
                sun.style.display = 'inline-block';
                moon.style.display = 'none';
            } else {
                sun.style.display = 'none';
                moon.style.display = 'inline-block';
            }
        }
    }

    // Initialize toggle icon state on DOM ready
    (function() {
        const applyIcon = function() {
            const current = document.documentElement.getAttribute('data-theme') || 'light';
            updateThemeToggleIcons(current);
        };
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', applyIcon);
        } else {
            applyIcon();
        }
    })();
</script>
