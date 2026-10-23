"use strict";

document.addEventListener("DOMContentLoaded", function() {
    var contextPath = window.QUICK_BITE_CONTEXT || window.QUICK_BITE_CONTEXT_PATH || "";

    var menuGrid = document.getElementById("menuGrid");
    var menuSearch = document.getElementById("menuSearch");
    var menuCount = document.getElementById("menuCount") || document.querySelector(".items-count-text");
    var noSearchResults = document.getElementById("noSearchResults");

    var filterDropdownBtn = document.getElementById("filterDropdownBtn");
    var filterDropdownMenu = document.getElementById("filterDropdownMenu");
    var applyFiltersBtn = document.getElementById("applyFiltersBtn");
    var resetFiltersBtn = document.getElementById("resetFiltersBtn");

    var floatingCartBar = document.getElementById("floatingCartBar") || document.getElementById("menuCartBar");
    var cartBarCount = document.getElementById("cartBarCount") || document.getElementById("menuCartCount");
    var cartBarTotal = document.getElementById("cartBarTotal") || document.getElementById("menuCartTotal");

    var cartPreviewPanel = document.getElementById("cartPreviewPanel") || document.getElementById("cartPreview");
    var previewItemsList = document.getElementById("previewItemsList") || document.getElementById("cartPreviewItems");
    var btnTogglePreview = document.getElementById("btnTogglePreview") || document.getElementById("cartPreviewToggle");
    var btnClosePreview = document.getElementById("btnClosePreview") || document.getElementById("closeCartPreview");

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
        if (isError) cartToast.classList.add("error");
        else cartToast.classList.remove("error");
        cartToast.hidden = false;

        if (toastTimeout) clearTimeout(toastTimeout);
        toastTimeout = setTimeout(function() {
            cartToast.hidden = true;
        }, 3000);
    }

    // -------------------------------------------------------------
    // 1. FILTERS & SEARCH (PRESERVED)
    // -------------------------------------------------------------
    if (filterDropdownBtn && filterDropdownMenu) {
        filterDropdownBtn.addEventListener("click", function(e) {
            e.stopPropagation();
            filterDropdownMenu.classList.toggle("show");
        });

        document.addEventListener("click", function(e) {
            if (!filterDropdownMenu.contains(e.target) && e.target !== filterDropdownBtn) {
                filterDropdownMenu.classList.remove("show");
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
        var visibleCards = [];

        cards.forEach(function(card) {
            var searchText = (card.dataset.search || card.textContent).toLowerCase();
            var foodType = card.dataset.foodType || "veg";

            var matchesSearch = !searchTerm || searchText.indexOf(searchTerm) !== -1;
            var matchesPref = true;

            if (selectedPref === "veg") matchesPref = (foodType === "veg");
            else if (selectedPref === "non-veg") matchesPref = (foodType === "non-veg");

            if (matchesSearch && matchesPref) {
                card.style.display = "";
                card.hidden = false;
                visibleCards.push(card);
            } else {
                card.style.display = "none";
                card.hidden = true;
            }
        });

        if (selectedSort === "low-high") {
            visibleCards.sort(function(a, b) {
                return (Number(a.dataset.price) || 0) - (Number(b.dataset.price) || 0);
            });
        } else if (selectedSort === "high-low") {
            visibleCards.sort(function(a, b) {
                return (Number(b.dataset.price) || 0) - (Number(a.dataset.price) || 0);
            });
        }

        if (menuGrid && (selectedSort === "low-high" || selectedSort === "high-low")) {
            visibleCards.forEach(function(card) {
                menuGrid.appendChild(card);
            });
        }

        if (menuCount) menuCount.textContent = "Showing " + visibleCards.length + " menu items";
        if (noSearchResults) noSearchResults.style.display = (visibleCards.length === 0) ? "block" : "none";
    }

    if (applyFiltersBtn && filterDropdownMenu) {
        applyFiltersBtn.addEventListener("click", function() {
            applyMenuFilters();
            filterDropdownMenu.classList.remove("show");
        });
    }

    if (resetFiltersBtn) {
        resetFiltersBtn.addEventListener("click", function(e) {
            e.preventDefault();
            var defaultSort = document.querySelector('input[name="sortOption"][value="default"]');
            if (defaultSort) defaultSort.checked = true;
            var defaultPref = document.querySelector('input[name="prefOption"][value="all"]');
            if (defaultPref) defaultPref.checked = true;
            if (menuSearch) menuSearch.value = "";
            applyMenuFilters();
        });
    }

    if (menuSearch) menuSearch.addEventListener("input", applyMenuFilters);

    // -------------------------------------------------------------
    // 2. DYNAMIC UI & STEPPER TRANSFORMATION
    // -------------------------------------------------------------
    function updateCartUI(data) {
        if (!data || typeof data !== "object") return;

        var totalQty = Number(data.totalQuantity) || 0;
        var totalAmt = Number(data.totalAmount) || 0;

        if (cartBarCount) cartBarCount.textContent = String(totalQty);
        if (cartBarTotal) cartBarTotal.textContent = formatPrice(totalAmt);

        if (floatingCartBar) {
            floatingCartBar.hidden = (totalQty <= 0);
            floatingCartBar.style.display = (totalQty <= 0) ? "none" : "flex";
        }

        var itemMap = new Map();
        if (Array.isArray(data.items)) {
            renderCartPreview(data.items);
            data.items.forEach(function(item) {
                itemMap.set(String(item.menuId), Number(item.quantity) || 0);
            });
        }

        getMenuCards().forEach(function(card) {
            var menuId = card.dataset.menuId;
            var qty = itemMap.get(String(menuId)) || 0;
            setCardQuantityUI(card, qty);
        });
    }

    function setCardQuantityUI(card, quantity) {
        var addForm = card.querySelector(".cart-form");
        var quantityForm = card.querySelector(".quantity-form");

        if (quantity > 0) {
            if (addForm) {
                addForm.style.display = "none";
                addForm.hidden = true;
            }
            if (quantityForm) {
                quantityForm.style.display = "flex";
                quantityForm.hidden = false;

                var qtyDisplay = quantityForm.querySelector(".quantity-value");
                var qtyInput = quantityForm.querySelector('input[name="quantity"]');

                if (qtyDisplay) qtyDisplay.textContent = String(quantity);
                if (qtyInput) qtyInput.value = String(quantity);
            }
        } else {
            if (addForm) {
                addForm.style.display = "";
                addForm.hidden = false;
            }
            if (quantityForm) {
                quantityForm.style.display = "none";
                quantityForm.hidden = true;
            }
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
            row.style.display = "flex";
            row.style.justifyContent = "space-between";
            row.style.padding = "8px 0";
            row.style.borderBottom = "1px solid #eee";

            var name = document.createElement("span");
            name.style.fontWeight = "600";
            name.textContent = (item.name || "Item") + " × " + item.quantity;

            var subtotal = document.createElement("strong");
            subtotal.textContent = "₹" + formatPrice(item.subtotal);

            row.appendChild(name);
            row.appendChild(subtotal);
            previewItemsList.appendChild(row);
        });
    }

    // -------------------------------------------------------------
    // 3. AJAX SERVER REQUESTS
    // -------------------------------------------------------------
    function sendCartRequest(form, action, quantity) {
        if (!form) return;
        var menuIdInput = form.querySelector('input[name="menuId"]');
        var menuId = menuIdInput ? menuIdInput.value : "";
        if (!menuId) return;

        var params = new URLSearchParams();
        params.append("action", action);
        params.append("menuId", menuId);
        params.append("source", "menu");
        if (quantity !== undefined) {
            params.append("quantity", String(quantity));
        }

        var requestUrl = form.action || (contextPath + "/cart");

        fetch(requestUrl, {
            method: "POST",
            body: params.toString(),
            credentials: "same-origin",
            headers: {
                "X-Requested-With": "XMLHttpRequest",
                "Accept": "application/json",
                "Content-Type": "application/x-www-form-urlencoded"
            }
        })
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                if (data && data.success !== false) {
                    updateCartUI(data);
                    showToast(data.message || "Cart updated!", false);
                } else {
                    showToast(data.message || "Could not update cart.", true);
                }
            })
            .catch(function(err) {
                console.error("Cart Request Error:", err);
                showToast("Server error updating cart.", true);
            });
    }

    // Listen for ADD + clicks
    document.addEventListener("submit", function(e) {
        var form = e.target;
        if (form && form.matches(".cart-form")) {
            e.preventDefault();
            sendCartRequest(form, "add");
        }
    });

    // Listen for Stepper (+ / −) clicks
    document.addEventListener("click", function(e) {
        var incBtn = e.target.closest(".quantity-increase");
        var decBtn = e.target.closest(".quantity-decrease");

        if (!incBtn && !decBtn) return;
        e.preventDefault();

        var form = (incBtn || decBtn).closest(".quantity-form");
        if (!form) return;

        var qtyInput = form.querySelector('input[name="quantity"]');
        var qtyDisplay = form.querySelector(".quantity-value");
        var currentQty = qtyInput ? Number(qtyInput.value) : Number(qtyDisplay ? qtyDisplay.textContent : 0);

        var newQty = incBtn ? currentQty + 1 : currentQty - 1;
        var action = (newQty <= 0) ? "remove" : "update";

        sendCartRequest(form, action, newQty);
    });

    // Cart preview drawer controls
    if (btnTogglePreview && cartPreviewPanel) {
        btnTogglePreview.addEventListener("click", function() {
            cartPreviewPanel.hidden = !cartPreviewPanel.hidden;
            cartPreviewPanel.style.display = cartPreviewPanel.hidden ? "none" : "block";
        });
    }

    if (btnClosePreview && cartPreviewPanel) {
        btnClosePreview.addEventListener("click", function() {
            cartPreviewPanel.hidden = true;
            cartPreviewPanel.style.display = "none";
        });
    }
});