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
 * StaffLoginServlet - Handles Staff (Receptionist) Authentication
 * Only allows users with role "Receptionist" to login
 */
@WebServlet("/staffLogin")
public class StaffLoginServlet extends HttpServlet {
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

        if (user != null && "Receptionist".equalsIgnoreCase(user.getRole())) {
            // Valid staff member - create new session
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("userType", "STAFF");
            session.setMaxInactiveInterval(1800); // 30 minutes
            
            AuditLogger.log("STAFF_LOGIN", "Staff logged in: " + user.getUsername());
            
            // Redirect to staff dashboard
            response.sendRedirect("dashboard.jsp");
        } else if (user != null && "Admin".equalsIgnoreCase(user.getRole())) {
            // Admin trying to login via staff portal
            request.setAttribute("errorMessage", "Access Denied: Please use Admin Portal");
            request.getRequestDispatcher("stafflogin.jsp").forward(request, response);
        } else {
            // Invalid credentials or unauthorized
            AuditLogger.log("STAFF_LOGIN_FAILED", "Failed staff login attempt: " + username);
            request.setAttribute("errorMessage", "Invalid Username or Password");
            request.getRequestDispatcher("stafflogin.jsp").forward(request, response);
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("stafflogin.jsp");
    }
}
