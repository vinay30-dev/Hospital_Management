import express from 'express';
import cors from 'cors';
import appointmentsRouter from './routes/appointments.js';
import doctorsRouter from './routes/doctors.js';
import doctorSlotsRouter from './routes/doctorSlots.js';
import authRouter from './routes/auth.js';
import chatRouter from './routes/chat.js';
import prescriptionsRouter from './routes/prescriptions.js';
import documentsRouter from './routes/documents.js';
import notificationsRouter from './routes/notifications.js';
import pool from './db.js';

const app = express();
const PORT = Number(process.env.PORT || 3001);

const corsOrigins = (process.env.CORS_ORIGINS || 'http://localhost:8080,http://127.0.0.1:8080')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

app.use(
  cors({
    origin: corsOrigins,
    credentials: true,
  })
);
app.use(express.json());
app.use('/uploads', express.static('uploads'));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'hospital-appointment-api' });
});

app.use('/auth', authRouter);
app.use('/doctors', doctorsRouter);
app.use('/doctor_slots', doctorSlotsRouter);
app.use('/api/v1/appointments', appointmentsRouter);
app.use('/api/v1', prescriptionsRouter);
app.use('/api/v1', documentsRouter);
app.use('/api/v1', notificationsRouter);
app.use('/api/chat', chatRouter);

// Automated Job for Appointment Notifications (Runs every minute for demo purposes)
setInterval(async () => {
  try {
    // Find upcoming appointments within 24 hours that haven't had a reminder sent
    const [rows] = await pool.query(`
      SELECT a.id, a.patient_id, a.doctor_id, a.appointment_time, p.name as patient_name, d.name as doctor_name 
      FROM appointments a
      JOIN patients p ON a.patient_id = p.id
      JOIN doctors d ON a.doctor_id = d.id
      WHERE a.status IN ('SCHEDULED', 'CONFIRMED')
      AND a.reminder_sent = 0
      AND a.appointment_time BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 24 HOUR)
    `);

    for (const appt of rows) {
      const timeStr = new Date(appt.appointment_time).toLocaleString();
      
      // Notify Patient
      await pool.query(
        'INSERT INTO notifications (user_id, user_type, message) VALUES (?, ?, ?)',
        [appt.patient_id, 'PATIENT', `Reminder: You have an appointment with ${appt.doctor_name} at ${timeStr}`]
      );
      
      // Notify Doctor
      await pool.query(
        'INSERT INTO notifications (user_id, user_type, message) VALUES (?, ?, ?)',
        [appt.doctor_id, 'DOCTOR', `Reminder: You have an appointment with ${appt.patient_name} at ${timeStr}`]
      );

      // Mark as reminder sent
      await pool.query('UPDATE appointments SET reminder_sent = 1 WHERE id = ?', [appt.id]);
      
      console.log(`[Notification System] Emulated sending Email/SMS reminder for appointment ${appt.id}`);
    }
  } catch (err) {
    console.error('Notification job failed:', err);
  }
}, 60000);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: err.message || 'Server error' });
});

app.listen(PORT, () => {
  console.log(`Appointment API listening on http://localhost:${PORT}`);
});
