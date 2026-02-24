<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.GuestUser" %>
<%
    GuestUser guest = (GuestUser) session.getAttribute("currentGuest");
    if(guest == null) {
        response.sendRedirect("guest_login.jsp");
        return;
    }
    
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Ocean View Resort</title>
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
            max-width: 800px;
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
        
        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease-out;
        }
        
        @keyframes slideIn {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .profile-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        
        .profile-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            padding: 40px 30px;
            text-align: center;
            color: white;
        }
        
        .avatar {
            width: 100px;
            height: 100px;
            background: rgba(255, 255, 255, 0.3);
            border: 4px solid white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            font-weight: 700;
            margin: 0 auto 20px;
            text-transform: uppercase;
        }
        
        .profile-header h2 {
            font-size: 28px;
            margin-bottom: 8px;
        }
        
        .profile-header .username {
            font-size: 16px;
            opacity: 0.9;
            margin-bottom: 15px;
        }
        
        .member-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255, 255, 255, 0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
        }
        
        .profile-body {
            padding: 40px 30px;
        }
        
        .mode-toggle {
            text-align: right;
            margin-bottom: 25px;
        }
        
        .btn-edit {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-edit:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .view-mode, .edit-mode {
            display: none;
        }
        
        .view-mode.active, .edit-mode.active {
            display: block;
        }
        
        .info-grid {
            display: grid;
            gap: 20px;
        }
        
        .info-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 20px;
            background: #f8f9ff;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        
        .info-item i {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        
        .info-content {
            flex: 1;
        }
        
        .info-label {
            font-size: 13px;
            color: #666;
            margin-bottom: 4px;
            font-weight: 500;
        }
        
        .info-value {
            font-size: 16px;
            color: #333;
            font-weight: 600;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group label i {
            color: #667eea;
            width: 20px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 15px;
            transition: border-color 0.3s, box-shadow 0.3s;
            font-family: 'Poppins', sans-serif;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .form-group input:disabled {
            background: #f5f5f5;
            cursor: not-allowed;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn-primary {
            flex: 1;
            padding: 14px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            flex: 1;
            padding: 14px;
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-secondary:hover {
            background: #667eea;
            color: white;
        }
        
        .help-text {
            font-size: 13px;
            color: #666;
            margin-top: 5px;
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                text-align: center;
            }
            
            .header h1 {
                font-size: 24px;
            }
            
            .profile-body {
                padding: 30px 20px;
            }
            
            .form-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-user-circle"></i> My Profile</h1>
            <a href="guest_dashboard.jsp" class="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
        
        <% if (successMsg != null) { %>
        <div class="alert alert-success" id="alertBox">
            <i class="fas fa-check-circle"></i>
            <span><%= successMsg %></span>
        </div>
        <% } %>
        
        <% if (errorMsg != null) { %>
        <div class="alert alert-error" id="alertBox">
            <i class="fas fa-exclamation-circle"></i>
            <span><%= errorMsg %></span>
        </div>
        <% } %>
        
        <div class="profile-card">
            <div class="profile-header">
                <div class="avatar">
                    <%= guest.getFullName().substring(0, 1).toUpperCase() %>
                </div>
                <h2><%= guest.getFullName() %></h2>
                <div class="username">@<%= guest.getUsername() %></div>
                <% if (guest.getRegisteredDate() != null) { %>
                <div class="member-badge">
                    <i class="fas fa-star"></i>
                    <span>Member since <%= guest.getRegisteredDate().toString().substring(0, 10) %></span>
                </div>
                <% } %>
            </div>
            
            <div class="profile-body">
                <div class="mode-toggle">
                    <button class="btn-edit" id="editBtn" onclick="toggleEditMode()">
                        <i class="fas fa-edit"></i> Edit Profile
                    </button>
                </div>
                
                <!-- View Mode -->
                <div class="view-mode active" id="viewMode">
                    <div class="info-grid">
                        <div class="info-item">
                            <i class="fas fa-user"></i>
                            <div class="info-content">
                                <div class="info-label">Full Name</div>
                                <div class="info-value"><%= guest.getFullName() %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <i class="fas fa-at"></i>
                            <div class="info-content">
                                <div class="info-label">Username</div>
                                <div class="info-value">@<%= guest.getUsername() %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <i class="fas fa-envelope"></i>
                            <div class="info-content">
                                <div class="info-label">Email Address</div>
                                <div class="info-value"><%= guest.getEmail() %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <i class="fas fa-phone"></i>
                            <div class="info-content">
                                <div class="info-label">Phone Number</div>
                                <div class="info-value"><%= guest.getPhone() %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <i class="fas fa-hashtag"></i>
                            <div class="info-content">
                                <div class="info-label">Account ID</div>
                                <div class="info-value">#<%= guest.getId() %></div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Edit Mode -->
                <div class="edit-mode" id="editMode">
                    <form action="updateProfile" method="post" onsubmit="return validateForm()">
                        <div class="form-group">
                            <label>
                                <i class="fas fa-user"></i>
                                Full Name
                            </label>
                            <input type="text" name="fullName" id="fullName" 
                                   value="<%= guest.getFullName() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label>
                                <i class="fas fa-at"></i>
                                Username
                            </label>
                            <input type="text" value="<%= guest.getUsername() %>" disabled>
                            <div class="help-text">
                                <i class="fas fa-info-circle"></i> Username cannot be changed
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>
                                <i class="fas fa-envelope"></i>
                                Email Address
                            </label>
                            <input type="email" name="email" id="email" 
                                   value="<%= guest.getEmail() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label>
                                <i class="fas fa-phone"></i>
                                Phone Number
                            </label>
                            <input type="tel" name="phone" id="phone" 
                                   value="<%= guest.getPhone() %>" 
                                   pattern="[0-9]{10,15}" required>
                            <div class="help-text">
                                <i class="fas fa-info-circle"></i> Enter 10-15 digits
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>
                                <i class="fas fa-lock"></i>
                                New Password (Optional)
                            </label>
                            <input type="password" name="password" id="password" 
                                   placeholder="Leave blank to keep current password">
                            <div class="help-text">
                                <i class="fas fa-info-circle"></i> Only fill if you want to change your password
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">
                                <i class="fas fa-save"></i> Save Changes
                            </button>
                            <button type="button" class="btn-secondary" onclick="toggleEditMode()">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Auto-dismiss alerts after 5 seconds
        const alertBox = document.getElementById('alertBox');
        if (alertBox) {
            setTimeout(() => {
                alertBox.style.transition = 'opacity 0.5s';
                alertBox.style.opacity = '0';
                setTimeout(() => alertBox.remove(), 500);
            }, 5000);
        }
        
        function toggleEditMode() {
            const viewMode = document.getElementById('viewMode');
            const editMode = document.getElementById('editMode');
            const editBtn = document.getElementById('editBtn');
            
            if (viewMode.classList.contains('active')) {
                viewMode.classList.remove('active');
                editMode.classList.add('active');
                editBtn.innerHTML = '<i class="fas fa-eye"></i> View Profile';
            } else {
                viewMode.classList.add('active');
                editMode.classList.remove('active');
                editBtn.innerHTML = '<i class="fas fa-edit"></i> Edit Profile';
            }
        }
        
        function validateForm() {
            const fullName = document.getElementById('fullName').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            
            if (fullName === '' || email === '' || phone === '') {
                alert('Please fill in all required fields');
                return false;
            }
            
            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert('Please enter a valid email address');
                return false;
            }
            
            // Phone validation
            const phoneRegex = /^[0-9]{10,15}$/;
            if (!phoneRegex.test(phone)) {
                alert('Phone number must be 10-15 digits');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>
