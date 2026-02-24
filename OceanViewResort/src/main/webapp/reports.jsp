<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.dao.ReservationDAO.RevenueReport" %>
<%@ page import="com.oceanview.model.User" %>
<%
    // RBAC: Only Admins can access reports
    User currentUser = (User) session.getAttribute("currentUser");
    if(currentUser == null) {
        response.sendRedirect("adminlogin.jsp?error=Please login as administrator");
        return;
    }
    
    if(!"Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("dashboard.jsp?error=Access Denied: Admins Only");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Business Reports - Ocean View Resort</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
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
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
        
        .report-card {
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .report-card h2 {
            color: #333;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .report-card > p {
            color: #666;
            margin-bottom: 25px;
        }
        
        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            overflow: hidden;
        }
        
        th {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 18px 15px;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        th:first-child { border-radius: 10px 0 0 0; }
        th:last-child { border-radius: 0 10px 0 0; }
        
        td {
            padding: 18px 15px;
            border-bottom: 1px solid #eee;
            color: #333;
        }
        
        tbody tr {
            background: white;
            transition: background 0.3s, transform 0.2s;
        }
        
        tbody tr:hover {
            background: #f8f9ff;
            transform: scale(1.01);
        }
        
        .room-type {
            font-weight: 600;
            color: #667eea;
        }
        
        .booking-badge {
            display: inline-block;
            padding: 6px 12px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        
        .revenue-cell {
            position: relative;
        }
        
        .revenue-amount {
            position: relative;
            z-index: 2;
            font-weight: 700;
            color: #333;
        }
        
        .revenue-bar {
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            height: 80%;
            background: linear-gradient(90deg, rgba(102, 126, 234, 0.15), rgba(118, 75, 162, 0.15));
            border-radius: 5px;
            z-index: 1;
            transition: width 1s ease-out;
        }
        
        .total-row {
            font-weight: bold;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1)) !important;
            border-top: 2px solid #667eea;
        }
        
        .total-row td {
            padding: 20px 15px;
            font-size: 16px;
            color: #667eea;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .empty-state i {
            font-size: 64px;
            color: #ccc;
            margin-bottom: 20px;
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                text-align: center;
            }
            
            .header h1 {
                font-size: 24px;
            }
            
            table {
                font-size: 14px;
            }
            
            th, td {
                padding: 12px 8px;
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
            <h1><i class="fas fa-chart-line"></i> Revenue Report</h1>
            <a href="admin_dashboard.jsp" class="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
        
        <%
            List<RevenueReport> list = (List<RevenueReport>) request.getAttribute("reportData");
            double grandTotal = 0;
            int totalBookings = 0;
            int roomTypeCount = 0;
            
            if(list != null) {
                roomTypeCount = list.size();
                for(RevenueReport r : list) {
                    grandTotal += r.totalRevenue;
                    totalBookings += r.bookingCount;
                }
            }
        %>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="icon">
                    <i class="fas fa-rupee-sign"></i>
                </div>
                <div class="label">Total Revenue</div>
                <div class="value">LKR <%= String.format("%,.0f", grandTotal) %></div>
            </div>
            
            <div class="stat-card">
                <div class="icon">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div class="label">Total Bookings</div>
                <div class="value"><%= totalBookings %></div>
            </div>
            
            <div class="stat-card">
                <div class="icon">
                    <i class="fas fa-bed"></i>
                </div>
                <div class="label">Room Types</div>
                <div class="value"><%= roomTypeCount %></div>
            </div>
        </div>

        <div class="report-card">
            <h2>Revenue Breakdown by Room Type</h2>
            <p>Detailed summary of all finalized bookings and revenue generation</p>

            <% if(list == null || list.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    <h3>No Data Available</h3>
                    <p>There are no finalized bookings yet.</p>
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Room Type</th>
                            <th>Bookings</th>
                            <th>Total Revenue (LKR)</th>
                            <th>% Share</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for(RevenueReport r : list) { 
                            double percentage = (r.totalRevenue / grandTotal) * 100;
                        %>
                        <tr>
                            <td class="room-type"><i class="fas fa-door-open"></i> <%= r.roomType %></td>
                            <td><span class="booking-badge"><%= r.bookingCount %></span></td>
                            <td class="revenue-cell">
                                <div class="revenue-bar" style="width: <%= percentage %>%"></div>
                                <span class="revenue-amount">LKR <%= String.format("%,.2f", r.totalRevenue) %></span>
                            </td>
                            <td><%= String.format("%.1f%%", percentage) %></td>
                        </tr>
                        <% } %>
                        <tr class="total-row">
                            <td colspan="2"><strong>GRAND TOTAL</strong></td>
                            <td colspan="2"><strong>LKR <%= String.format("%,.2f", grandTotal) %></strong></td>
                        </tr>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
</body>
</html>
