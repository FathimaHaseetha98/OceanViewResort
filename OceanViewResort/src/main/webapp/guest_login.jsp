<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Guest Login - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #2193b0 0%, #6dd5ed 100%);
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
            max-width: 420px;
        }
        .logo {
            text-align: center;
            color: #2193b0;
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
            border-color: #2193b0;
        }
        button {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #2193b0 0%, #6dd5ed 100%);
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
        .alert-success {
            background: #efe;
            color: #3c3;
            border: 1px solid #cfc;
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
            font-size: 13px;
        }
        .links {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .links a {
            color: #2193b0;
            text-decoration: none;
            font-weight: 500;
        }
        .links a:hover {
            text-decoration: underline;
        }
        .info-box {
            background: #f0f8ff;
            border-left: 4px solid #2193b0;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .info-box p {
            margin: 5px 0;
            color: #555;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🌊 Ocean View Resort</div>
        <h2>Guest Portal Login</h2>
        
        <% if(request.getParameter("error") != null) { %>
            <div class="alert-error">
                ❌ Invalid username or password. Please try again.
            </div>
        <% } %>
        
        <% if(request.getParameter("msg") != null) { %>
            <div class="alert-success">
                ✅ <%= request.getParameter("msg") %>
            </div>
        <% } %>
        
        <% if(request.getParameter("logout") != null) { %>
            <div class="alert-success">
                ✅ You have been logged out successfully.
            </div>
        <% } %>
        
        <div class="info-box">
            <p>📌 <strong>Guest Portal Features:</strong></p>
            <p>• View your reservations</p>
            <p>• Book new rooms online</p>
            <p>• Access your booking history</p>
        </div>
        
        <form action="guestLogin" method="post">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" placeholder="Enter your username" required autofocus>
            </div>
            
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="Enter your password" required>
            </div>
            
            <button type="submit">Login to Guest Portal</button>
        </form>
        
        <div class="divider">
            <span>New to Ocean View Resort?</span>
        </div>
        
        <div class="links">
            <p>Don't have an account? <a href="guest_register.jsp"><strong>Register here</strong></a></p>
            <p style="margin-top: 15px;"><a href="index.jsp">← Back to Home</a></p>
        </div>
    </div>
</body>
</html>
