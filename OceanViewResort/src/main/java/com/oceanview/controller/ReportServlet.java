package com.oceanview.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.User;

@WebServlet("/viewReports")
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // RBAC Security Check
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
            // If not Admin, redirect to Dashboard with error
            response.sendRedirect("dashboard.jsp?error=Access Denied: Admins Only");
            return;
        }
        
        ReservationDAO dao = new ReservationDAO();
        List<ReservationDAO.RevenueReport> reportData = dao.getRevenueReport();
        
        request.setAttribute("reportData", reportData);
        request.getRequestDispatcher("reports.jsp").forward(request, response);
    }
}
