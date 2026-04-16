import express from 'express';
import pool from '../db.js';

const router = express.Router();

router.get('/', async (req, res) => {
  const { doctorId, available } = req.query;
  if (!doctorId) {
    return res.status(400).json({ message: 'doctorId required' });
  }
  try {
    let sql =
      'SELECT id, doctor_id, start_time, end_time, is_booked FROM doctor_slots WHERE doctor_id = ?';
    const params = [doctorId];
    if (available === '1' || available === 'true') {
      sql += ' AND is_booked = 0';
    }
    sql += ' ORDER BY start_time';
    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: e.message });
  }
});

router.post('/', async (req, res) => {
  const { doctor_id, start_time, end_time } = req.body || {};
  if (!doctor_id || !start_time || !end_time) {
    return res.status(400).json({ message: 'doctor_id, start_time, end_time required' });
  }
  const normalizedStart = normalizeDateTime(start_time);
  const normalizedEnd = normalizeDateTime(end_time);
  if (normalizedEnd <= normalizedStart) {
    return res.status(400).json({ message: 'end_time must be after start_time' });
  }
  try {
    const [conflicts] = await pool.query(
      `SELECT id
       FROM doctor_slots
       WHERE doctor_id = ?
         AND (? < end_time AND ? > start_time)
       LIMIT 1`,
      [doctor_id, normalizedStart, normalizedEnd]
    );
    if (conflicts.length) {
      return res.status(409).json({ message: 'Slot overlaps with existing availability' });
    }
    const [result] = await pool.query(
      `INSERT INTO doctor_slots (doctor_id, start_time, end_time, is_booked)
       VALUES (?, ?, ?, 0)`,
      [doctor_id, normalizedStart, normalizedEnd]
    );
    res.status(201).json({ id: result.insertId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: e.message });
  }
});

function normalizeDateTime(v) {
  if (typeof v !== 'string') return v;
  let s = v.replace('T', ' ').trim();
  if (s.length === 16) s += ':00';
  return s.length > 19 ? s.substring(0, 19) : s;
}

export default router;
