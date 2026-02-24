package com.oceanview.controller;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.model.GuestUser;
import com.oceanview.model.Reservation;
import com.oceanview.utils.AuditLogger;

/**
 * GuestBookRoomServlet - Handles Guest Room Booking
 * Allows guests to book rooms directly from their portal
 */
@WebServlet("/guestBookRoom")
public class GuestBookRoomServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get guest from session
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("guest_login.jsp?error=Session expired");
            return;
        }
        
        GuestUser guest = (GuestUser) session.getAttribute("currentGuest");
        if (guest == null) {
            response.sendRedirect("guest_login.jsp?error=Please login to continue");
            return;
        }
        
        // 2. Get form parameters
        String roomType = request.getParameter("roomType");
        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        String guestName = request.getParameter("guestName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        
        // 3. Validate inputs
        if (roomType == null || roomType.isEmpty() ||
            checkInStr == null || checkOutStr == null ||
            guestName == null || guestName.isEmpty() ||
            phone == null || phone.isEmpty() ||
            address == null || address.isEmpty()) {
            
            request.setAttribute("errorMessage", "Please fill in all required fields and select a room type");
            request.getRequestDispatcher("guest_book_room.jsp").forward(request, response);
            return;
        }
        
        // 4. Parse dates
        Date checkIn, checkOut;
        try {
            checkIn = Date.valueOf(checkInStr);
            checkOut = Date.valueOf(checkOutStr);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Invalid date format");
            request.getRequestDispatcher("guest_book_room.jsp").forward(request, response);
            return;
        }
        
        // 5. Validate date logic
        if (!checkOut.after(checkIn)) {
            request.setAttribute("errorMessage", "Check-out date must be after check-in date");
            request.getRequestDispatcher("guest_book_room.jsp").forward(request, response);
            return;
        }
        
        // 6. Calculate nights and price
        LocalDate checkInLocal = checkIn.toLocalDate();
        LocalDate checkOutLocal = checkOut.toLocalDate();
        long nights = ChronoUnit.DAYS.between(checkInLocal, checkOutLocal);
        
        // Get price per night based on room type
        double pricePerNight = getPricePerNight(roomType);
        double totalAmount = pricePerNight * nights;
        
        // 7. Find an available room of the requested type
        ReservationDAO reservationDAO = new ReservationDAO();
        RoomDAO roomDAO = new RoomDAO();
        
        String assignedRoom = findAvailableRoom(roomType, checkIn, checkOut, reservationDAO);
        
        if (assignedRoom == null) {
            request.setAttribute("errorMessage", "Sorry, no " + roomType + " rooms are available for the selected dates. Please try different dates or room type.");
            request.getRequestDispatcher("guest_book_room.jsp").forward(request, response);
            return;
        }
        
        // 8. Create reservation
        Reservation reservation = new Reservation();
        reservation.setGuestName(guestName.trim());
        reservation.setAddress(address.trim());
        reservation.setContactNumber(phone.trim());
        reservation.setRoomType(roomType);
        reservation.setRoomNumber(assignedRoom);
        reservation.setCheckIn(checkIn);
        reservation.setCheckOut(checkOut);
        reservation.setTotalAmount(totalAmount);
        
        // 9. Save reservation with guest account link
        boolean success = reservationDAO.addReservationWithGuest(reservation, guest.getId());
        
        if (success) {
            AuditLogger.log("GUEST_BOOKING", "Guest " + guest.getUsername() + " booked room " + 
                          assignedRoom + " (" + roomType + ") from " + checkInStr + " to " + checkOutStr +
                          " Total: LKR " + totalAmount);
            
            // Redirect to dashboard with success message
            response.sendRedirect("guest_dashboard.jsp?msg=Booking confirmed! Room " + assignedRoom + 
                                 " has been reserved for you. Total: LKR " + String.format("%,.2f", totalAmount));
        } else {
            request.setAttribute("errorMessage", "Failed to create booking. Please try again.");
            request.getRequestDispatcher("guest_book_room.jsp").forward(request, response);
        }
    }
    
    /**
     * Get price per night based on room type
     */
    private double getPricePerNight(String roomType) {
        switch (roomType.toLowerCase()) {
            case "standard":
                return 5000.0;
            case "deluxe":
                return 8500.0;
            case "suite":
                return 15000.0;
            default:
                return 5000.0;
        }
    }
    
    /**
     * Find an available room of the specified type for the given dates
     */
    private String findAvailableRoom(String roomType, Date checkIn, Date checkOut, ReservationDAO dao) {
        // Room numbers based on type
        String[] rooms;
        
        switch (roomType.toLowerCase()) {
            case "standard":
                rooms = new String[]{"101", "102", "103"};
                break;
            case "deluxe":
                rooms = new String[]{"201", "202"};
                break;
            case "suite":
                rooms = new String[]{"301"};
                break;
            default:
                return null;
        }
        
        // Check each room for availability
        for (String room : rooms) {
            if (dao.isRoomAvailable(room, checkIn, checkOut)) {
                return room;
            }
        }
        
        return null; // No available room found
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("guest_book_room.jsp");
    }
}
