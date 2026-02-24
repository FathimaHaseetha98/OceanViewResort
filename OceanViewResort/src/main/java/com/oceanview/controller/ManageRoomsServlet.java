package com.oceanview.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.oceanview.dao.RoomDAO;
import com.oceanview.model.User;
import com.oceanview.utils.AuditLogger;

/**
 * ManageRoomsServlet - Handles CRUD operations for Room Management
 * Admin-only servlet for managing rooms and room types
 */
@WebServlet("/manageRooms")
public class ManageRoomsServlet extends HttpServlet {
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
        
        RoomDAO dao = new RoomDAO();
        String action = request.getParameter("action");
        
        if ("deleteRoom".equals(action)) {
            handleDeleteRoom(request, response, dao, currentUser);
            return;
        }
        
        if ("deleteType".equals(action)) {
            handleDeleteType(request, response, dao, currentUser);
            return;
        }
        
        // Default: List all rooms and types
        List<Map<String, Object>> rooms = dao.getAllRooms();
        List<Map<String, Object>> roomTypes = dao.getAllRoomTypes();
        
        request.setAttribute("rooms", rooms);
        request.setAttribute("roomTypes", roomTypes);
        request.getRequestDispatcher("manage_rooms.jsp").forward(request, response);
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
        
        RoomDAO dao = new RoomDAO();
        String action = request.getParameter("action");
        
        if ("addRoom".equals(action)) {
            handleAddRoom(request, response, dao, currentUser);
        } else if ("addType".equals(action)) {
            handleAddType(request, response, dao, currentUser);
        } else if ("updateType".equals(action)) {
            handleUpdateType(request, response, dao, currentUser);
        }
    }
    
    private void handleAddRoom(HttpServletRequest request, HttpServletResponse response, 
                               RoomDAO dao, User currentUser) throws IOException {
        String roomNumber = request.getParameter("roomNumber");
        String roomType = request.getParameter("roomType");
        
        if (roomNumber == null || roomNumber.trim().isEmpty() ||
            roomType == null || roomType.trim().isEmpty()) {
            response.sendRedirect("manageRooms?error=Invalid input");
            return;
        }
        
        if (dao.roomExists(roomNumber)) {
            response.sendRedirect("manageRooms?error=Room number already exists");
            return;
        }
        
        boolean success = dao.addRoom(roomNumber, roomType);
        
        if (success) {
            AuditLogger.log("ROOM_ADDED", "Admin " + currentUser.getUsername() + 
                           " added room: " + roomNumber + " (" + roomType + ")");
            response.sendRedirect("manageRooms?msg=Room added successfully");
        } else {
            response.sendRedirect("manageRooms?error=Failed to add room");
        }
    }
    
    private void handleDeleteRoom(HttpServletRequest request, HttpServletResponse response, 
                                  RoomDAO dao, User currentUser) throws IOException {
        String roomNumber = request.getParameter("id");
        
        if (roomNumber == null || roomNumber.trim().isEmpty()) {
            response.sendRedirect("manageRooms?error=Invalid room number");
            return;
        }
        
        boolean success = dao.deleteRoom(roomNumber);
        
        if (success) {
            AuditLogger.log("ROOM_DELETED", "Admin " + currentUser.getUsername() + 
                           " deleted room: " + roomNumber);
            response.sendRedirect("manageRooms?msg=Room deleted successfully");
        } else {
            response.sendRedirect("manageRooms?error=Cannot delete room (may have active reservations)");
        }
    }
    
    private void handleAddType(HttpServletRequest request, HttpServletResponse response, 
                               RoomDAO dao, User currentUser) throws IOException {
        String typeName = request.getParameter("typeName");
        String priceStr = request.getParameter("price");
        
        if (typeName == null || typeName.trim().isEmpty() || priceStr == null) {
            response.sendRedirect("manageRooms?error=Invalid input");
            return;
        }
        
        try {
            double price = Double.parseDouble(priceStr);
            boolean success = dao.addRoomType(typeName, price);
            
            if (success) {
                AuditLogger.log("ROOM_TYPE_ADDED", "Admin " + currentUser.getUsername() + 
                               " added room type: " + typeName + " (LKR " + price + ")");
                response.sendRedirect("manageRooms?msg=Room type added successfully");
            } else {
                response.sendRedirect("manageRooms?error=Room type already exists");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manageRooms?error=Invalid price format");
        }
    }
    
    private void handleUpdateType(HttpServletRequest request, HttpServletResponse response, 
                                  RoomDAO dao, User currentUser) throws IOException {
        try {
            int typeId = Integer.parseInt(request.getParameter("typeId"));
            String typeName = request.getParameter("typeName");
            double price = Double.parseDouble(request.getParameter("price"));
            
            boolean success = dao.updateRoomType(typeId, typeName, price);
            
            if (success) {
                AuditLogger.log("ROOM_TYPE_UPDATED", "Admin " + currentUser.getUsername() + 
                               " updated room type ID: " + typeId);
                response.sendRedirect("manageRooms?msg=Room type updated successfully");
            } else {
                response.sendRedirect("manageRooms?error=Failed to update room type");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manageRooms?error=Invalid input");
        }
    }
    
    private void handleDeleteType(HttpServletRequest request, HttpServletResponse response, 
                                  RoomDAO dao, User currentUser) throws IOException {
        try {
            int typeId = Integer.parseInt(request.getParameter("id"));
            boolean success = dao.deleteRoomType(typeId);
            
            if (success) {
                AuditLogger.log("ROOM_TYPE_DELETED", "Admin " + currentUser.getUsername() + 
                               " deleted room type ID: " + typeId);
                response.sendRedirect("manageRooms?msg=Room type deleted successfully");
            } else {
                response.sendRedirect("manageRooms?error=Cannot delete room type (may be in use)");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manageRooms?error=Invalid type ID");
        }
    }
}
