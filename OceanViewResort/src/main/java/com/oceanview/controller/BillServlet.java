package com.oceanview.controller;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;
import com.oceanview.utils.PDFGenerator;

@WebServlet("/generateBill")
public class BillServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // RBAC: Only Staff and Admin can generate bills
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect("stafflogin.jsp?error=Please login to continue");
            return;
        }
        
        String role = currentUser.getRole();
        if (!"Receptionist".equalsIgnoreCase(role) && !"Admin".equalsIgnoreCase(role)) {
            response.sendRedirect("index.jsp?error=Access Denied");
            return;
        }
        
        try {
            // 1. Get ID from URL
            int id = Integer.parseInt(request.getParameter("id"));
            
            // 2. Fetch Reservation Data
            ReservationDAO dao = new ReservationDAO();
            Reservation res = dao.getReservationById(id);
            
            if (res == null) {
                response.sendRedirect("viewReservations?error=NotFound");
                return;
            }

            // 3. Calculate breakdown for the Invoice
            LocalDate inDate = res.getCheckIn().toLocalDate();
            LocalDate outDate = res.getCheckOut().toLocalDate();
            long nights = ChronoUnit.DAYS.between(inDate, outDate);
            if (nights == 0) nights = 1;

            // Reverse engineer price per night from total (Total / Nights)
            double pricePerNight = res.getTotalAmount() / nights;

            // 4. Generate PDF using custom generator (no tax/service charge)
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=invoice_" + id + ".pdf");

            PDFGenerator pdfGen = new PDFGenerator(response.getOutputStream());
            pdfGen.generateInvoice(res, currentUser, nights, pricePerNight);

        } catch (Exception e) {
            e.printStackTrace();
            try {
                response.sendRedirect("viewReservations");
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }
        }
    }
}