package com.tap.DAO;

import java.util.List;
import com.tap.model.User;

public interface UserDAO {

    void addUser(User user);

    User getUser(int userId);

    void updateUser(User user);

    void deleteUser(int userId);
    
    List<User> getAllUsers();

	User getUserByEmail(String email);

	User getUserByPhone(String phone);

	List<User> getUsersByRole(String role);

	boolean updatePassword(String email, String newPassword);
}