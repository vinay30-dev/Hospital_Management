<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Patient — Profile</title>
  <jsp:include page="/WEB-INF/jsp/include/portal-head.jsp"/>
  <style>
    body.portal-body { font-family: 'DM Sans', system-ui, sans-serif; background: #0b1628; color: #ccd6f6; min-height: 100vh; }
    .portal-bg-orb { position: fixed; border-radius: 50%; filter: blur(80px); opacity: 0.18; pointer-events: none; z-index: 0; }
    .portal-bg-orb-1 { width: 480px; height: 480px; background: #0ee8c4; top: -140px; left: -180px; }
    .portal-bg-orb-2 { width: 360px; height: 360px; background: #3b82f6; bottom: -120px; right: -120px; }
    .portal-bg-grid { position: fixed; inset: 0; background-image: linear-gradient(rgba(14,232,196,.04) 1px, transparent 1px), linear-gradient(90deg, rgba(14,232,196,.04) 1px, transparent 1px); background-size: 60px 60px; pointer-events: none; z-index: 0; }
    .portal-nav { position: relative; z-index: 10; background: rgba(11,22,40,.82)!important; backdrop-filter: blur(14px); border-bottom: 1px solid rgba(14,232,196,.15)!important; }
    .portal-brand { font-family: 'Playfair Display', Georgia, serif; color: #ccd6f6 !important; }
    .portal-main { position: relative; z-index: 5; }
    .portal-hero h1 { font-family: 'Playfair Display', Georgia, serif; font-size: 1.65rem; margin-bottom: .35rem; }
    .portal-hero p, .text-muted-portal { color: #8892b0 !important; }
    .panel-card { background: rgba(17,34,64,.82); border: 1px solid rgba(14,232,196,.12)!important; border-radius: 14px; backdrop-filter: blur(14px); box-shadow: 0 18px 40px rgba(0,0,0,.35); }
    .panel-title { color: #ccd6f6; font-family: 'Playfair Display', Georgia, serif; }
    .panel-subtitle { color: #8892b0 !important; }
    .form-label { font-size: 11px; text-transform: uppercase; letter-spacing: .08em; color: #8892b0; margin-bottom: 6px; }
    .form-control { background: rgba(11,22,40,.7)!important; border: 1px solid rgba(136,146,176,.25)!important; color: #ccd6f6!important; }
    .form-control:focus { border-color: #0ee8c4!important; box-shadow: 0 0 0 3px rgba(14,232,196,.12)!important; }
    .btn-primary { background: linear-gradient(135deg,#0ee8c4,#0acfb1); border: none; color: #0b1628; font-weight: 600; box-shadow: 0 8px 22px rgba(14,232,196,.35); }
    .btn-outline-light { border-color: rgba(204,214,246,.35); color: #ccd6f6; }
    .portal-footer { position: relative; z-index: 5; padding: 1.5rem 0 2rem; text-align: center; font-size: .8rem; color: rgba(136,146,176,.55); }
    .portal-footer a { color: rgba(14,232,196,.85); text-decoration: none; }
  </style>
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
