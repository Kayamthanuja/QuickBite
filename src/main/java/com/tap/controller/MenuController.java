
package com.tap.controller;

import java.io.IOException;
import java.util.List;

import com.tap.DAO.RestaurantDAO;
import com.tap.DAOImpl.MenuDAOImpl;
import com.tap.DAOImpl.RestaurantDAOImpl;
import com.tap.model.Menu;
import com.tap.model.Restaurant;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse resp)
            throws ServletException, IOException {

        String restaurantIdParam = req.getParameter("restaurantId");

        // Check whether restaurantId was provided
        if (restaurantIdParam == null || restaurantIdParam.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Restaurant ID is required.");
            return;
        }

        int restaurantId;

        try {
            restaurantId = Integer.parseInt(restaurantIdParam);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid restaurant ID.");
            return;
        }

        // 1. Retrieve menu items for the selected restaurant
        MenuDAOImpl menuDAO = new MenuDAOImpl();

        List<Menu> menuList =
                menuDAO.getMenuByRestaurantID(restaurantId);

        // 2. Retrieve the selected restaurant details
        RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

        Restaurant restaurant =
                restaurantDAO.getRestaurant(restaurantId);

        // 3. Pass menu items to Menu.jsp
        req.setAttribute("menuList", menuList);

        // 4. Pass restaurant name to Menu.jsp
        if (restaurant != null) {
            req.setAttribute("restaurantName", restaurant.getName());
        } else {
            req.setAttribute("restaurantName", "Restaurant Menu");
        }

        // Optional: pass the complete restaurant object if needed later
        req.setAttribute("restaurant", restaurant);

        // 5. Forward the request to Menu.jsp
        RequestDispatcher rd =
                req.getRequestDispatcher("/Menu.jsp");

        rd.forward(req, resp);
    }
}
