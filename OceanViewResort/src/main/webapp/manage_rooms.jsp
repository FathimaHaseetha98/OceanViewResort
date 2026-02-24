<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    // RBAC: Only Admins
    User currentUser = (User) session.getAttribute("currentUser");
    if(currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("dashboard.jsp?error=Access Denied");
        return;
    }
    
    List<Map<String, Object>> rooms = (List<Map<String, Object>>) request.getAttribute("rooms");
    List<Map<String, Object>> roomTypes = (List<Map<String, Object>>) request.getAttribute("roomTypes");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Rooms - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f5f7fa; }
        
        .topnav {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            padding: 15px 30px;
            color: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .topnav .brand { font-size: 20px; font-weight: bold; }
        .topnav .back-btn {
            background: rgba(255,255,255,0.2);
            padding: 8px 15px;
            border-radius: 5px;
            text-decoration: none;
            color: white;
        }
        
        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
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
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .card h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 22px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            color: #555;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #11998e;
        }
        
        .btn {
            padding: 12px 25px;
            border-radius: 6px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(17, 153, 142, 0.4);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background: #f8f9fa;
            color: #555;
            font-weight: 600;
            font-size: 13px;
        }
        tr:hover {
            background: #f8f9fa;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }
        .btn-delete {
            background: #e74c3c;
            color: white;
        }
        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-standard {
            background: #d1ecf1;
            color: #0c5460;
        }
        .badge-deluxe {
            background: #d4edda;
            color: #155724;
        }
        .badge-suite {
            background: #fff3cd;
            color: #856404;
        }
    </style>
    <script>
        function confirmDeleteRoom(roomNumber) {
            if (confirm('Are you sure you want to delete room: ' + roomNumber + '?')) {
                window.location.href = 'manageRooms?action=deleteRoom&id=' + roomNumber;
            }
        }
        
        function confirmDeleteType(typeId, typeName) {
            if (confirm('Are you sure you want to delete room type: ' + typeName + '?\nThis will fail if rooms are using this type.')) {
                window.location.href = 'manageRooms?action=deleteType&id=' + typeId;
            }
        }
    </script>
</head>
<body>
    <div class="topnav">
        <div class="brand">🏨 Room Management</div>
        <a href="admin_dashboard.jsp" class="back-btn">← Back to Admin Panel</a>
    </div>

    <div class="container">
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
        
        <div class="grid">
            <!-- Add Room -->
            <div class="card">
                <h2>➕ Add New Room</h2>
                <form action="manageRooms" method="post">
                    <input type="hidden" name="action" value="addRoom">
                    
                    <div class="form-group">
                        <label>Room Number <span style="color:red;">*</span></label>
                        <input type="text" name="roomNumber" required placeholder="e.g., 101, 202, 305">
                    </div>
                    
                    <div class="form-group">
                        <label>Room Type <span style="color:red;">*</span></label>
                        <select name="roomType" required>
                            <option value="">-- Select Type --</option>
                            <% if(roomTypes != null) {
                                for(Map<String, Object> type : roomTypes) {
                            %>
                                <option value="<%= type.get("type_name") %>">
                                    <%= type.get("type_name") %> (LKR <%= type.get("price_per_night") %>/night)
                                </option>
                            <% 
                                }
                            } %>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">➕ Add Room</button>
                </form>
            </div>
            
            <!-- Add Room Type -->
            <div class="card">
                <h2>🏷️ Add New Room Type</h2>
                <form action="manageRooms" method="post">
                    <input type="hidden" name="action" value="addType">
                    
                    <div class="form-group">
                        <label>Type Name <span style="color:red;">*</span></label>
                        <input type="text" name="typeName" required placeholder="e.g., Standard, Deluxe, Suite">
                    </div>
                    
                    <div class="form-group">
                        <label>Price Per Night (LKR) <span style="color:red;">*</span></label>
                        <input type="number" name="price" required step="0.01" min="0" placeholder="e.g., 5000.00">
                    </div>
                    
                    <button type="submit" class="btn btn-primary">➕ Add Type</button>
                </form>
            </div>
        </div>
        
        <!-- Room Types List -->
        <div class="card" style="margin-bottom: 30px;">
            <h2>🏷️ Room Types (<%= roomTypes != null ? roomTypes.size() : 0 %>)</h2>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type Name</th>
                        <th>Price Per Night (LKR)</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(roomTypes != null && !roomTypes.isEmpty()) {
                        for(Map<String, Object> type : roomTypes) {
                    %>
                    <tr>
                        <td><strong>#<%= type.get("type_id") %></strong></td>
                        <td><%= type.get("type_name") %></td>
                        <td>LKR <%= String.format("%,.2f", (Double)type.get("price_per_night")) %></td>
                        <td>
                            <button onclick="confirmDeleteType(<%= type.get("type_id") %>, '<%= type.get("type_name") %>')" class="btn btn-sm btn-delete">🗑️ Delete</button>
                        </td>
                    </tr>
                    <% 
                        }
                    } else { 
                    %>
                    <tr>
                        <td colspan="4" style="text-align:center; color:#999;">No room types found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Rooms List -->
        <div class="card">
            <h2>🏨 All Rooms (<%= rooms != null ? rooms.size() : 0 %>)</h2>
            <table>
                <thead>
                    <tr>
                        <th>Room Number</th>
                        <th>Type</th>
                        <th>Price Per Night</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(rooms != null && !rooms.isEmpty()) {
                        for(Map<String, Object> room : rooms) {
                            String roomType = (String) room.get("room_type");
                            String badgeClass = "standard";
                            if(roomType != null) {
                                if(roomType.toLowerCase().contains("deluxe")) badgeClass = "deluxe";
                                else if(roomType.toLowerCase().contains("suite")) badgeClass = "suite";
                            }
                    %>
                    <tr>
                        <td><strong><%= room.get("room_number") %></strong></td>
                        <td>
                            <span class="badge badge-<%= badgeClass %>">
                                <%= room.get("room_type") %>
                            </span>
                        </td>
                        <td>LKR <%= String.format("%,.2f", (Double)room.get("price_per_night")) %></td>
                        <td>
                            <button onclick="confirmDeleteRoom('<%= room.get("room_number") %>')" class="btn btn-sm btn-delete">🗑️ Delete</button>
                        </td>
                    </tr>
                    <% 
                        }
                    } else { 
                    %>
                    <tr>
                        <td colspan="4" style="text-align:center; color:#999;">No rooms found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
