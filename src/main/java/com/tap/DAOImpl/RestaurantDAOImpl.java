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
          + "(name, cuisineType, deliveryTime, address, adminUserId, rating, isActive, imagePath) "
          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ID_QUERY =
            "SELECT * FROM restaurant WHERE restaurantId = ?";

    private static final String SELECT_ALL_QUERY =
            "SELECT * FROM restaurant";

    private static final String UPDATE_QUERY =
            "UPDATE restaurant SET name = ?, cuisineType = ?, deliveryTime = ?, "
          + "address = ?, adminUserId = ?, rating = ?, isActive = ?, imagePath = ? "
          + "WHERE restaurantId = ?";

    private static final String DELETE_QUERY =
            "DELETE FROM restaurant WHERE restaurantId = ?";


    @Override
    public void addRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(INSERT_QUERY)) {

            preparedStatement.setString(1, restaurant.getName());
            preparedStatement.setString(2, restaurant.getCuisineType());
            preparedStatement.setString(3, restaurant.getDeliveryTime());
            preparedStatement.setString(4, restaurant.getAddress());
            preparedStatement.setInt(5, restaurant.getAdminUserId());
            preparedStatement.setDouble(6, restaurant.getRating());
            preparedStatement.setBoolean(7, restaurant.isActive());
            preparedStatement.setString(8, restaurant.getImagePath());

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public Restaurant getRestaurant(int restaurantId) {

        Restaurant restaurant = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_BY_ID_QUERY)) {

            preparedStatement.setInt(1, restaurantId);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                if (resultSet.next()) {

                    restaurant = new Restaurant();

                    restaurant.setRestaurantId(
                            resultSet.getInt("restaurantId"));

                    restaurant.setName(
                            resultSet.getString("name"));

                    restaurant.setCuisineType(
                            resultSet.getString("cuisineType"));

                    restaurant.setDeliveryTime(
                            resultSet.getString("deliveryTime"));

                    restaurant.setAddress(
                            resultSet.getString("address"));

                    restaurant.setAdminUserId(
                            resultSet.getInt("adminUserId"));

                    restaurant.setRating(
                            resultSet.getDouble("rating"));

                    restaurant.setActive(
                            resultSet.getBoolean("isActive"));

                    restaurant.setImagePath(
                            resultSet.getString("imagePath"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurant;
    }


    @Override
    public List<Restaurant> getAllRestaurants() {

        List<Restaurant> restaurantList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_ALL_QUERY);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {

                Restaurant restaurant = new Restaurant();

                restaurant.setRestaurantId(
                        resultSet.getInt("restaurantId"));

                restaurant.setName(
                        resultSet.getString("name"));

                restaurant.setCuisineType(
                        resultSet.getString("cuisineType"));

                restaurant.setDeliveryTime(
                        resultSet.getString("deliveryTime"));

                restaurant.setAddress(
                        resultSet.getString("address"));

                restaurant.setAdminUserId(
                        resultSet.getInt("adminUserId"));

                restaurant.setRating(
                        resultSet.getDouble("rating"));

                restaurant.setActive(
                        resultSet.getBoolean("isActive"));

                restaurant.setImagePath(
                        resultSet.getString("imagePath"));

                restaurantList.add(restaurant);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurantList;
    }


    @Override
    public void updateRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(UPDATE_QUERY)) {

            preparedStatement.setString(1, restaurant.getName());
            preparedStatement.setString(2, restaurant.getCuisineType());
            preparedStatement.setString(3, restaurant.getDeliveryTime());
            preparedStatement.setString(4, restaurant.getAddress());
            preparedStatement.setInt(5, restaurant.getAdminUserId());
            preparedStatement.setDouble(6, restaurant.getRating());
            preparedStatement.setBoolean(7, restaurant.isActive());
            preparedStatement.setString(8, restaurant.getImagePath());
            preparedStatement.setInt(9, restaurant.getRestaurantId());

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void deleteRestaurant(int restaurantId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(DELETE_QUERY)) {

            preparedStatement.setInt(1, restaurantId);

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}