<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Patient — Profile</title>
  <jsp:include page="/WEB-INF/jsp/include/portal-head.jsp"/>
</head>
<body class="app-bg portal-body portal-page">
  <div class="portal-bg-orb portal-bg-orb-1"></div>
  <div class="portal-bg-orb portal-bg-orb-2"></div>
  <div class="portal-bg-grid"></div>

  <nav class="navbar navbar-expand-lg navbar-dark portal-nav">
    <div class="container">
      <a class="navbar-brand portal-brand fw-semibold" href="${pageContext.request.contextPath}/patient/dashboard">Hospital</a>
      <div class="d-flex align-items-center gap-2 flex-wrap justify-content-end">
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/patient/dashboard">Appointments</a>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">Sign out</a>
      </div>
    </div>
  </nav>

  <main class="container py-4 portal-main">
    <div class="portal-hero">
      <h1>Your profile</h1>
      <p>Contact details stored securely in the hospital records system.</p>
    </div>

    <c:if test="${param.saved == '1'}">
      <div class="alert alert-success border-0 mb-4" style="background:rgba(25,135,84,.15);color:#9be7c4;border-radius:10px;">
        Profile updated.
      </div>
    </c:if>

    <div class="card panel-card" style="max-width:520px;">
      <div class="card-body p-4">
        <dl class="row mb-4 small">
          <dt class="col-sm-4 text-muted-portal">Name</dt>
          <dd class="col-sm-8 mb-0">${patient.name}</dd>
          <dt class="col-sm-4 text-muted-portal">Email</dt>
          <dd class="col-sm-8 mb-0">${patient.email}</dd>
        </dl>
        <form method="post" action="${pageContext.request.contextPath}/patient/profile" class="vstack gap-3">
          <div>
            <label class="form-label">Phone</label>
            <input class="form-control" type="text" name="phone" value="<c:out value='${patient.phone}'/>"
                   maxlength="30" placeholder="e.g. 555-0101"/>
          </div>
          <button type="submit" class="btn btn-primary">Save changes</button>
        </form>
      </div>
    </div>
  </main>

  <footer class="portal-footer">
    <p class="mb-0">Need help? Contact <a href="mailto:support@hospital.local">support@hospital.local</a></p>
  </footer>
  <jsp:include page="/WEB-INF/jsp/include/portal-chat-widget.jsp"/>
</body>
</html>
