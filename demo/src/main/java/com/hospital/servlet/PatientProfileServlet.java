package com.hospital.servlet;

import com.hospital.model.Patient;
import com.hospital.persistence.HibernateUtil;
import org.hibernate.Session;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.hospital.filter.AuthFilter;

import java.io.IOException;

@WebServlet(name = "PatientProfileServlet", urlPatterns = {"/patient/profile"})
public class PatientProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession httpSession = req.getSession(false);
        if (httpSession == null || !AuthFilter.ROLE_PATIENT.equals(httpSession.getAttribute(AuthFilter.SESSION_ROLE))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Long id = (Long) httpSession.getAttribute(AuthFilter.SESSION_USER_ID);
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Patient p = session.find(Patient.class, id);
            if (p == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("patient", p);
        }
        req.getRequestDispatcher("/WEB-INF/jsp/patient/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession httpSession = req.getSession(false);
        if (httpSession == null || !AuthFilter.ROLE_PATIENT.equals(httpSession.getAttribute(AuthFilter.SESSION_ROLE))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Long id = (Long) httpSession.getAttribute(AuthFilter.SESSION_USER_ID);
        String phone = req.getParameter("phone");
        if (phone != null) {
            phone = phone.trim();
        }
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            Patient p = session.get(Patient.class, id);
            if (p != null) {
                if (phone == null || phone.isEmpty()) {
                    p.setPhone(null);
                } else if (phone.length() <= 30) {
                    p.setPhone(phone);
                }
            }
            session.getTransaction().commit();
        }
        resp.sendRedirect(req.getContextPath() + "/patient/profile?saved=1");
    }
}
