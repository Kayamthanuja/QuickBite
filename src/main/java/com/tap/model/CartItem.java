package com.tap.model;

public class CartItem {

    private Menu menu;
    private int quantity;

    // Default Constructor
    public CartItem() {

    }

    // Parameterized Constructor
    public CartItem(Menu menu, int quantity) {
        this.menu = menu;
        this.quantity = quantity;
    }

    // Getter and Setter for Menu

    public Menu getMenu() {
        return menu;
    }

    public void setMenu(Menu menu) {
        this.menu = menu;
    }

    // Getter and Setter for Quantity

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    // Calculate Sub Total

    public double getSubTotal() {
        return menu.getPrice() * quantity;
    }

    @Override
    public String toString() {
        return "CartItem [menu=" + menu
                + ", quantity=" + quantity
                + ", subTotal=" + getSubTotal() + "]";
    }
}