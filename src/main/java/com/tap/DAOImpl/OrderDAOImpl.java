package com.tap.DAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.OrderDAO;
import com.tap.model.Order;
import com.tap.model.OrderHistory;
import com.tap.util.DBConnection;
import com.tap.util.GeoUtil;

public class OrderDAOImpl implements OrderDAO {

	private static final String INSERT_QUERY = "INSERT INTO orders (userId, restaurantId, orderDate, totalAmount, "
			+ "status, paymentMode, deliveryAddress, deliveryPartnerId, destLat, destLng, riderLat, riderLng) "
			+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

	private static final String SELECT_BY_ID_QUERY = "SELECT * FROM orders WHERE orderId = ?";

	private static final String SELECT_ALL_QUERY = "SELECT * FROM orders";

	private static final String SELECT_BY_USER_ID_QUERY = "SELECT * FROM orders WHERE userId = ?";

	private static final String UPDATE_QUERY = "UPDATE orders SET userId = ?, restaurantId = ?, orderDate = ?, "
			+ "totalAmount = ?, status = ?, paymentMode = ?, deliveryAddress = ?, deliveryPartnerId = ?, "
			+ "destLat = ?, destLng = ?, riderLat = ?, riderLng = ? WHERE orderId = ?";

	private static final String DELETE_QUERY = "DELETE FROM orders WHERE orderId = ?";

	private static final String SELECT_ITEMS_BY_USER_ID_QUERY = "SELECT * FROM orders WHERE userId = ? ORDER BY orderDate DESC";

	@Override
	public int addOrder(Order order) {

		int orderId = 0;

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(INSERT_QUERY,
						Statement.RETURN_GENERATED_KEYS)) {

			preparedStatement.setInt(1, order.getUserId());
			preparedStatement.setInt(2, order.getRestaurantId());
			preparedStatement.setTimestamp(3, order.getOrderDate());
			preparedStatement.setDouble(4, order.getTotalAmount());
			preparedStatement.setString(5, order.getStatus());
			preparedStatement.setString(6, order.getPaymentMode());
			preparedStatement.setString(7, order.getDeliveryAddress());
			if (order.getDeliveryPartnerId() != null) {
				preparedStatement.setInt(8, order.getDeliveryPartnerId());
			} else {
				preparedStatement.setNull(8, java.sql.Types.INTEGER);
			}
			if (order.getDestLat() != null) {
				preparedStatement.setDouble(9, order.getDestLat());
			} else {
				preparedStatement.setNull(9, java.sql.Types.DOUBLE);
			}
			if (order.getDestLng() != null) {
				preparedStatement.setDouble(10, order.getDestLng());
			} else {
				preparedStatement.setNull(10, java.sql.Types.DOUBLE);
			}
			if (order.getRiderLat() != null) {
				preparedStatement.setDouble(11, order.getRiderLat());
			} else {
				preparedStatement.setNull(11, java.sql.Types.DOUBLE);
			}
			if (order.getRiderLng() != null) {
				preparedStatement.setDouble(12, order.getRiderLng());
			} else {
				preparedStatement.setNull(12, java.sql.Types.DOUBLE);
			}

			preparedStatement.executeUpdate();

			// Get the generated orderId
			try (ResultSet resultSet = preparedStatement.getGeneratedKeys()) {

				if (resultSet.next()) {

					orderId = resultSet.getInt(1);

					// Also set the generated ID inside Order object
					order.setOrderId(orderId);
				}
			}

		} catch (SQLException e) {

			e.printStackTrace();
		}

