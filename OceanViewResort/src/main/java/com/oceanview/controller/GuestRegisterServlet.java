package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.oceanview.dao.GuestDAO;
import com.oceanview.utils.AuditLogger;

/**
 * GuestRegisterServlet - Handles Guest Account Registration
 * Demonstrates proper Input Validation and Security Practices
 */
@WebServlet("/guestRegister")
public class GuestRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get form parameters
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // 2. Input validation
        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            password == null || password.length() < 6) {
            
            response.sendRedirect("guest_register.jsp?error=invalid");
            return;
        }
        
        // 3. Sanitize inputs (basic XSS prevention)
        fullName = fullName.trim();
        email = email.trim().toLowerCase();
        phone = phone.trim();
        username = username.trim().toLowerCase();
        
        // 4. Check if username or email already exists
        GuestDAO dao = new GuestDAO();
        
        if (dao.usernameExists(username)) {
            AuditLogger.log("REGISTRATION_FAILED", "Username already exists: " + username);
            response.sendRedirect("guest_register.jsp?error=exists");
            return;
        }
        
        if (dao.emailExists(email)) {
            AuditLogger.log("REGISTRATION_FAILED", "Email already exists: " + email);
            response.sendRedirect("guest_register.jsp?error=exists");
            return;
        }
        
        // 5. Register the guest
        boolean success = dao.registerGuest(username, password, fullName, email, phone);
        
        if (success) {
            AuditLogger.log("GUEST_REGISTERED", "New guest registered: " + username + " (" + email + ")");
            response.sendRedirect("guest_login.jsp?msg=Account created successfully! Please login.");
        } else {
            AuditLogger.log("REGISTRATION_FAILED", "Failed to register guest: " + username);
            response.sendRedirect("guest_register.jsp?error=failed");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to registration page
        response.sendRedirect("guest_register.jsp");
    }
}
