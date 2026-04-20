import { Router } from 'express';
import pool from '../db.js';

const router = Router();

// Get prescriptions for a specific appointment
router.get('/appointments/:id/prescriptions', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM prescriptions WHERE appointment_id = ? ORDER BY created_at DESC',
      [req.params.id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create a prescription for an appointment
router.post('/appointments/:id/prescriptions', async (req, res) => {
  const appointmentId = req.params.id;
  const { medication, dosage, instructions } = req.body;

  if (!medication || !dosage) {
    return res.status(400).json({ message: 'Medication and dosage are required' });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO prescriptions (appointment_id, medication, dosage, instructions) VALUES (?, ?, ?, ?)',
      [appointmentId, medication, dosage, instructions || '']
    );
    res.status(201).json({ id: result.insertId, appointment_id: appointmentId, medication, dosage, instructions });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
