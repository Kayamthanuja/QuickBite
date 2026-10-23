package com.tap.DAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.OrderItemDAO;
import com.tap.model.OrderItem;
import com.tap.util.DBConnection;

public class OrderItemDAOImpl implements OrderItemDAO {

    private static final String INSERT_QUERY =
            "INSERT INTO order_item (orderId, menuId, quantity, totalAmount) "
          + "VALUES (?, ?, ?, ?)";

    private static final String SELECT_BY_ID_QUERY =
            "SELECT * FROM order_item WHERE orderItemId = ?";

    private static final String SELECT_ALL_QUERY =
            "SELECT * FROM order_item";

    private static final String SELECT_BY_ORDER_ID_QUERY =
            "SELECT * FROM order_item WHERE orderId = ?";

    private static final String UPDATE_QUERY =
            "UPDATE order_item SET orderId = ?, menuId = ?, quantity = ?, "
          + "totalAmount = ? WHERE orderItemId = ?";

    private static final String DELETE_QUERY =
            "DELETE FROM order_item WHERE orderItemId = ?";


    @Override
    public void addOrderItem(OrderItem orderItem) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(INSERT_QUERY)) {

            preparedStatement.setInt(1, orderItem.getOrderId());
            preparedStatement.setInt(2, orderItem.getMenuId());
            preparedStatement.setInt(3, orderItem.getQuantity());
            preparedStatement.setDouble(4, orderItem.getTotalAmount());

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public OrderItem getOrderItem(int orderItemId) {

        OrderItem orderItem = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_BY_ID_QUERY)) {

            preparedStatement.setInt(1, orderItemId);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                if (resultSet.next()) {

                    orderItem = new OrderItem();

                    orderItem.setOrderItemId(
                            resultSet.getInt("orderItemId"));
                    orderItem.setOrderId(
                            resultSet.getInt("orderId"));
                    orderItem.setMenuId(
                            resultSet.getInt("menuId"));
                    orderItem.setQuantity(
                            resultSet.getInt("quantity"));
                    orderItem.setTotalAmount(
                            resultSet.getDouble("totalAmount"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItem;
    }


    @Override
    public List<OrderItem> getAllOrderItems() {

        List<OrderItem> orderItemList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_ALL_QUERY);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {

                OrderItem orderItem = new OrderItem();

                orderItem.setOrderItemId(
                        resultSet.getInt("orderItemId"));
                orderItem.setOrderId(
                        resultSet.getInt("orderId"));
                orderItem.setMenuId(
                        resultSet.getInt("menuId"));
                orderItem.setQuantity(
                        resultSet.getInt("quantity"));
                orderItem.setTotalAmount(
                        resultSet.getDouble("totalAmount"));

                orderItemList.add(orderItem);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItemList;
    }


    @Override
    public List<OrderItem> getAllOrderItemsByOrderID(int orderId) {

        List<OrderItem> orderItemList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_BY_ORDER_ID_QUERY)) {

            preparedStatement.setInt(1, orderId);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                while (resultSet.next()) {

                    OrderItem orderItem = new OrderItem();

                    orderItem.setOrderItemId(
                            resultSet.getInt("orderItemId"));
                    orderItem.setOrderId(
                            resultSet.getInt("orderId"));
                    orderItem.setMenuId(
                            resultSet.getInt("menuId"));
                    orderItem.setQuantity(
                            resultSet.getInt("quantity"));
                    orderItem.setTotalAmount(
                            resultSet.getDouble("totalAmount"));

                    orderItemList.add(orderItem);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItemList;
    }


    @Override
    public void updateOrderItem(OrderItem orderItem) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(UPDATE_QUERY)) {

            preparedStatement.setInt(1, orderItem.getOrderId());
            preparedStatement.setInt(2, orderItem.getMenuId());
            preparedStatement.setInt(3, orderItem.getQuantity());
            preparedStatement.setDouble(4, orderItem.getTotalAmount());
            preparedStatement.setInt(5, orderItem.getOrderItemId());

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void deleteOrderItem(int orderItemId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(DELETE_QUERY)) {

            preparedStatement.setInt(1, orderItemId);

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}