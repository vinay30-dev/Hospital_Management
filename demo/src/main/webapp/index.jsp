<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.hospital.filter.AuthFilter" %>
<%
  Object role = session.getAttribute(AuthFilter.SESSION_ROLE);
  if (role == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  if (AuthFilter.ROLE_PATIENT.equals(role)) {
    response.sendRedirect(request.getContextPath() + "/patient/dashboard");
    return;
  }
  if (AuthFilter.ROLE_DOCTOR.equals(role)) {
    response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
    return;
  }
  response.sendRedirect(request.getContextPath() + "/login");
%>
