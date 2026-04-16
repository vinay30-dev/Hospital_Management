import express from 'express';
import pool from '../db.js';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT id, name, email, specialty FROM doctors ORDER BY name'
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: e.message });
  }
});

export default router;
