package com.tap.DAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.RestaurantDAO;
import com.tap.model.Restaurant;
import com.tap.util.DBConnection;

public class RestaurantDAOImpl implements RestaurantDAO {

    private static final String INSERT_QUERY =
            "INSERT INTO restaurant "
            + "(name, cuisineType, deliveryTime, address, adminUserId, "
            + "rating, isActive, imagePath) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ID_QUERY =
            "SELECT * FROM restaurant WHERE restaurantId = ?";

    private static final String SELECT_ALL_QUERY =
            "SELECT * FROM restaurant ORDER BY restaurantId";

    private static final String UPDATE_QUERY =
            "UPDATE restaurant SET name = ?, cuisineType = ?, "
            + "deliveryTime = ?, address = ?, adminUserId = ?, "
            + "rating = ?, isActive = ?, imagePath = ? "
            + "WHERE restaurantId = ?";

    private static final String DELETE_QUERY =
            "DELETE FROM restaurant WHERE restaurantId = ?";


    // Add a new restaurant
    @Override
    public void addRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(INSERT_QUERY)) {

            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setString(3, restaurant.getDeliveryTime());
            ps.setString(4, restaurant.getAddress());
            ps.setInt(5, restaurant.getAdminUserId());
            ps.setDouble(6, restaurant.getRating());
            ps.setBoolean(7, restaurant.isActive());
            ps.setString(8, restaurant.getImagePath());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                    "Unable to add restaurant.", e);
        }
    }


    // Get one restaurant by ID
    @Override
    public Restaurant getRestaurant(int restaurantId) {

        Restaurant restaurant = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(SELECT_BY_ID_QUERY)) {

            ps.setInt(1, restaurantId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    restaurant = mapRestaurant(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                    "Unable to retrieve restaurant.", e);
        }

        return restaurant;
    }


    // Get all restaurants for the existing management page
    @Override
    public List<Restaurant> getAllRestaurants() {

        List<Restaurant> restaurantList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(SELECT_ALL_QUERY);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                restaurantList.add(mapRestaurant(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                    "Unable to retrieve restaurants.", e);
        }

        return restaurantList;
    }


    // Update restaurant details, including active/closed status
    @Override
    public void updateRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(UPDATE_QUERY)) {

            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setString(3, restaurant.getDeliveryTime());
            ps.setString(4, restaurant.getAddress());
            ps.setInt(5, restaurant.getAdminUserId());
            ps.setDouble(6, restaurant.getRating());
            ps.setBoolean(7, restaurant.isActive());
            ps.setString(8, restaurant.getImagePath());
            ps.setInt(9, restaurant.getRestaurantId());

            int rowsUpdated = ps.executeUpdate();

            if (rowsUpdated == 0) {
                throw new RuntimeException(
                        "Restaurant not found: "
                        + restaurant.getRestaurantId());
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                    "Unable to update restaurant.", e);
        }
    }


    // Delete a restaurant by ID
    @Override
    public void deleteRestaurant(int restaurantId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(DELETE_QUERY)) {

            ps.setInt(1, restaurantId);

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                    "Unable to delete restaurant.", e);
        }
    }


    // Convert a database row into a Restaurant object
    private Restaurant mapRestaurant(ResultSet rs)
            throws SQLException {

        Restaurant restaurant = new Restaurant();

        restaurant.setRestaurantId(
                rs.getInt("restaurantId"));

        restaurant.setName(
                rs.getString("name"));

        restaurant.setCuisineType(
                rs.getString("cuisineType"));

        restaurant.setDeliveryTime(
                rs.getString("deliveryTime"));

        restaurant.setAddress(
                rs.getString("address"));

        restaurant.setAdminUserId(
                rs.getInt("adminUserId"));

        restaurant.setRating(
                rs.getDouble("rating"));

        restaurant.setActive(
                rs.getBoolean("isActive"));

        restaurant.setImagePath(
                rs.getString("imagePath"));

        return restaurant;
    }
}