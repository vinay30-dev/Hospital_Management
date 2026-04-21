# Hospital Management

Two-part system: a **Java (Maven) WAR** on Tomcat for the web UI and patient/doctor records (Hibernate), and a **Node.js Express** appointment REST API on port **3001** that shares the same **MySQL** database.

## Prerequisites

- JDK 17+, Maven 3.8+
- Tomcat 9+
- Node.js 18+
- MySQL 8+

## 1. Database

Create the schema and seed data:

```bash
mysql -u root -p < sql/schema.sql
```

If MySQL uses a password, set it for both apps:

- **Hibernate:** set env `HOSPITAL_DB_PASSWORD` or JVM `-Dhospital.db.password=...`, and optionally `HOSPITAL_DB_URL`, `HOSPITAL_DB_USER`.
- **Node:** set `HOSPITAL_DB_PASSWORD` (and optionally `HOSPITAL_DB_HOST`, `HOSPITAL_DB_USER`, `HOSPITAL_DB_NAME`).

Default app credentials are `hospital_user` / `hospital123` (created by `schema.sql`).
Update `demo/src/main/resources/hibernate.cfg.xml` if your MySQL host/user differs.

## 2. Node appointment API

```bash
cd node-api
npm install
npm start
```

Endpoints include:

- `GET /health`
- `POST /auth/login` — JSON `{ "email", "password" }` (optional; Java UI uses servlet login)
- `GET /doctors`
- `GET /doctor_slots?doctorId=&available=1`
- `POST /doctor_slots`
- `GET /api/v1/appointments?patientId=` or `?doctorId=`
- `POST /api/v1/appointments` — `{ patient_id, doctor_id, slot_id, notes? }`
- `PATCH /api/v1/appointments/:id/status` — `{ status, notes? }` (`SCHEDULED|CONFIRMED|COMPLETED|CANCELLED`)
- `GET /api/v1/appointments/summary?doctorId=&from=&to=`
- `DELETE /api/v1/appointments/:id`

Default CORS allows `http://localhost:8080`. Override with env `CORS_ORIGINS` (comma-separated).

## 3. Java WAR (Tomcat)

```bash
cd demo
mvn package
```

Copy `demo/target/hospital-management.war` to Tomcat’s `webapps/` and start Tomcat, or deploy from your IDE.

The UI uses `web.xml` context param `nodeApiBase` (default `http://localhost:3001`) for `fetch()` from JSP. Change it if the API runs elsewhere.

Static CSS is loaded via `WEB-INF/jsp/include/portal-head.jsp`, which sets `<base href="…/">` and root-relative `css/app.css` / `css/portal.css` so styles work on nested paths like `/patient/dashboard` (avoids the browser requesting `/patient/css/...`).

## Demo accounts

All use password **`password123`**:

| Role    | Email                 |
|---------|------------------------|
| Patient | `alice@patient.com`   |
| Doctor  | `dr.smith@hospital.com` |

## Architecture

- **Tomcat:** JSP login, session + `AuthFilter` on `/patient/*` and `/doctor/*`, Hibernate for `patients` and `doctors`.
- **Node:** `mysql2` for `appointments` and `doctor_slots`; JSP dashboards call the API via AJAX.

## Professional features added

- Shared **portal UI** (`css/portal.css`): glass panels, typography, and background consistent with the login page.
- Patient dashboard: **next visit** summary, **upcoming count**, status/search filters, booking notes, **CSV export**.
- Doctor dashboard: **today / needs-action / active** stat tiles, patient search, workflow actions, **CSV export**, API health link.
- Patient **profile** (`/patient/profile`): view name/email and update **phone** via Hibernate.
- Doctor analytics page: status counts, charts, date-range filtering.
- API upgrades: stricter status/date validation, overlap prevention for slot creation, summary + timeline endpoints.
- **Clinical Records**: File uploads support (`multer`) for patients to attach past lab reports and documents. Doctors can effortlessly view/download them.
- **Digital Prescriptions**: Built-in capability for doctors to issue medications, dosages, and instructions during a visit.
- **Automated Notifications**: Background polling job scans for appointments within 24 hours to silently trigger in-app bell reminders, eliminating no-shows.
- **UI Bug Fixes**: Hardened the Tomcat JSP renderer against Java EL collisions to ensure complex scheduling data popups display reliably.
