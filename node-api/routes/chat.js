import express from 'express';

const router = express.Router();

/**
 * Simple FAQ-style replies (no external AI). Replace with an LLM call if you add API keys server-side.
 */
function replyFromMessage(raw) {
  const text = String(raw ?? '').trim();
  if (!text) {
    return 'Type a question below — for example hours, appointments, or emergencies.';
  }
  const m = text.toLowerCase();

  if (/(emergency|urgent|911|chest pain|stroke|bleeding)/.test(m)) {
    return 'If this is a medical emergency, call your local emergency number immediately. This assistant cannot diagnose or triage.';
  }
  if (/(hour|open|close|when.*visit)/.test(m)) {
    return 'Typical reception hours are Monday–Friday 8:00–18:00 and Saturday 9:00–13:00 (demo values).';
  }
  if (/(book|schedule|appointment|slot)/.test(m)) {
    return 'Signed-in patients can book from the dashboard by choosing a doctor and an available time slot.';
  }
  if (/(doctor|physician|provider)/.test(m)) {
    return 'Use the dashboard to see your doctors and upcoming visits. Contact support if you need to change assignment.';
  }
  if (/(password|login|sign in|forgot)/.test(m)) {
    return 'Use the Sign in page with your email and password. Demo accounts are listed on the login screen.';
  }
  if (/(contact|support|email|phone)/.test(m)) {
    return 'You can reach support at support@hospital.local (demo). For clinical questions, message your care team through official channels.';
  }

  return (
    'Thanks for your message. This is a demo assistant with limited answers. ' +
    'Try asking about hours, booking appointments, or emergencies. ' +
    'For personal medical advice, speak with your clinician.'
  );
}

/* POST /api/chat  body: { "message": "..." } */
router.post('/', (req, res) => {
  const { message } = req.body || {};
  if (typeof message !== 'string') {
    return res.status(400).json({ message: 'Expected JSON body: { "message": string }' });
  }
  res.json({ reply: replyFromMessage(message) });
});

export default router;
