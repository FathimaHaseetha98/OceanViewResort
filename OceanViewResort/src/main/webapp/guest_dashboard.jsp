<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.GuestUser" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="com.oceanview.dao.ReservationDAO" %>
<%@ page import="java.util.List" %>
<%
    // Security check - ensure guest is logged in
    GuestUser guest = (GuestUser) session.getAttribute("currentGuest");
    if(guest == null) {
        response.sendRedirect("guest_login.jsp");
        return;
    }
    
    // Get guest's reservations
    ReservationDAO dao = new ReservationDAO();
    List<Reservation> upcomingBookings = dao.getUpcomingReservationsByGuest(guest.getId());
    List<Reservation> allBookings = dao.getReservationsByGuestId(guest.getId());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Dashboard - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; }
        
        /* Sidebar */
        .sidebar {
            width: 250px;
            height: 100vh;
            background: linear-gradient(180deg, #1e3c72 0%, #2a5298 100%);
            color: white;
            position: fixed;
            padding: 20px;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        .sidebar .logo {
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 10px;
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
        .sidebar .user-info p {
            font-size: 12px;
            opacity: 0.8;
        }
        .sidebar a {
            color: #ddd;
            text-decoration: none;
            display: block;
            padding: 12px 15px;
            margin: 5px 0;
            border-radius: 5px;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        .sidebar .logout {
            position: absolute;
            bottom: 20px;
            width: calc(100% - 40px);
            background: #e74c3c;
            text-align: center;
        }
        .sidebar .logout:hover {
            background: #c0392b;
        }
        
        /* Main Content */
        .main {
            margin-left: 250px;
            padding: 30px;
        }
        .header {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }
        .header h1 {
            color: #333;
            margin-bottom: 5px;
        }
        .header p {
            color: #666;
        }
        
        /* Stats Cards */
        .stats {
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
        }
        .stat-card.upcoming { border-color: #3498db; }
        .stat-card.total { border-color: #2ecc71; }
        .stat-card.book { border-color: #e74c3c; }
        .stat-card h3 {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .stat-card .number {
            font-size: 32px;
            font-weight: bold;
            color: #333;
        }
        .stat-card a {
            display: inline-block;
            margin-top: 10px;
            color: #3498db;
            text-decoration: none;
        }
        
        /* Reservations Section */
        .section {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        .section h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: #f8f9fa;
            padding: 12px;
            text-align: left;
            color: #555;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #eee;
            color: #666;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-standard { background: #d1ecf1; color: #0c5460; }
        .badge-deluxe { background: #d4edda; color: #155724; }
        .badge-suite { background: #fff3cd; color: #856404; }
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        .empty-state h3 {
            margin-bottom: 10px;
        }
        .btn-book-now {
            display: inline-block;
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            margin-top: 15px;
        }
        .btn-book-now:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="logo">🌊 Ocean View Resort</div>
        <div class="user-info">
            <h3><%= guest.getFullName() %></h3>
            <p>Guest Account</p>
            <p><%= guest.getEmail() %></p>
        </div>
        
        <a href="guest_dashboard.jsp" class="active">📊 My Dashboard</a>
        <a href="guest_book_room.jsp">🏨 Book a Room</a>
        <a href="guest_my_bookings.jsp">📋 My Bookings</a>
        <a href="guest_profile.jsp">👤 My Profile</a>
        
        <a href="logout" class="logout">🚪 Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main">
        <div class="header">
            <h1>Welcome back, <%= guest.getFullName() %>! 👋</h1>
            <p>Manage your reservations and explore our luxurious accommodations</p>
        </div>
        
        <% String msg = request.getParameter("msg"); if (msg != null) { %>
        <div style="background: #d4edda; color: #155724; padding: 15px 20px; border-radius: 10px; margin-bottom: 20px; border-left: 4px solid #28a745;">
            ✅ <%= msg %>
        </div>
        <% } %>
        
        <!-- Stats Cards -->
        <div class="stats">
            <div class="stat-card upcoming">
                <h3>Upcoming Reservations</h3>
                <div class="number"><%= upcomingBookings.size() %></div>
                <a href="guest_my_bookings.jsp">View Details →</a>
            </div>
            
            <div class="stat-card total">
                <h3>Total Bookings</h3>
                <div class="number"><%= allBookings.size() %></div>
                <a href="guest_my_bookings.jsp">View History →</a>
            </div>
            
            <div class="stat-card book">
                <h3>Ready for a Vacation?</h3>
                <div class="number" style="font-size: 20px;">Book Now!</div>
                <a href="guest_book_room.jsp">Make Reservation →</a>
            </div>
        </div>
        
        <!-- Upcoming Reservations -->
        <div class="section">
            <h2>📅 Upcoming Reservations</h2>
            
            <% if (upcomingBookings.isEmpty()) { %>
                <div class="empty-state">
                    <h3>No upcoming reservations</h3>
                    <p>You don't have any upcoming reservations. Ready to book your next stay?</p>
                    <a href="guest_book_room.jsp" class="btn-book-now">Book a Room</a>
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Reservation #</th>
                            <th>Room Type</th>
                            <th>Room Number</th>
                            <th>Check-In</th>
                            <th>Check-Out</th>
                            <th>Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Reservation r : upcomingBookings) { %>
                        <tr>
                            <td><strong>#<%= r.getId() %></strong></td>
                            <td>
                                <span class="badge badge-<%= r.getRoomType().toLowerCase().replace(" ", "") %>">
                                    <%= r.getRoomType() %>
                                </span>
                            </td>
                            <td><%= r.getRoomNumber() %></td>
                            <td><%= r.getCheckIn() %></td>
                            <td><%= r.getCheckOut() %></td>
                            <td><strong>LKR <%= String.format("%,.2f", r.getTotalAmount()) %></strong></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Quick Actions -->
        <div class="section">
            <h2>⚡ Quick Actions</h2>
            <p style="margin-bottom: 15px;">Explore what you can do with your guest account</p>
            
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                <a href="guest_book_room.jsp" style="background: #3498db; color: white; padding: 20px; border-radius: 8px; text-decoration: none; text-align: center;">
                    <div style="font-size: 32px; margin-bottom: 10px;">🏨</div>
                    <strong>Book a Room</strong>
                </a>
                
                <a href="guest_my_bookings.jsp" style="background: #2ecc71; color: white; padding: 20px; border-radius: 8px; text-decoration: none; text-align: center;">
                    <div style="font-size: 32px; margin-bottom: 10px;">📋</div>
                    <strong>View All Bookings</strong>
                </a>
                
                <a href="guest_profile.jsp" style="background: #9b59b6; color: white; padding: 20px; border-radius: 8px; text-decoration: none; text-align: center;">
                    <div style="font-size: 32px; margin-bottom: 10px;">👤</div>
                    <strong>Update Profile</strong>
                </a>
            </div>
        </div>
    </div>
</body>
</html>
