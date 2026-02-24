<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Staff Login - Ocean View Resort</title>
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
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 420px;
        }
        .logo {
            text-align: center;
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
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
        .alert-error {
            background: #fee;
            color: #c33;
            border: 1px solid #fcc;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
            text-align: center;
        }
        .divider {
            margin: 25px 0;
            text-align: center;
            border-top: 1px solid #eee;
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
            font-size: 14px;
        }
        .links {
            text-align: center;
            margin-top: 20px;
        }
        .links a {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
        }
        .links a:hover {
            text-decoration: underline;
        }
        .staff-badge {
            background: #667eea;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            display: inline-block;
            font-size: 12px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="logo">🌊</div>
    <h2>Staff Portal</h2>
    <div style="text-align: center;">
        <span class="staff-badge">STAFF LOGIN</span>
    </div>
    
    <% 
        String error = (String) request.getAttribute("errorMessage");
        if(error != null) { 
    %>
        <div class="alert-error"><%= error %></div>
    <% } %>
    
    <% 
        String msg = request.getParameter("msg");
        if(msg != null) { 
    %>
        <div class="alert-success" style="background: #efe; color: #3c3; border: 1px solid #cfc; padding: 12px; margin-bottom: 20px; border-radius: 6px; text-align: center;">
            ✅ <%= msg %>
        </div>
    <% } %>

    <form action="staffLogin" method="post">
        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username" required autofocus>
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Enter your password" required>
        </div>
        <button type="submit">Sign In to Staff Portal</button>
    </form>

    <div class="divider">
        <span>OR</span>
    </div>

    <div class="links">
        <a href="index.jsp">← Back to Home</a> |
        <a href="adminlogin.jsp">Admin Login</a>
    </div>
</div>

</body>
</html>
