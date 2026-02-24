<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.dao.ReservationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%
    // Security Check: If no user in session, kick them back to login
    User currentUser = (User) session.getAttribute("currentUser");
    if(currentUser == null) {
        response.sendRedirect("stafflogin.jsp");
        return;
    }
    
    // Only Receptionists (Staff) can access this page - Admins have their own dashboard
    if("Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("admin_dashboard.jsp");
        return;
    }
    
    if(!"Receptionist".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("stafflogin.jsp?error=Access Denied");
        return;
    }
    
    // Get quick stats
    ReservationDAO dao = new ReservationDAO();
    List<Reservation> allReservations = dao.getAllReservations();
    int totalReservations = allReservations.size();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Staff Dashboard - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f5f7fa; }
        
        /* Sidebar */
        .sidebar {
            width: 260px;
            height: 100vh;
            background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
            color: white;
            position: fixed;
            padding: 20px;
            overflow-y: auto;
        }
        .sidebar .logo {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #3498db;
        }
        .sidebar .user-info {
            background: rgba(255,255,255,0.1);
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .sidebar .user-info h3 {
            font-size: 16px;
            margin-bottom: 5px;
        }
        .sidebar .user-info .role-badge {
            display: inline-block;
            background: #3498db;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .sidebar .nav-section {
            margin-bottom: 20px;
        }
        .sidebar .nav-section h4 {
            color: #95a5a6;
            font-size: 12px;
            text-transform: uppercase;
            margin-bottom: 10px;
            padding-left: 5px;
        }
        .sidebar a {
            color: #ecf0f1;
            text-decoration: none;
            display: block;
            padding: 12px 15px;
            margin: 5px 0;
            border-radius: 6px;
            transition: all 0.3s;
            font-size: 14px;
        }
        .sidebar a:hover {
            background: rgba(52, 152, 219, 0.2);
            padding-left: 20px;
        }
        .sidebar a.active {
            background: #3498db;
        }
        .sidebar .admin-section {
            border-top: 1px solid rgba(255,255,255,0.1);
            padding-top: 20px;
            margin-top: 20px;
        }
        .sidebar .logout {
            background: #e74c3c;
            text-align: center;
            margin-top: 30px;
        }
        .sidebar .logout:hover {
            background: #c0392b;
            padding-left: 15px;
        }
        
        /* Main Content */
        .main {
            margin-left: 260px;
            padding: 30px;
        }
        .header {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }
        .header h1 {
            color: #2c3e50;
            margin-bottom: 8px;
            font-size: 28px;
        }
        .header p {
            color: #7f8c8d;
            font-size: 15px;
        }
        
        /* Alert Messages */
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            animation: slideIn 0.3s;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid;
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .stat-card.blue { border-color: #3498db; }
        .stat-card.green { border-color: #27ae60; }
        .stat-card.orange { border-color: #f39c12; }
        .stat-card.purple { border-color: #9b59b6; }
        .stat-card h3 {
            color: #7f8c8d;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .stat-card .number {
            font-size: 36px;
            font-weight: bold;
            color: #2c3e50;
            margin: 10px 0;
        }
        .stat-card .icon {
            font-size: 40px;
            opacity: 0.3;
            float: right;
        }
        
        /* Quick Actions */
        .quick-actions {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .quick-actions h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 20px;
        }
        .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        .action-btn {
            display: block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
        }
        .action-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .action-btn .icon {
            font-size: 32px;
            margin-bottom: 10px;
            display: block;
        }
        .action-btn.green {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        .action-btn.orange {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .action-btn.blue {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="logo">🌊 Ocean View Resort</div>
        <div class="user-info">
            <h3><%= currentUser.getFullName() %></h3>
            <span class="role-badge">Staff</span>
        </div>
        
        <div class="nav-section">
            <h4>Staff Menu</h4>
            <a href="dashboard.jsp" class="active">🏠 Dashboard</a>
            <a href="reservation_form.jsp">➕ New Reservation</a>
            <a href="viewReservations">📋 View Reservations</a>
            <a href="help.jsp">❓ Help & Guide</a>
        </div>
        
        <a href="logout" class="logout">🚪 Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main">
        <% 
            String msg = request.getParameter("msg");
            String error = request.getParameter("error");
            if(msg != null) { 
        %>
            <div class="alert alert-success">✅ <%= msg %></div>
        <% } %>
        <% if(error != null) { %>
            <div class="alert alert-error">❌ <%= error %></div>
        <% } %>
        
        <div class="header">
            <h1>Welcome back, <%= currentUser.getFullName() %>! 👋</h1>
            <p>Here's what's happening with your resort today</p>
        </div>
        
        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card blue">
                <span class="icon">📊</span>
                <h3>Total Reservations</h3>
                <div class="number"><%= totalReservations %></div>
            </div>
            
            <div class="stat-card green">
                <span class="icon">✅</span>
                <h3>Active Bookings</h3>
                <div class="number"><%= totalReservations %></div>
            </div>
            
            <div class="stat-card orange">
                <span class="icon">🏨</span>
                <h3>Available Rooms</h3>
                <div class="number">--</div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="quick-actions">
            <h2>⚡ Quick Actions</h2>
            <div class="action-grid">
                <a href="reservation_form.jsp" class="action-btn green">
                    <span class="icon">➕</span>
                    <strong>New Reservation</strong>
                </a>
                
                <a href="viewReservations" class="action-btn blue">
                    <span class="icon">📋</span>
                    <strong>View All Bookings</strong>
                </a>
                
                <a href="help.jsp" class="action-btn orange">
                    <span class="icon">❓</span>
                    <strong>Help & Guide</strong>
                </a>
            </div>
        </div>
    </div>
</body>
</html>