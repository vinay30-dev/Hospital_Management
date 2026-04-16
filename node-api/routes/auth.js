import express from 'express';
import bcrypt from 'bcryptjs';
import pool from '../db.js';

const router = express.Router();

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

export default router;
