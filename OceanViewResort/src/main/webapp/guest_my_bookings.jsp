<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.GuestUser" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="com.oceanview.dao.ReservationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.sql.Date" %>
<%
    GuestUser guest = (GuestUser) session.getAttribute("currentGuest");
    if(guest == null) {
        response.sendRedirect("guest_login.jsp");
        return;
    }
    
    ReservationDAO dao = new ReservationDAO();
    List<Reservation> allBookings = dao.getReservationsByGuestId(guest.getId());
    
    // Calculate statistics
    int totalBookings = allBookings.size();
    int upcomingBookings = 0;
    int completedBookings = 0;
    double totalSpent = 0;
    LocalDate today = LocalDate.now();
    
    for(Reservation r : allBookings) {
        totalSpent += r.getTotalAmount();
        Date checkInDate = r.getCheckIn();
        if(checkInDate != null) {
            LocalDate checkIn = checkInDate.toLocalDate();
            if(checkIn.isAfter(today) || checkIn.isEqual(today)) {
                upcomingBookings++;
            } else {
                completedBookings++;
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings - Ocean View Resort</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body { 
            font-family: 'Poppins', sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            padding: 25px 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .header h1 {
            color: #667eea;
            font-weight: 700;
            font-size: 28px;
        }
        
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 500;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-back:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card .icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            margin-bottom: 15px;
        }
        
        .stat-card .label {
            color: #666;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
        }
        
        .stat-card .value {
            color: #333;
            font-size: 28px;
            font-weight: 700;
        }
        
        .bookings-container {
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .bookings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
            margin-top: 25px;
        }
        
        .booking-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-left: 4px solid #667eea;
            transition: transform 0.3s, box-shadow 0.3s;
            position: relative;
        }
        
        .booking-card:hover {
            transform: translateX(5px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .booking-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .reservation-id {
            font-size: 16px;
            font-weight: 600;
            color: #667eea;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-upcoming {
            background: #d4edda;
            color: #155724;
        }
        
        .status-completed {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .booking-details {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .detail-row {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #555;
        }
        
        .detail-row i {
            width: 20px;
            color: #667eea;
        }
        
        .detail-label {
            font-weight: 500;
            min-width: 100px;
        }
        
        .detail-value {
            color: #333;
        }
        
        .booking-amount {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid #f0f0f0;
            text-align: right;
        }
        
        .amount-label {
            font-size: 13px;
            color: #666;
            margin-bottom: 5px;
        }
        
        .amount-value {
            font-size: 24px;
            font-weight: 700;
            color: #667eea;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }
        
        .empty-state i {
            font-size: 64px;
            color: #ccc;
            margin-bottom: 20px;
        }
        
        .empty-state h3 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #666;
            margin-bottom: 25px;
        }
        
        .btn-book {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 30px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-book:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                text-align: center;
            }
            
            .header h1 {
                font-size: 24px;
            }
            
            .bookings-grid {
                grid-template-columns: 1fr;
            }
            
            .stat-card .value {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-calendar-check"></i> My Bookings</h1>
            <a href="guest_dashboard.jsp" class="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="icon">
                    <i class="fas fa-list"></i>
                </div>
                <div class="label">Total Bookings</div>
                <div class="value"><%= totalBookings %></div>
            </div>
            
            <div class="stat-card">
                <div class="icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="label">Upcoming</div>
                <div class="value"><%= upcomingBookings %></div>
            </div>
            
            <div class="stat-card">
                <div class="icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="label">Completed</div>
                <div class="value"><%= completedBookings %></div>
            </div>
            
            <div class="stat-card">
                <div class="icon">
                    <i class="fas fa-rupee-sign"></i>
                </div>
                <div class="label">Total Spent</div>
                <div class="value">LKR <%= String.format("%,.0f", totalSpent) %></div>
            </div>
        </div>

        <div class="bookings-container">
            <h2 style="color: #333; margin-bottom: 10px;">Booking History</h2>
            <p style="color: #666; margin-bottom: 20px;">View all your past and upcoming reservations</p>
            
            <% if (allBookings.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-calendar-times"></i>
                    <h3>No Bookings Yet</h3>
                    <p>You haven't made any reservations yet. Start planning your perfect getaway!</p>
                    <a href="guest_book_room.jsp" class="btn-book">
                        <i class="fas fa-plus"></i> Make a Booking
                    </a>
                </div>
            <% } else { %>
                <div class="bookings-grid">
                    <% 
                    for (Reservation r : allBookings) { 
                        Date checkInDate = r.getCheckIn();
                        boolean isUpcoming = false;
                        if(checkInDate != null) {
                            LocalDate checkIn = checkInDate.toLocalDate();
                            isUpcoming = checkIn.isAfter(today) || checkIn.isEqual(today);
                        }
                    %>
                    <div class="booking-card">
                        <div class="booking-header">
                            <div class="reservation-id">
                                <i class="fas fa-ticket-alt"></i> #<%= r.getId() %>
                            </div>
                            <span class="status-badge <%= isUpcoming ? "status-upcoming" : "status-completed" %>">
                                <%= isUpcoming ? "Upcoming" : "Completed" %>
                            </span>
                        </div>
                        
                        <div class="booking-details">
                            <div class="detail-row">
                                <i class="fas fa-door-open"></i>
                                <span class="detail-label">Room Type:</span>
                                <span class="detail-value"><strong><%= r.getRoomType() %></strong></span>
                            </div>
                            
                            <div class="detail-row">
                                <i class="fas fa-hashtag"></i>
                                <span class="detail-label">Room Number:</span>
                                <span class="detail-value"><%= r.getRoomNumber() %></span>
                            </div>
                            
                            <div class="detail-row">
                                <i class="fas fa-sign-in-alt"></i>
                                <span class="detail-label">Check-In:</span>
                                <span class="detail-value"><%= r.getCheckIn() %></span>
                            </div>
                            
                            <div class="detail-row">
                                <i class="fas fa-sign-out-alt"></i>
                                <span class="detail-label">Check-Out:</span>
                                <span class="detail-value"><%= r.getCheckOut() %></span>
                            </div>
                        </div>
                        
                        <div class="booking-amount">
                            <div class="amount-label">Total Amount</div>
                            <div class="amount-value">LKR <%= String.format("%,.2f", r.getTotalAmount()) %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
