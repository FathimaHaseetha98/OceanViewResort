package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.oceanview.dao.GuestDAO;
import com.oceanview.model.BaseUser;
import com.oceanview.model.GuestUser;
import com.oceanview.utils.AuditLogger;

/**
 * GuestLoginServlet - Handles Guest Authentication
 * Uses Strategy Pattern for authentication
 * Demonstrates Session Management and Security
 */
@WebServlet("/guestLogin")
public class GuestLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get credentials
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // 2. Input validation
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            response.sendRedirect("guest_login.jsp?error=1");
            return;
        }
        
        // 3. Sanitize
        username = username.trim().toLowerCase();
        
        // 4. Authenticate using Strategy Pattern
        GuestDAO guestDAO = new GuestDAO();
        BaseUser user = guestDAO.authenticate(username, password);
        
        if (user != null && user instanceof GuestUser) {
            GuestUser guest = (GuestUser) user;
            
            // 5. Create session for guest (separate from staff session)
            HttpSession session = request.getSession(true);
            session.setAttribute("currentGuest", guest);
            session.setAttribute("userType", "GUEST"); // Helps with filtering
            session.setMaxInactiveInterval(1800); // 30 minutes
            
            // 6. Log successful login
            AuditLogger.log("GUEST_LOGIN", "Guest logged in: " + guest.getUsername() + 
                           " (ID: " + guest.getId() + ")");
            
            // 7. Redirect to guest dashboard
            response.sendRedirect("guest_dashboard.jsp");
            
        } else {
            // Login failed
            AuditLogger.log("GUEST_LOGIN_FAILED", "Failed login attempt for username: " + username);
            response.sendRedirect("guest_login.jsp?error=1");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to login page
        response.sendRedirect("guest_login.jsp");
    }
}
