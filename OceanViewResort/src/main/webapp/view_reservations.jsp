<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="com.oceanview.model.User" %>

<!-- Security Check -->
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if(currentUser == null) {
        response.sendRedirect("stafflogin.jsp?error=Please login to continue");
        return;
    }
    
    // Only allow Staff (Receptionist) and Admin
    String role = currentUser.getRole();
    if(!"Receptionist".equalsIgnoreCase(role) && !"Admin".equalsIgnoreCase(role)) {
        response.sendRedirect("dashboard.jsp?error=Access Denied");
        return;
    }
    
    boolean isAdmin = "Admin".equalsIgnoreCase(role);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Reservations - Ocean View Resort</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            padding: 30px 20px;
            min-height: 100vh;
        }
        
        .container { 
            max-width: 1400px; 
            margin: auto; 
            background: white; 
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1); 
            border-radius: 20px;
            animation: fadeIn 0.5s ease-out;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
        }
        
        .page-header h2 { 
            color: #2c3e50;
            font-size: 32px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .role-badge {
            display: inline-block;
            background: <%= isAdmin ? "#e74c3c" : "#3498db" %>;
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
        }
        
        .btn { 
            padding: 12px 24px; 
            text-decoration: none; 
            border-radius: 10px; 
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-block;
        }
        
        .btn-back { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        
        .btn-back:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        
        .search-section {
            margin-bottom: 25px;
        }
        
        .search-box {
            width: 100%;
            max-width: 400px;
            padding: 14px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s;
        }
        
        .search-box:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }
        
        .stats-bar {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }
        
        .stat-item {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 25px;
            border-radius: 10px;
            font-size: 14px;
        }
        
        .stat-item strong {
            font-size: 24px;
            display: block;
            margin-bottom: 5px;
        }
        
        .table-wrapper {
            overflow-x: auto;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        table { 
            width: 100%; 
            border-collapse: collapse;
            background: white;
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        th { 
            padding: 18px 15px; 
            text-align: left; 
            color: white;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 13px;
            letter-spacing: 0.5px;
        }
        
        td { 
            padding: 16px 15px; 
            border-bottom: 1px solid #f0f0f0;
            color: #2c3e50;
        }
        
        tbody tr { 
            transition: all 0.3s;
        }
        
        tbody tr:hover { 
            background: #f8f9fa;
            transform: scale(1.01);
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .btn-bill { 
            background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
            color: white;
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-block;
        }
        
        .btn-bill:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
        }
        
        .room-badge {
            background: #3498db;
            color: white;
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #95a5a6;
        }
        
        .no-data .icon {
            font-size: 64px;
            margin-bottom: 15px;
        }
        
        .no-data h3 {
            font-size: 20px;
            margin-bottom: 10px;
        }
        
        .empty-state {
            text-align: center;
            padding: 20px;
        }
        
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .stats-bar {
                flex-direction: column;
            }
        }
    </style>
    <script>
        function searchTable() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toUpperCase();
            const table = document.querySelector('table');
            const tr = table.getElementsByTagName('tr');
            
            let visibleCount = 0;
            
            for (let i = 1; i < tr.length; i++) {
                const td = tr[i].getElementsByTagName('td');
                let found = false;
                
                for (let j = 0; j < td.length; j++) {
                    if (td[j]) {
                        const txtValue = td[j].textContent || td[j].innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found) {
                    tr[i].style.display = '';
                    visibleCount++;
                } else {
                    tr[i].style.display = 'none';
                }
            }
            
            // Update count
            const countEl = document.getElementById('visibleCount');
            if (countEl) {
                countEl.textContent = visibleCount;
            }
        }
    </script>
</head>
<body>

<div class="container">
    <div class="page-header">
        <div>
            <h2>
                📋 Manage Reservations
            </h2>
            <span class="role-badge"><%= isAdmin ? "👑 ADMIN" : "🌊 STAFF" %></span>
        </div>
        <a href="<%= isAdmin ? "admin_dashboard.jsp" : "dashboard.jsp" %>" class="btn btn-back">← Back to Dashboard</a>
    </div>
    
    <% 
        List<Reservation> list = (List<Reservation>) request.getAttribute("reservationList");
        int totalCount = (list != null) ? list.size() : 0;
    %>
    
    <div class="stats-bar">
        <div class="stat-item">
            <strong id="visibleCount"><%= totalCount %></strong>
            Total Reservations
        </div>
    </div>
    
    <div class="search-section">
        <input type="text" id="searchInput" class="search-box" onkeyup="searchTable()" placeholder="🔍 Search by guest name, room, or booking ID...">
    </div>

    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Room</th>
                    <th>Guest Name</th>
                    <th>Contact</th>
                    <th>Check-In</th>
                    <th>Check-Out</th>
                    <th>Total Amount</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    if (list != null && !list.isEmpty()) {
                        for (Reservation r : list) {
                %>
                <tr>
                    <td><strong>#<%= r.getId() %></strong></td>
                    <td>
                        <span class="room-badge">🏠 <%= r.getRoomNumber() %></span>
                        <br>
                        <small style="color: #7f8c8d;"><%= r.getRoomType() %></small>
                    </td>
                    <td>
                        <strong><%= r.getGuestName() %></strong>
                        <br>
                        <small style="color: #7f8c8d;"><%= r.getAddress() %></small>
                    </td>
                    <td>
                        <small>📞 <%= r.getContactNumber() %></small>
                    </td>
                    <td><%= r.getCheckIn() %></td>
                    <td><%= r.getCheckOut() %></td>
                    <td>
                        <strong style="color: #27ae60;">LKR <%= String.format("%,.2f", r.getTotalAmount()) %></strong>
                    </td>
                    <td>
                        <a href="generateBill?id=<%= r.getId() %>" class="btn-bill" target="_blank">🖨️ Print Bill</a>
                    </td>
                </tr>
                <% 
                        }
                    } else {
                %>
                <tr>
                    <td colspan="8" class="no-data">
                        <div class="icon">📭</div>
                        <h3>No Reservations Found</h3>
                        <p>There are currently no bookings in the system.</p>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>