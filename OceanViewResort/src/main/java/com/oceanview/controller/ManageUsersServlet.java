package com.oceanview.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.oceanview.dao.StaffManagementDAO;
import com.oceanview.model.User;
import com.oceanview.utils.AuditLogger;

/**
 * ManageUsersServlet - Handles CRUD operations for Staff Management
 * Admin-only servlet for managing system users
 */
@WebServlet("/manageUsers")
public class ManageUsersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // RBAC: Only Admins
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect("dashboard.jsp?error=Access Denied");
            return;
        }
        
        StaffManagementDAO dao = new StaffManagementDAO();
        
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            handleDelete(request, response, dao, currentUser);
            return;
        }
        
        if ("edit".equals(action)) {
            handleEditForm(request, response, dao);
            return;
        }
        
        // Default: List all staff
        List<User> staffList = dao.getAllStaff();
        request.setAttribute("staffList", staffList);
        request.getRequestDispatcher("manage_users.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // RBAC: Only Admins
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect("dashboard.jsp?error=Access Denied");
            return;
        }
        
        StaffManagementDAO dao = new StaffManagementDAO();
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            handleAdd(request, response, dao, currentUser);
        } else if ("update".equals(action)) {
            handleUpdate(request, response, dao, currentUser);
        }
    }
    
    private void handleAdd(HttpServletRequest request, HttpServletResponse response, 
                          StaffManagementDAO dao, User currentUser) throws IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");
        
        // Validation
        if (username == null || username.trim().isEmpty() ||
            password == null || password.length() < 6 ||
            fullName == null || fullName.trim().isEmpty()) {
            response.sendRedirect("manageUsers?error=Invalid input");
            return;
        }
        
        // Check if username exists
        if (dao.usernameExists(username)) {
            response.sendRedirect("manageUsers?error=Username already exists");
            return;
        }
        
        boolean success = dao.addStaff(username, password, fullName, role);
        
        if (success) {
            AuditLogger.log("STAFF_ADDED", "Admin " + currentUser.getUsername() + 
                           " added new staff: " + username + " (" + role + ")");
            response.sendRedirect("manageUsers?msg=Staff member added successfully");
        } else {
            response.sendRedirect("manageUsers?error=Failed to add staff");
        }
    }
    
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, 
                             StaffManagementDAO dao, User currentUser) throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String fullName = request.getParameter("fullName");
            String role = request.getParameter("role");
            String newPassword = request.getParameter("newPassword");
            
            boolean success = dao.updateStaff(userId, fullName, role);
            
            // Update password if provided
            if (newPassword != null && !newPassword.trim().isEmpty() && newPassword.length() >= 6) {
                dao.updateStaffPassword(userId, newPassword);
            }
            
            if (success) {
                AuditLogger.log("STAFF_UPDATED", "Admin " + currentUser.getUsername() + 
                               " updated staff ID: " + userId);
                response.sendRedirect("manageUsers?msg=Staff member updated successfully");
            } else {
                response.sendRedirect("manageUsers?error=Failed to update staff");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manageUsers?error=Invalid user ID");
        }
    }
    
    private void handleDelete(HttpServletRequest request, HttpServletResponse response, 
                             StaffManagementDAO dao, User currentUser) throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            
            // Prevent self-deletion
            if (userId == currentUser.getId()) {
                response.sendRedirect("manageUsers?error=Cannot delete your own account");
                return;
            }
            
            User staffToDelete = dao.getStaffById(userId);
            boolean success = dao.deleteStaff(userId);
            
            if (success) {
                AuditLogger.log("STAFF_DELETED", "Admin " + currentUser.getUsername() + 
                               " deleted staff: " + staffToDelete.getUsername());
                response.sendRedirect("manageUsers?msg=Staff member deleted successfully");
            } else {
                response.sendRedirect("manageUsers?error=Failed to delete staff");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manageUsers?error=Invalid user ID");
        }
    }
    
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response, 
                                StaffManagementDAO dao) throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            User staff = dao.getStaffById(userId);
            
            if (staff != null) {
                request.setAttribute("staffToEdit", staff);
                List<User> staffList = dao.getAllStaff();
                request.setAttribute("staffList", staffList);
                request.getRequestDispatcher("manage_users.jsp").forward(request, response);
            } else {
                response.sendRedirect("manageUsers?error=Staff not found");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manageUsers?error=Invalid user ID");
        }
    }
}
