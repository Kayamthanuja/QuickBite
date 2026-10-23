package com.tap.DAO;

import java.util.List;
import com.tap.model.Order;
import com.tap.model.OrderHistory;

public interface OrderDAO {

    int  addOrder(Order order);

    Order getOrder(int orderId);

    List<Order> getAllOrders();

    List<Order> getAllOrdersByUserID(int userId);

    void updateOrder(Order order);

    void deleteOrder(int orderId);
    
    List<OrderHistory> getOrderHistoryByUserId(int userId);

    List<Order> getOrdersByDeliveryPartner(int deliveryPartnerId);

    List<Order> getUnassignedActiveOrders();

    void updateStatus(int orderId, String status);

    void assignDeliveryPartner(int orderId, int deliveryPartnerId);

    void updateRiderLocation(int orderId, double lat, double lng);
}