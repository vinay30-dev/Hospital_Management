package com.hospital.filter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {"/patient/*", "/doctor/*"})
public class AuthFilter implements Filter {

    public static final String SESSION_ROLE = "role";
    public static final String SESSION_USER_ID = "userId";
    public static final String SESSION_EMAIL = "email";
    public static final String SESSION_NAME = "displayName";
    public static final String ROLE_PATIENT = "PATIENT";
    public static final String ROLE_DOCTOR = "DOCTOR";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        String path = req.getRequestURI().substring(req.getContextPath().length());

        if (session == null || session.getAttribute(SESSION_ROLE) == null) {
            res.sendRedirect(req.getContextPath() + "/login?error=session");
            return;
        }

        String role = (String) session.getAttribute(SESSION_ROLE);
        if (path.startsWith("/patient/") && !ROLE_PATIENT.equals(role)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (path.startsWith("/doctor/") && !ROLE_DOCTOR.equals(role)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(request, response);
    }
}
