<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Patient — Appointments</title>
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
                <thead style="background: rgba(255,255,255,.03); color: #8892b0;">
                <tr><th>ID</th><th>Doctor</th><th>Time</th><th>Status</th><th>Notes</th><th class="text-end">Prescription</th><th class="text-end"></th></tr>
                </thead>
                <tbody></tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- New Documents Section -->
      <div class="col-12 mt-4">
        <div class="card panel-card">
          <div class="card-body">
            <h2 class="h5 mb-2 panel-title">My Lab Reports & Documents</h2>
            <div class="row">
               <div class="col-md-5 vstack gap-2 border-end border-secondary pe-3">
                 <label class="form-label">Upload New Document</label>
                 <input type="file" id="docUpload" class="form-control form-control-sm">
                 <button class="btn btn-sm btn-outline-light" type="button" id="uploadDocBtn">Upload</button>
                 <div id="uploadMsg" class="small text-muted-portal"></div>
               </div>
               <div class="col-md-7 ps-3">
                 <ul id="docList" class="list-group list-group-flush bg-transparent"></ul>
               </div>
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
              '">' + a.status + '</span></td><td class="small">' + (a.notes || '-') + 
              '</td><td class="text-end">' + (a.status === 'COMPLETED' ? '<button class="btn btn-link btn-sm p-0 me-2 rx" data-id="' + a.id + '">View</button>' : '-') + 
              '</td><td class="text-end">' +
              (a.status === 'SCHEDULED' ? '<button data-id="' + a.id + '" class="btn btn-link btn-sm p-0 cancel">Cancel</button>' : '') + '</td>';
            tbody.appendChild(tr);
          });
          
          tbody.querySelectorAll('.rx').forEach(btn => {
            btn.addEventListener('click', async () => {
              try {
                const rxList = await getJson(API + '/api/v1/appointments/' + btn.dataset.id + '/prescriptions');
                if(!rxList.length) { alert('No prescription found for this visit.'); return; }
                const rx = rxList[0];
                alert(`Medication: ${rx.medication}\nDosage: ${rx.dosage}\nNotes: ${rx.instructions}`);
              } catch(e) { }
            });
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

    async function loadDocuments() {
      const docList = document.getElementById('docList');
      docList.innerHTML = '';
      try {
        const docs = await getJson(API + '/api/v1/patients/' + patientId + '/documents');
        if(!docs.length) { docList.innerHTML = '<li class="list-group-item bg-transparent text-white-50 border-0">No documents uploaded.</li>'; return; }
        docs.forEach(d => {
           docList.innerHTML += `<li class="list-group-item bg-transparent border-secondary text-light d-flex justify-content-between align-items-center" style="color:#ccd6f6!important;">
             <span>\${d.filename} <small style="color:#8892b0;"><br/>by \${d.uploader_role} on \${String(d.uploaded_at).substring(0, 10)}</small></span>
             <a href="\${API}\${d.filepath}" target="_blank" class="btn btn-sm btn-outline-info">Download</a>
           </li>`;
        });
      } catch (e) {
        docList.innerHTML = `<li class="list-group-item bg-transparent text-danger">${e.message}</li>`;
      }
    }
    
    document.getElementById('uploadDocBtn').addEventListener('click', async () => {
      const fileInput = document.getElementById('docUpload');
      if(!fileInput.files[0]) return;
      const formData = new FormData();
      formData.append('file', fileInput.files[0]);
      formData.append('uploader_id', patientId);
      formData.append('uploader_role', 'PATIENT');
      document.getElementById('uploadMsg').textContent = 'Uploading...';
      try {
         const resp = await fetch(API + '/api/v1/patients/' + patientId + '/documents', {
             method: 'POST', body: formData
         });
         if(!resp.ok) throw new Error('Upload failed');
         document.getElementById('uploadMsg').textContent = 'Uploaded successfully.';
         fileInput.value = '';
         loadDocuments();
      } catch(e) {
         document.getElementById('uploadMsg').textContent = e.message;
      }
    });

    async function loadNotifications() {
      try {
        const notifs = await getJson(API + '/api/v1/notifications?userType=PATIENT&userId=' + patientId);
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
    loadNotifications();
    loadDocuments();
    loadDoctors().then(loadAppointments);
  </script>
  <jsp:include page="/WEB-INF/jsp/include/portal-chat-widget.jsp"/>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
