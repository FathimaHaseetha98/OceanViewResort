package com.oceanview.dao;

import java.sql.*;
import com.oceanview.model.BaseUser;
import com.oceanview.model.User;
import com.oceanview.utils.DBConnection;

/**
 * UserDAO - Handles Staff User Authentication
 * Implements AuthenticationStrategy (STRATEGY PATTERN)
 */
public class UserDAO implements AuthenticationStrategy {

    // Legacy method maintained for backward compatibility
    public User checkLogin(String username, String plainPassword) {
        BaseUser user = authenticate(username, plainPassword);
        return (User) user;
    }
    
    // Implements Strategy Pattern
    @Override
    public BaseUser authenticate(String username, String plainPassword) {
        User user = null;
        
        // The Query: We use MySQL's SHA2 function to match the hash we stored earlier
        String sql = "SELECT * FROM users WHERE username = ? AND password = SHA2(?, 256)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, plainPassword);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Login Success! Create a User object from the DB data
                user = new User(
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getString("full_name"),
                    rs.getString("role")
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return user; // Returns null if login fails
    }
    
    @Override
    public String getAuthenticationType() {
        return "STAFF";
    }
}
