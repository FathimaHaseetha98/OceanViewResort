package com.oceanview.dao;

import java.sql.*;
import com.oceanview.model.BaseUser;
import com.oceanview.model.GuestUser;
import com.oceanview.utils.DBConnection;

/**
 * GuestDAO - Handles Guest Account Management
 * Implements AuthenticationStrategy (STRATEGY PATTERN)
 * Follows Single Responsibility Principle (SRP)
 */
public class GuestDAO implements AuthenticationStrategy {

    // 1. Guest Registration
    public boolean registerGuest(String username, String password, String fullName, String email, String phone) {
        String sql = "INSERT INTO guest_accounts (username, password, full_name, email, phone) " +
                     "VALUES (?, SHA2(?, 256), ?, ?, ?)";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, email);
            ps.setString(5, phone);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. Guest Login - Implements Strategy Pattern
    @Override
    public BaseUser authenticate(String username, String password) {
        String sql = "SELECT * FROM guest_accounts WHERE username = ? AND password = SHA2(?, 256)";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return new GuestUser(
                    rs.getInt("account_id"),
                    rs.getString("username"),
                    rs.getString("full_name"),
                    rs.getString("email"),
                    rs.getString("phone"),
                    rs.getTimestamp("created_at")
                );
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    @Override
    public String getAuthenticationType() {
        return "GUEST";
    }

    // 3. Check if username exists
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM guest_accounts WHERE username = ?";
        
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
    
    // 4. Check if email exists
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM guest_accounts WHERE email = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 5. Get guest by ID
    public GuestUser getGuestById(int guestId) {
        String sql = "SELECT * FROM guest_accounts WHERE account_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, guestId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return new GuestUser(
                    rs.getInt("account_id"),
                    rs.getString("username"),
                    rs.getString("full_name"),
                    rs.getString("email"),
                    rs.getString("phone"),
                    rs.getTimestamp("created_at")
                );
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    // 6. Update guest profile (without password change)
    public boolean updateGuestProfile(int guestId, String fullName, String email, String phone) {
        String sql = "UPDATE guest_accounts SET full_name = ?, email = ?, phone = ? WHERE account_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setInt(4, guestId);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 7. Update guest profile (with password change)
    public boolean updateGuestProfile(int guestId, String fullName, String email, String phone, String newPassword) {
        String sql = "UPDATE guest_accounts SET full_name = ?, email = ?, phone = ?, password = SHA2(?, 256) WHERE account_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, newPassword);
            ps.setInt(5, guestId);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
