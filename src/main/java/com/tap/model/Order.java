package com.tap.model;

import java.sql.Timestamp;

public class Order {

    private int orderId;
    private int userId;
    private int restaurantId;
    private Timestamp orderDate;
    private double totalAmount;
    private String status;
    private String paymentMode;
    private String deliveryAddress;
    private Integer deliveryPartnerId;
    private Double destLat;
    private Double destLng;
    private Double riderLat;
    private Double riderLng;

    // Default Constructor
    public Order() {
    }

    // Parameterized Constructor
    public Order(int orderId, int userId, int restaurantId,
                 Timestamp orderDate, double totalAmount,
                 String status, String paymentMode,
                 String deliveryAddress) {
        this.orderId = orderId;
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
        this.paymentMode = paymentMode;
        this.deliveryAddress = deliveryAddress;
    }

    // Getters and Setters

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentMode() {
        return paymentMode;
    }

    public void setPaymentMode(String paymentMode) {
        this.paymentMode = paymentMode;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public Integer getDeliveryPartnerId() {
        return deliveryPartnerId;
    }

    public void setDeliveryPartnerId(Integer deliveryPartnerId) {
        this.deliveryPartnerId = deliveryPartnerId;
    }

    public Double getDestLat() {
        return destLat;
    }

    public void setDestLat(Double destLat) {
        this.destLat = destLat;
    }

    public Double getDestLng() {
        return destLng;
    }

    public void setDestLng(Double destLng) {
        this.destLng = destLng;
    }

    public Double getRiderLat() {
        return riderLat;
    }

    public void setRiderLat(Double riderLat) {
        this.riderLat = riderLat;
    }

    public Double getRiderLng() {
        return riderLng;
    }

    public void setRiderLng(Double riderLng) {
        this.riderLng = riderLng;
    }

    @Override
    public String toString() {
        return "Order [orderId=" + orderId
                + ", userId=" + userId
                + ", restaurantId=" + restaurantId
                + ", orderDate=" + orderDate
                + ", totalAmount=" + totalAmount
                + ", status=" + status
                + ", paymentMode=" + paymentMode
                + ", deliveryAddress=" + deliveryAddress + "]";
    }
}