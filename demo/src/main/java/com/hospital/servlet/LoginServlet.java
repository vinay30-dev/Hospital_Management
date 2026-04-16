package com.hospital.servlet;

import com.hospital.filter.AuthFilter;
import com.hospital.model.Doctor;
import com.hospital.model.Patient;
import com.hospital.persistence.HibernateUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.hibernate.Session;
import org.hibernate.query.Query;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        if (email == null || password == null || email.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/login?error=invalid");
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<Patient> pq = session.createQuery(
                    "from Patient p where lower(p.email) = lower(:email)", Patient.class);
            pq.setParameter("email", email.trim());
            Patient patient = pq.uniqueResult();

            if (patient != null && BCrypt.checkpw(password, patient.getPasswordHash())) {
                bindSession(req, AuthFilter.ROLE_PATIENT, patient.getId(), patient.getEmail(), patient.getName());
                resp.sendRedirect(req.getContextPath() + "/patient/dashboard");
                return;
            }

            Query<Doctor> dq = session.createQuery(
                    "from Doctor d where lower(d.email) = lower(:email)", Doctor.class);
            dq.setParameter("email", email.trim());
            Doctor doctor = dq.uniqueResult();

            if (doctor != null && BCrypt.checkpw(password, doctor.getPasswordHash())) {
                bindSession(req, AuthFilter.ROLE_DOCTOR, doctor.getId(), doctor.getEmail(), doctor.getName());
                resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/login?error=credentials");
    }

    private void bindSession(HttpServletRequest req, String role, Long userId, String email, String name) {
        HttpSession httpSession = req.getSession(true);
        httpSession.setAttribute(AuthFilter.SESSION_ROLE, role);
        httpSession.setAttribute(AuthFilter.SESSION_USER_ID, userId);
        httpSession.setAttribute(AuthFilter.SESSION_EMAIL, email);
        httpSession.setAttribute(AuthFilter.SESSION_NAME, name);
    }
}
