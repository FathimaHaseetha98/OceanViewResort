package com.oceanview.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;

@WebServlet("/viewReservations")
public class ViewReservationsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // RBAC: Only Staff and Admin can view reservations
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
        
        // 1. Fetch Data
        ReservationDAO dao = new ReservationDAO();
        List<Reservation> list = dao.getAllReservations();
        
        // 2. Attach data to the request object so JSP can use it
        request.setAttribute("reservationList", list);
        
        // 3. Send to the Display Page
        request.getRequestDispatcher("view_reservations.jsp").forward(request, response);
    }
}