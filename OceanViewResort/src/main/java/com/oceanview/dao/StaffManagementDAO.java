package com.oceanview.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.oceanview.model.User;
import com.oceanview.utils.DBConnection;

/**
 * StaffManagementDAO - Handles CRUD operations for Staff Users
 * Admin-only operations for managing system users
 */
public class StaffManagementDAO {
    
    /**
     * Get all staff users
     */
    public List<User> getAllStaff() {
        List<User> staffList = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                User user = new User(
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getString("full_name"),
                    rs.getString("role")
                );
                staffList.add(user);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return staffList;
    }
    
    /**
     * Get staff user by ID
     */
    public User getStaffById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return new User(
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getString("full_name"),
                    rs.getString("role")
                );
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Add new staff member
     */
    public boolean addStaff(String username, String password, String fullName, String role) {
        String sql = "INSERT INTO users (username, password, full_name, role) " +
                     "VALUES (?, SHA2(?, 256), ?, ?)";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, role);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update staff member (without password change)
     */
    public boolean updateStaff(int userId, String fullName, String role) {
        String sql = "UPDATE users SET full_name = ?, role = ? WHERE user_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, role);
            ps.setInt(3, userId);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update staff password
     */
    public boolean updateStaffPassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = SHA2(?, 256) WHERE user_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, newPassword);
            ps.setInt(2, userId);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete staff member
     */
    public boolean deleteStaff(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Check if username exists
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get staff statistics
     */
    public Map<String, Object> getStaffStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        try (Connection con = DBConnection.getConnection()) {
            // Total staff
            String sql1 = "SELECT COUNT(*) as total FROM users";
            PreparedStatement ps1 = con.prepareStatement(sql1);
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) {
                stats.put("total_staff", rs1.getInt("total"));
            }
            
            // Count by role
            String sql2 = "SELECT role, COUNT(*) as count FROM users GROUP BY role";
            PreparedStatement ps2 = con.prepareStatement(sql2);
            ResultSet rs2 = ps2.executeQuery();
            int adminCount = 0, receptionistCount = 0;
            while (rs2.next()) {
                String role = rs2.getString("role");
                int count = rs2.getInt("count");
                if ("Admin".equalsIgnoreCase(role)) {
                    adminCount = count;
                } else if ("Receptionist".equalsIgnoreCase(role)) {
                    receptionistCount = count;
                }
            }
            stats.put("admin_count", adminCount);
            stats.put("receptionist_count", receptionistCount);
            
            ps1.close();
            ps2.close();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
}