		return orderId;
	}

	@Override
	public Order getOrder(int orderId) {

		Order order = null;

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(SELECT_BY_ID_QUERY)) {

			preparedStatement.setInt(1, orderId);

			try (ResultSet resultSet = preparedStatement.executeQuery()) {

				if (resultSet.next()) {
					order = mapOrder(resultSet);
				}
			}

		} catch (SQLException e) {

			e.printStackTrace();
		}

		return order;
	}

	@Override
	public List<Order> getAllOrders() {

		List<Order> orderList = new ArrayList<>();

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL_QUERY);
				ResultSet resultSet = preparedStatement.executeQuery()) {

			while (resultSet.next()) {
				orderList.add(mapOrder(resultSet));
			}

		} catch (SQLException e) {

			e.printStackTrace();
		}

		return orderList;
	}

	@Override
	public List<Order> getAllOrdersByUserID(int userId) {

		List<Order> orderList = new ArrayList<>();

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(SELECT_BY_USER_ID_QUERY)) {

			preparedStatement.setInt(1, userId);

			try (ResultSet resultSet = preparedStatement.executeQuery()) {

				while (resultSet.next()) {
					orderList.add(mapOrder(resultSet));
				}
			}

		} catch (SQLException e) {

			e.printStackTrace();
		}

		return orderList;
	}

	@Override
	public void updateOrder(Order order) {

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(UPDATE_QUERY)) {

			preparedStatement.setInt(1, order.getUserId());

			preparedStatement.setInt(2, order.getRestaurantId());

			preparedStatement.setTimestamp(3, order.getOrderDate());

			preparedStatement.setDouble(4, order.getTotalAmount());

			preparedStatement.setString(5, order.getStatus());

			preparedStatement.setString(6, order.getPaymentMode());

			preparedStatement.setString(7, order.getDeliveryAddress());

			if (order.getDeliveryPartnerId() != null) {
				preparedStatement.setInt(8, order.getDeliveryPartnerId());
			} else {
				preparedStatement.setNull(8, java.sql.Types.INTEGER);
			}
			if (order.getDestLat() != null) {
				preparedStatement.setDouble(9, order.getDestLat());
			} else {
				preparedStatement.setNull(9, java.sql.Types.DOUBLE);
			}
			if (order.getDestLng() != null) {
				preparedStatement.setDouble(10, order.getDestLng());
			} else {
				preparedStatement.setNull(10, java.sql.Types.DOUBLE);
			}
			if (order.getRiderLat() != null) {
				preparedStatement.setDouble(11, order.getRiderLat());
			} else {
				preparedStatement.setNull(11, java.sql.Types.DOUBLE);
			}
			if (order.getRiderLng() != null) {
				preparedStatement.setDouble(12, order.getRiderLng());
			} else {
				preparedStatement.setNull(12, java.sql.Types.DOUBLE);
			}

			preparedStatement.setInt(13, order.getOrderId());

			preparedStatement.executeUpdate();

		} catch (SQLException e) {

			e.printStackTrace();
		}
	}

	@Override
	public void deleteOrder(int orderId) {

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(DELETE_QUERY)) {

			preparedStatement.setInt(1, orderId);

			preparedStatement.executeUpdate();

		} catch (SQLException e) {

			e.printStackTrace();
		}
	}
	

