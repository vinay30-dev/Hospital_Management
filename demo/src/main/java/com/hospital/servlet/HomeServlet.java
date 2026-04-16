package com.hospital.servlet;

import com.hospital.filter.AuthFilter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "HomeServlet", urlPatterns = {"/"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        var session = req.getSession(false);
        if (session != null && session.getAttribute(AuthFilter.SESSION_ROLE) != null) {
            String role = (String) session.getAttribute(AuthFilter.SESSION_ROLE);
            if (AuthFilter.ROLE_PATIENT.equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/patient/dashboard");
                return;
            }
            if (AuthFilter.ROLE_DOCTOR.equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
                return;
            }
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
