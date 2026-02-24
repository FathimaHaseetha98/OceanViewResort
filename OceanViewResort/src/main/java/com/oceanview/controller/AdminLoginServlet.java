package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;
import com.oceanview.utils.AuditLogger;

/**
 * AdminLoginServlet - Handles Administrator Authentication
 * Only allows users with role "Admin" to login
 */
@WebServlet("/adminLogin")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    public void init() {
        userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Authenticate user
        User user = userDAO.checkLogin(username, password);

        if (user != null && "Admin".equalsIgnoreCase(user.getRole())) {
            // Valid admin - create new session
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("userType", "ADMIN");
            session.setMaxInactiveInterval(1800); // 30 minutes
            
            AuditLogger.log("ADMIN_LOGIN", "Admin logged in: " + user.getUsername());
            
            // Redirect to admin dashboard
            response.sendRedirect("admin_dashboard.jsp");
        } else if (user != null && "Receptionist".equalsIgnoreCase(user.getRole())) {
            // Staff trying to login via admin portal
            request.setAttribute("errorMessage", "Access Denied: Admins Only. Please use Staff Portal");
            request.getRequestDispatcher("adminlogin.jsp").forward(request, response);
        } else {
            // Invalid credentials
            AuditLogger.log("ADMIN_LOGIN_FAILED", "Failed admin login attempt: " + username);
            request.setAttribute("errorMessage", "Invalid Admin Credentials");
            request.getRequestDispatcher("adminlogin.jsp").forward(request, response);
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("adminlogin.jsp");
    }
}
