<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    // Security: Only staff and admin can access help
    User currentUser = (User) session.getAttribute("currentUser");
    if(currentUser == null) {
        response.sendRedirect("stafflogin.jsp?error=Please login to continue");
        return;
    }
    
    String role = currentUser.getRole();
    if(!"Receptionist".equalsIgnoreCase(role) && !"Admin".equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    boolean isAdmin = "Admin".equalsIgnoreCase(role);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Help & User Guide - Ocean View Resort</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 30px 20px;
        }
        
        .container { 
            max-width: 1200px; 
            margin: auto; 
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            animation: slideUp 0.5s ease-out;
        }
        
        @keyframes slideUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        .header {
            background: linear-gradient(135deg, <%= isAdmin ? "#e74c3c 0%, #c0392b 100%" : "#667eea 0%, #764ba2 100%" %>);
            color: white;
            padding: 40px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 36px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }
        
        .header p {
            font-size: 16px;
            opacity: 0.95;
        }
        
        .role-badge {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            padding: 8px 20px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: bold;
            margin-top: 15px;
        }
        
        .content {
            padding: 40px;
        }
        
        .back-btn { 
            display: inline-block; 
            padding: 12px 25px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; 
            text-decoration: none; 
            border-radius: 10px;
            font-weight: 600;
            margin-bottom: 30px;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        
        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        
        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            border-bottom: 2px solid #e0e0e0;
            flex-wrap: wrap;
        }
        
        .tab {
            padding: 15px 25px;
            cursor: pointer;
            border: none;
            background: none;
            font-size: 15px;
            font-weight: 600;
            color: #7f8c8d;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }
        
        .tab:hover {
            color: #667eea;
        }
        
        .tab.active {
            color: #667eea;
            border-bottom-color: #667eea;
        }
        
        .tab-content {
            display: none;
            animation: fadeIn 0.4s;
        }
        
        .tab-content.active {
            display: block;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        h2 {
            color: #2c3e50;
            font-size: 28px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        h3 { 
            color: #667eea; 
            margin-top: 30px;
            margin-bottom: 15px;
            font-size: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .workflow-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 20px;
            transition: all 0.3s;
        }
        
        .workflow-card:hover {
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            transform: translateX(5px);
        }
        
        .workflow-card h4 {
            color: #2c3e50;
            margin-bottom: 15px;
            font-size: 18px;
        }
        
        .step { 
            background: white;
            padding: 18px 20px; 
            border-radius: 8px;
            margin-bottom: 12px;
            border-left: 3px solid #3498db;
            transition: all 0.3s;
        }
        
        .step:hover {
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transform: translateX(3px);
        }
        
        .step strong {
            color: #3498db;
            display: block;
            margin-bottom: 5px;
        }
        
        .note { 
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px 20px;
            border-radius: 8px;
            margin: 20px 0;
            font-size: 14px;
            color: #856404;
        }
        
        .tip {
            background: #d1ecf1;
            border-left: 4px solid #17a2b8;
            padding: 15px 20px;
            border-radius: 8px;
            margin: 20px 0;
            font-size: 14px;
            color: #0c5460;
        }
        
        .warning {
            background: #f8d7da;
            border-left: 4px solid #dc3545;
            padding: 15px 20px;
            border-radius: 8px;
            margin: 20px 0;
            font-size: 14px;
            color: #721c24;
        }
        
        .success {
            background: #d4edda;
            border-left: 4px solid #28a745;
            padding: 15px 20px;
            border-radius: 8px;
            margin: 20px 0;
            font-size: 14px;
            color: #155724;
        }
        
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .feature-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            border: 2px solid #e0e0e0;
            transition: all 0.3s;
        }
        
        .feature-card:hover {
            border-color: #667eea;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.2);
        }
        
        .feature-card .icon {
            font-size: 36px;
            margin-bottom: 15px;
        }
        
        .feature-card h4 {
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 18px;
        }
        
        .feature-card p {
            color: #7f8c8d;
            line-height: 1.6;
            font-size: 14px;
        }
        
        ul {
            margin-left: 20px;
            line-height: 1.8;
            color: #2c3e50;
        }
        
        code {
            background: #2c3e50;
            color: #fff;
            padding: 2px 8px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
        }
    </style>
    <script>
        function showTab(tabName) {
            // Hide all tab contents
            const contents = document.querySelectorAll('.tab-content');
            contents.forEach(content => content.classList.remove('active'));
            
            // Deactivate all tabs
            const tabs = document.querySelectorAll('.tab');
            tabs.forEach(tab => tab.classList.remove('active'));
            
            // Show selected tab content
            document.getElementById(tabName).classList.add('active');
            
            // Activate selected tab
            event.target.classList.add('active');
        }
        
        // Show first tab on load
        window.onload = function() {
            document.querySelector('.tab').classList.add('active');
            document.querySelector('.tab-content').classList.add('active');
        };
    </script>
</head>
<body>

<div class="container">
    <div class="header">
        <h1>
            <span>📚</span>
            Help & User Guide
        </h1>
        <p>Complete guide to using the Ocean View Resort Management System</p>
        <div class="role-badge">
            <%= isAdmin ? "👑 ADMINISTRATOR GUIDE" : "🌊 STAFF GUIDE" %>
        </div>
    </div>
    
    <div class="content">
        <a href="<%= isAdmin ? "admin_dashboard.jsp" : "dashboard.jsp" %>" class="back-btn">← Back to Dashboard</a>
        
        <% if(isAdmin) { %>
        <!-- ADMIN HELP CONTENT -->
        <div class="tabs">
            <button class="tab" onclick="showTab('overview')">🏠 Overview</button>
            <button class="tab" onclick="showTab('staff-mgmt')">👥 Staff Management</button>
            <button class="tab" onclick="showTab('room-mgmt')">🏨 Room Management</button>
            <button class="tab" onclick="showTab('reports')">📊 Reports</button>
            <button class="tab" onclick="showTab('security')">🔒 Security</button>
        </div>
        
        <div id="overview" class="tab-content">
            <h2>🏠 System Overview</h2>
            <p>As an administrator, you have full access to all system features and management capabilities.</p>
            
            <div class="feature-grid">
                <div class="feature-card">
                    <div class="icon">👥</div>
                    <h4>Staff Management</h4>
                    <p>Create, edit, and manage staff accounts. Control access permissions and monitor staff activities.</p>
                </div>
                <div class="feature-card">
                    <div class="icon">🏨</div>
                    <h4>Room Management</h4>
                    <p>Manage room inventory, pricing, and availability. Update room types and amenities.</p>
                </div>
                <div class="feature-card">
                    <div class="icon">📋</div>
                    <h4>Reservation Oversight</h4>
                    <p>View all reservations, generate reports, and monitor booking patterns.</p>
                </div>
                <div class="feature-card">
                    <div class="icon">📊</div>
                    <h4>Analytics & Reports</h4>
                    <p>Access comprehensive reports on revenue, occupancy rates, and system performance.</p>
                </div>
            </div>
            
            <div class="success">
                <strong>✅ Admin Privileges:</strong> You can perform all operations that staff can do, plus administrative functions.
            </div>
        </div>
        
        <div id="staff-mgmt" class="tab-content">
            <h2>👥 Staff Management</h2>
            
            <div class="workflow-card">
                <h4>Adding New Staff Members</h4>
                <div class="step">
                    <strong>Step 1:</strong> Click "Manage Users" on your dashboard.
                </div>
                <div class="step">
                    <strong>Step 2:</strong> Click "Add New User" button.
                </div>
                <div class="step">
                    <strong>Step 3:</strong> Fill in staff details (username, password, full name, email).
                </div>
                <div class="step">
                    <strong>Step 4:</strong> Select role: <code>Admin</code> or <code>Receptionist</code>.
                </div>
                <div class="step">
                    <strong>Step 5:</strong> Click "Create User" to save.
                </div>
            </div>
            
            <div class="workflow-card">
                <h4>Editing Staff Information</h4>
                <div class="step">
                    <strong>Step 1:</strong> Go to "Manage Users" page.
                </div>
                <div class="step">
                    <strong>Step 2:</strong> Locate the staff member in the list.
                </div>
                <div class="step">
                    <strong>Step 3:</strong> Click the "Edit" button next to their name.
                </div>
                <div class="step">
                    <strong>Step 4:</strong> Update necessary information.
                </div>
                <div class="step">
                    <strong>Step 5:</strong> Click "Update User" to save changes.
                </div>
            </div>
            
            <div class="warning">
                <strong>⚠️ Important:</strong> Be careful when changing user roles or deleting accounts. These actions cannot be undone.
            </div>
            
            <h3>🔐 Role Descriptions</h3>
            <ul>
                <li><strong>Admin:</strong> Full system access, can manage staff, rooms, view all reports, and perform all operations.</li>
                <li><strong>Receptionist:</strong> Can create reservations, view bookings, generate bills, but cannot manage staff or rooms.</li>
            </ul>
        </div>
        
        <div id="room-mgmt" class="tab-content">
            <h2>🏨 Room Management</h2>
            
            <div class="workflow-card">
                <h4>Managing Room Inventory</h4>
                <div class="step">
                    <strong>Step 1:</strong> Click "Manage Rooms" on your dashboard.
                </div>
                <div class="step">
                    <strong>Step 2:</strong> View all rooms with their types, prices, and current status.
                </div>
                <div class="step">
                    <strong>Step 3:</strong> Use the edit feature to update room details or pricing.
                </div>
            </div>
            
            <h3>💰 Room Types & Pricing</h3>
            <ul>
                <li><strong>Standard Rooms (101-103):</strong> LKR 5,000 per night</li>
                <li><strong>Deluxe Rooms (201-202):</strong> LKR 8,500 per night</li>
                <li><strong>Suite Rooms (301):</strong> LKR 15,000 per night</li>
            </ul>
            
            <div class="tip">
                <strong>💡 Tip:</strong> Regularly check room availability to ensure accurate booking information.
            </div>
        </div>
        
        <div id="reports" class="tab-content">
            <h2>📊 Reports & Analytics</h2>
            
            <div class="workflow-card">
                <h4>Accessing Reports</h4>
                <div class="step">
                    <strong>Step 1:</strong> Click "Reports" on your dashboard.
                </div>
                <div class="step">
                    <strong>Step 2:</strong> Select the type of report you want to view.
                </div>
                <div class="step">
                    <strong>Step 3:</strong> Apply date filters if needed.
                </div>
                <div class="step">
                    <strong>Step 4:</strong> Export or print the report as required.
                </div>
            </div>
            
            <h3>📈 Available Reports</h3>
            <ul>
                <li><strong>Revenue Reports:</strong> Track total earnings by date range</li>
                <li><strong>Occupancy Reports:</strong> Monitor room utilization rates</li>
                <li><strong>Booking Reports:</strong> View all reservations with filters</li>
                <li><strong>Staff Activity:</strong> Monitor system usage by staff members</li>
            </ul>
        </div>
        
        <div id="security" class="tab-content">
            <h2>🔒 Security Best Practices</h2>
            
            <div class="warning">
                <strong>⚠️ Security Guidelines:</strong>
                <ul style="margin-top: 10px;">
                    <li>Never share your admin credentials with anyone</li>
                    <li>Always logout when leaving your workstation</li>
                    <li>Use strong passwords with letters, numbers, and symbols</li>
                    <li>Review audit logs regularly for suspicious activity</li>
                    <li>Change passwords every 90 days</li>
                </ul>
            </div>
            
            <h3>🔍 Audit Logging</h3>
            <p>All admin actions are logged for security purposes. This includes:</p>
            <ul>
                <li>User account creation and modifications</li>
                <li>Login attempts (successful and failed)</li>
                <li>Room and pricing changes</li>
                <li>Report access</li>
            </ul>
        </div>
        
        <% } else { %>
        <!-- STAFF HELP CONTENT -->
        <div class="tabs">
            <button class="tab" onclick="showTab('overview')">🏠 Overview</button>
            <button class="tab" onclick="showTab('reservations')">📋 Reservations</button>
            <button class="tab" onclick="showTab('billing')">💰 Billing</button>
            <button class="tab" onclick="showTab('tips')">💡 Tips</button>
        </div>
        
        <div id="overview" class="tab-content">
            <h2>🏠 Staff Dashboard Overview</h2>
            <p>Welcome to the Ocean View Resort Management System. As a receptionist, you can manage guest reservations and handle check-ins/check-outs.</p>
            
            <div class="feature-grid">
                <div class="feature-card">
                    <div class="icon">📋</div>
                    <h4>Make Reservations</h4>
                    <p>Create new bookings for guests with automatic room availability checking.</p>
                </div>
                <div class="feature-card">
                    <div class="icon">👀</div>
                    <h4>View Bookings</h4>
                    <p>Access all current and past reservations with search functionality.</p>
                </div>
                <div class="feature-card">
                    <div class="icon">🖨️</div>
                    <h4>Generate Bills</h4>
                    <p>Create and print professional invoices for guest payments.</p>
                </div>
                <div class="feature-card">
                    <div class="icon">📊</div>
                    <h4>Quick Stats</h4>
                    <p>View important metrics about current occupancy and bookings.</p>
                </div>
            </div>
            
            <div class="success">
                <strong>✅ Your Role:</strong> You are responsible for managing day-to-day reservations and providing excellent guest service.
            </div>
        </div>
        
        <div id="reservations" class="tab-content">
            <h2>📋 Managing Reservations</h2>
            
            <div class="workflow-card">
                <h4>Creating a New Reservation</h4>
                <div class="step">
                    <strong>Step 1:</strong> Click "Add New Reservation" on the dashboard.
                </div>
                <div class="step">
                    <strong>Step 2:</strong> Enter guest details:
                    <ul style="margin-top: 8px;">
                        <li>Full Name</li>
                        <li>Complete Address</li>
                        <li>10-digit Contact Number (e.g., 0771234567)</li>
                    </ul>
                </div>
                <div class="step">
                    <strong>Step 3:</strong> Select a <strong>specific room</strong> from the dropdown menu.
                </div>
                <div class="step">
                    <strong>Step 4:</strong> Choose check-in and check-out dates (check-in cannot be in the past).
                </div>
                <div class="step">
                    <strong>Step 5:</strong> Click "Confirm Booking". The system will automatically:
                    <ul style="margin-top: 8px;">
                        <li>Check room availability for selected dates</li>
                        <li>Calculate total bill based on number of nights</li>
                        <li>Create the reservation if room is available</li>
                    </ul>
                </div>
            </div>
            
            <div class="note">
                <strong>📝 Note:</strong> If a room is already booked for the selected dates, you'll receive an error message. Try selecting a different room or different dates.
            </div>
            
            <div class="workflow-card">
                <h4>Viewing Existing Reservations</h4>
                <div class="step">
                    <strong>Step 1:</strong> Click "View Reservations" on the dashboard.
                </div>
                <div class="step">
                    <strong>Step 2:</strong> Use the search box to quickly find specific bookings by:
                    <ul style="margin-top: 8px;">
                        <li>Guest name</li>
                        <li>Room number</li>
                        <li>Booking ID</li>
                    </ul>
                </div>
                <div class="step">
                    <strong>Step 3:</strong> View complete booking details in the table.
                </div>
            </div>
            
            <h3>🏠 Available Rooms</h3>
            <ul>
                <li><strong>Standard Rooms:</strong> 101, 102, 103 (LKR 5,000/night)</li>
                <li><strong>Deluxe Rooms:</strong> 201, 202 (LKR 8,500/night)</li>
                <li><strong>Suite Rooms:</strong> 301 (LKR 15,000/night)</li>
            </ul>
        </div>
        
        <div id="billing" class="tab-content">
            <h2>💰 Billing & Invoices</h2>
            
            <div class="workflow-card">
                <h4>Generating Guest Bills</h4>
                <div class="step">
                    <strong>Step 1:</strong> Navigate to "View Reservations".
                </div>
                <div class="step">
                    <strong>Step 2:</strong> Locate the guest's booking in the table.
                </div>
                <div class="step">
                    <strong>Step 3:</strong> Click the green <code>Print Bill</code> button in the Action column.
                </div>
                <div class="step">
                    <strong>Step 4:</strong> A professional PDF invoice will open in a new tab.
                </div>
                <div class="step">
                    <strong>Step 5:</strong> You can:
                    <ul style="margin-top: 8px;">
                        <li>Print the invoice directly</li>
                        <li>Save it as a PDF for records</li>
                        <li>Email it to the guest</li>
                    </ul>
                </div>
            </div>
            
            <h3>📄 Invoice Contents</h3>
            <p>Each invoice automatically includes:</p>
            <ul>
                <li>Hotel logo and contact information</li>
                <li>Guest details and booking ID</li>
                <li>Room type and number</li>
                <li>Check-in and check-out dates</li>
                <li>Number of nights stayed</li>
                <li>Nightly rate and total amount</li>
                <li>Date of invoice generation</li>
            </ul>
            
            <div class="tip">
                <strong>💡 Pro Tip:</strong> Generate bills at check-out time to ensure accurate billing information.
            </div>
        </div>
        
        <div id="tips" class="tab-content">
            <h2>💡 Tips & Best Practices</h2>
            
            <div class="success">
                <strong>✅ Daily Workflow:</strong>
                <ol style="margin-top: 10px; margin-left: 20px; line-height: 2;">
                    <li>Log in to the staff portal at the start of your shift</li>
                    <li>Check the dashboard for today's check-ins and check-outs</li>
                    <li>Process new reservations as guests arrive</li>
                    <li>Generate bills for guests checking out</li>
                    <li>Log out at the end of your shift</li>
                </ol>
            </div>
            
            <h3>⚡ Quick Tips</h3>
            <ul>
                <li><strong>Double-check dates:</strong> Always verify check-in and check-out dates with the guest before confirming</li>
                <li><strong>Room availability:</strong> If a room is unavailable, the system will notify you immediately</li>
                <li><strong>Guest information:</strong> Ensure all guest details are accurate for proper record-keeping</li>
                <li><strong>Contact numbers:</strong> Enter 10-digit numbers without spaces or dashes</li>
                <li><strong>Search feature:</strong> Use the search box in View Reservations to quickly find bookings</li>
            </ul>
            
            <div class="warning">
                <strong>⚠️ Common Mistakes to Avoid:</strong>
                <ul style="margin-top: 10px;">
                    <li>Don't book a room that's already occupied for the dates</li>
                    <li>Don't enter check-out date before check-in date</li>
                    <li>Don't use special characters in phone numbers</li>
                    <li>Don't forget to log out when leaving your workstation</li>
                </ul>
            </div>
            
            <h3>❓ Need More Help?</h3>
            <p>If you encounter any issues or need assistance:</p>
            <ul>
                <li>Contact your supervisor or administrator</li>
                <li>Check the error messages displayed on screen - they usually explain what went wrong</li>
                <li>Refer back to this help guide for step-by-step instructions</li>
            </ul>
        </div>
        <% } %>
    </div>
</div>

</body>
</html>
