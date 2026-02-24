package com.oceanview.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.oceanview.model.Reservation;
import com.oceanview.utils.DBConnection;

public class ReservationDAO {

    // 1. NEW METHOD: Check if a room is already booked
    public boolean isRoomAvailable(String roomNumber, Date checkIn, Date checkOut) {
        boolean available = true;
        
        // This SQL checks for OVERLAPPING dates
        // Logic: A room is occupied if (NewCheckIn < ExistingCheckOut) AND (NewCheckOut > ExistingCheckIn)
        String sql = "SELECT COUNT(*) FROM reservations WHERE room_number = ? " +
                     "AND (check_in_date < ? AND check_out_date > ?) " +
                     "AND status != 'Cancelled'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, roomNumber);
            ps.setDate(2, checkOut); // Note the order of parameters for the logic
            ps.setDate(3, checkIn);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (rs.getInt(1) > 0) {
                    available = false; // Found a conflict!
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return available;
    }

    // 2. UPDATED METHOD: Save Reservation with Room Number
    public boolean addReservation(Reservation r) {
        boolean isSuccess = false;
        // Added 'room_number' to the SQL
        String sql = "INSERT INTO reservations (guest_name, guest_address, contact_number, room_type, room_number, check_in_date, check_out_date, total_bill) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, r.getGuestName());
            ps.setString(2, r.getAddress());
            ps.setString(3, r.getContactNumber());
            ps.setString(4, r.getRoomType());
            ps.setString(5, r.getRoomNumber()); // <--- NEW FIELD
            ps.setDate(6, r.getCheckIn());
            ps.setDate(7, r.getCheckOut());
            ps.setDouble(8, r.getTotalAmount());

            int result = ps.executeUpdate();
            if (result > 0) isSuccess = true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return isSuccess;
    }

    // 3. NEW METHOD: Get all reservations
    public List<Reservation> getAllReservations() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT * FROM reservations ORDER BY check_in_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("reservation_id"));
                r.setGuestName(rs.getString("guest_name"));
                r.setAddress(rs.getString("guest_address"));
                r.setContactNumber(rs.getString("contact_number"));
                r.setRoomType(rs.getString("room_type"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setCheckIn(rs.getDate("check_in_date"));
                r.setCheckOut(rs.getDate("check_out_date"));
                r.setTotalAmount(rs.getDouble("total_bill"));

                reservations.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return reservations;
    }

    // 4. NEW METHOD: Get a single reservation by ID
    public Reservation getReservationById(int id) {
        Reservation r = null;
        String sql = "SELECT * FROM reservations WHERE reservation_id = ?"; // Adjust column name if needed (id vs reservation_id)

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                r = new Reservation();
                r.setId(rs.getInt("reservation_id"));
                r.setGuestName(rs.getString("guest_name"));
                r.setAddress(rs.getString("guest_address"));
                r.setContactNumber(rs.getString("contact_number"));
                r.setRoomType(rs.getString("room_type"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setCheckIn(rs.getDate("check_in_date"));
                r.setCheckOut(rs.getDate("check_out_date"));
                r.setTotalAmount(rs.getDouble("total_bill"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return r;
    }

    // 5. HELPER CLASS: For holding Report Data
    public static class RevenueReport {
        public String roomType;
        public int bookingCount;
        public double totalRevenue;
    }

    // 6. REPORT METHOD: Get Revenue Report grouped by Room Type
    public List<RevenueReport> getRevenueReport() {
        List<RevenueReport> list = new ArrayList<>();
        
        String sql = "SELECT room_type, COUNT(*) as count, SUM(total_bill) as revenue " +
                     "FROM reservations GROUP BY room_type";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RevenueReport report = new RevenueReport();
                report.roomType = rs.getString("room_type");
                report.bookingCount = rs.getInt("count");
                report.totalRevenue = rs.getDouble("revenue");
                list.add(report);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // 7. NEW METHOD: Get reservations for a specific guest (for Guest Portal)
    public List<Reservation> getReservationsByGuestId(int guestAccountId) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT * FROM reservations WHERE guest_account_id = ? ORDER BY check_in_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, guestAccountId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("reservation_id"));
                r.setGuestName(rs.getString("guest_name"));
                r.setAddress(rs.getString("guest_address"));
                r.setContactNumber(rs.getString("contact_number"));
                r.setRoomType(rs.getString("room_type"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setCheckIn(rs.getDate("check_in_date"));
                r.setCheckOut(rs.getDate("check_out_date"));
                r.setTotalAmount(rs.getDouble("total_bill"));

                reservations.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // 8. NEW METHOD: Add reservation with guest account link
    public boolean addReservationWithGuest(Reservation r, int guestAccountId) {
        boolean isSuccess = false;
        String sql = "INSERT INTO reservations (guest_name, guest_address, contact_number, room_type, " +
                     "room_number, check_in_date, check_out_date, total_bill, guest_account_id, booking_date) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, r.getGuestName());
            ps.setString(2, r.getAddress());
            ps.setString(3, r.getContactNumber());
            ps.setString(4, r.getRoomType());
            ps.setString(5, r.getRoomNumber());
            ps.setDate(6, r.getCheckIn());
            ps.setDate(7, r.getCheckOut());
            ps.setDouble(8, r.getTotalAmount());
            ps.setInt(9, guestAccountId);

            int result = ps.executeUpdate();
            if (result > 0) isSuccess = true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return isSuccess;
    }
    
    // 9. NEW METHOD: Get upcoming reservations for a guest
    public List<Reservation> getUpcomingReservationsByGuest(int guestAccountId) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT * FROM reservations WHERE guest_account_id = ? " +
                     "AND check_in_date >= CURDATE() ORDER BY check_in_date ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, guestAccountId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("reservation_id"));
                r.setGuestName(rs.getString("guest_name"));
                r.setAddress(rs.getString("guest_address"));
                r.setContactNumber(rs.getString("contact_number"));
                r.setRoomType(rs.getString("room_type"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setCheckIn(rs.getDate("check_in_date"));
                r.setCheckOut(rs.getDate("check_out_date"));
                r.setTotalAmount(rs.getDouble("total_bill"));

                reservations.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return reservations;
    }
}
