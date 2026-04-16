<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Patient — Appointments</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css"/>
  <style>
    :root {
      --navy: #0b1628;
      --teal: #0ee8c4;
      --teal-dim: rgba(14,232,196,0.12);
      --teal-glow: rgba(14,232,196,0.35);
      --slate: #8892b0;
      --light: #ccd6f6;
      --card-bg: rgba(17, 34, 64, 0.82);
      --input-bg: rgba(11, 22, 40, 0.7);
    }

    body { font-family: 'DM Sans', sans-serif; background: var(--navy); }
    .bg-orb { position: fixed; border-radius: 50%; filter: blur(80px); opacity: .18; pointer-events: none; }
    .bg-orb-1 { width: 480px; height: 480px; background: var(--teal); top: -140px; left: -180px; }
    .bg-orb-2 { width: 360px; height: 360px; background: #3b82f6; bottom: -120px; right: -120px; }
    .bg-grid { position: fixed; inset: 0; background-image:
      linear-gradient(rgba(14,232,196,0.04) 1px, transparent 1px),
      linear-gradient(90deg, rgba(14,232,196,0.04) 1px, transparent 1px);
      background-size: 60px 60px; pointer-events: none; }

    .nav-glass { background: rgba(11, 22, 40, 0.82) !important; backdrop-filter: blur(14px); border-bottom: 1px solid rgba(14,232,196,.15) !important; }
    .nav-brand { font-family: 'Playfair Display', serif; color: var(--light) !important; }

    .panel-card { background: var(--card-bg); border: 1px solid rgba(14,232,196,0.12) !important; border-radius: 14px; backdrop-filter: blur(14px); box-shadow: 0 18px 40px rgba(0,0,0,.35); }
    .panel-title { color: var(--light); font-family: 'Playfair Display', serif; }

    .form-label { font-size: 11px; text-transform: uppercase; letter-spacing: .08em; color: var(--slate); margin-bottom: 6px; }
    .form-control, .form-select { background: var(--input-bg) !important; border: 1px solid rgba(136,146,176,.25) !important; color: var(--light) !important; }
    .form-control:focus, .form-select:focus { border-color: var(--teal) !important; box-shadow: 0 0 0 3px var(--teal-dim) !important; }
    .btn-primary { background: linear-gradient(135deg, var(--teal), #0acfb1); border: none; color: var(--navy); font-weight: 600; box-shadow: 0 8px 22px var(--teal-glow); }
    .btn-outline-light { border-color: rgba(204,214,246,.35); color: var(--light); }
    .table { color: var(--light); }
    .table thead { --bs-table-bg: rgba(255,255,255,.03); --bs-table-color: var(--slate); }
    .table tbody tr { --bs-table-bg: transparent; --bs-table-color: var(--light); }
  </style>
</head>
<body class="app-bg">
  <div class="bg-orb bg-orb-1"></div>
  <div class="bg-orb bg-orb-2"></div>
  <div class="bg-grid"></div>
  <nav class="navbar navbar-expand-lg navbar-dark nav-glass">
    <div class="container">
      <a class="navbar-brand nav-brand fw-semibold" href="${pageContext.request.contextPath}/">Hospital</a>
      <div class="d-flex align-items-center gap-3">
        <div class="text-white-50 small">
          Signed in as <span class="text-white">${sessionScope.displayName}</span>
        </div>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">Sign out</a>
      </div>
    </div>
  </nav>

  <main class="container py-4">
    <div class="row g-4">
      <div class="col-12 col-lg-5">
        <div class="card panel-card">
          <div class="card-body">
            <h2 class="h5 mb-1 panel-title">Book an appointment</h2>
            <p class="text-muted mb-3">Choose a doctor and an available slot.</p>

            <div class="vstack gap-3">
              <div>
                <label class="form-label">Doctor</label>
                <select class="form-select" id="doctorSelect"></select>
              </div>
              <div>
                <label class="form-label">Slot</label>
                <select class="form-select" id="slotSelect" disabled></select>
              </div>
              <div>
                <label class="form-label">Reason / Notes</label>
                <textarea class="form-control" id="notesInput" rows="2" placeholder="Describe symptoms or reason"></textarea>
              </div>
              <button class="btn btn-primary" type="button" id="bookBtn" disabled>Book</button>
              <div id="bookMsg" class="small text-muted"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 col-lg-7">
        <div class="card panel-card">
          <div class="card-body">
            <div class="d-flex align-items-center justify-content-between mb-2">
              <h2 class="h5 mb-0 panel-title">Your appointments</h2>
              <span class="badge text-bg-secondary">Patient</span>
            </div>
            <div class="row g-2 mb-3">
              <div class="col-md-4">
                <label class="form-label mb-1">Status</label>
                <select id="statusFilter" class="form-select form-select-sm">
                  <option value="">Active</option>
                  <option value="SCHEDULED">Scheduled</option>
                  <option value="CONFIRMED">Confirmed</option>
                  <option value="COMPLETED">Completed</option>
                  <option value="CANCELLED">Cancelled</option>
                </select>
              </div>
              <div class="col-md-5">
                <label class="form-label mb-1">Doctor Search</label>
                <input id="searchFilter" class="form-control form-control-sm" placeholder="doctor or specialty"/>
              </div>
              <div class="col-md-3 d-flex align-items-end">
                <button id="refreshBtn" class="btn btn-sm btn-primary w-100" type="button">Refresh</button>
              </div>
            </div>
            <div id="listMsg" class="small text-muted mb-2"></div>

            <div class="table-responsive">
              <table class="table table-sm align-middle mb-0" id="apptTable">
                <thead class="table-light">
                <tr><th>ID</th><th>Doctor</th><th>Time</th><th>Status</th><th>Notes</th><th class="text-end"></th></tr>
                </thead>
                <tbody></tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <script>
    const API = '${initParam.nodeApiBase}';
    const patientId = Number('${sessionScope.userId}');
    const role = '${sessionScope.role}';

    async function getJson(url, opts) {
      const r = await fetch(url, Object.assign({headers: {'Accept': 'application/json'}}, opts || {}));
      const text = await r.text();
      let data = null;
      try { data = text ? JSON.parse(text) : null; } catch (e) {}
      if (!r.ok) throw new Error((data && data.message) || text || r.statusText);
      return data;
    }

    async function loadDoctors() {
      const sel = document.getElementById('doctorSelect');
      sel.innerHTML = '<option value="">Loading…</option>';
      try {
        const rows = await getJson(API + '/doctors');
        sel.innerHTML = '<option value="">Choose doctor</option>';
        rows.forEach(d => {
          const o = document.createElement('option');
          o.value = d.id;
          o.textContent = d.name + (d.specialty ? ' — ' + d.specialty : '');
          sel.appendChild(o);
        });
      } catch (e) {
        sel.innerHTML = '';
        document.getElementById('bookMsg').textContent = 'Could not load doctors. Is the Node API running on ' + API + '?';
      }
    }

    async function loadSlots(doctorId) {
      const slotSel = document.getElementById('slotSelect');
      slotSel.innerHTML = '';
      slotSel.disabled = true;
      document.getElementById('bookBtn').disabled = true;
      if (!doctorId) return;
      try {
        const rows = await getJson(API + '/doctor_slots?doctorId=' + encodeURIComponent(doctorId) + '&available=1');
        slotSel.innerHTML = '<option value="">Choose slot</option>';
        rows.forEach(s => {
          const o = document.createElement('option');
          o.value = s.id;
          o.textContent = s.start_time.replace('T', ' ').substring(0, 16);
          slotSel.appendChild(o);
        });
        slotSel.disabled = rows.length === 0;
      } catch (e) {
        document.getElementById('bookMsg').textContent = e.message;
      }
    }

    async function loadAppointments() {
      const tbody = document.querySelector('#apptTable tbody');
      tbody.innerHTML = '';
      document.getElementById('listMsg').textContent = 'Loading…';
      try {
        const status = document.getElementById('statusFilter').value;
        const q = document.getElementById('searchFilter').value.trim();
        const params = new URLSearchParams({patientId: String(patientId)});
        if (status) params.set('status', status);
        if (q) params.set('q', q);
        if (!status) params.set('includeCancelled', 'false');
        const rows = await getJson(API + '/api/v1/appointments?' + params.toString());
        document.getElementById('listMsg').textContent = rows.length ? '' : 'No appointments yet.';
        rows.forEach(a => {
          const tr = document.createElement('tr');
          tr.innerHTML = '<td>' + a.id + '</td><td>' + (a.doctor_name || a.doctor_id) + '</td><td>' +
            String(a.appointment_time).replace('T', ' ').substring(0, 16) + '</td><td><span class="badge text-bg-' +
            (a.status === 'SCHEDULED' ? 'primary' : (a.status === 'CONFIRMED' ? 'info' : (a.status === 'CANCELLED' ? 'secondary' : 'success'))) +
            '">' + a.status + '</span></td><td class="small">' + (a.notes || '-') + '</td><td class="text-end">' +
            (a.status === 'SCHEDULED' ? '<button data-id="' + a.id + '" class="btn btn-link btn-sm p-0 cancel">Cancel</button>' : '') + '</td>';
          tbody.appendChild(tr);
        });
        tbody.querySelectorAll('.cancel').forEach(btn => {
          btn.addEventListener('click', async () => {
            if (!confirm('Cancel this appointment?')) return;
            try {
              await fetch(API + '/api/v1/appointments/' + btn.dataset.id, {method: 'DELETE'});
              await loadAppointments();
              const did = document.getElementById('doctorSelect').value;
              if (did) await loadSlots(did);
            } catch (e) {
              alert(e.message);
            }
          });
        });
      } catch (e) {
        document.getElementById('listMsg').textContent = e.message;
      }
    }

    document.getElementById('doctorSelect').addEventListener('change', e => loadSlots(e.target.value));
    document.getElementById('slotSelect').addEventListener('change', e => {
      document.getElementById('bookBtn').disabled = !e.target.value;
    });
    document.getElementById('bookBtn').addEventListener('click', async () => {
      const doctorId = document.getElementById('doctorSelect').value;
      const slotId = document.getElementById('slotSelect').value;
      const notes = document.getElementById('notesInput').value;
      document.getElementById('bookMsg').textContent = '';
      try {
        await getJson(API + '/api/v1/appointments', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            patient_id: patientId,
            doctor_id: Number(doctorId),
            slot_id: Number(slotId),
            notes
          })
        });
        document.getElementById('bookMsg').textContent = 'Booked.';
        document.getElementById('notesInput').value = '';
        await loadAppointments();
        await loadSlots(doctorId);
      } catch (e) {
        document.getElementById('bookMsg').textContent = e.message;
      }
    });

    document.getElementById('refreshBtn').addEventListener('click', loadAppointments);
    document.getElementById('statusFilter').addEventListener('change', loadAppointments);
    document.getElementById('searchFilter').addEventListener('keyup', (e) => {
      if (e.key === 'Enter') loadAppointments();
    });

    loadDoctors().then(loadAppointments);
  </script>
</body>
</html>
