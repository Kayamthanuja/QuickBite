
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
             PreparedStatement ps = connection.prepareStatement(INSERT_QUERY)) {

            ps.setInt(1, menu.getRestaurantId());
            ps.setString(2, menu.getItemName());
            ps.setString(3, menu.getDescription());
            ps.setDouble(4, menu.getPrice());
            ps.setBoolean(5, menu.isAvailable());
            ps.setString(6, menu.getImagePath());

            ps.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Failed to add menu item.", e);
        }
    }

    @Override
    public Menu getMenu(int menuId) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(SELECT_BY_ID_QUERY)) {

            ps.setInt(1, menuId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMenu(rs);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to retrieve menu item.", e);
        }

        return null;
    }

    @Override
    public List<Menu> getAllMenus() {
        List<Menu> menuList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(SELECT_ALL_QUERY);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                menuList.add(mapMenu(rs));
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to retrieve menu items.", e);
        }

        return menuList;
    }

    @Override
    public List<Menu> getMenuByRestaurantID(int restaurantId) {
        List<Menu> menuList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps =
                     connection.prepareStatement(SELECT_BY_RESTAURANT_ID_QUERY)) {

            ps.setInt(1, restaurantId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    menuList.add(mapMenu(rs));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Failed to retrieve menu items for restaurant " + restaurantId, e);
        }

        return menuList;
    }

    @Override
    public void updateMenu(Menu menu) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(UPDATE_QUERY)) {

            ps.setInt(1, menu.getRestaurantId());
            ps.setString(2, menu.getItemName());
            ps.setString(3, menu.getDescription());
            ps.setDouble(4, menu.getPrice());
            ps.setBoolean(5, menu.isAvailable());
            ps.setString(6, menu.getImagePath());
            ps.setInt(7, menu.getMenuId());

            int rowsUpdated = ps.executeUpdate();

            if (rowsUpdated == 0) {
                throw new RuntimeException(
                        "Menu item not found. ID: " + menu.getMenuId());
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to update menu item.", e);
        }
    }

    @Override
    public void deleteMenu(int menuId) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(DELETE_QUERY)) {

            ps.setInt(1, menuId);

            int rowsDeleted = ps.executeUpdate();

            if (rowsDeleted == 0) {
                throw new RuntimeException("Menu item not found. ID: " + menuId);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to delete menu item.", e);
        }
    }

    private Menu mapMenu(ResultSet rs) throws SQLException {
        Menu menu = new Menu();

        menu.setMenuId(rs.getInt("menuId"));
        menu.setRestaurantId(rs.getInt("restaurantId"));
        menu.setItemName(rs.getString("itemName"));
        menu.setDescription(rs.getString("description"));
        menu.setPrice(rs.getDouble("price"));
        menu.setAvailable(rs.getBoolean("isAvailable"));
        menu.setImagePath(rs.getString("imagePath"));

        return menu;
    }
}
