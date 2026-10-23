"use strict";

document.addEventListener("DOMContentLoaded", function() {
    var contextPath = window.QUICK_BITE_CONTEXT || window.QUICK_BITE_CONTEXT_PATH || "";

    // DOM Elements
    var menuGrid = document.getElementById("menuGrid");
    var menuSearch = document.getElementById("menuSearch") || document.querySelector('input[name="search"]');
    var menuCount = document.getElementById("menuCount") || document.querySelector(".items-count-text");
    var noSearchResults = document.getElementById("noSearchResults") || document.getElementById("menuInstantEmptyNotice");

    var filterToggle = document.getElementById("filter-toggle");
    var filterDropdownBtn = document.getElementById("filterDropdownBtn") || document.querySelector(".filter-dropdown-btn");
    var filterDropdownMenu = document.getElementById("filterDropdownMenu") || document.querySelector(".filter-dropdown-menu");
    var applyFiltersBtn = document.getElementById("applyFiltersBtn");
    var resetFiltersBtn = document.getElementById("resetFiltersBtn");

    var floatingCartBar = document.getElementById("floatingCartBar") || document.getElementById("menuCartBar");
    var cartBarCount = document.getElementById("cartCountVal") || document.getElementById("cartBarCount");
    var cartBarSummary = document.getElementById("cartBarSummary");
    var cartPreviewModal = document.getElementById("cartPreviewModal") || document.getElementById("cartPreviewPanel");
    var previewItemsList = document.getElementById("previewItemsList");
    var previewTotalAmount = document.getElementById("previewTotalAmount") || document.getElementById("cartBarTotal");

    var cartToast = document.getElementById("cartToast");
    var toastTimeout = null;

    function getMenuCards() {
        return Array.from(document.querySelectorAll(".food-card, .menu-card"));
    }

    function formatPrice(val) {
        var num = Number(val);
        return (Number.isFinite(num) ? num : 0).toFixed(2);
    }

    function showToast(message, isError) {
        if (!cartToast) return;
        cartToast.textContent = message;
        if (isError) {
            cartToast.classList.add("error");
        } else {
            cartToast.classList.remove("error");
        }
        cartToast.hidden = false;

        if (toastTimeout) clearTimeout(toastTimeout);
        toastTimeout = setTimeout(function() {
            cartToast.hidden = true;
        }, 3000);
    }

    // -------------------------------------------------------------
    // 1. FILTERS & SEARCH
    // -------------------------------------------------------------
    function closeDropdown() {
        if (filterToggle) filterToggle.checked = false;
        if (filterDropdownMenu) filterDropdownMenu.classList.remove("show");
    }

    if (filterDropdownBtn && filterDropdownMenu && !filterToggle) {
        filterDropdownBtn.addEventListener("click", function(e) {
            e.stopPropagation();
            filterDropdownMenu.classList.toggle("show");
        });

        document.addEventListener("click", function(e) {
            if (!filterDropdownMenu.contains(e.target) && e.target !== filterDropdownBtn) {
                closeDropdown();
            }
        });
    }

    function applyMenuFilters() {
        var searchTerm = menuSearch ? menuSearch.value.trim().toLowerCase() : "";
        var sortInput = document.querySelector('input[name="sortOption"]:checked');
        var selectedSort = sortInput ? sortInput.value : "default";

        var prefInput = document.querySelector('input[name="prefOption"]:checked');
        var selectedPref = prefInput ? prefInput.value : "all";

        var cards = getMenuCards();
        var visibleCount = 0;

        cards.forEach(function(card) {
            var searchText = (card.dataset.search || card.textContent || "").toLowerCase();
            var foodType = card.dataset.foodType || "veg";

            var matchesSearch = !searchTerm || searchText.indexOf(searchTerm) !== -1;
            var matchesPref = true;

            if (selectedPref === "veg") {
                matchesPref = (foodType === "veg");
            } else if (selectedPref === "non-veg") {
                matchesPref = (foodType === "non-veg");
            }

            var isVisible = matchesSearch && matchesPref;
            card.style.display = isVisible ? "" : "none";
            card.hidden = !isVisible;

            if (isVisible) visibleCount++;
        });

        // Sorting
        if (selectedSort === "low-high") {
            cards.sort(function(a, b) {
                return (Number(a.dataset.price) || 0) - (Number(b.dataset.price) || 0);
            });
        } else if (selectedSort === "high-low") {
            cards.sort(function(a, b) {
                return (Number(b.dataset.price) || 0) - (Number(a.dataset.price) || 0);
            });
        } else {
            // Restore default order by menu ID
            cards.sort(function(a, b) {
                return (Number(a.dataset.menuId) || 0) - (Number(b.dataset.menuId) || 0);
            });
        }

        if (menuGrid) {
            cards.forEach(function(card) {
                menuGrid.appendChild(card);
            });
        }

        if (menuCount) {
            menuCount.textContent = "Showing " + visibleCount + " menu items";
        }

        // Handle empty state notice
        if (visibleCount === 0) {
            if (!noSearchResults && menuGrid) {
                var notice = document.createElement("div");
                notice.id = "menuInstantEmptyNotice";
                notice.className = "empty-state-notice";
                notice.style.cssText = "grid-column: 1 / -1; text-align: center; padding: 40px 20px; color: #7a6e5d;";
                notice.innerHTML = "<h3>No dishes match your filter</h3><p style='margin: 8px 0 16px;'>Try choosing another preference or clearing the search text.</p><button type='button' class='btn-apply-filters' style='max-width:160px;margin:0 auto;display:inline-block;' onclick='resetMenuFilters()'>Reset Filters</button>";
                menuGrid.appendChild(notice);
            } else if (noSearchResults) {
                noSearchResults.style.display = "block";
            }
        } else if (noSearchResults) {
            noSearchResults.style.display = "none";
        }
    }

    function resetMenuFilters() {
        var defaultSort = document.querySelector('input[name="sortOption"][value="default"]');
        if (defaultSort) defaultSort.checked = true;

        var defaultPref = document.querySelector('input[name="prefOption"][value="all"]');
        if (defaultPref) defaultPref.checked = true;

        if (menuSearch) menuSearch.value = "";

        applyMenuFilters();
        closeDropdown();
    }

    if (applyFiltersBtn) {
        applyFiltersBtn.addEventListener("click", function() {
            applyMenuFilters();
            closeDropdown();
        });
    }

    if (resetFiltersBtn) {
        resetFiltersBtn.addEventListener("click", function(e) {
            e.preventDefault();
            resetMenuFilters();
        });
    }

    if (menuSearch) {
        menuSearch.addEventListener("input", applyMenuFilters);
    }

    // Expose filter functions to window for onclick handlers
    window.applyMenuFilters = applyMenuFilters;
    window.resetMenuFilters = resetMenuFilters;

    // -------------------------------------------------------------
    // 2. DYNAMIC UI & CART UPDATES
    // -------------------------------------------------------------
    function updateCartUI(data) {
        if (!data || typeof data !== "object") return;

        var totalQty = Number(data.totalQuantity) || 0;
        var totalAmt = Number(data.totalAmount) || 0;

        if (cartBarCount) cartBarCount.textContent = String(totalQty);
        if (previewTotalAmount) previewTotalAmount.textContent = "₹" + formatPrice(totalAmt);

        if (floatingCartBar) {
            floatingCartBar.hidden = (totalQty <= 0);
            floatingCartBar.style.display = (totalQty <= 0) ? "none" : "flex";
        }

        var itemMap = new Map();
        var summaryParts = [];

        if (Array.isArray(data.items)) {
            renderCartPreview(data.items);
            data.items.forEach(function(item) {
                itemMap.set(String(item.menuId), Number(item.quantity) || 0);
                summaryParts.push((item.name || "Item") + " x" + item.quantity);
            });
        }

        if (cartBarSummary) {
            cartBarSummary.textContent = summaryParts.join(", ");
        }

        // Update card stepper displays
        getMenuCards().forEach(function(card) {
            var menuId = card.dataset.menuId;
            var qty = itemMap.get(String(menuId)) || 0;
            setCardQuantityUI(card, menuId, qty);
        });
    }

    function setCardQuantityUI(card, menuId, quantity) {
        var addBtn = document.getElementById("addBtn-" + menuId) || card.querySelector(".btn-add-cart, .cart-form");
        var stepper = document.getElementById("stepper-" + menuId) || card.querySelector(".quantity-stepper-box, .quantity-form");
        var qtyVal = document.getElementById("qty-val-" + menuId) || (stepper ? stepper.querySelector(".stepper-val, .quantity-value") : null);

        if (quantity > 0) {
            if (addBtn) addBtn.style.display = "none";
            if (stepper) stepper.style.display = "flex";
            if (qtyVal) qtyVal.textContent = String(quantity);
        } else {
            if (addBtn) addBtn.style.display = "";
            if (stepper) stepper.style.display = "none";
            if (qtyVal) qtyVal.textContent = "0";
        }
    }

    function renderCartPreview(items) {
        if (!previewItemsList) return;

        if (!items || items.length === 0) {
            previewItemsList.innerHTML = "<p style='color:#777; text-align:center;'>Your cart is empty.</p>";
            return;
        }

        previewItemsList.innerHTML = "";
        items.forEach(function(item) {
            var row = document.createElement("div");
            row.className = "preview-item-row";
            row.style.cssText = "display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid #eee;";

            var name = document.createElement("span");
            name.innerHTML = "<strong>" + (item.name || "Item") + "</strong> × " + item.quantity;

            var subtotal = document.createElement("span");
            subtotal.textContent = "₹" + formatPrice(item.subtotal);

            row.appendChild(name);
            row.appendChild(subtotal);
            previewItemsList.appendChild(row);
        });
    }

    // -------------------------------------------------------------
    // 3. AJAX SERVER REQUESTS
    // -------------------------------------------------------------
    async function sendCartAjax(menuId, action, quantity) {
        try {
            var params = new URLSearchParams();
            params.append("action", action);
            params.append("menuId", String(menuId));
            params.append("quantity", String(quantity));
            params.append("ajax", "true");
            params.append("source", "menu");

            var response = await fetch(contextPath + "/cart", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "Accept": "application/json",
                    "X-Requested-With": "XMLHttpRequest"
                },
                body: params.toString()
            });

            var data = await response.json();

            if (data.conflict) {
                var popup = document.getElementById("restaurantConflict");
                var msgEl = document.getElementById("conflictMessageText");
                if (msgEl) msgEl.textContent = data.message || "You cannot add items from another restaurant.";
                if (popup) popup.style.display = "flex";
                return;
            }

            if (data.success !== false) {
                updateCartUI(data);
                showToast(data.message || "Cart updated!", false);
            } else {
                showToast(data.message || "Could not update cart.", true);
            }
        } catch (err) {
            console.error("Cart Request Error:", err);
            showToast("Server error updating cart.", true);
        }
    }

    // Global action helpers compatible with inline JSP onclick attributes
    window.ajaxCartAction = function(menuId, action, quantity) {
        sendCartAjax(menuId, action, quantity || 1);
    };

    window.ajaxCartStep = function(menuId, delta) {
        var qtyVal = document.getElementById("qty-val-" + menuId);
        var current = parseInt(qtyVal ? qtyVal.textContent : "0", 10) || 0;
        var newQty = Math.max(0, current + delta);
        var action = (newQty <= 0) ? "remove" : "update";
        sendCartAjax(menuId, action, newQty);
    };

    // Modal helpers
    window.openCartPreview = function() {
        if (cartPreviewModal) cartPreviewModal.style.display = "flex";
    };

    window.closeCartPreview = function() {
        if (cartPreviewModal) cartPreviewModal.style.display = "none";
    };

    window.closeConflictPopup = function() {
        var popup = document.getElementById("restaurantConflict");
        if (popup) popup.style.display = "none";
    };
});