<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    // Security: Only staff and admin can create reservations
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
    <title>New Reservation - Ocean View Resort</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .form-container { 
            background: white; 
            padding: 40px;
            border-radius: 20px; 
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 600px;
            animation: slideUp 0.4s ease-out;
        }
        
        @keyframes slideUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        .form-header {
            text-align: center;
            margin-bottom: 35px;
        }
        
        .form-header .icon {
            font-size: 48px;
            margin-bottom: 10px;
        }
        
        .form-header h2 { 
            color: #2c3e50; 
            font-size: 28px;
            margin-bottom: 8px;
        }
        
        .form-header p {
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        label { 
            display: block; 
            margin-bottom: 8px; 
            color: #2c3e50; 
            font-weight: 600;
            font-size: 14px;
        }
        
        input, select { 
            width: 100%; 
            padding: 14px 16px; 
            border: 2px solid #e0e0e0; 
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s;
            font-family: inherit;
        }
        
        input:focus, select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }
        
        select {
            cursor: pointer;
            background-color: white;
        }
        
        optgroup {
            font-weight: bold;
            color: #2c3e50;
        }
        
        option {
            padding: 10px;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        button { 
            flex: 1;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; 
            padding: 16px; 
            border: none; 
            cursor: pointer; 
            border-radius: 10px; 
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        
        button:hover { 
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        
        button:active {
            transform: translateY(0);
        }
        
        .back-btn { 
            flex: 1;
            display: inline-block; 
            background: #ecf0f1;
            color: #2c3e50; 
            text-decoration: none;
            padding: 16px;
            border-radius: 10px;
            text-align: center;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .back-btn:hover { 
            background: #d5dbdb;
            transform: translateY(-2px);
        }
        
        .error { 
            background: #fee;
            color: #c33;
            border-left: 4px solid #e74c3c;
            padding: 15px 20px; 
            border-radius: 10px; 
            margin-bottom: 25px;
            animation: shake 0.4s;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
        
        .info-box {
            background: #e8f4fd;
            border-left: 4px solid #3498db;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 25px;
            font-size: 14px;
            color: #2c3e50;
        }
        
        .info-box strong {
            color: #3498db;
        }
        
        .role-badge {
            display: inline-block;
            background: <%= isAdmin ? "#e74c3c" : "#3498db" %>;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            margin-bottom: 20px;
        }
    </style>
    <script>
        // Set minimum date to today
        window.onload = function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('checkIn').setAttribute('min', today);
            
            document.getElementById('checkIn').addEventListener('change', function() {
                const checkInDate = this.value;
                document.getElementById('checkOut').setAttribute('min', checkInDate);
            });
        };
    </script>
</head>
<body>

<div class="form-container">
    <div class="form-header">
        <div class="icon">🏨</div>
        <h2>New Reservation</h2>
        <p>Create a new booking for a guest</p>
        <div style="text-align: center; margin-top: 10px;">
            <span class="role-badge"><%= isAdmin ? "👑 ADMIN" : "🌊 STAFF" %></span>
        </div>
    </div>
    
    <% String err = (String) request.getAttribute("errorMessage"); 
       if(err != null) { %> 
        <div class="error">⚠️ <%= err %></div> 
    <% } %>
    
    <div class="info-box">
        <strong>💡 Tip:</strong> The system will automatically check room availability for the selected dates.
    </div>

    <form action="addReservation" method="post">
        <div class="form-group">
            <label>👤 Guest Name</label>
            <input type="text" name="name" placeholder="Enter guest full name" required autofocus>
        </div>

        <div class="form-group">
            <label>📍 Address</label>
            <input type="text" name="address" placeholder="Enter guest address" required>
        </div>

        <div class="form-group">
            <label>📞 Contact Number</label>
            <input type="tel" name="phone" placeholder="0771234567" required pattern="[0-9]{10}" title="Please enter a 10-digit phone number">
        </div>

        <div class="form-group">
            <label>🏠 Select Room</label>
            <select name="roomNumber" required>
                <option value="" disabled selected>Choose a room...</option>
                <optgroup label="💎 Standard Rooms (LKR 5,000/night)">
                    <option value="101">Room 101 - Standard</option>
                    <option value="102">Room 102 - Standard</option>
                    <option value="103">Room 103 - Standard</option>
                </optgroup>
                <optgroup label="⭐ Deluxe Rooms (LKR 8,500/night)">
                    <option value="201">Room 201 - Deluxe</option>
                    <option value="202">Room 202 - Deluxe</option>
                </optgroup>
                <optgroup label="👑 Suite Rooms (LKR 15,000/night)">
                    <option value="301">Room 301 - Suite</option>
                </optgroup>
            </select>
        </div>

        <div class="form-group">
            <label>📅 Check-in Date</label>
            <input type="date" id="checkIn" name="checkIn" required>
        </div>

        <div class="form-group">
            <label>📅 Check-out Date</label>
            <input type="date" id="checkOut" name="checkOut" required>
        </div>

        <div class="button-group">
            <a href="<%= isAdmin ? "admin_dashboard.jsp" : "dashboard.jsp" %>" class="back-btn">← Cancel</a>
            <button type="submit">✓ Confirm Booking</button>
        </div>
    </form>
</div>

</body>
</html>