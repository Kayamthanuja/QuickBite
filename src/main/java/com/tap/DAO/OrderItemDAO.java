package com.tap.DAO;

import java.util.List;
import com.tap.model.OrderItem;

public interface OrderItemDAO {

    void addOrderItem(OrderItem orderItem);

    OrderItem getOrderItem(int orderItemId);

    List<OrderItem> getAllOrderItems();

    List<OrderItem> getAllOrderItemsByOrderID(int orderId);

    void updateOrderItem(OrderItem orderItem);

    void deleteOrderItem(int orderItemId);
}