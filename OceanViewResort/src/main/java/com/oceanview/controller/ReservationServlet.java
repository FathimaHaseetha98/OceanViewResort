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

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;
import com.oceanview.utils.AuditLogger;

@WebServlet("/addReservation")
public class ReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // RBAC: Only Staff and Admin can create reservations
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect("stafflogin.jsp?error=Please login to continue");
            return;
        }
        
        String role = currentUser.getRole();
        if (!"Receptionist".equalsIgnoreCase(role) && !"Admin".equalsIgnoreCase(role)) {
            response.sendRedirect("index.jsp?error=Access Denied");
            return;
        }
        
        boolean isAdmin = "Admin".equalsIgnoreCase(role);
        
        try {
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String phone = request.getParameter("phone");
            String roomNumber = request.getParameter("roomNumber"); // <--- Get Specific Room (e.g., 101)
            
            // Auto-detect type based on number (Simple logic for now)
            String roomType = "Standard";
            if(roomNumber.startsWith("2")) roomType = "Deluxe";
            if(roomNumber.startsWith("3")) roomType = "Suite";

            LocalDate inDate = LocalDate.parse(request.getParameter("checkIn"));
            LocalDate outDate = LocalDate.parse(request.getParameter("checkOut"));
            LocalDate today = LocalDate.now();

            // 1. VALIDATION: Past dates blocked
            if (inDate.isBefore(today)) {
                request.setAttribute("errorMessage", "Error: Check-in date cannot be in the past.");
                request.getRequestDispatcher("reservation_form.jsp").forward(request, response);
                return;
            }

            // 2. VALIDATION: Check-out before Check-in blocked
            // Removed the "equals" check. Same day checkout is now ALLOWED.
            if (outDate.isBefore(inDate)) {
                request.setAttribute("errorMessage", "Error: Check-out cannot be before Check-in.");
                request.getRequestDispatcher("reservation_form.jsp").forward(request, response);
                return;
            }

            // 3. AVAILABILITY CHECK (The Key Logic)
            ReservationDAO dao = new ReservationDAO();
            if (!dao.isRoomAvailable(roomNumber, Date.valueOf(inDate), Date.valueOf(outDate))) {
                // Room is BUSY
                request.setAttribute("errorMessage", "Error: Room " + roomNumber + " is already booked for these dates!");
                request.getRequestDispatcher("reservation_form.jsp").forward(request, response);
                return;
            }

            // 4. BILL CALCULATION
            long days = ChronoUnit.DAYS.between(inDate, outDate);
            if (days == 0) days = 1; // Charge for at least 1 day if checking out same day
            
            double pricePerNight = 0;
            switch(roomType) {
                case "Standard": pricePerNight = 5000; break;
                case "Deluxe": pricePerNight = 8500; break;
                case "Suite": pricePerNight = 15000; break;
            }
            double totalBill = days * pricePerNight;

            // 5. SAVE
            Reservation res = new Reservation(name, address, phone, roomType, roomNumber, Date.valueOf(inDate), Date.valueOf(outDate), totalBill);
            boolean success = dao.addReservation(res);

            if (success) {
                String username = currentUser.getUsername();
                
                // Log the reservation creation
                AuditLogger.log("Created Reservation for Room " + roomNumber, username);
                
                // Redirect based on role
                String redirectPage = isAdmin ? "admin_dashboard.jsp" : "dashboard.jsp";
                response.sendRedirect(redirectPage + "?msg=Confirmed! Room " + roomNumber + " Booked. Bill: " + totalBill);
            } else {
                response.sendRedirect("reservation_form.jsp?error=Database Error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("reservation_form.jsp?error=Invalid Data");
        }
    }
}