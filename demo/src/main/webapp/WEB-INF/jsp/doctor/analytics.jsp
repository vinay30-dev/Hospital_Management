<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Doctor — Analytics</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css"/>
  <style>
    :root {
      --navy: #0b1628;
      --navy-mid: #112240;
      --teal: #0ee8c4;
      --teal-dim: rgba(14,232,196,0.1);
      --teal-glow: rgba(14,232,196,0.3);
      --slate: #8892b0;
      --light: #ccd6f6;
      --card-bg: rgba(17,34,64,0.9);
      --input-bg: rgba(11,22,40,0.6);
      --border: rgba(136,146,176,0.15);
      --radius: 14px;
    }
    *, *::before, *::after { box-sizing: border-box; }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--navy);
      color: var(--light);
      min-height: 100vh;
    }
    body::before {
      content: '';
      position: fixed; inset: 0;
      background-image:
        linear-gradient(rgba(14,232,196,0.025) 1px, transparent 1px),
        linear-gradient(90deg, rgba(14,232,196,0.025) 1px, transparent 1px);
      background-size: 60px 60px;
      pointer-events: none; z-index: 0;
    }

    /* ── Navbar ── */
    .app-nav {
      background: rgba(11,22,40,0.95);
      backdrop-filter: blur(16px);
      border-bottom: 1px solid var(--border);
      padding: 0 24px; height: 62px;
      display: flex; align-items: center; justify-content: space-between;
      position: sticky; top: 0; z-index: 100;
    }
    .nav-brand { display: flex; align-items: center; gap: 10px; text-decoration: none; }
    .nav-logo {
      width: 34px; height: 34px; border-radius: 9px;
      background: linear-gradient(135deg, var(--teal), #3b82f6);
      display: flex; align-items: center; justify-content: center;
      font-family: 'Playfair Display', serif; font-size: 13px; font-weight: 700; color: var(--navy);
    }
    .nav-brand-text { font-weight: 600; font-size: 15px; color: var(--light); }
    .nav-right { display: flex; align-items: center; gap: 10px; }
    .btn-nav {
      font-size: 13px; font-weight: 500; color: var(--slate);
      border: 1px solid var(--border); border-radius: 8px;
      padding: 6px 14px; background: transparent; text-decoration: none;
      transition: color 0.15s, border-color 0.15s, background 0.15s;
    }
    .btn-nav:hover { color: var(--light); border-color: rgba(136,146,176,0.4); background: rgba(136,146,176,0.06); }
    .btn-nav.active { color: var(--teal); border-color: rgba(14,232,196,0.35); background: var(--teal-dim); }

    /* ── Main ── */
    .app-main {
      position: relative; z-index: 1;
      max-width: 1200px; margin: 0 auto;
      padding: 30px 24px 48px;
    }

    .page-header {
      display: flex; align-items: flex-end; justify-content: space-between;
      flex-wrap: wrap; gap: 12px; margin-bottom: 28px;
    }
    .page-title { font-family: 'Playfair Display', serif; font-size: 26px; font-weight: 600; color: var(--light); }
    .doctor-badge {
      font-size: 13px; color: var(--slate);
      background: var(--teal-dim); border: 1px solid rgba(14,232,196,0.18);
      padding: 5px 14px; border-radius: 20px;
    }
    .doctor-badge strong { color: var(--teal); font-weight: 500; }

    /* ── Filter card ── */
    .panel {
      background: var(--card-bg);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      overflow: hidden;
      box-shadow: 0 8px 32px rgba(0,0,0,0.3);
    }
    .panel-body { padding: 22px 24px; }

    .form-label {
      font-size: 11.5px; font-weight: 500;
      text-transform: uppercase; letter-spacing: 0.08em;
      color: var(--slate); margin-bottom: 7px; display: block;
    }
    .form-control {
      background: var(--input-bg) !important;
      border: 1px solid var(--border) !important;
      border-radius: 10px !important;
      color: var(--light) !important;
      font-size: 14px !important;
      padding: 10px 13px !important;
      font-family: 'DM Sans', sans-serif !important;
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    .form-control:focus {
      border-color: var(--teal) !important;
      box-shadow: 0 0 0 3px var(--teal-dim) !important;
      outline: none !important;
    }

    .btn-primary-custom {
      background: linear-gradient(135deg, var(--teal), #0acfb1);
      color: var(--navy); font-weight: 600; font-size: 14px;
      border: none; border-radius: 10px;
      padding: 11px 20px; cursor: pointer; width: 100%;
      transition: transform 0.15s, box-shadow 0.2s;
      box-shadow: 0 4px 16px var(--teal-glow);
      font-family: 'DM Sans', sans-serif;
    }
    .btn-primary-custom:hover { transform: translateY(-1px); box-shadow: 0 8px 24px var(--teal-glow); }

    /* Auto-refresh toggle */
    .toggle-row {
      display: flex; align-items: center; gap: 10px; margin-top: 14px;
    }
    .form-check-input {
      width: 36px !important; height: 20px !important;
      border-radius: 20px !important;
      background-color: rgba(136,146,176,0.2) !important;
      border: 1px solid rgba(136,146,176,0.25) !important;
      cursor: pointer; appearance: none; -webkit-appearance: none;
      position: relative; transition: background 0.2s;
    }
    .form-check-input::after {
      content: ''; position: absolute; top: 2px; left: 2px;
      width: 14px; height: 14px; border-radius: 50%;
      background: var(--slate); transition: transform 0.2s, background 0.2s;
    }
    .form-check-input:checked {
      background-color: var(--teal-dim) !important;
      border-color: rgba(14,232,196,0.4) !important;
    }
    .form-check-input:checked::after { transform: translateX(16px); background: var(--teal); }
    .form-check-label { font-size: 13px; color: var(--slate); cursor: pointer; }

    /* ── Stat cards ── */
    .stat-card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      padding: 20px 22px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.25);
      transition: transform 0.2s, box-shadow 0.2s;
      position: relative; overflow: hidden;
    }
    .stat-card::before {
      content: ''; position: absolute; top: 0; left: 0; right: 0;
      height: 2px;
    }
    .stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(0,0,0,0.35); }
    .stat-card.total::before    { background: linear-gradient(90deg, var(--teal), #3b82f6); }
    .stat-card.scheduled::before { background: linear-gradient(90deg, #3b82f6, #6366f1); }
    .stat-card.completed::before { background: linear-gradient(90deg, #22c55e, #16a34a); }
    .stat-card.cancelled::before  { background: var(--slate); }

    .stat-label {
      font-size: 11px; font-weight: 500;
      text-transform: uppercase; letter-spacing: 0.1em;
      color: var(--slate); margin-bottom: 10px;
    }
    .stat-value {
      font-family: 'Playfair Display', serif;
      font-size: 38px; font-weight: 600;
      color: var(--light); line-height: 1;
    }
    .stat-card.total    .stat-value { color: var(--teal); }
    .stat-card.scheduled .stat-value { color: #93c5fd; }
    .stat-card.completed .stat-value { color: #86efac; }

    /* ── Chart cards ── */
    .chart-card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      padding: 22px 24px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.3);
      height: 100%;
    }
    .chart-title {
      font-size: 13px; font-weight: 600;
      color: var(--light); margin-bottom: 18px;
      text-transform: uppercase; letter-spacing: 0.06em;
    }

    #msg { font-size: 13px; color: #ff8a8a; margin-top: 12px; }
  </style>
</head>
<body>
  <nav class="app-nav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/">
      <div class="nav-logo">HM</div>
      <span class="nav-brand-text">Hospital Management</span>
    </a>
    <div class="nav-right">
      <a class="btn-nav" href="${pageContext.request.contextPath}/doctor/dashboard">Dashboard</a>
      <a class="btn-nav active" href="#">Analytics</a>
      <a class="btn-nav" href="${pageContext.request.contextPath}/logout">Sign out</a>
    </div>
  </nav>

  <main class="app-main">
    <div class="page-header">
      <h1 class="page-title">Analytics</h1>
      <div class="doctor-badge">Dr. <strong>${sessionScope.displayName}</strong></div>
    </div>

    <!-- Date filter -->
    <div class="panel mb-4">
      <div class="panel-body">
        <div class="row g-3 align-items-end">
          <div class="col-md-4">
            <label class="form-label">From Date</label>
            <input class="form-control" id="fromDate" type="date"/>
          </div>
          <div class="col-md-4">
            <label class="form-label">To Date</label>
            <input class="form-control" id="toDate" type="date"/>
          </div>
          <div class="col-md-4">
            <button class="btn-primary-custom" id="refreshBtn" type="button">↻ Refresh Data</button>
          </div>
        </div>
        <div class="toggle-row">
          <input class="form-check-input" type="checkbox" id="autoRefresh" checked>
          <label class="form-check-label" for="autoRefresh">Auto-refresh every 15 seconds</label>
        </div>
      </div>
    </div>

    <!-- Stat cards -->
    <div class="row g-3 mb-4">
      <div class="col-6 col-lg-3">
        <div class="stat-card total">
          <div class="stat-label">Total</div>
          <div class="stat-value" id="total">0</div>
        </div>
      </div>
      <div class="col-6 col-lg-3">
        <div class="stat-card scheduled">
          <div class="stat-label">Scheduled</div>
          <div class="stat-value" id="scheduled">0</div>
        </div>
      </div>
      <div class="col-6 col-lg-3">
        <div class="stat-card completed">
          <div class="stat-label">Completed</div>
          <div class="stat-value" id="completed">0</div>
        </div>
      </div>
      <div class="col-6 col-lg-3">
        <div class="stat-card cancelled">
          <div class="stat-label">Cancelled</div>
          <div class="stat-value" id="cancelled">0</div>
        </div>
      </div>
    </div>

    <!-- Charts -->
    <div class="row g-3">
      <div class="col-lg-4">
        <div class="chart-card">
          <div class="chart-title">Status Distribution</div>
          <canvas id="statusChart" height="240"></canvas>
        </div>
      </div>
      <div class="col-lg-8">
        <div class="chart-card">
          <div class="chart-title">Appointment Trend</div>
          <canvas id="timelineChart" height="240"></canvas>
        </div>
      </div>
    </div>

    <p id="msg"></p>
  </main>

  <script>
    const API = '${initParam.nodeApiBase}';
    const doctorId = ${sessionScope.userId};
    let statusChart, timelineChart, refreshTimer;

    // Chart.js global defaults for dark theme
    Chart.defaults.color = '#8892b0';
    Chart.defaults.borderColor = 'rgba(136,146,176,0.12)';

    async function getJson(url) {
      const r = await fetch(url, {headers: {'Accept': 'application/json'}});
      const text = await r.text();
      const data = text ? JSON.parse(text) : {};
      if (!r.ok) throw new Error(data.message || r.statusText);
      return data;
    }

    function getCount(map, key) { return Number(map[key] || 0); }

    function ensureCharts() {
      if (!statusChart) {
        statusChart = new Chart(document.getElementById('statusChart'), {
          type: 'doughnut',
          data: {
            labels: ['Scheduled', 'Confirmed', 'Completed', 'Cancelled'],
            datasets: [{
              data: [0, 0, 0, 0],
              backgroundColor: ['rgba(59,130,246,0.75)', 'rgba(14,232,196,0.75)', 'rgba(34,197,94,0.75)', 'rgba(136,146,176,0.5)'],
              borderColor: ['#3b82f6', '#0ee8c4', '#22c55e', '#8892b0'],
              borderWidth: 2,
              hoverOffset: 6
            }]
          },
          options: {
            plugins: {
              legend: { position: 'bottom', labels: { padding: 16, usePointStyle: true, pointStyleWidth: 8, font: { family: 'DM Sans', size: 12 } } }
            },
            maintainAspectRatio: false,
            cutout: '65%'
          }
        });
      }
      if (!timelineChart) {
        const tealGrad = document.getElementById('timelineChart').getContext('2d').createLinearGradient(0,0,0,200);
        tealGrad.addColorStop(0, 'rgba(14,232,196,0.25)');
        tealGrad.addColorStop(1, 'rgba(14,232,196,0)');

        timelineChart = new Chart(document.getElementById('timelineChart'), {
          type: 'line',
          data: {
            labels: [],
            datasets: [
              {label: 'Scheduled', data: [], borderColor: '#3b82f6', backgroundColor: 'rgba(59,130,246,0.08)', fill: true, tension: 0.35, pointRadius: 3, pointHoverRadius: 5},
              {label: 'Confirmed', data: [], borderColor: '#0ee8c4', backgroundColor: tealGrad, fill: true, tension: 0.35, pointRadius: 3, pointHoverRadius: 5},
              {label: 'Completed', data: [], borderColor: '#22c55e', backgroundColor: 'rgba(34,197,94,0.08)', fill: true, tension: 0.35, pointRadius: 3, pointHoverRadius: 5},
              {label: 'Cancelled', data: [], borderColor: '#8892b0', backgroundColor: 'transparent', fill: false, tension: 0.35, pointRadius: 2, borderDash: [4,4]}
            ]
          },
          options: {
            responsive: true, maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            plugins: {
              legend: { position: 'bottom', labels: { padding: 16, usePointStyle: true, pointStyleWidth: 8, font: { family: 'DM Sans', size: 12 } } }
            },
            scales: {
              x: { grid: { color: 'rgba(136,146,176,0.08)' }, ticks: { font: { family: 'DM Sans', size: 11 } } },
              y: { beginAtZero: true, ticks: { precision: 0, font: { family: 'DM Sans', size: 11 } }, grid: { color: 'rgba(136,146,176,0.08)' } }
            }
          }
        });
      }
    }

    function getFilters() {
      const from = document.getElementById('fromDate').value;
      const to   = document.getElementById('toDate').value;
      const params = new URLSearchParams({doctorId: String(doctorId)});
      if (from) params.set('from', from + ' 00:00:00');
      if (to)   params.set('to',   to   + ' 23:59:59');
      return params;
    }

    async function loadSummary() {
      const params = getFilters();
      try {
        const [data, timeline] = await Promise.all([
          getJson(API + '/api/v1/appointments/summary?' + params.toString()),
          getJson(API + '/api/v1/appointments/summary/timeline?' + params.toString())
        ]);
        const statusMap = {};
        (data.byStatus || []).forEach(x => statusMap[x.status] = x.total);
        document.getElementById('total').textContent     = data.totals?.totalAppointments || 0;
        document.getElementById('scheduled').textContent = getCount(statusMap, 'SCHEDULED') + getCount(statusMap, 'CONFIRMED');
        document.getElementById('completed').textContent = getCount(statusMap, 'COMPLETED');
        document.getElementById('cancelled').textContent = getCount(statusMap, 'CANCELLED');
        statusChart.data.datasets[0].data = [
          getCount(statusMap, 'SCHEDULED'),
          getCount(statusMap, 'CONFIRMED'),
          getCount(statusMap, 'COMPLETED'),
          getCount(statusMap, 'CANCELLED')
        ];
        statusChart.update('active');
        timelineChart.data.labels = timeline.labels || [];
        timelineChart.data.datasets[0].data = timeline.series?.SCHEDULED || [];
        timelineChart.data.datasets[1].data = timeline.series?.CONFIRMED  || [];
        timelineChart.data.datasets[2].data = timeline.series?.COMPLETED  || [];
        timelineChart.data.datasets[3].data = timeline.series?.CANCELLED  || [];
        timelineChart.update('active');
        document.getElementById('msg').textContent = '';
      } catch (e) {
        document.getElementById('msg').textContent = e.message;
      }
    }

    function setAutoRefresh() {
      if (refreshTimer) clearInterval(refreshTimer);
      if (document.getElementById('autoRefresh').checked) {
        refreshTimer = setInterval(loadSummary, 15000);
      }
    }

    ensureCharts();
    document.getElementById('refreshBtn').addEventListener('click', loadSummary);
    document.getElementById('autoRefresh').addEventListener('change', setAutoRefresh);
    setAutoRefresh();
    loadSummary();
  </script>
</body>
</html>
