<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="java.util.List" %>
<%
    // RBAC: Only Admins
    User currentUser = (User) session.getAttribute("currentUser");
    if(currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("dashboard.jsp?error=Access Denied");
        return;
    }
    
    List<User> staffList = (List<User>) request.getAttribute("staffList");
    User staffToEdit = (User) request.getAttribute("staffToEdit");
    boolean isEditMode = (staffToEdit != null);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f5f7fa; }
        
        .topnav {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            max-width: 1200px;
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
        
        .card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }
        .card h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 24px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
        }
        .form-group label {
            color: #555;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .form-group input, .form-group select {
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .btn {
            padding: 12px 25px;
            border-radius: 6px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .btn-cancel {
            background: #ecf0f1;
            color: #2c3e50;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background: #f8f9fa;
            color: #555;
            font-weight: 600;
        }
        tr:hover {
            background: #f8f9fa;
        }
        
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-admin {
            background: #e74c3c;
            color: white;
        }
        .badge-receptionist {
            background: #3498db;
            color: white;
        }
        
        .action-btns {
            display: flex;
            gap: 8px;
        }
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }
        .btn-edit {
            background: #f39c12;
            color: white;
        }
        .btn-delete {
            background: #e74c3c;
            color: white;
        }
    </style>
    <script>
        function confirmDelete(userId, username) {
            if (confirm('Are you sure you want to delete user: ' + username + '?')) {
                window.location.href = 'manageUsers?action=delete&id=' + userId;
            }
        }
    </script>
</head>
<body>
    <div class="topnav">
        <div class="brand">👥 User Management</div>
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
        
        <!-- Add/Edit User Form -->
        <div class="card">
            <h2><%= isEditMode ? "📝 Edit Staff Member" : "➕ Add New Staff Member" %></h2>
            <form action="manageUsers" method="post">
                <input type="hidden" name="action" value="<%= isEditMode ? "update" : "add" %>">
                <% if(isEditMode) { %>
                    <input type="hidden" name="userId" value="<%= staffToEdit.getId() %>">
                <% } %>
                
                <div class="form-grid">
                    <% if(!isEditMode) { %>
                    <div class="form-group">
                        <label>Username <span style="color:red;">*</span></label>
                        <input type="text" name="username" required minlength="4">
                    </div>
                    
                    <div class="form-group">
                        <label>Password <span style="color:red;">*</span></label>
                        <input type="password" name="password" required minlength="6" placeholder="Minimum 6 characters">
                    </div>
                    <% } else { %>
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" value="<%= staffToEdit.getUsername() %>" disabled>
                    </div>
                    
                    <div class="form-group">
                        <label>New Password (leave blank to keep current)</label>
                        <input type="password" name="newPassword" minlength="6" placeholder="Enter new password or leave blank">
                    </div>
                    <% } %>
                    
                    <div class="form-group">
                        <label>Full Name <span style="color:red;">*</span></label>
                        <input type="text" name="fullName" required value="<%= isEditMode ? staffToEdit.getFullName() : "" %>">
                    </div>
                    
                    <div class="form-group">
                        <label>Role <span style="color:red;">*</span></label>
                        <select name="role" required>
                            <option value="Receptionist" <%= isEditMode && "Receptionist".equals(staffToEdit.getRole()) ? "selected" : "" %>>Receptionist</option>
                            <option value="Admin" <%= isEditMode && "Admin".equals(staffToEdit.getRole()) ? "selected" : "" %>>Admin</option>
                        </select>
                    </div>
                </div>
                
                <div style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary">
                        <%= isEditMode ? "💾 Update User" : "➕ Add User" %>
                    </button>
                    <% if(isEditMode) { %>
                        <a href="manageUsers" class="btn btn-cancel">Cancel</a>
                    <% } %>
                </div>
            </form>
        </div>
        
        <!-- User List -->
        <div class="card">
            <h2>📋 Staff Members (<%= staffList != null ? staffList.size() : 0 %>)</h2>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Role</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(staffList != null && !staffList.isEmpty()) {
                        for(User staff : staffList) {
                    %>
                    <tr>
                        <td><strong>#<%= staff.getId() %></strong></td>
                        <td><%= staff.getUsername() %></td>
                        <td><%= staff.getFullName() %></td>
                        <td>
                            <span class="badge badge-<%= staff.getRole().toLowerCase() %>">
                                <%= staff.getRole() %>
                            </span>
                        </td>
                        <td>
                            <div class="action-btns">
                                <a href="manageUsers?action=edit&id=<%= staff.getId() %>" class="btn btn-sm btn-edit">✏️ Edit</a>
                                <% if(staff.getId() != currentUser.getId()) { %>
                                    <button onclick="confirmDelete(<%= staff.getId() %>, '<%= staff.getUsername() %>')" class="btn btn-sm btn-delete">🗑️ Delete</button>
                                <% } else { %>
                                    <button class="btn btn-sm btn-secondary" disabled>You</button>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% 
                        }
                    } else { 
                    %>
                    <tr>
                        <td colspan="5" style="text-align:center; color:#999;">No staff members found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
