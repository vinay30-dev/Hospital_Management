<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Doctor — Schedule</title>
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
    .portal-stat { background: rgba(14,232,196,.06); border: 1px solid rgba(14,232,196,.12); border-radius: 12px; padding: .85rem 1rem; }
    .portal-stat .label { font-size: .65rem; text-transform: uppercase; letter-spacing: .1em; color: #8892b0; margin-bottom: .25rem; }
    .portal-stat .value { font-size: 1.35rem; font-weight: 600; color: #0ee8c4; line-height: 1.2; }
    .portal-stat .hint { font-size: .75rem; color: rgba(136,146,176,.85); margin-top: .25rem; }
    .panel-card { background: rgba(17,34,64,.82); border: 1px solid rgba(14,232,196,.12)!important; border-radius: 14px; backdrop-filter: blur(14px); box-shadow: 0 18px 40px rgba(0,0,0,.35); }
    .panel-title { color: #ccd6f6; font-family: 'Playfair Display', Georgia, serif; }
    .panel-subtitle { color: #8892b0 !important; }
    .portal-page .form-label { font-size: 11px; text-transform: uppercase; letter-spacing: .08em; color: #8892b0; margin-bottom: 6px; }
    .portal-page .form-control, .portal-page .form-select { background: rgba(11,22,40,.7)!important; border: 1px solid rgba(136,146,176,.25)!important; color: #ccd6f6!important; }
    .portal-page .form-control:focus, .portal-page .form-select:focus { border-color: #0ee8c4!important; box-shadow: 0 0 0 3px rgba(14,232,196,.12)!important; }
    .portal-page .btn-primary { background: linear-gradient(135deg,#0ee8c4,#0acfb1); border: none; color: #0b1628; font-weight: 600; box-shadow: 0 8px 22px rgba(14,232,196,.35); }
    .portal-page .btn-outline-light { border-color: rgba(204,214,246,.35); color: #ccd6f6; }
    .portal-page .table { color: #ccd6f6; }
    .portal-page .table thead { --bs-table-bg: rgba(255,255,255,.03); --bs-table-color: #8892b0; }
    .portal-page .table tbody tr { --bs-table-bg: transparent; --bs-table-color: #ccd6f6; }
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
      <a class="navbar-brand portal-brand fw-semibold" href="${pageContext.request.contextPath}/">Hospital</a>
      <div class="d-flex align-items-center gap-2 flex-wrap justify-content-end">
        <div class="dropdown me-2">
          <button class="btn btn-outline-light btn-sm position-relative dropdown-toggle" type="button" id="notifDropdown" data-bs-toggle="dropdown" aria-expanded="false">
            🔔 
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" id="notifBadge" style="display:none;">0</span>
          </button>
          <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="notifDropdown" id="notifList" style="min-width: 250px; background: rgba(11,22,40,.9); border: 1px solid rgba(14,232,196,.15);">
             <li><a class="dropdown-item text-white-50" href="#">No new notifications</a></li>
          </ul>
        </div>
        <span class="text-white-50 small d-none d-md-inline">Signed in as <span class="text-white">${sessionScope.displayName}</span></span>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/doctor/analytics">Analytics</a>
        <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">Sign out</a>
      </div>
    </div>
  </nav>

  <main class="container py-4 portal-main">
    <header class="portal-hero">
      <h1>Physician workspace</h1>
      <p>Manage availability, review visits, and keep your schedule under control.</p>
    </header>

    <div class="row g-3 mb-4">
      <div class="col-6 col-md-3">
        <div class="portal-stat">
          <div class="label">Today</div>
          <div class="value" id="statToday">—</div>
          <div class="hint">Scheduled + confirmed</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="portal-stat">
          <div class="label">Needs action</div>
          <div class="value" id="statPending">—</div>
          <div class="hint">Awaiting confirmation</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="portal-stat">
          <div class="label">Active total</div>
          <div class="value" id="statActive">—</div>
          <div class="hint">Non-cancelled</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="portal-stat">
          <div class="label">API</div>
          <div class="value" style="font-size:0.95rem;word-break:break-all;">Live</div>
          <div class="hint" id="apiHint">Node appointments</div>
        </div>
      </div>
    </div>

    <div class="row g-4">
      <div class="col-12 col-lg-5">
        <div class="card panel-card">
          <div class="card-body">
            <div class="d-flex align-items-center justify-content-between mb-2">
              <h2 class="h5 mb-0 panel-title">Add availability slot</h2>
              <span class="badge text-bg-secondary">Doctor</span>
            </div>
            <p class="small mb-3 panel-subtitle">Create a slot so patients can book it from the portal.</p>

            <div class="vstack gap-3">
              <div>
                <label class="form-label">Start</label>
                <input class="form-control" type="datetime-local" id="startTime"/>
              </div>
              <div>
                <label class="form-label">End</label>
                <input class="form-control" type="datetime-local" id="endTime"/>
              </div>
              <button class="btn btn-primary" type="button" id="addSlotBtn">Add slot</button>
              <div id="slotMsg" class="small text-muted-portal"></div>
              
              <div class="mt-2">
                <div class="d-flex justify-content-between align-items-center mb-1">
                  <h3 class="h6 mb-0" style="color: #ccd6f6;">Upcoming Slots</h3>
                </div>
                <ul id="doctorSlotsList" class="list-group list-group-flush bg-transparent small overflow-auto" style="max-height: 180px;"></ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 col-lg-7">
        <div class="card panel-card">
          <div class="card-body">
            <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3">
              <h2 class="h5 mb-0 panel-title">Appointments</h2>
              <button type="button" class="btn btn-sm btn-outline-light" id="exportCsvBtn">Export CSV</button>
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
                <label class="form-label mb-1">Patient search</label>
                <input id="searchFilter" class="form-control form-control-sm" placeholder="Name or email"/>
              </div>
              <div class="col-md-3 d-flex align-items-end">
                <button id="refreshBtn" class="btn btn-sm btn-primary w-100" type="button">Refresh</button>
              </div>
            </div>
            <div id="listMsg" class="small text-muted-portal mb-2"></div>

            <div class="table-responsive">
              <table class="table table-sm align-middle mb-0" id="apptTable">
                <thead style="background: rgba(255,255,255,.03); color: #8892b0;">
                <tr><th>ID</th><th>Patient</th><th>Time</th><th>Status</th><th>Notes</th><th class="text-end">Actions</th></tr>
                </thead>
                <tbody></tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <!-- Docs Modal -->
  <div class="modal fade" id="docsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content" style="background: rgba(11,22,40,.95); border: 1px solid rgba(14,232,196,.25); color: #ccd6f6;">
        <div class="modal-header border-secondary">
          <h5 class="modal-title" style="font-family: 'Playfair Display', serif;">Patient Documents</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <ul id="modalDocList" class="list-group list-group-flush bg-transparent"></ul>
        </div>
      </div>
    </div>
  </div>

  <footer class="portal-footer">
    <p class="mb-0">${sessionScope.displayName} · Physician · <a href="${initParam.nodeApiBase}/health" target="_blank" rel="noopener">API health</a></p>
  </footer>

  <script>
    const API = '${initParam.nodeApiBase}';
    const doctorId = Number('${sessionScope.userId}');
    let lastRows = [];

    async function getJson(url, opts) {
      const r = await fetch(url, Object.assign({headers: {'Accept': 'application/json'}}, opts || {}));
      const text = await r.text();
      let data = null;
      try { data = text ? JSON.parse(text) : null; } catch (e) {}
      if (!r.ok) throw new Error((data && data.message) || text || r.statusText);
      return data;
    }

    async function refreshStats() {
      try {
        const rows = await getJson(API + '/api/v1/appointments?doctorId=' + doctorId + '&includeCancelled=false');
        const todayStr = new Date().toISOString().slice(0, 10);
        let today = 0, pending = 0;
        rows.forEach(a => {
          const d = String(a.appointment_time).slice(0, 10);
          if (a.status === 'SCHEDULED' || a.status === 'CONFIRMED') today++;
          if (a.status === 'SCHEDULED') pending++;
        });
        document.getElementById('statToday').textContent = today;
        document.getElementById('statPending').textContent = pending;
        document.getElementById('statActive').textContent = rows.length;
      } catch (e) {
        document.getElementById('statToday').textContent = '—';
        document.getElementById('statPending').textContent = '—';
        document.getElementById('statActive').textContent = '—';
      }
    }

    document.getElementById('addSlotBtn').addEventListener('click', async () => {
      const start = document.getElementById('startTime').value;
      const end = document.getElementById('endTime').value;
      document.getElementById('slotMsg').textContent = '';
      if (!start || !end) {
        document.getElementById('slotMsg').textContent = 'Pick start and end.';
        return;
      }
      try {
        await getJson(API + '/doctor_slots', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            doctor_id: doctorId,
            start_time: start.replace(' ', 'T'),
            end_time: end.replace(' ', 'T')
          })
        });
        document.getElementById('slotMsg').textContent = 'Slot added.';
        await loadAppointments();
        await refreshStats();
        await loadDoctorSlots();
      } catch (e) {
        document.getElementById('slotMsg').textContent = e.message;
      }
    });

    async function loadAppointments() {
      const tbody = document.querySelector('#apptTable tbody');
      tbody.innerHTML = '';
      document.getElementById('listMsg').textContent = 'Loading…';
      try {
        const status = document.getElementById('statusFilter').value;
        const q = document.getElementById('searchFilter').value.trim();
        const params = new URLSearchParams({doctorId: String(doctorId)});
        if (status) params.set('status', status);
        if (q) params.set('q', q);
        if (!status) params.set('includeCancelled', 'false');
        const rows = await getJson(API + '/api/v1/appointments?' + params.toString());
        lastRows = rows;
        document.getElementById('listMsg').textContent = rows.length ? '' : 'No appointments yet.';
        rows.forEach(a => {
          const tr = document.createElement('tr');
          const actions = [];
          if (a.status === 'SCHEDULED') {
            actions.push('<button class="btn btn-link btn-sm p-0 me-2 action" data-id="' + a.id + '" data-action="CONFIRMED">Confirm</button>');
            actions.push('<button class="btn btn-link btn-sm p-0 text-danger action" data-id="' + a.id + '" data-action="CANCELLED">Cancel</button>');
          } else if (a.status === 'CONFIRMED') {
            actions.push('<button class="btn btn-link btn-sm p-0 me-2 action" data-id="' + a.id + '" data-action="COMPLETED">Complete</button>');
            actions.push('<button class="btn btn-link btn-sm p-0 text-danger action" data-id="' + a.id + '" data-action="CANCELLED">Cancel</button>');
          }
          if (a.status === 'COMPLETED' || a.status === 'CONFIRMED') {
            actions.push('<button class="btn btn-link btn-sm p-0 me-2 prescribe" data-id="' + a.id + '">Prescribe</button>');
          }
          actions.push('<button class="btn btn-link btn-sm p-0 view-docs" data-pid="' + a.patient_id + '">Docs</button>');

          tr.innerHTML = '<td>' + a.id + '</td><td>' + (a.patient_name || a.patient_id) + '</td><td>' +
            String(a.appointment_time).replace('T', ' ').substring(0, 16) + '</td><td><span class="badge text-bg-' +
            (a.status === 'SCHEDULED' ? 'primary' : (a.status === 'CONFIRMED' ? 'info' : (a.status === 'CANCELLED' ? 'secondary' : 'success'))) +
            '">' + a.status + '</span></td><td class="small">' + (a.notes || '-') + '</td><td class="text-end">' + actions.join('') + '</td>';
          tbody.appendChild(tr);
        });

        tbody.querySelectorAll('.prescribe').forEach(btn => {
          btn.addEventListener('click', async () => {
             const med = prompt('Medication name:');
             if(!med) return;
             const dosage = prompt('Dosage:');
             if(!dosage) return;
             const inst = prompt('Instructions (optional):');
             try {
                await getJson(API + '/api/v1/appointments/' + btn.dataset.id + '/prescriptions', {
                   method: 'POST',
                   headers: {'Content-Type': 'application/json'},
                   body: JSON.stringify({ medication: med, dosage: dosage, instructions: inst })
                });
                alert('Prescription saved.');
             } catch(e) { alert(e.message); }
          });
        });

        tbody.querySelectorAll('.view-docs').forEach(btn => {
          btn.addEventListener('click', async () => {
             const list = document.getElementById('modalDocList');
             list.innerHTML = 'Loading...';
             const modal = new bootstrap.Modal(document.getElementById('docsModal'));
             modal.show();
             try {
                const docs = await getJson(API + '/api/v1/patients/' + btn.dataset.pid + '/documents');
                if(!docs.length) { list.innerHTML = 'No documents found.'; return; }
                list.innerHTML = '';
                docs.forEach(d => {
                   list.innerHTML += `<li class="list-group-item bg-transparent border-secondary text-light d-flex justify-content-between align-items-center" style="color:#ccd6f6!important;">
                     <span>\${d.filename} <small style="color:#8892b0;"><br/>by \${d.uploader_role} on \${String(d.uploaded_at).substring(0, 10)}</small></span>
                     <a href="\${API}\${d.filepath}" target="_blank" class="btn btn-sm btn-outline-info">Download</a>
                   </li>`;
                });
             } catch(e) { list.innerHTML = e.message; }
          });
        });
        tbody.querySelectorAll('.action').forEach(btn => {
          btn.addEventListener('click', async () => {
            const note = prompt('Optional note for this update:', '');
            try {
              await getJson(API + '/api/v1/appointments/' + btn.dataset.id + '/status', {
                method: 'PATCH',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({status: btn.dataset.action, notes: note || undefined})
              });
              await loadAppointments();
              await refreshStats();
            } catch (err) {
              alert(err.message);
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
      const cols = ['id', 'patient_name', 'appointment_time', 'status', 'notes'];
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
      a.download = 'doctor-appointments.csv';
      a.click();
      URL.revokeObjectURL(url);
    });

    document.getElementById('refreshBtn').addEventListener('click', () => { loadAppointments(); refreshStats(); });
    document.getElementById('statusFilter').addEventListener('change', loadAppointments);
    document.getElementById('searchFilter').addEventListener('keyup', (e) => {
      if (e.key === 'Enter') loadAppointments();
    });

    async function loadNotifications() {
      try {
        const notifs = await getJson(API + '/api/v1/notifications?userType=DOCTOR&userId=' + doctorId);
        const badge = document.getElementById('notifBadge');
        const list = document.getElementById('notifList');
        if(notifs.length > 0) {
           badge.textContent = notifs.length;
           badge.style.display = 'inline-block';
           list.innerHTML = '';
           notifs.forEach(n => {
              const li = document.createElement('li');
              li.innerHTML = `<a class="dropdown-item text-white" href="#" style="white-space:normal;font-size:0.85rem;">\${n.message}</a>`;
              li.addEventListener('click', async (e) => {
                 e.preventDefault();
                 await fetch(API + '/api/v1/notifications/' + n.id + '/read', {method:'PATCH'});
                 loadNotifications();
              });
              list.appendChild(li);
           });
        } else {
           badge.style.display = 'none';
           list.innerHTML = '<li><a class="dropdown-item text-white-50" href="#">No new notifications</a></li>';
        }
      } catch(e) {}
    }

    setInterval(loadNotifications, 30000); // Check every 30s

    async function loadDoctorSlots() {
      const list = document.getElementById('doctorSlotsList');
      list.innerHTML = '';
      try {
        const slots = await getJson(API + '/doctor_slots?doctorId=' + doctorId);
        if(!slots.length) {
          list.innerHTML = '<li class="list-group-item bg-transparent text-muted-portal border-0 px-0">No slots created.</li>';
          return;
        }
        slots.forEach(s => {
          list.innerHTML += `<li class="list-group-item bg-transparent text-light border-secondary px-0 d-flex justify-content-between align-items-center" style="color:#ccd6f6!important;">
            <span>\${String(s.start_time).replace('T', ' ').substring(0, 16)}</span>
            <span class="badge \${s.is_booked ? 'text-bg-success' : 'text-bg-secondary'}">\${s.is_booked ? 'Booked' : 'Open'}</span>
          </li>`;
        });
      } catch (e) {
        list.innerHTML = `<li class="list-group-item bg-transparent text-danger px-0">${e.message}</li>`;
      }
    }

    loadNotifications();
    refreshStats();
    loadAppointments();
    loadDoctorSlots();
  </script>
  <jsp:include page="/WEB-INF/jsp/include/portal-chat-widget.jsp"/>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
