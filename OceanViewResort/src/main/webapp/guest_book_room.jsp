<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.GuestUser" %>
<%@ page import="com.oceanview.dao.RoomDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    GuestUser guest = (GuestUser) session.getAttribute("currentGuest");
    if(guest == null) {
        response.sendRedirect("guest_login.jsp?error=Please login to continue");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book a Room - Ocean View Resort</title>
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
        
        .container { 
            background: white; 
            padding: 40px;
            border-radius: 20px; 
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 700px;
            animation: slideUp 0.4s ease-out;
        }
        
        @keyframes slideUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .header .icon {
            font-size: 48px;
            margin-bottom: 10px;
        }
        
        .header h2 { 
            color: #2c3e50; 
            font-size: 28px;
            margin-bottom: 8px;
        }
        
        .header p {
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .user-badge {
            display: inline-block;
            background: #3498db;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            margin-top: 10px;
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
        
        input:read-only {
            background: #f8f9fa;
            color: #7f8c8d;
        }
        
        select {
            cursor: pointer;
            background-color: white;
        }
        
        .room-types {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 25px;
        }
        
        .room-card {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .room-card:hover {
            border-color: #667eea;
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
        }
        
        .room-card.selected {
            border-color: #667eea;
            background: rgba(102, 126, 234, 0.1);
        }
        
        .room-card .icon { font-size: 32px; margin-bottom: 10px; }
        .room-card h4 { color: #2c3e50; margin-bottom: 5px; }
        .room-card .price { color: #27ae60; font-weight: bold; font-size: 18px; }
        .room-card .desc { color: #95a5a6; font-size: 12px; margin-top: 5px; }
        
        .date-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
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
        
        .back-btn { 
            flex: 0.5;
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
        }
        
        .error { 
            background: #fee;
            color: #c33;
            border-left: 4px solid #e74c3c;
            padding: 15px 20px; 
            border-radius: 10px; 
            margin-bottom: 25px;
        }
        
        .success { 
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
            padding: 15px 20px; 
            border-radius: 10px; 
            margin-bottom: 25px;
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
        
        @media (max-width: 600px) {
            .room-types {
                grid-template-columns: 1fr;
            }
            .date-row {
                grid-template-columns: 1fr;
            }
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
        
        function selectRoom(type, price) {
            // Remove selected class from all cards
            document.querySelectorAll('.room-card').forEach(card => {
                card.classList.remove('selected');
            });
            
            // Add selected class to clicked card
            event.currentTarget.classList.add('selected');
            
            // Set hidden field value
            document.getElementById('selectedRoomType').value = type;
        }
    </script>
</head>
<body>

<div class="container">
    <div class="header">
        <div class="icon">🏨</div>
        <h2>Book Your Stay</h2>
        <p>Choose your room and dates for a perfect vacation</p>
        <div class="user-badge">👤 <%= guest.getFullName() %></div>
    </div>
    
    <% String err = (String) request.getAttribute("errorMessage"); 
       if(err != null) { %> 
        <div class="error">⚠️ <%= err %></div> 
    <% } %>
    
    <% String success = (String) request.getAttribute("successMessage"); 
       if(success != null) { %> 
        <div class="success">✅ <%= success %></div> 
    <% } %>
    
    <div class="info-box">
        <strong>💡 Booking Tips:</strong>
        <ul style="margin-left: 20px; margin-top: 8px;">
            <li>Select your preferred room type below</li>
            <li>Choose check-in and check-out dates</li>
            <li>Your contact details are pre-filled from your account</li>
        </ul>
    </div>
    
    <form action="guestBookRoom" method="post">
        <label style="margin-bottom: 15px; display: block;">🏠 Select Room Type</label>
        <div class="room-types">
            <div class="room-card" onclick="selectRoom('Standard', 5000)">
                <div class="icon">🛏️</div>
                <h4>Standard</h4>
                <div class="price">LKR 5,000</div>
                <div class="desc">per night</div>
            </div>
            
            <div class="room-card" onclick="selectRoom('Deluxe', 8500)">
                <div class="icon">⭐</div>
                <h4>Deluxe</h4>
                <div class="price">LKR 8,500</div>
                <div class="desc">per night</div>
            </div>
            
            <div class="room-card" onclick="selectRoom('Suite', 15000)">
                <div class="icon">👑</div>
                <h4>Suite</h4>
                <div class="price">LKR 15,000</div>
                <div class="desc">per night</div>
            </div>
        </div>
        <input type="hidden" id="selectedRoomType" name="roomType" required>
        
        <div class="date-row">
            <div class="form-group">
                <label>📅 Check-in Date</label>
                <input type="date" id="checkIn" name="checkIn" required>
            </div>
            
            <div class="form-group">
                <label>📅 Check-out Date</label>
                <input type="date" id="checkOut" name="checkOut" required>
            </div>
        </div>
        
        <div class="form-group">
            <label>👤 Guest Name</label>
            <input type="text" name="guestName" value="<%= guest.getFullName() %>" readonly>
        </div>
        
        <div class="form-group">
            <label>📞 Contact Number</label>
            <input type="tel" name="phone" value="<%= guest.getPhone() != null ? guest.getPhone() : "" %>" 
                   placeholder="Enter your phone number" required pattern="[0-9]{10}" title="10 digit number">
        </div>
        
        <div class="form-group">
            <label>📍 Address</label>
            <input type="text" name="address" placeholder="Enter your address" required>
        </div>
        
        <div class="button-group">
            <a href="guest_dashboard.jsp" class="back-btn">← Back</a>
            <button type="submit">✓ Confirm Booking</button>
        </div>
    </form>
</div>

</body>
</html>
