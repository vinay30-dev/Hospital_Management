<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Hospital Management — Sign In</title>
  <jsp:include page="/WEB-INF/jsp/include/portal-head.jsp"/>
  <style>
    :root {
      --navy: #0b1628;
      --navy-mid: #112240;
      --teal: #0ee8c4;
      --teal-dim: rgba(14,232,196,0.12);
      --teal-glow: rgba(14,232,196,0.35);
      --slate: #8892b0;
      --light: #ccd6f6;
      --card-bg: rgba(17, 34, 64, 0.85);
      --input-bg: rgba(11, 22, 40, 0.7);
      --radius: 14px;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--navy);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      position: relative;
    }

    /* Animated background */
    .bg-orb {
      position: fixed;
      border-radius: 50%;
      filter: blur(80px);
      opacity: 0.18;
      animation: drift 14s ease-in-out infinite alternate;
      pointer-events: none;
    }
    .bg-orb-1 { width: 500px; height: 500px; background: var(--teal); top: -120px; left: -180px; animation-delay: 0s; }
    .bg-orb-2 { width: 380px; height: 380px; background: #3b82f6; bottom: -80px; right: -100px; animation-delay: -6s; }
    .bg-orb-3 { width: 260px; height: 260px; background: var(--teal); top: 55%; left: 50%; animation-delay: -3s; }
    @keyframes drift { 0% { transform: translate(0,0) scale(1); } 100% { transform: translate(30px, 20px) scale(1.08); } }

    /* Grid lines overlay */
    .bg-grid {
      position: fixed; inset: 0;
      background-image:
        linear-gradient(rgba(14,232,196,0.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(14,232,196,0.04) 1px, transparent 1px);
      background-size: 60px 60px;
      pointer-events: none;
    }

    .login-wrap {
      position: relative;
      z-index: 10;
      width: 100%;
      max-width: 440px;
      padding: 24px;
      animation: fadeUp 0.6s cubic-bezier(.16,1,.3,1) both;
    }
    @keyframes fadeUp { from { opacity: 0; transform: translateY(32px); } to { opacity: 1; transform: none; } }

    /* Logo / Brand */
    .brand-ring {
      width: 64px; height: 64px;
      border-radius: 18px;
      background: linear-gradient(135deg, var(--teal), #3b82f6);
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 18px;
      box-shadow: 0 0 32px var(--teal-glow);
      font-family: 'Playfair Display', serif;
      font-size: 22px; font-weight: 600;
      color: var(--navy);
      letter-spacing: -1px;
    }
    .brand-title {
      font-family: 'Playfair Display', serif;
      font-size: 28px; font-weight: 600;
      color: var(--light);
      text-align: center;
      letter-spacing: -0.5px;
      margin-bottom: 6px;
    }
    .brand-sub {
      text-align: center;
      font-size: 14px;
      color: var(--slate);
      margin-bottom: 32px;
    }

    /* Card */
    .login-card {
      background: var(--card-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border: 1px solid rgba(14,232,196,0.15);
      border-radius: var(--radius);
      padding: 36px 36px 28px;
      box-shadow: 0 24px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04) inset;
    }

    /* Form labels */
    .form-label {
      font-size: 12px;
      font-weight: 500;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: var(--slate);
      margin-bottom: 8px;
    }

    /* Inputs */
    .form-control {
      background: var(--input-bg) !important;
      border: 1px solid rgba(136,146,176,0.2) !important;
      border-radius: 10px !important;
      color: var(--light) !important;
      font-size: 15px !important;
      padding: 11px 14px !important;
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    .form-control::placeholder { color: rgba(136,146,176,0.5) !important; }
    .form-control:focus {
      border-color: var(--teal) !important;
      box-shadow: 0 0 0 3px var(--teal-dim) !important;
      outline: none !important;
    }

    /* Button */
    .btn-signin {
      width: 100%;
      padding: 13px;
      border-radius: 10px;
      border: none;
      background: linear-gradient(135deg, var(--teal), #0acfb1);
      color: var(--navy);
      font-weight: 600;
      font-size: 15px;
      cursor: pointer;
      transition: transform 0.15s, box-shadow 0.2s, opacity 0.2s;
      box-shadow: 0 6px 20px var(--teal-glow);
      margin-top: 4px;
    }
    .btn-signin:hover { transform: translateY(-1px); box-shadow: 0 10px 28px var(--teal-glow); }
    .btn-signin:active { transform: translateY(0); opacity: 0.9; }

    /* Alerts */
    .alert {
      border-radius: 10px !important;
      border: none !important;
      font-size: 13.5px;
      padding: 10px 14px !important;
    }
    .alert-danger { background: rgba(220,53,69,0.15) !important; color: #ff8a8a !important; border: 1px solid rgba(220,53,69,0.25) !important; }
    .alert-warning { background: rgba(255,193,7,0.12) !important; color: #ffd76e !important; border: 1px solid rgba(255,193,7,0.2) !important; }

    /* Demo credentials */
    .demo-box {
      margin-top: 22px;
      background: rgba(14,232,196,0.06);
      border: 1px solid rgba(14,232,196,0.12);
      border-radius: 10px;
      padding: 12px 16px;
    }
    .demo-box .demo-label { font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em; color: var(--teal); font-weight: 600; margin-bottom: 8px; }
    .demo-box .demo-row { display: flex; align-items: baseline; gap: 8px; margin-bottom: 4px; font-size: 12.5px; color: var(--slate); }
    .demo-box .demo-row:last-child { margin-bottom: 0; }
    .demo-box code { background: rgba(14,232,196,0.08); color: #a8ffed; border-radius: 4px; padding: 1px 6px; font-size: 11.5px; }
    .demo-box .demo-role { font-size: 10.5px; color: rgba(136,146,176,0.6); margin-left: auto; }

    .footer-note {
      text-align: center;
      font-size: 12px;
      color: rgba(136,146,176,0.45);
      margin-top: 20px;
    }
    .footer-note code { color: rgba(136,146,176,0.55); }

    /* Divider */
    .field-gap { margin-bottom: 18px; }
  </style>
</head>
<body>
  <div class="bg-orb bg-orb-1"></div>
  <div class="bg-orb bg-orb-2"></div>
  <div class="bg-orb bg-orb-3"></div>
  <div class="bg-grid"></div>

  <div class="login-wrap">
    <div class="brand-ring">HM</div>
    <h1 class="brand-title">Hospital Management</h1>
    <p class="brand-sub">Secure portal for patients &amp; physicians</p>

    <div class="login-card">
      <c:if test="${param.error == 'credentials'}">
        <div class="alert alert-danger mb-4" role="alert">
          ⚠ Invalid email or password. Please try again.
        </div>
      </c:if>
      <c:if test="${param.error == 'session'}">
        <div class="alert alert-warning mb-4" role="alert">
          🔒 Your session expired. Please sign in to continue.
        </div>
      </c:if>
      <c:if test="${param.error == 'invalid'}">
        <div class="alert alert-warning mb-4" role="alert">
          ⚠ Please fill in all required fields.
        </div>
      </c:if>

      <form method="post" action="${pageContext.request.contextPath}/login">
        <div class="field-gap">
          <label class="form-label">Email Address</label>
          <input class="form-control" type="email" name="email" required autocomplete="username"
                 placeholder="name@example.com"/>
        </div>
        <div class="field-gap">
          <label class="form-label">Password</label>
          <input class="form-control" type="password" name="password" required autocomplete="current-password"
                 placeholder="••••••••"/>
        </div>
        <button class="btn-signin" type="submit">Sign In →</button>
      </form>

    </form>

    <!-- Register link -->
    <div style="text-align:center; margin-top: 20px; padding-top: 18px; border-top: 1px solid rgba(136,146,176,0.12);">
      <span style="font-size:13px; color: var(--slate);">Don't have an account?</span>
      <a href="${pageContext.request.contextPath}/register"
         style="color: var(--teal); font-size:13px; font-weight:600; text-decoration:none; margin-left:6px;">
        Create one →
      </a>
    </div>

      <div class="demo-box">
        <div class="demo-label">Demo Credentials</div>
        <div class="demo-row">
          <code>alice@patient.com</code> / <code>password123</code>
          <span class="demo-role">Patient</span>
        </div>
        <div class="demo-row">
          <code>dr.smith@hospital.com</code> / <code>password123</code>
          <span class="demo-role">Doctor</span>
        </div>
      </div>
    </div>

    <p class="footer-note">Node API on <code>http://localhost:3001</code></p>
  </div>
</body>
</html>
