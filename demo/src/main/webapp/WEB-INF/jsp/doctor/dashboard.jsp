<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Doctor — Schedule</title>
  <jsp:include page="/WEB-INF/jsp/include/portal-head.jsp"/>
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
                <thead class="table-light">
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
          if (d === todayStr && (a.status === 'SCHEDULED' || a.status === 'CONFIRMED')) today++;
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
          tr.innerHTML = '<td>' + a.id + '</td><td>' + (a.patient_name || a.patient_id) + '</td><td>' +
            String(a.appointment_time).replace('T', ' ').substring(0, 16) + '</td><td><span class="badge text-bg-' +
            (a.status === 'SCHEDULED' ? 'primary' : (a.status === 'CONFIRMED' ? 'info' : (a.status === 'CANCELLED' ? 'secondary' : 'success'))) +
            '">' + a.status + '</span></td><td class="small">' + (a.notes || '-') + '</td><td class="text-end">' + actions.join('') + '</td>';
          tbody.appendChild(tr);
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

    refreshStats();
    loadAppointments();
  </script>
</body>
</html>
