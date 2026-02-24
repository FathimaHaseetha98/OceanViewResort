<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dao.*" %>
<%@ page import="java.util.*" %>
<%
    // RBAC: Only Admins can access this page
    User currentUser = (User) session.getAttribute("currentUser");
    if(currentUser == null) {
        response.sendRedirect("adminlogin.jsp?error=Please login as administrator");
        return;
    }
    
    if(!"Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("dashboard.jsp?error=Access Denied: Admins Only");
        return;
    }
    
    // Get statistics
    StaffManagementDAO staffDAO = new StaffManagementDAO();
    RoomDAO roomDAO = new RoomDAO();
    ReservationDAO resDAO = new ReservationDAO();
    
    Map<String, Object> staffStats = staffDAO.getStaffStatistics();
    Map<String, Object> roomStats = roomDAO.getRoomStatistics();
    int totalReservations = resDAO.getAllReservations().size();
    
    int totalStaff = (Integer) staffStats.getOrDefault("total_staff", 0);
    int adminCount = (Integer) staffStats.getOrDefault("admin_count", 0);
    int receptionistCount = (Integer) staffStats.getOrDefault("receptionist_count", 0);
    int totalRooms = (Integer) roomStats.getOrDefault("total_rooms", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f5f7fa; }
        
        /* Top Navigation */
        .topnav {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 15px 30px;
            color: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .topnav .brand {
            font-size: 22px;
            font-weight: bold;
        }
        .topnav .user {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .topnav .back-btn {
            background: rgba(255,255,255,0.2);
            padding: 8px 15px;
            border-radius: 5px;
            text-decoration: none;
            color: white;
            transition: all 0.3s;
        }
        .topnav .back-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        /* Main Container */
        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        /* Page Header */
        .page-header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }
        .page-header h1 {
            color: #2c3e50;
            font-size: 32px;
            margin-bottom: 10px;
        }
        .page-header p {
            color: #7f8c8d;
            font-size: 16px;
        }
        
        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
            position: relative;
            overflow: hidden;
            transition: all 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 25px rgba(0,0,0,0.15);
        }
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
        }
        .stat-card.purple::before { background: #9b59b6; }
        .stat-card.blue::before { background: #3498db; }
        .stat-card.green::before { background: #27ae60; }
        .stat-card.orange::before { background: #e67e22; }
        .stat-card .icon {
            font-size: 48px;
            opacity: 0.2;
            position: absolute;
            right: 20px;
            top: 20px;
        }
        .stat-card h3 {
            color: #7f8c8d;
            font-size: 15px;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stat-card .number {
            font-size: 42px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        .stat-card .subtitle {
            color: #95a5a6;
            font-size: 13px;
        }
        
        /* Management Sections */
        .management-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        .management-card {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
        }
        .management-card h2 {
            color: #2c3e50;
            font-size: 22px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .management-card p {
            color: #7f8c8d;
            margin-bottom: 20px;
            line-height: 1.6;
        }
        .btn-primary {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 25px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary {
            display: inline-block;
            background: #ecf0f1;
            color: #2c3e50;
            padding: 12px 25px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            margin-left: 10px;
        }
        .btn-secondary:hover {
            background: #bdc3c7;
        }
        
        /* Quick Links */
        .quick-links {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.08);
        }
        .quick-links h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 22px;
        }
        .link-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        .link-item {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            text-decoration: none;
            transition: all 0.3s;
        }
        .link-item:hover {
            transform: scale(1.05);
        }
        .link-item .icon {
            font-size: 32px;
            margin-bottom: 10px;
            display: block;
        }
    </style>
</head>
<body>
    <!-- Top Navigation -->
    <div class="topnav">
        <div class="brand">👑 Admin Control Panel - Ocean View Resort</div>
        <div class="user">
            <span><%= currentUser.getFullName() %> (Administrator)</span>
            <a href="logout" class="back-btn">🚪 Logout</a>
        </div>
    </div>

    <!-- Main Container -->
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1>System Administration</h1>
            <p>Manage users, rooms, and monitor system performance</p>
        </div>
        
        <!-- Statistics Grid -->
        <div class="stats-grid">
            <div class="stat-card purple">
                <span class="icon">👥</span>
                <h3>Total Staff</h3>
                <div class="number"><%= totalStaff %></div>
                <div class="subtitle"><%= adminCount %> Admins, <%= receptionistCount %> Receptionists</div>
            </div>
            
            <div class="stat-card blue">
                <span class="icon">🏨</span>
                <h3>Total Rooms</h3>
                <div class="number"><%= totalRooms %></div>
                <div class="subtitle">Across all room types</div>
            </div>
            
            <div class="stat-card green">
                <span class="icon">📊</span>
                <h3>Total Reservations</h3>
                <div class="number"><%= totalReservations %></div>
                <div class="subtitle">All-time bookings</div>
            </div>
            
            <div class="stat-card orange">
                <span class="icon">💰</span>
                <h3>Revenue</h3>
                <div class="number">--</div>
                <div class="subtitle">View detailed reports</div>
            </div>
        </div>
        
        <!-- Management Sections -->
        <div class="management-grid">
            <div class="management-card">
                <h2>👥 User Management</h2>
                <p>Add, edit, or remove staff members. Manage roles and permissions for system access.</p>
                <a href="manageUsers" class="btn-primary">Manage Users</a>
                <a href="manageUsers?action=add" class="btn-secondary">+ Add New User</a>
            </div>
            
            <div class="management-card">
                <h2>🏨 Room Management</h2>
                <p>Manage room inventory, types, and pricing. Add or remove rooms from the system.</p>
                <a href="manageRooms" class="btn-primary">Manage Rooms</a>
                <a href="manageRooms?action=add" class="btn-secondary">+ Add New Room</a>
            </div>
            
            <div class="management-card">
                <h2>📊 Business Reports</h2>
                <p>View revenue reports, booking analytics, and performance metrics.</p>
                <a href="viewReports" class="btn-primary">View Reports</a>
            </div>
            
            <div class="management-card">
                <h2>📋 Reservation Management</h2>
                <p>View, edit, and manage all reservations. Access to all booking operations.</p>
                <a href="viewReservations" class="btn-primary">All Reservations</a>
                <a href="reservation_form.jsp" class="btn-secondary">+ New Booking</a>
            </div>
        </div>
        
        <!-- Quick Links -->
        <div class="quick-links">
            <h2>⚡ Quick Access</h2>
            <div class="link-grid">
                <a href="manageUsers" class="link-item" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <span class="icon">👥</span>
                    <strong>Manage Users</strong>
                </a>
                
                <a href="manageRooms" class="link-item" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);">
                    <span class="icon">🏨</span>
                    <strong>Manage Rooms</strong>
                </a>
                
                <a href="viewReports" class="link-item" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                    <span class="icon">📊</span>
                    <strong>Business Reports</strong>
                </a>
                
                <a href="viewReservations" class="link-item" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                    <span class="icon">📋</span>
                    <strong>View Reservations</strong>
                </a>
                
                <a href="reservation_form.jsp" class="link-item" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);">
                    <span class="icon">➕</span>
                    <strong>New Reservation</strong>
                </a>
                
                <a href="help.jsp" class="link-item" style="background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);">
                    <span class="icon">❓</span>
                    <strong>Help & Guide</strong>
                </a>
            </div>
        </div>
    </div>
</body>
</html>
