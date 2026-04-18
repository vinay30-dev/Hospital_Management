import express from 'express';
import bcrypt from 'bcryptjs';
import pool from '../db.js';

const router = express.Router();

/* ── POST /auth/login ── */
router.post('/login', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({ message: 'email and password required' });
  }
  try {
    const [patients] = await pool.query(
      'SELECT id, email, password_hash FROM patients WHERE LOWER(email) = LOWER(?)',
      [email.trim()]
    );
    if (patients.length && bcrypt.compareSync(password, patients[0].password_hash)) {
      return res.json({
        ok: true,
        role: 'PATIENT',
        userId: patients[0].id,
        email: patients[0].email,
      });
    }
    const [doctors] = await pool.query(
      'SELECT id, email, password_hash FROM doctors WHERE LOWER(email) = LOWER(?)',
      [email.trim()]
    );
    if (doctors.length && bcrypt.compareSync(password, doctors[0].password_hash)) {
      return res.json({
        ok: true,
        role: 'DOCTOR',
        userId: doctors[0].id,
        email: doctors[0].email,
      });
    }
    return res.status(401).json({ message: 'Invalid credentials' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: e.message });
  }
});

/* ── POST /auth/register ── */
router.post('/register', async (req, res) => {
  const { role, name, email, password, phone, specialty } = req.body || {};

  // Basic validation
  if (!role || !name || !email || !password) {
    return res.status(400).json({ message: 'role, name, email, and password are required' });
  }
  if (!['PATIENT', 'DOCTOR'].includes(role)) {
    return res.status(400).json({ message: 'role must be PATIENT or DOCTOR' });
  }
  if (password.length < 8) {
    return res.status(400).json({ message: 'Password must be at least 8 characters' });
  }

  const normalizedEmail = email.trim().toLowerCase();

  try {
    // Check for duplicate email in both tables
    const [[{ count: patientCount }]] = await pool.query(
      'SELECT COUNT(*) AS count FROM patients WHERE LOWER(email) = ?',
      [normalizedEmail]
    );
    const [[{ count: doctorCount }]] = await pool.query(
      'SELECT COUNT(*) AS count FROM doctors WHERE LOWER(email) = ?',
      [normalizedEmail]
    );
    if (Number(patientCount) > 0 || Number(doctorCount) > 0) {
      return res.status(409).json({ message: 'An account with this email already exists' });
    }

    const password_hash = await bcrypt.hash(password, 12);

    let userId;
    if (role === 'PATIENT') {
      const [result] = await pool.query(
        'INSERT INTO patients (name, email, phone, password_hash) VALUES (?, ?, ?, ?)',
        [name.trim(), normalizedEmail, phone || null, password_hash]
      );
      userId = result.insertId;
    } else {
      // DOCTOR
      const [result] = await pool.query(
        'INSERT INTO doctors (name, email, specialty, phone, password_hash) VALUES (?, ?, ?, ?, ?)',
        [name.trim(), normalizedEmail, specialty || null, phone || null, password_hash]
      );
      userId = result.insertId;
    }

    return res.status(201).json({ ok: true, role, userId, email: normalizedEmail });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: e.message });
  }
});

export default router;