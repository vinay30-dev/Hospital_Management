import express from 'express';
import cors from 'cors';
import appointmentsRouter from './routes/appointments.js';
import doctorsRouter from './routes/doctors.js';
import doctorSlotsRouter from './routes/doctorSlots.js';
import authRouter from './routes/auth.js';
import chatRouter from './routes/chat.js';

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

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'hospital-appointment-api' });
});

app.use('/auth', authRouter);
app.use('/doctors', doctorsRouter);
app.use('/doctor_slots', doctorSlotsRouter);
app.use('/api/v1/appointments', appointmentsRouter);
app.use('/api/chat', chatRouter);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: err.message || 'Server error' });
});

app.listen(PORT, () => {
  console.log(`Appointment API listening on http://localhost:${PORT}`);
});
