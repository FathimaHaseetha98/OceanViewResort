package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oceanview.model.User;
import com.oceanview.model.GuestUser;
import com.oceanview.utils.AuditLogger;

/**
 * Enhanced LogoutServlet - Handles Admin, Staff, and Guest logouts separately
 * Each user type redirects to their respective login portal
 * FIXED: Properly saves session data BEFORE invalidation
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Fetch current session
        HttpSession session = request.getSession(false);
        
        String redirectURL = "index.jsp"; // Default fallback
        
        if (session != null) {
            // CRITICAL: Save all session data BEFORE invalidating
            User staffUser = (User) session.getAttribute("currentUser");
            GuestUser guestUser = (GuestUser) session.getAttribute("currentGuest");
            String userType = (String) session.getAttribute("userType");
            
            // 2. Determine redirect URL based on user type (check in priority order)
            if (guestUser != null) {
                // Guest user logging out
                AuditLogger.log("GUEST_LOGOUT", "Guest logged out: " + guestUser.getUsername() + 
                              " (ID: " + guestUser.getId() + ")");
                redirectURL = "guest_login.jsp?msg=Logged out successfully";
                
            } else if (staffUser != null) {
                // Staff or Admin logging out
                String role = staffUser.getRole();
                AuditLogger.log("USER_LOGOUT", role + " logged out: " + staffUser.getUsername());
                
                if ("Admin".equalsIgnoreCase(role)) {
                    // Admin goes to admin login
                    redirectURL = "adminlogin.jsp?msg=Logged out successfully";
                } else if ("Receptionist".equalsIgnoreCase(role)) {
                    // Staff/Receptionist goes to staff login
                    redirectURL = "stafflogin.jsp?msg=Logged out successfully";
                }
                
            } else if ("GUEST".equals(userType)) {
                // Fallback if guestUser was null but userType was set
                redirectURL = "guest_login.jsp?msg=Logged out successfully";
                
            } else if ("ADMIN".equals(userType)) {
                // Fallback if staffUser was null but userType was ADMIN
                redirectURL = "adminlogin.jsp?msg=Logged out successfully";
                
            } else if ("STAFF".equals(userType)) {
                // Fallback if staffUser was null but userType was STAFF
                redirectURL = "stafflogin.jsp?msg=Logged out successfully";
            }
            
            // 3. Invalidate session (clear all session data)
            session.invalidate();
        }
        
        // 4. Redirect to appropriate login page
        response.sendRedirect(redirectURL);
    }
}
