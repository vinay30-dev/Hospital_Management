import express from 'express';
import pool from '../db.js';

const router = express.Router();
const ALLOWED_STATUSES = new Set(['SCHEDULED', 'CONFIRMED', 'COMPLETED', 'CANCELLED']);

router.get('/', async (req, res) => {
  const { patientId, doctorId, status, from, to, q, includeCancelled } = req.query;
  if (!patientId && !doctorId) {
    return res.status(400).json({ message: 'patientId or doctorId required' });
  }
  try {
    const filters = [];
    const params = [];
    const statusValue = toStatus(status);
    const includeCancelledFlag = includeCancelled === '1' || includeCancelled === 'true';

    if (status && !statusValue) {
      return res.status(400).json({ message: 'Invalid status filter' });
    }

    if (patientId) {
      filters.push('a.patient_id = ?');
      params.push(patientId);
      if (!includeCancelledFlag && !statusValue) {
        filters.push("a.status <> 'CANCELLED'");
      }
      if (statusValue) {
        filters.push('a.status = ?');
        params.push(statusValue);
      }
      if (from) {
        filters.push('a.appointment_time >= ?');
        params.push(normalizeDateTime(from));
      }
      if (to) {
        filters.push('a.appointment_time <= ?');
        params.push(normalizeDateTime(to));
      }
      if (q) {
        filters.push('(d.name LIKE ? OR d.specialty LIKE ?)');
        params.push(`%${q.trim()}%`, `%${q.trim()}%`);
      }
      const [rows] = await pool.query(
        `SELECT a.id, a.patient_id, a.doctor_id, a.slot_id, a.appointment_time, a.status, a.notes,
                d.name AS doctor_name, d.specialty
         FROM appointments a
         JOIN doctors d ON d.id = a.doctor_id
         WHERE ${filters.join(' AND ')}
         ORDER BY a.appointment_time DESC`,
        params
      );
      return res.json(rows);
    }

    filters.push('a.doctor_id = ?');
    params.push(doctorId);
    if (!includeCancelledFlag && !statusValue) {
      filters.push("a.status <> 'CANCELLED'");
    }
    if (statusValue) {
      filters.push('a.status = ?');
      params.push(statusValue);
    }
    if (from) {
      filters.push('a.appointment_time >= ?');
      params.push(normalizeDateTime(from));
    }
    if (to) {
      filters.push('a.appointment_time <= ?');
      params.push(normalizeDateTime(to));
    }
    if (q) {
      filters.push('(p.name LIKE ? OR p.email LIKE ?)');
      params.push(`%${q.trim()}%`, `%${q.trim()}%`);
    }
    const [rows] = await pool.query(
      `SELECT a.id, a.patient_id, a.doctor_id, a.slot_id, a.appointment_time, a.status, a.notes,
              p.name AS patient_name, p.email AS patient_email
       FROM appointments a
       JOIN patients p ON p.id = a.patient_id
       WHERE ${filters.join(' AND ')}
       ORDER BY a.appointment_time DESC`,
      params
    );
    return res.json(rows);
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: e.message });
  }
});

router.post('/', async (req, res) => {
  const { patient_id, doctor_id, slot_id, notes } = req.body || {};
  if (!patient_id || !doctor_id || !slot_id) {
    return res.status(400).json({ message: 'patient_id, doctor_id, slot_id required' });
  }
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [slots] = await conn.query(
      'SELECT id, doctor_id, is_booked FROM doctor_slots WHERE id = ? FOR UPDATE',
      [slot_id]
    );
    if (!slots.length) {
      await conn.rollback();
      return res.status(404).json({ message: 'Slot not found' });
    }
    const slot = slots[0];
    if (Number(slot.doctor_id) !== Number(doctor_id)) {
      await conn.rollback();
      return res.status(400).json({ message: 'Slot does not belong to doctor' });
    }
    if (slot.is_booked) {
      await conn.rollback();
      return res.status(409).json({ message: 'Slot already booked' });
    }
    const [startRows] = await conn.query(
      'SELECT start_time FROM doctor_slots WHERE id = ?',
      [slot_id]
    );
    const appointmentTime = startRows[0].start_time;
    const [result] = await conn.query(
      `INSERT INTO appointments (patient_id, doctor_id, slot_id, appointment_time, status, notes)
       VALUES (?, ?, ?, ?, 'SCHEDULED', ?)`,
      [patient_id, doctor_id, slot_id, appointmentTime, cleanNotes(notes)]
    );
    await conn.query('UPDATE doctor_slots SET is_booked = 1 WHERE id = ?', [slot_id]);
    await conn.commit();
    return res.status(201).json({ id: result.insertId });
  } catch (e) {
    await conn.rollback();
    console.error(e);
    return res.status(500).json({ message: e.message });
  } finally {
    conn.release();
  }
});

