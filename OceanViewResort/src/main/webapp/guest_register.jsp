<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Guest Registration - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 500px;
        }
        .logo {
            text-align: center;
            color: #667eea;
            font-size: 28px;
            margin-bottom: 10px;
            font-weight: bold;
        }
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: 500;
        }
        input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            transition: border 0.3s;
        }
        input:focus {
            outline: none;
            border-color: #667eea;
        }
        .divider {
            margin: 25px 0;
            border-top: 2px solid #eee;
            position: relative;
        }
        .divider span {
            position: absolute;
            top: -12px;
            left: 50%;
            transform: translateX(-50%);
            background: white;
            padding: 0 10px;
            color: #999;
            font-size: 13px;
        }
        button {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.3s;
        }
        button:hover {
            transform: translateY(-2px);
        }
        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
            text-align: center;
        }
        .alert-error {
            background: #fee;
            color: #c33;
            border: 1px solid #fcc;
        }
        .alert-success {
            background: #efe;
            color: #3c3;
            border: 1px solid #cfc;
        }
        .links {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .links a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }
        .links a:hover {
            text-decoration: underline;
        }
        .required {
            color: #e74c3c;
        }
    </style>
    <script>
        function validateForm() {
            var password = document.getElementById("password").value;
            var phone = document.getElementById("phone").value;
            
            if (password.length < 6) {
                alert("Password must be at least 6 characters long!");
                return false;
            }
            
            if (phone.length < 10) {
                alert("Please enter a valid phone number!");
                return false;
            }
            
            return true;
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="logo">🌊 Ocean View Resort</div>
        <h2>Create Your Guest Account</h2>
        
        <% 
            String error = request.getParameter("error");
            String msg = request.getParameter("msg");
            
            if (error != null) {
                String errorMsg = "Registration failed. Please try again.";
                if ("exists".equals(error)) {
                    errorMsg = "Username or email already exists!";
                }
        %>
            <div class="alert alert-error"><%= errorMsg %></div>
        <% } %>
        
        <% if (msg != null) { %>
            <div class="alert alert-success"><%= msg %></div>
        <% } %>
        
        <form action="guestRegister" method="post" onsubmit="return validateForm()">
            <div class="form-group">
                <label>Full Name <span class="required">*</span></label>
                <input type="text" name="fullName" placeholder="Enter your full name" required>
            </div>
            
            <div class="form-group">
                <label>Email Address <span class="required">*</span></label>
                <input type="email" id="email" name="email" placeholder="your.email@example.com" required>
            </div>
            
            <div class="form-group">
                <label>Phone Number <span class="required">*</span></label>
                <input type="tel" id="phone" name="phone" placeholder="+94 XX XXX XXXX" required>
            </div>
            
            <div class="divider">
                <span>Login Credentials</span>
            </div>
            
            <div class="form-group">
                <label>Username <span class="required">*</span></label>
                <input type="text" name="username" placeholder="Choose a unique username" required minlength="4">
            </div>
            
            <div class="form-group">
                <label>Password <span class="required">*</span></label>
                <input type="password" id="password" name="password" placeholder="Minimum 6 characters" required minlength="6">
            </div>
            
            <button type="submit">Register Now</button>
        </form>
        
        <div class="links">
            Already have an account? <a href="guest_login.jsp">Login here</a><br>
            <a href="index.jsp">← Back to Home</a>
        </div>
    </div>
</body>
</html>
