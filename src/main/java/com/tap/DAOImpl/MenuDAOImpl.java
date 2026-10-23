package com.tap.DAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.DAO.MenuDAO;
import com.tap.model.Menu;
import com.tap.util.DBConnection;

public class MenuDAOImpl implements MenuDAO {

    private static final String INSERT_QUERY =
            "INSERT INTO menu (restaurantId, itemName, description, price, isAvailable, imagePath) "
          + "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ID_QUERY =
            "SELECT * FROM menu WHERE menuId = ?";

    private static final String SELECT_ALL_QUERY =
            "SELECT * FROM menu";

    private static final String SELECT_BY_RESTAURANT_ID_QUERY =
            "SELECT * FROM menu WHERE restaurantId = ?";

    private static final String UPDATE_QUERY =
            "UPDATE menu SET restaurantId = ?, itemName = ?, description = ?, "
          + "price = ?, isAvailable = ?, imagePath = ? WHERE menuId = ?";

    private static final String DELETE_QUERY =
            "DELETE FROM menu WHERE menuId = ?";


    @Override
    public void addMenu(Menu menu) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(INSERT_QUERY)) {

            preparedStatement.setInt(1, menu.getRestaurantId());
            preparedStatement.setString(2, menu.getItemName());
            preparedStatement.setString(3, menu.getDescription());
            preparedStatement.setDouble(4, menu.getPrice());
            preparedStatement.setBoolean(5, menu.isAvailable());
            preparedStatement.setString(6, menu.getImagePath());

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public Menu getMenu(int menuId) {

        Menu menu = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_BY_ID_QUERY)) {

            preparedStatement.setInt(1, menuId);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                if (resultSet.next()) {

                    menu = new Menu();

                    menu.setMenuId(resultSet.getInt("menuId"));
                    menu.setRestaurantId(resultSet.getInt("restaurantId"));
                    menu.setItemName(resultSet.getString("itemName"));
                    menu.setDescription(resultSet.getString("description"));
                    menu.setPrice(resultSet.getDouble("price"));
                    menu.setAvailable(resultSet.getBoolean("isAvailable"));
                    menu.setImagePath(resultSet.getString("imagePath"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menu;
    }


    @Override
    public List<Menu> getAllMenus() {

        List<Menu> menuList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_ALL_QUERY);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {

                Menu menu = new Menu();

                menu.setMenuId(resultSet.getInt("menuId"));
                menu.setRestaurantId(resultSet.getInt("restaurantId"));
                menu.setItemName(resultSet.getString("itemName"));
                menu.setDescription(resultSet.getString("description"));
                menu.setPrice(resultSet.getDouble("price"));
                menu.setAvailable(resultSet.getBoolean("isAvailable"));
                menu.setImagePath(resultSet.getString("imagePath"));

                menuList.add(menu);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menuList;
    }


    @Override
    public List<Menu> getMenuByRestaurantID(int restaurantId) {

        List<Menu> menuList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(SELECT_BY_RESTAURANT_ID_QUERY)) {

            preparedStatement.setInt(1, restaurantId);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                while (resultSet.next()) {

                    Menu menu = new Menu();

                    menu.setMenuId(resultSet.getInt("menuId"));
                    menu.setRestaurantId(resultSet.getInt("restaurantId"));
                    menu.setItemName(resultSet.getString("itemName"));
                    menu.setDescription(resultSet.getString("description"));
                    menu.setPrice(resultSet.getDouble("price"));
                    menu.setAvailable(resultSet.getBoolean("isAvailable"));
                    menu.setImagePath(resultSet.getString("imagePath"));

                    menuList.add(menu);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menuList;
    }


    @Override
    public void updateMenu(Menu menu) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(UPDATE_QUERY)) {

            preparedStatement.setInt(1, menu.getRestaurantId());
            preparedStatement.setString(2, menu.getItemName());
            preparedStatement.setString(3, menu.getDescription());
            preparedStatement.setDouble(4, menu.getPrice());
            preparedStatement.setBoolean(5, menu.isAvailable());
            preparedStatement.setString(6, menu.getImagePath());
            preparedStatement.setInt(7, menu.getMenuId());

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void deleteMenu(int menuId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement =
                     connection.prepareStatement(DELETE_QUERY)) {

            preparedStatement.setInt(1, menuId);

            preparedStatement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}