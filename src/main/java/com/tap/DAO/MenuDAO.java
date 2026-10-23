package com.tap.DAO;

import java.util.List;
import com.tap.model.Menu;

public interface MenuDAO {

    void addMenu(Menu menu);

    Menu getMenu(int menuId);

    List<Menu> getAllMenus();

    List<Menu> getMenuByRestaurantID(int restaurantId);

    void updateMenu(Menu menu);

    void deleteMenu(int menuId);
}