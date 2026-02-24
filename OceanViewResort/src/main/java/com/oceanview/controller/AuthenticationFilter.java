package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.oceanview.model.User;

/**
 * Enhanced Authentication Filter
 * Supports both Staff and Guest portals with proper access control
 * Demonstrates SECURITY best practices and RBAC (Role-Based Access Control)
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        // 1. CACHE CONTROL (Prevents back button issue after logout)
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies

        // 2. Get request URI
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        
        // 3. Define PUBLIC pages (accessible without login)
        boolean isPublicPage = uri.endsWith("index.jsp") ||
                              uri.endsWith("guest_login.jsp") ||
                              uri.endsWith("guest_register.jsp") ||
                              uri.endsWith("adminlogin.jsp") ||
                              uri.endsWith("stafflogin.jsp") ||
                              uri.endsWith("login.jsp") ||
                              uri.contains("/guestLogin") ||
                              uri.contains("/guestRegister") ||
                              uri.contains("/adminLogin") ||
                              uri.contains("/staffLogin") ||
                              uri.contains("/login") ||
                              uri.contains("/css/") ||
                              uri.contains("/js/") ||
                              uri.contains("/images/");
        
        // 4. Define GUEST-ONLY pages (CHECK FIRST to avoid conflicts with dashboard.jsp)
        boolean isGuestPage = uri.endsWith("guest_dashboard.jsp") ||
                             uri.endsWith("guest_book_room.jsp") ||
                             uri.endsWith("guest_my_bookings.jsp") ||
                             uri.endsWith("guest_profile.jsp") ||
                             uri.contains("/guestBookRoom") ||
                             uri.contains("/guestBooking") ||
                             uri.contains("/updateProfile");
        
        // 4.5. Define ADMIN-ONLY pages
        boolean isAdminPage = uri.endsWith("admin_dashboard.jsp") ||
                             uri.endsWith("manage_users.jsp") ||
                             uri.endsWith("manage_rooms.jsp") ||
                             uri.contains("/manageUsers") ||
                             uri.contains("/manageRooms");
        
        // 5. Define STAFF-ONLY pages (both Staff and Admin can access)
        // NOTE: Check this AFTER guest pages to avoid conflicts with guest_dashboard.jsp
        boolean isStaffPage = (uri.endsWith("dashboard.jsp") && !uri.endsWith("guest_dashboard.jsp") && !uri.endsWith("admin_dashboard.jsp")) ||
                             uri.endsWith("reservation_form.jsp") ||
                             uri.endsWith("view_reservations.jsp") ||
                             uri.endsWith("reports.jsp") ||
                             uri.contains("/reservation") ||
                             uri.contains("/addReservation") ||
                             uri.contains("/viewReservations") ||
                             uri.contains("/bill") ||
                             uri.contains("/generateBill") ||
                             uri.contains("/report") ||
                             uri.contains("/viewReports") ||
                             uri.endsWith("help.jsp");
        
        // 6. Check login status
        boolean staffLoggedIn = (session != null && session.getAttribute("currentUser") != null);
        boolean guestLoggedIn = (session != null && session.getAttribute("currentGuest") != null);
        
        // 7. AUTHORIZATION LOGIC
        
        // Allow public pages
        if (isPublicPage) {
            chain.doFilter(request, response);
            return;
        }
        
        // Guest pages - require guest login (CHECK FIRST to avoid dashboard.jsp conflicts)
        if (isGuestPage) {
            if (guestLoggedIn) {
                chain.doFilter(request, response);
            } else {
                response.sendRedirect(contextPath + "/guest_login.jsp?error=Please login to continue");
            }
            return;
        }
        
        // Admin pages - require admin login with proper role
        if (isAdminPage) {
            if (staffLoggedIn) {
                User user = (User) session.getAttribute("currentUser");
                if ("Admin".equalsIgnoreCase(user.getRole())) {
                    chain.doFilter(request, response);
                } else {
                    response.sendRedirect(contextPath + "/dashboard.jsp?error=Access Denied: Admins Only");
                }
            } else {
                response.sendRedirect(contextPath + "/adminlogin.jsp?error=Please login as Admin");
            }
            return;
        }
        
        // Staff pages - require staff login (both Staff and Admin can access)
        if (isStaffPage) {
            if (staffLoggedIn) {
                chain.doFilter(request, response);
            } else {
                response.sendRedirect(contextPath + "/stafflogin.jsp?error=Please login to continue");
            }
            return;
        }
        
        // Logout is accessible to both
        if (uri.contains("/logout")) {
            chain.doFilter(request, response);
            return;
        }
        
        // For any other page, check if ANY user is logged in
        if (staffLoggedIn || guestLoggedIn) {
            chain.doFilter(request, response);
        } else {
            // Default: redirect to public homepage
            response.sendRedirect(contextPath + "/index.jsp");
        }
    }

    public void init(FilterConfig fConfig) throws ServletException {}
    public void destroy() {}
}