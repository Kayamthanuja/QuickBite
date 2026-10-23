
package com.tap.model;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

public class Cart {

    private int restaurantId;

    private Map<Integer, CartItem> cartItems;

    // Default Constructor
    public Cart() {
        cartItems = new LinkedHashMap<>();
    }

    // Parameterized Constructor
    public Cart(int restaurantId) {
        this.restaurantId = restaurantId;
        cartItems = new LinkedHashMap<>();
    }

    // Getter and Setter for Restaurant ID
    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    // Getter for Cart Items
    public Map<Integer, CartItem> getCartItems() {
        return cartItems;
    }

    // Get All Items
    public Collection<CartItem> getItems() {
        return cartItems.values();
    }

    // Add Menu Item to Cart
    public boolean addItem(Menu menu) {

        if (cartItems.isEmpty()) {
            restaurantId = menu.getRestaurantId();
        }

        // Prevent items from different restaurants.
        if (restaurantId != menu.getRestaurantId()) {
            return false;
        }

        int menuId = menu.getMenuId();

        // If item already exists, increase its quantity.
        if (cartItems.containsKey(menuId)) {

            CartItem existingItem = cartItems.get(menuId);

            existingItem.setQuantity(
                existingItem.getQuantity() + 1
            );

        } else {

            // Add a new item with quantity 1.
            CartItem cartItem = new CartItem(menu, 1);

            cartItems.put(menuId, cartItem);
        }

        return true;
    }

    // Remove Item from Cart
    public void removeItem(int menuId) {

        cartItems.remove(menuId);

        // Reset restaurant ID when cart becomes empty.
        if (cartItems.isEmpty()) {
            restaurantId = 0;
        }
    }

    // Update Quantity
    public void updateQuantity(int menuId, int quantity) {

        if (cartItems.containsKey(menuId)) {

            if (quantity > 0) {

                CartItem cartItem = cartItems.get(menuId);

                cartItem.setQuantity(quantity);

            } else {

                // Remove item when quantity is zero or less.
                cartItems.remove(menuId);

                if (cartItems.isEmpty()) {
                    restaurantId = 0;
                }
            }
        }
    }

    // Calculate Total Amount
    public double getTotalAmount() {

        double total = 0;

        for (CartItem cartItem : cartItems.values()) {
            total = total + cartItem.getSubTotal();
        }

        return total;
    }

    // Clear Cart
    public void clearCart() {

        cartItems.clear();
        restaurantId = 0;
    }

    @Override
    public String toString() {

        return "Cart [restaurantId=" + restaurantId
                + ", cartItems=" + cartItems
                + ", totalAmount=" + getTotalAmount() + "]";
    }
}