@Override
public List<OrderHistory> getOrderHistoryByUserId(int userId) {

    List<OrderHistory> historyList = new ArrayList<>();

    String query =
        "SELECT o.orderId, r.name AS restaurantName, " +
        "o.status, o.totalAmount, " +
        "COALESCE(GROUP_CONCAT(" +
        "CONCAT(m.itemName, ' x ', oi.quantity) " +
        "ORDER BY oi.orderItemId SEPARATOR ', '), " +
        "'Items unavailable') AS items " +
        "FROM orders o " +
        "JOIN restaurant r ON o.restaurantId = r.restaurantId " +
        "LEFT JOIN order_item oi ON o.orderId = oi.orderId " +
        "LEFT JOIN menu m ON oi.menuId = m.menuId " +
        "WHERE o.userId = ? " +
        "GROUP BY o.orderId, r.name, o.status, " +
        "o.totalAmount, o.orderDate " +
        "ORDER BY o.orderDate DESC";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ps = connection.prepareStatement(query)) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                OrderHistory history = new OrderHistory();

                history.setOrderId(rs.getInt("orderId"));
                history.setRestaurantName(
                    rs.getString("restaurantName")
                );
                history.setItems(rs.getString("items"));
                history.setStatus(rs.getString("status"));
                history.setTotalAmount(
                    rs.getDouble("totalAmount")
                );

                historyList.add(history);
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return historyList;
}

	@Override
	public List<Order> getOrdersByDeliveryPartner(int deliveryPartnerId) {
		List<Order> orderList = new ArrayList<>();
		String query = "SELECT * FROM orders WHERE deliveryPartnerId = ? ORDER BY orderDate DESC";
		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(query)) {
			preparedStatement.setInt(1, deliveryPartnerId);
			try (ResultSet resultSet = preparedStatement.executeQuery()) {
				while (resultSet.next()) {
					orderList.add(mapOrder(resultSet));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return orderList;
	}

	@Override
	public List<Order> getUnassignedActiveOrders() {
		List<Order> orderList = new ArrayList<>();
		String query = "SELECT * FROM orders WHERE (deliveryPartnerId IS NULL OR deliveryPartnerId = 0) "
				+ "AND LOWER(status) NOT LIKE '%deliver%' AND LOWER(status) NOT LIKE '%cancel%' "
				+ "ORDER BY orderDate DESC";
		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(query);
				ResultSet resultSet = preparedStatement.executeQuery()) {
			while (resultSet.next()) {
				orderList.add(mapOrder(resultSet));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return orderList;
	}

	@Override
	public void updateStatus(int orderId, String status) {
		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection
						.prepareStatement("UPDATE orders SET status = ? WHERE orderId = ?")) {
			preparedStatement.setString(1, status);
			preparedStatement.setInt(2, orderId);
			preparedStatement.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void assignDeliveryPartner(int orderId, int deliveryPartnerId) {
		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection
						.prepareStatement("UPDATE orders SET deliveryPartnerId = ? WHERE orderId = ?")) {
			preparedStatement.setInt(1, deliveryPartnerId);
			preparedStatement.setInt(2, orderId);
			preparedStatement.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void updateRiderLocation(int orderId, double lat, double lng) {
		try (Connection connection = DBConnection.getConnection();
				PreparedStatement preparedStatement = connection
						.prepareStatement("UPDATE orders SET riderLat = ?, riderLng = ? WHERE orderId = ?")) {
			preparedStatement.setDouble(1, lat);
			preparedStatement.setDouble(2, lng);
			preparedStatement.setInt(3, orderId);
			preparedStatement.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	private static Order mapOrder(ResultSet resultSet) throws SQLException {
		Order order = new Order();
		order.setOrderId(resultSet.getInt("orderId"));
		order.setUserId(resultSet.getInt("userId"));
		order.setRestaurantId(resultSet.getInt("restaurantId"));
		order.setOrderDate(resultSet.getTimestamp("orderDate"));
		order.setTotalAmount(resultSet.getDouble("totalAmount"));
		order.setStatus(resultSet.getString("status"));
		order.setPaymentMode(resultSet.getString("paymentMode"));
		order.setDeliveryAddress(resultSet.getString("deliveryAddress"));

		try {
			int partnerId = resultSet.getInt("deliveryPartnerId");
			if (!resultSet.wasNull()) {
				order.setDeliveryPartnerId(partnerId);
			}
			double destLat = resultSet.getDouble("destLat");
			if (!resultSet.wasNull()) {
				order.setDestLat(destLat);
			}
			double destLng = resultSet.getDouble("destLng");
			if (!resultSet.wasNull()) {
				order.setDestLng(destLng);
			}
			double riderLat = resultSet.getDouble("riderLat");
			if (!resultSet.wasNull()) {
				order.setRiderLat(riderLat);
			}
			double riderLng = resultSet.getDouble("riderLng");
			if (!resultSet.wasNull()) {
				order.setRiderLng(riderLng);
			}
		} catch (SQLException ignored) {
		}

		GeoUtil.fillMissingCoords(order);
		return order;
	}

}