router.delete('/:id', async (req, res) => {
  const id = req.params.id;
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [rows] = await conn.query(
      'SELECT id, slot_id, status FROM appointments WHERE id = ? FOR UPDATE',
      [id]
    );
    if (!rows.length) {
      await conn.rollback();
      return res.status(404).json({ message: 'Not found' });
    }
    const appt = rows[0];
    if (appt.status === 'CANCELLED') {
      await conn.rollback();
      return res.json({ ok: true });
    }
    await conn.query("UPDATE appointments SET status = 'CANCELLED' WHERE id = ?", [id]);
    if (appt.slot_id) {
      await conn.query('UPDATE doctor_slots SET is_booked = 0 WHERE id = ?', [appt.slot_id]);
    }
    await conn.commit();
    return res.json({ ok: true });
  } catch (e) {
    await conn.rollback();
    console.error(e);
    return res.status(500).json({ message: e.message });
  } finally {
    conn.release();
  }
});

router.patch('/:id/status', async (req, res) => {
  const id = req.params.id;
  const status = toStatus(req.body?.status);
  const notes = cleanNotes(req.body?.notes);
  if (!status) {
    return res.status(400).json({ message: 'Valid status is required' });
  }
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [rows] = await conn.query(
      'SELECT id, slot_id, status FROM appointments WHERE id = ? FOR UPDATE',
      [id]
    );
    if (!rows.length) {
      await conn.rollback();
      return res.status(404).json({ message: 'Appointment not found' });
    }
    const current = rows[0];
    if (current.status === 'CANCELLED' && status !== 'CANCELLED') {
      await conn.rollback();
      return res.status(409).json({ message: 'Cancelled appointments cannot be re-opened' });
    }
    await conn.query('UPDATE appointments SET status = ?, notes = COALESCE(?, notes) WHERE id = ?', [
      status,
      notes,
      id,
    ]);
    if (status === 'CANCELLED' && current.slot_id) {
      await conn.query('UPDATE doctor_slots SET is_booked = 0 WHERE id = ?', [current.slot_id]);
    }
    await conn.commit();
    return res.json({ ok: true });
  } catch (e) {
    await conn.rollback();
    console.error(e);
    return res.status(500).json({ message: e.message });
  } finally {
    conn.release();
  }
});

router.get('/summary/timeline', async (req, res) => {
  const { doctorId, from, to } = req.query;
  try {
    const filters = [];
    const params = [];
    if (doctorId) {
      filters.push('a.doctor_id = ?');
      params.push(doctorId);
    }
    if (from) {
      filters.push('a.appointment_time >= ?');
      params.push(normalizeDateTime(from));
    }
    if (to) {
      filters.push('a.appointment_time <= ?');
      params.push(normalizeDateTime(to));
    }
    const whereClause = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
    const [rows] = await pool.query(
      `SELECT DATE(a.appointment_time) AS day, a.status, COUNT(*) AS total
       FROM appointments a
       ${whereClause}
       GROUP BY DATE(a.appointment_time), a.status
       ORDER BY day ASC`,
      params
    );

    const daySet = new Set();
    rows.forEach((r) => daySet.add(String(r.day)));
    const labels = Array.from(daySet);
    const series = {
      SCHEDULED: labels.map(() => 0),
      CONFIRMED: labels.map(() => 0),
      COMPLETED: labels.map(() => 0),
      CANCELLED: labels.map(() => 0),
    };
    const idx = new Map(labels.map((d, i) => [d, i]));
    rows.forEach((r) => {
      const day = String(r.day);
      const status = String(r.status || '').toUpperCase();
      if (series[status] && idx.has(day)) {
        series[status][idx.get(day)] = Number(r.total || 0);
      }
    });

    return res.json({ labels, series });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: e.message });
  }
});

router.get('/summary', async (req, res) => {
  const { doctorId, from, to } = req.query;
  try {
    const filters = [];
    const params = [];
    if (doctorId) {
      filters.push('a.doctor_id = ?');
      params.push(doctorId);
    }
    if (from) {
      filters.push('a.appointment_time >= ?');
      params.push(normalizeDateTime(from));
    }
    if (to) {
      filters.push('a.appointment_time <= ?');
      params.push(normalizeDateTime(to));
    }

    const whereClause = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
    const [counts] = await pool.query(
      `SELECT status, COUNT(*) AS total
       FROM appointments a
       ${whereClause}
       GROUP BY status`,
      params
    );
    const [totals] = await pool.query(
      `SELECT COUNT(*) AS totalAppointments, COUNT(DISTINCT doctor_id) AS activeDoctors
       FROM appointments a
       ${whereClause}`,
      params
    );
    return res.json({
      totals: totals[0],
      byStatus: counts,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: e.message });
  }
});

function toStatus(value) {
  if (!value || typeof value !== 'string') {
    return null;
  }
  const normalized = value.toUpperCase().trim();
  return ALLOWED_STATUSES.has(normalized) ? normalized : null;
}

function cleanNotes(value) {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  if (!trimmed) return null;
  return trimmed.substring(0, 1000);
}

function normalizeDateTime(v) {
  if (typeof v !== 'string') return v;
  let s = v.replace('T', ' ').trim();
  if (s.length === 16) s += ':00';
  return s.length > 19 ? s.substring(0, 19) : s;
}

export default router;
