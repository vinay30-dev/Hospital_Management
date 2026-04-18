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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/portal.css"/>
</head>
<body class="app-bg portal-body portal-page">
  <div class="portal-bg-orb portal-bg-orb-1"></div>
  <div class="portal-bg-orb portal-bg-orb-2"></div>
  <div class="portal-bg-grid"></div>

  <nav class="navbar navbar-expand-lg navbar-dark portal-nav">
    <div class="container">
      <a class="navbar-brand portal-brand fw-semibold" href="${pageContext.request.contextPath}/">Hospital</a>
      <div class="d-flex align-items-center gap-2 flex-wrap justify-content-end">
        <span class="text-white-50 small d-none d-md-inline">Signed in as <span class="text-white">${sessionScope.displayName}</span></span>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/patient/profile">Profile</a>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">Sign out</a>
      </div>
    </div>
  </nav>

  <main class="container py-4 portal-main">
    <header class="portal-hero">
      <h1>Your care hub</h1>
      <p>Book visits, track status, and manage upcoming appointments in one place.</p>
    </header>

    <div class="row g-3 mb-4">
      <div class="col-md-4">
        <div class="portal-stat h-100">
          <div class="label">Upcoming</div>
          <div class="value" id="statUpcoming">—</div>
          <div class="hint">Scheduled or confirmed, future</div>
        </div>
      </div>
      <div class="col-md-8">
        <div class="card panel-card mb-0">
          <div class="card-body py-3">
            <div class="label text-uppercase small text-muted-portal mb-1">Next visit</div>
            <div id="nextVisit" class="panel-title mb-0" style="font-size:1rem;">—</div>
          </div>
        </div>
      </div>
    </div>

    <div class="row g-4">
      <div class="col-12 col-lg-5">
        <div class="card panel-card">
          <div class="card-body">
            <h2 class="h5 mb-1 panel-title">Book an appointment</h2>
            <p class="text-muted-portal small mb-3">Choose a doctor and an open slot. Add notes for triage.</p>

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
                <label class="form-label">Reason / notes</label>
                <textarea class="form-control" id="notesInput" rows="2" placeholder="Symptoms, medications, or questions"></textarea>
              </div>
              <button class="btn btn-primary" type="button" id="bookBtn" disabled>Book visit</button>
              <div id="bookMsg" class="small text-muted-portal"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 col-lg-7">
        <div class="card panel-card">
          <div class="card-body">
            <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3">
              <h2 class="h5 mb-0 panel-title">Your appointments</h2>
              <div class="d-flex gap-2 align-items-center">
                <span class="badge text-bg-secondary">Patient</span>
                <button type="button" class="btn btn-sm btn-outline-light" id="exportCsvBtn">Export CSV</button>
              </div>
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
                <label class="form-label mb-1">Doctor search</label>
                <input id="searchFilter" class="form-control form-control-sm" placeholder="Name or specialty"/>
              </div>
              <div class="col-md-3 d-flex align-items-end">
                <button id="refreshBtn" class="btn btn-sm btn-primary w-100" type="button">Refresh</button>
              </div>
            </div>
            <div id="listMsg" class="small text-muted-portal mb-2"></div>

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

  <footer class="portal-footer">
    <p class="mb-0">Questions? <a href="mailto:support@hospital.local">support@hospital.local</a> · <a href="${initParam.nodeApiBase}/health" target="_blank" rel="noopener">Service status</a></p>
  </footer>

  <script>
    const API = '${initParam.nodeApiBase}';
    const patientId = Number('${sessionScope.userId}');
    let lastRows = [];

    async function getJson(url, opts) {
      const r = await fetch(url, Object.assign({headers: {'Accept': 'application/json'}}, opts || {}));
      const text = await r.text();
      let data = null;
      try { data = text ? JSON.parse(text) : null; } catch (e) {}
      if (!r.ok) throw new Error((data && data.message) || text || r.statusText);
      return data;
    }

    function parseTime(v) {
      if (!v) return null;
      const s = String(v).replace(' ', 'T');
      const d = new Date(s);
      return isNaN(d.getTime()) ? null : d;
    }

    function updatePatientStats(rows) {
      const now = new Date();
      const active = rows.filter(a => a.status === 'SCHEDULED' || a.status === 'CONFIRMED');
      let upcoming = 0;
      let next = null;
      const future = active
        .map(a => ({a, t: parseTime(a.appointment_time)}))
        .filter(x => x.t && x.t >= now)
        .sort((x, y) => x.t - y.t);
      upcoming = future.length;
      if (future.length) next = future[0].a;
      document.getElementById('statUpcoming').textContent = upcoming;
      const el = document.getElementById('nextVisit');
      if (!next) {
        el.textContent = 'No upcoming visits.';
      } else {
        const when = String(next.appointment_time).replace('T', ' ').substring(0, 16);
        el.innerHTML = '<strong>' + (next.doctor_name || 'Doctor') + '</strong> · ' + when +
          ' <span class="badge text-bg-primary ms-1">' + next.status + '</span>';
      }
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
        lastRows = rows;
        document.getElementById('listMsg').textContent = rows.length ? '' : 'No appointments yet.';
        updatePatientStats(rows);
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

    document.getElementById('exportCsvBtn').addEventListener('click', () => {
      if (!lastRows.length) {
        alert('No rows to export.');
        return;
      }
      const cols = ['id', 'doctor_name', 'appointment_time', 'status', 'notes'];
      let csv = cols.join(',') + '\n';
      lastRows.forEach(a => {
        const row = cols.map(c => {
          let v = a[c] != null ? String(a[c]) : '';
          v = v.replace(/"/g, '""');
          if (/[",\n]/.test(v)) v = '"' + v + '"';
          return v;
        });
        csv += row.join(',') + '\n';
      });
      const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'});
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'patient-appointments.csv';
      a.click();
      URL.revokeObjectURL(url);
    });

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
