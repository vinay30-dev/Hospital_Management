import { Router } from 'express';
import pool from '../db.js';

const router = Router();

// Get unread notifications for a user
router.get('/notifications', async (req, res) => {
  const { userId, userType } = req.query;

  if (!userId || !userType) {
    return res.status(400).json({ message: 'userId and userType are required' });
  }

  try {
    const [rows] = await pool.query(
      'SELECT * FROM notifications WHERE user_id = ? AND user_type = ? AND is_read = 0 ORDER BY created_at DESC',
      [userId, userType]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Mark a notification as read
router.patch('/notifications/:id/read', async (req, res) => {
  try {
    await pool.query(
      'UPDATE notifications SET is_read = 1 WHERE id = ?',
      [req.params.id]
    );
    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
