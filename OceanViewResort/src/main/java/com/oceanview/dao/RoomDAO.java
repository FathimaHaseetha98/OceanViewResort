package com.oceanview.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.oceanview.utils.DBConnection;

/**
 * RoomDAO - Handles Room Management (CRUD Operations)
 * Manages both rooms and room_types tables
 */
public class RoomDAO {
    
    // ==================== ROOM TYPE OPERATIONS ====================
    
    /**
     * Get all room types
     */
    public List<Map<String, Object>> getAllRoomTypes() {
        List<Map<String, Object>> roomTypes = new ArrayList<>();
        String sql = "SELECT * FROM room_types ORDER BY price_per_night ASC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> type = new HashMap<>();
                type.put("type_id", rs.getInt("type_id"));
                type.put("type_name", rs.getString("type_name"));
                type.put("price_per_night", rs.getDouble("price_per_night"));
                roomTypes.add(type);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return roomTypes;
    }
    
    /**
     * Add new room type
     */
    public boolean addRoomType(String typeName, double pricePerNight) {
        String sql = "INSERT INTO room_types (type_name, price_per_night) VALUES (?, ?)";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, typeName);
            ps.setDouble(2, pricePerNight);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update room type
     */
    public boolean updateRoomType(int typeId, String typeName, double pricePerNight) {
        String sql = "UPDATE room_types SET type_name = ?, price_per_night = ? WHERE type_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, typeName);
            ps.setDouble(2, pricePerNight);
            ps.setInt(3, typeId);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete room type (only if no rooms are using it)
     */
    public boolean deleteRoomType(int typeId) {
        String sql = "DELETE FROM room_types WHERE type_id = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, typeId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // ==================== ROOM OPERATIONS ====================
    
    /**
     * Get all rooms with their types
     */
    public List<Map<String, Object>> getAllRooms() {
        List<Map<String, Object>> rooms = new ArrayList<>();
        String sql = "SELECT r.room_number, r.room_type, rt.price_per_night " +
                     "FROM rooms r " +
                     "LEFT JOIN room_types rt ON r.room_type = rt.type_name " +
                     "ORDER BY r.room_number ASC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> room = new HashMap<>();
                room.put("room_number", rs.getString("room_number"));
                room.put("room_type", rs.getString("room_type"));
                room.put("price_per_night", rs.getDouble("price_per_night"));
                rooms.add(room);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return rooms;
    }
    
    /**
     * Add new room
     */
    public boolean addRoom(String roomNumber, String roomType) {
        String sql = "INSERT INTO rooms (room_number, room_type) VALUES (?, ?)";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, roomNumber);
            ps.setString(2, roomType);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update room
     */
    public boolean updateRoom(String oldRoomNumber, String newRoomNumber, String roomType) {
        String sql = "UPDATE rooms SET room_number = ?, room_type = ? WHERE room_number = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, newRoomNumber);
            ps.setString(2, roomType);
            ps.setString(3, oldRoomNumber);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete room (only if no active reservations)
     */
    public boolean deleteRoom(String roomNumber) {
        String sql = "DELETE FROM rooms WHERE room_number = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, roomNumber);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Check if room number exists
     */
    public boolean roomExists(String roomNumber) {
        String sql = "SELECT COUNT(*) FROM rooms WHERE room_number = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, roomNumber);
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
     * Get room statistics
     */
    public Map<String, Object> getRoomStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        try (Connection con = DBConnection.getConnection()) {
            // Total rooms
            String sql1 = "SELECT COUNT(*) as total FROM rooms";
            PreparedStatement ps1 = con.prepareStatement(sql1);
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) {
                stats.put("total_rooms", rs1.getInt("total"));
            }
            
            // Rooms by type
            String sql2 = "SELECT room_type, COUNT(*) as count FROM rooms GROUP BY room_type";
            PreparedStatement ps2 = con.prepareStatement(sql2);
            ResultSet rs2 = ps2.executeQuery();
            Map<String, Integer> byType = new HashMap<>();
            while (rs2.next()) {
                byType.put(rs2.getString("room_type"), rs2.getInt("count"));
            }
            stats.put("by_type", byType);
            
            ps1.close();
            ps2.close();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
}
