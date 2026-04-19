<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Hospital Management — Create Account</title>
  <jsp:include page="/WEB-INF/jsp/include/portal-head.jsp"/>
  <style>
    :root {
      --navy:      #0b1628;
      --navy-mid:  #112240;
      --teal:      #0ee8c4;
      --teal-dim:  rgba(14,232,196,0.12);
      --teal-glow: rgba(14,232,196,0.35);
      --slate:     #8892b0;
      --light:     #ccd6f6;
      --card-bg:   rgba(17,34,64,0.85);
      --input-bg:  rgba(11,22,40,0.7);
      --radius:    14px;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--navy);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow-x: hidden;
      position: relative;
      padding: 32px 16px;
    }

    /* ── Animated background (mirrors login.jsp) ── */
    .bg-orb {
      position: fixed;
      border-radius: 50%;
      filter: blur(80px);
      opacity: 0.18;
      animation: drift 14s ease-in-out infinite alternate;
      pointer-events: none;
    }
    .bg-orb-1 { width:500px; height:500px; background:var(--teal);   top:-120px;   left:-180px; animation-delay:0s;  }
    .bg-orb-2 { width:380px; height:380px; background:#3b82f6;       bottom:-80px; right:-100px; animation-delay:-6s; }
    .bg-orb-3 { width:260px; height:260px; background:var(--teal);   top:55%;      left:50%;     animation-delay:-3s; }
    @keyframes drift { 0%{transform:translate(0,0) scale(1);} 100%{transform:translate(30px,20px) scale(1.08);} }

    .bg-grid {
      position: fixed; inset: 0;
      background-image:
        linear-gradient(rgba(14,232,196,0.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(14,232,196,0.04) 1px, transparent 1px);
      background-size: 60px 60px;
      pointer-events: none;
    }

    /* ── Wrapper ── */
    .reg-wrap {
      position: relative;
      z-index: 10;
      width: 100%;
      max-width: 500px;
      animation: fadeUp 0.6s cubic-bezier(.16,1,.3,1) both;
    }
    @keyframes fadeUp { from{opacity:0;transform:translateY(32px);} to{opacity:1;transform:none;} }

    /* ── Brand ── */
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

    /* ── Card ── */
    .reg-card {
      background: var(--card-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border: 1px solid rgba(14,232,196,0.15);
      border-radius: var(--radius);
      padding: 36px 36px 28px;
      box-shadow: 0 24px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04) inset;
    }

    /* ── Step tabs ── */
    .step-bar {
      display: flex;
      align-items: center;
      gap: 0;
      margin-bottom: 28px;
    }
    .step {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
      position: relative;
    }
    .step:not(:last-child)::after {
      content: '';
      position: absolute;
      top: 16px;
      left: calc(50% + 16px);
      right: calc(-50% + 16px);
      height: 1px;
      background: rgba(136,146,176,0.25);
      transition: background 0.3s;
    }
    .step.done:not(:last-child)::after { background: var(--teal); }

    .step-dot {
      width: 32px; height: 32px;
      border-radius: 50%;
      border: 1.5px solid rgba(136,146,176,0.3);
      background: var(--input-bg);
      display: flex; align-items: center; justify-content: center;
      font-size: 12px; font-weight: 600;
      color: var(--slate);
      transition: all 0.3s;
      position: relative; z-index: 1;
    }
    .step.active .step-dot {
      border-color: var(--teal);
      background: var(--teal-dim);
      color: var(--teal);
      box-shadow: 0 0 12px var(--teal-dim);
    }
    .step.done .step-dot {
      border-color: var(--teal);
      background: var(--teal);
      color: var(--navy);
    }
    .step-label {
      font-size: 10px;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: var(--slate);
      font-weight: 500;
      transition: color 0.3s;
    }
    .step.active .step-label { color: var(--teal); }
    .step.done  .step-label { color: rgba(14,232,196,0.7); }

    /* ── Role toggle ── */
    .role-toggle {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
      margin-bottom: 24px;
    }
    .role-btn {
      padding: 14px 10px;
      border-radius: 10px;
      border: 1.5px solid rgba(136,146,176,0.2);
      background: var(--input-bg);
      color: var(--slate);
      font-family: 'DM Sans', sans-serif;
      font-size: 14px; font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      display: flex; flex-direction: column; align-items: center; gap: 6px;
    }
    .role-btn .role-icon { font-size: 22px; }
    .role-btn:hover { border-color: rgba(14,232,196,0.4); color: var(--light); }
    .role-btn.selected {
      border-color: var(--teal);
      background: var(--teal-dim);
      color: var(--teal);
      box-shadow: 0 0 16px var(--teal-dim);
    }

    /* ── Form labels & inputs ── */
    .form-label {
      font-size: 12px;
      font-weight: 500;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: var(--slate);
      margin-bottom: 8px;
      display: block;
    }
    .form-control, .form-select {
      background: var(--input-bg) !important;
      border: 1px solid rgba(136,146,176,0.2) !important;
      border-radius: 10px !important;
      color: var(--light) !important;
      font-size: 15px !important;
      padding: 11px 14px !important;
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    .form-control::placeholder { color: rgba(136,146,176,0.5) !important; }
    .form-control:focus, .form-select:focus {
      border-color: var(--teal) !important;
      box-shadow: 0 0 0 3px var(--teal-dim) !important;
      outline: none !important;
    }
    /* Fix select option colors on dark background */
    .form-select option { background: var(--navy-mid); color: var(--light); }

    /* ── Password strength ── */
    .strength-bar {
      height: 3px;
      border-radius: 2px;
      background: rgba(136,146,176,0.15);
      margin-top: 8px;
      overflow: hidden;
    }
    .strength-fill {
      height: 100%;
      border-radius: 2px;
      transition: width 0.3s, background 0.3s;
      width: 0%;
    }
    .strength-hint {
      font-size: 11px;
      color: var(--slate);
      margin-top: 5px;
      min-height: 16px;
      transition: color 0.3s;
    }

    /* ── Input icon wrapper ── */
    .input-icon-wrap {
      position: relative;
    }
    .input-icon-wrap .form-control { padding-right: 42px !important; }
    .toggle-pw {
      position: absolute; right: 13px; top: 50%; transform: translateY(-50%);
      background: none; border: none; padding: 0;
      color: var(--slate); cursor: pointer; font-size: 16px;
      transition: color 0.2s;
    }
    .toggle-pw:hover { color: var(--light); }

    /* ── Buttons ── */
    .btn-primary-custom {
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
      font-family: 'DM Sans', sans-serif;
    }
    .btn-primary-custom:hover { transform: translateY(-1px); box-shadow: 0 10px 28px var(--teal-glow); }
    .btn-primary-custom:active { transform: translateY(0); opacity: 0.9; }
    .btn-primary-custom:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

    .btn-ghost {
      width: 100%;
      padding: 12px;
      border-radius: 10px;
      border: 1px solid rgba(136,146,176,0.2);
      background: transparent;
      color: var(--slate);
      font-size: 14px; font-weight: 500;
      cursor: pointer;
      transition: border-color 0.2s, color 0.2s;
      font-family: 'DM Sans', sans-serif;
    }
    .btn-ghost:hover { border-color: rgba(136,146,176,0.4); color: var(--light); }

    /* ── Alerts ── */
    .alert {
      border-radius: 10px !important;
      border: none !important;
      font-size: 13.5px;
      padding: 10px 14px !important;
    }
    .alert-danger  { background: rgba(220,53,69,0.15) !important;  color: #ff8a8a !important; border: 1px solid rgba(220,53,69,0.25) !important; }
    .alert-success { background: rgba(14,232,196,0.10) !important; color: #a8ffed !important; border: 1px solid rgba(14,232,196,0.2) !important; }

    /* ── Success state ── */
    .success-view { display: none; text-align: center; padding: 12px 0; }
    .success-icon {
      width: 64px; height: 64px;
      border-radius: 50%;
      background: var(--teal-dim);
      border: 2px solid var(--teal);
      display: flex; align-items: center; justify-content: center;
      font-size: 28px;
      margin: 0 auto 16px;
      animation: popIn 0.5s cubic-bezier(.16,1,.3,1) both;
    }
    @keyframes popIn { from{transform:scale(0.5);opacity:0;} to{transform:scale(1);opacity:1;} }
    .success-title { font-family: 'Playfair Display', serif; font-size: 22px; color: var(--light); margin-bottom: 8px; }
    .success-sub   { font-size: 14px; color: var(--slate); margin-bottom: 24px; }

    /* ── Footer / sign-in link ── */
    .signin-link {
      text-align: center;
      font-size: 13px;
      color: var(--slate);
      margin-top: 20px;
    }
    .signin-link a {
      color: var(--teal);
      text-decoration: none;
      font-weight: 500;
    }
    .signin-link a:hover { text-decoration: underline; }

    .footer-note {
      text-align: center;
      font-size: 12px;
      color: rgba(136,146,176,0.45);
      margin-top: 20px;
    }
    .footer-note code { color: rgba(136,146,176,0.55); }

    /* ── Misc ── */
    .field-gap { margin-bottom: 18px; }
    .section-divider {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: rgba(136,146,176,0.4);
      margin: 24px 0 18px;
      display: flex; align-items: center; gap: 10px;
    }
    .section-divider::before, .section-divider::after {
      content: ''; flex: 1; height: 1px; background: rgba(136,146,176,0.15);
    }
  </style>
</head>
<body>
  <!-- Background -->
  <div class="bg-orb bg-orb-1"></div>
  <div class="bg-orb bg-orb-2"></div>
  <div class="bg-orb bg-orb-3"></div>
  <div class="bg-grid"></div>

  <div class="reg-wrap">
    <!-- Brand -->
    <div class="brand-ring">HM</div>
    <h1 class="brand-title">Create Account</h1>
    <p class="brand-sub">Join the Hospital Management portal</p>

    <div class="reg-card">

      <!-- Alert area -->
      <div id="alertArea"></div>

      <!-- Step indicator -->
      <div class="step-bar" id="stepBar">
        <div class="step active" id="step-dot-1">
          <div class="step-dot">1</div>
          <span class="step-label">Role</span>
        </div>
        <div class="step" id="step-dot-2">
          <div class="step-dot">2</div>
          <span class="step-label">Details</span>
        </div>
        <div class="step" id="step-dot-3">
          <div class="step-dot">3</div>
          <span class="step-label">Security</span>
        </div>
      </div>

      <!-- STEP 1 — Role selection -->
      <div id="stepPanel1">
        <p class="form-label mb-3" style="text-align:center; text-transform:none; letter-spacing:0; font-size:14px; color:var(--slate);">
          I am registering as a…
        </p>
        <div class="role-toggle">
          <button type="button" class="role-btn" id="rolePatient" onclick="selectRole('PATIENT')">
            <span class="role-icon">🧑‍⚕️</span>
            Patient
          </button>
          <button type="button" class="role-btn" id="roleDoctor" onclick="selectRole('DOCTOR')">
            <span class="role-icon">👨‍⚕️</span>
            Doctor
          </button>
        </div>
        <button class="btn-primary-custom" type="button" id="step1Next" disabled onclick="goStep(2)">
          Continue →
        </button>
      </div>

      <!-- STEP 2 — Personal details -->
      <div id="stepPanel2" style="display:none;">
        <div class="field-gap">
          <label class="form-label" for="fullName">Full Name</label>
          <input class="form-control" type="text" id="fullName" name="fullName"
                 required autocomplete="name" placeholder="Dr. Jane Smith"/>
        </div>
        <div class="field-gap">
          <label class="form-label" for="email">Email Address</label>
          <input class="form-control" type="email" id="email" name="email"
                 required autocomplete="email" placeholder="name@example.com"/>
        </div>
        <div class="field-gap">
          <label class="form-label" for="phone">Phone Number <span style="color:rgba(136,146,176,0.4); font-size:10px;">(optional)</span></label>
          <input class="form-control" type="tel" id="phone" name="phone"
                 autocomplete="tel" placeholder="+91 98765 43210"/>
        </div>

        <!-- Doctor-specific field -->
        <div class="field-gap" id="specialtyField" style="display:none;">
          <label class="form-label" for="specialty">Specialty</label>
          <select class="form-select" id="specialty" name="specialty">
            <option value="">Select specialty</option>
            <option>General Practice</option>
            <option>Cardiology</option>
            <option>Dermatology</option>
            <option>Endocrinology</option>
            <option>Gastroenterology</option>
            <option>Neurology</option>
            <option>Oncology</option>
            <option>Ophthalmology</option>
            <option>Orthopedics</option>
            <option>Pediatrics</option>
            <option>Psychiatry</option>
            <option>Pulmonology</option>
            <option>Radiology</option>
            <option>Urology</option>
          </select>
        </div>

        <div class="d-flex gap-2">
          <button class="btn-ghost" type="button" onclick="goStep(1)">← Back</button>
          <button class="btn-primary-custom" type="button" onclick="validateStep2()">Continue →</button>
        </div>
      </div>

      <!-- STEP 3 — Password -->
      <div id="stepPanel3" style="display:none;">
        <div class="field-gap">
          <label class="form-label" for="password">Password</label>
          <div class="input-icon-wrap">
            <input class="form-control" type="password" id="password" name="password"
                   required autocomplete="new-password" placeholder="Min. 8 characters"
                   oninput="checkStrength(this.value)"/>
            <button class="toggle-pw" type="button" onclick="togglePw('password', this)" aria-label="Toggle password">👁</button>
          </div>
          <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
          <div class="strength-hint" id="strengthHint"></div>
        </div>
        <div class="field-gap">
          <label class="form-label" for="confirmPassword">Confirm Password</label>
          <div class="input-icon-wrap">
            <input class="form-control" type="password" id="confirmPassword" name="confirmPassword"
                   required autocomplete="new-password" placeholder="Re-enter password"/>
            <button class="toggle-pw" type="button" onclick="togglePw('confirmPassword', this)" aria-label="Toggle confirm password">👁</button>
          </div>
        </div>

        <div class="section-divider">Summary</div>
        <div id="summaryBox" style="font-size:13px; color:var(--slate); margin-bottom:20px; line-height:1.8;"></div>

        <div class="d-flex gap-2">
          <button class="btn-ghost" type="button" onclick="goStep(2)">← Back</button>
          <button class="btn-primary-custom" type="button" id="submitBtn" onclick="submitForm()">
            Create Account →
          </button>
        </div>
      </div>

      <!-- SUCCESS state -->
      <div class="success-view" id="successView">
        <div class="success-icon">✓</div>
        <h2 class="success-title">Account Created!</h2>
        <p class="success-sub">Your account is ready. Sign in to access the portal.</p>
        <a href="${pageContext.request.contextPath}/login" class="btn-primary-custom"
           style="display:inline-block; text-decoration:none; text-align:center; padding:13px 28px; width:auto; border-radius:10px;">
          Go to Sign In →
        </a>
      </div>

    </div><!-- /reg-card -->

    <p class="signin-link">
      Already have an account? <a href="${pageContext.request.contextPath}/login">Sign in</a>
    </p>
    <p class="footer-note">Node API on <code>${initParam.nodeApiBase}</code></p>
  </div><!-- /reg-wrap -->

  <script>
    const API = '${initParam.nodeApiBase}';
    let selectedRole = null;
    let currentStep = 1;

    /* ── Role selection ── */
    function selectRole(role) {
      selectedRole = role;
      document.getElementById('rolePatient').classList.toggle('selected', role === 'PATIENT');
      document.getElementById('roleDoctor').classList.toggle('selected',  role === 'DOCTOR');
      document.getElementById('step1Next').disabled = false;
      document.getElementById('specialtyField').style.display = (role === 'DOCTOR') ? 'block' : 'none';
    }

    /* ── Step navigation ── */
    function goStep(n) {
      for (let i = 1; i <= 3; i++) {
        document.getElementById('stepPanel' + i).style.display = (i === n) ? 'block' : 'none';
        const dot = document.getElementById('step-dot-' + i);
        dot.classList.remove('active', 'done');
        if (i < n)       dot.classList.add('done');
        else if (i === n) dot.classList.add('active');
      }
      currentStep = n;
      clearAlert();
      if (n === 3) buildSummary();
    }

    /* ── Step 2 validation ── */
    function validateStep2() {
      const name  = document.getElementById('fullName').value.trim();
      const email = document.getElementById('email').value.trim();
      if (!name)  { showAlert('Please enter your full name.', 'danger'); return; }
      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        showAlert('Please enter a valid email address.', 'danger'); return;
      }
      if (selectedRole === 'DOCTOR' && !document.getElementById('specialty').value) {
        showAlert('Please select your medical specialty.', 'danger'); return;
      }
      goStep(3);
    }

    /* ── Summary ── */
    function buildSummary() {
      const lines = [
        '<span style="color:var(--light);">Role:</span> ' + selectedRole,
        '<span style="color:var(--light);">Name:</span> ' + esc(document.getElementById('fullName').value.trim()),
        '<span style="color:var(--light);">Email:</span> ' + esc(document.getElementById('email').value.trim()),
      ];
      const phone = document.getElementById('phone').value.trim();
      if (phone) lines.push('<span style="color:var(--light);">Phone:</span> ' + esc(phone));
      if (selectedRole === 'DOCTOR') {
        const sp = document.getElementById('specialty').value;
        if (sp) lines.push('<span style="color:var(--light);">Specialty:</span> ' + esc(sp));
      }
      document.getElementById('summaryBox').innerHTML = lines.join('<br>');
    }

    /* ── Password strength ── */
    function checkStrength(pw) {
      const fill = document.getElementById('strengthFill');
      const hint = document.getElementById('strengthHint');
      let score = 0;
      if (pw.length >= 8)  score++;
      if (/[A-Z]/.test(pw)) score++;
      if (/[0-9]/.test(pw)) score++;
      if (/[^A-Za-z0-9]/.test(pw)) score++;
      const levels = [
        { pct: '0%',   color: 'transparent',  text: '' },
        { pct: '25%',  color: '#ef4444',       text: 'Weak' },
        { pct: '50%',  color: '#f59e0b',       text: 'Fair' },
        { pct: '75%',  color: '#3b82f6',       text: 'Good' },
        { pct: '100%', color: 'var(--teal)',   text: 'Strong' },
      ];
      const lvl = pw.length === 0 ? levels[0] : levels[score];
      fill.style.width = lvl.pct;
      fill.style.background = lvl.color;
      hint.textContent = lvl.text;
      hint.style.color = lvl.color === 'transparent' ? 'var(--slate)' : lvl.color;
    }

    /* ── Toggle password visibility ── */
    function togglePw(id, btn) {
      const inp = document.getElementById(id);
      const isText = inp.type === 'text';
      inp.type = isText ? 'password' : 'text';
      btn.textContent = isText ? '👁' : '🙈';
    }

    /* ── Submit ── */
    async function submitForm() {
      const password = document.getElementById('password').value;
      const confirm  = document.getElementById('confirmPassword').value;
      if (password.length < 8) { showAlert('Password must be at least 8 characters.', 'danger'); return; }
      if (password !== confirm) { showAlert('Passwords do not match.', 'danger'); return; }

      const btn = document.getElementById('submitBtn');
      btn.disabled = true;
      btn.textContent = 'Creating account…';
      clearAlert();

      const payload = {
        role:      selectedRole,
        name:      document.getElementById('fullName').value.trim(),
        email:     document.getElementById('email').value.trim(),
        phone:     document.getElementById('phone').value.trim() || null,
        specialty: selectedRole === 'DOCTOR' ? (document.getElementById('specialty').value || null) : null,
        password,
      };

      try {
        const res = await fetch(API + '/auth/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Registration failed');

        // Hide multi-step form, show success
        document.getElementById('stepBar').style.display = 'none';
        for (let i = 1; i <= 3; i++) document.getElementById('stepPanel' + i).style.display = 'none';
        document.getElementById('successView').style.display = 'block';

      } catch (err) {
        showAlert('⚠ ' + err.message, 'danger');
        btn.disabled = false;
        btn.textContent = 'Create Account →';
      }
    }

    /* ── Helpers ── */
    function showAlert(msg, type) {
      document.getElementById('alertArea').innerHTML =
        '<div class="alert alert-' + type + ' mb-4" role="alert">' + msg + '</div>';
    }
    function clearAlert() {
      document.getElementById('alertArea').innerHTML = '';
    }
    function esc(s) {
      return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
  </script>
  <jsp:include page="/WEB-INF/jsp/include/portal-chat-widget.jsp"/>
</body>
</html>
