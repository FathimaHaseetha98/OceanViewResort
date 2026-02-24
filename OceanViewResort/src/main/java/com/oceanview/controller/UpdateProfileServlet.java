package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oceanview.dao.GuestDAO;
import com.oceanview.model.GuestUser;

/**
 * UpdateProfileServlet - Handles Guest Profile Updates
 * Demonstrates user data management and session handling
 */
@WebServlet("/updateProfile")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Security check - ensure guest is logged in
        if (session == null || session.getAttribute("currentGuest") == null) {
            response.sendRedirect("guest_login.jsp?error=Please login to continue");
            return;
        }
        
        GuestUser currentGuest = (GuestUser) session.getAttribute("currentGuest");
        
        // Get form data
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        
        // Validate input
        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty()) {
            response.sendRedirect("guest_profile.jsp?error=All fields are required");
            return;
        }
        
        // Validate email format
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            response.sendRedirect("guest_profile.jsp?error=Invalid email format");
            return;
        }
        
        // Validate phone format (10-15 digits)
        if (!phone.matches("^[0-9]{10,15}$")) {
            response.sendRedirect("guest_profile.jsp?error=Phone number must be 10-15 digits");
            return;
        }
        
        // Update profile in database
        GuestDAO dao = new GuestDAO();
        boolean success;
        
        // Check if password is provided
        if (password != null && !password.trim().isEmpty()) {
            // Update with new password
            success = dao.updateGuestProfile(currentGuest.getId(), fullName, email, phone, password);
        } else {
            // Update without changing password
            success = dao.updateGuestProfile(currentGuest.getId(), fullName, email, phone);
        }
        
        if (success) {
            // Refresh guest data in session
            GuestUser updatedGuest = dao.getGuestById(currentGuest.getId());
            if (updatedGuest != null) {
                session.setAttribute("currentGuest", updatedGuest);
            }
            
            response.sendRedirect("guest_profile.jsp?success=Profile updated successfully!");
        } else {
            response.sendRedirect("guest_profile.jsp?error=Failed to update profile. Please try again.");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to profile page
        response.sendRedirect("guest_profile.jsp");
    }
}
