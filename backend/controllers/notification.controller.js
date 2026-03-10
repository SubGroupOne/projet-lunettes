const db = require('../config/db');

// Récupérer les notifications d'un utilisateur
exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const [rows] = await db.execute(
      'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50',
      [userId]
    );
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Erreur', error: error.message });
  }
};

// Compter les notifications non lues
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const [rows] = await db.execute(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId]
    );
    res.status(200).json({ count: rows[0].count });
  } catch (error) {
    res.status(500).json({ message: 'Erreur', error: error.message });
  }
};

// Marquer une notification comme lue
exports.markAsRead = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    await db.execute(
      'UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?',
      [req.params.id, userId]
    );
    res.status(200).json({ message: 'Notification lue' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur', error: error.message });
  }
};

// Marquer toutes les notifications comme lues
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    await db.execute(
      'UPDATE notifications SET is_read = 1 WHERE user_id = ?',
      [userId]
    );
    res.status(200).json({ message: 'Toutes les notifications lues' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur', error: error.message });
  }
};

// Créer une notification (utilisé en interne)
exports.createNotification = async (userId, title, message, type = 'order') => {
  try {
    await db.execute(
      'INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)',
      [userId, title, message, type]
    );
  } catch (error) {
    console.error('Erreur creation notification:', error.message);
  }
};