import { Router } from 'express';
import pool from '../db.js';
import multer from 'multer';
import path from 'path';

const router = Router();

// Configure multer for file storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

// Get documents for a patient
router.get('/patients/:id/documents', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM patient_documents WHERE patient_id = ? ORDER BY uploaded_at DESC',
      [req.params.id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Upload a generic document for a patient
router.post('/patients/:id/documents', upload.single('file'), async (req, res) => {
  const patientId = req.params.id;
  const { uploader_id, uploader_role } = req.body;
  const file = req.file;

  if (!file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }
  
  if (!uploader_id || !uploader_role) {
    return res.status(400).json({ message: 'Uploader ID and Role are required' });
  }

  try {
    const filename = file.originalname;
    const filepath = '/uploads/' + file.filename;

    const [result] = await pool.query(
      'INSERT INTO patient_documents (patient_id, uploader_id, uploader_role, filename, filepath) VALUES (?, ?, ?, ?, ?)',
      [patientId, uploader_id, uploader_role, filename, filepath]
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      patient_id: patientId, 
      filename, 
      filepath,
      uploader_id,
      uploader_role
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
