const Order = require('../models/order.model');
const emailService = require('../services/email.service');
const db = require('../config/db');
const notificationController = require('./notification.controller');

const statusMessages = {
  pending:   { title: 'Commande reçue',      message: 'Votre commande est en attente de validation par l\'opticien.' },
  validated: { title: 'Commande validée ✅',  message: 'Votre commande a été validée par l\'opticien. Elle est en cours de préparation.' },
  rejected:  { title: 'Commande rejetée ❌',  message: 'Votre commande a été rejetée par l\'opticien. Contactez-nous pour plus d\'informations.' },
  shipped:   { title: 'Commande expédiée 🚚', message: 'Votre commande est en route ! Vous la recevrez prochainement.' },
  delivered: { title: 'Commande livrée 🎉',   message: 'Votre commande a été livrée. Merci pour votre confiance !' },
};

exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.getAllOrders();
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la récupération des commandes', error: error.message });
  }
};

exports.getOrderDetails = async (req, res) => {
  try {
    const order = await Order.getOrderById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Commande non trouvée' });
    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la récupération des détails', error: error.message });
  }
};

exports.createOrder = async (req, res) => {
  try {
    const { frameId, frameName, prescriptionData, insuranceData, totalPrice } = req.body;
    const userId = req.user.id || req.user.userId;
    const userEmail = req.user.email;
    const userName = req.user.name || 'Client';

    if ((!frameId && !frameName) || !totalPrice) {
      return res.status(400).json({ message: 'Monture et prix requis' });
    }

    let finalFrameId = parseInt(frameId);
    let finalFrameName = frameName;

    if (isNaN(finalFrameId)) {
      finalFrameId = null;
      if (!finalFrameName) finalFrameName = frameId;
    }

    const orderId = await Order.createOrder(
      userId,
      finalFrameId,
      finalFrameName,
      JSON.stringify(prescriptionData || {}),
      JSON.stringify(insuranceData || {}),
      totalPrice
    );

    // Notification in-app au client
    await notificationController.createNotification(
      userId,
      'Commande reçue 📦',
      `Votre commande #${orderId} a bien été enregistrée. En attente de validation.`,
      'order'
    );

    res.status(201).json({
      message: 'Commande créée avec succès',
      orderId
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ message: 'Erreur lors de la création de la commande', error: error.message });
  }
};

exports.updateStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const orderId = req.params.id;

    if (!['pending', 'validated', 'rejected', 'shipped', 'delivered'].includes(status)) {
      return res.status(400).json({ message: 'Statut invalide' });
    }

    await Order.updateOrderStatus(orderId, status);

    // Récupérer les infos de la commande
    const order = await Order.getOrderById(orderId);

    if (order) {
      let clientUserId = order.user_id;

      // Fallback si user_id pas dans order
      if (!clientUserId && (order.client_email || order.user_email)) {
        const email = order.client_email || order.user_email;
        const [users] = await db.execute('SELECT id FROM users WHERE email = ?', [email]);
        if (users.length > 0) clientUserId = users[0].id;
      }

      // Créer notification in-app
      if (clientUserId) {
        const notif = statusMessages[status] || {
          title: 'Commande mise à jour',
          message: `Le statut de votre commande #${orderId} a été mis à jour : ${status}`
        };
        await notificationController.createNotification(
          clientUserId,
          notif.title,
          `Commande #${orderId} — ${notif.message}`,
          'order'
        );
        console.log(`Notification in-app créée pour user ${clientUserId}, commande ${orderId}, statut ${status}`);
      }
    }

    res.status(200).json({ message: 'Statut mis à jour et client notifié' });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ message: 'Erreur lors de la mise à jour du statut', error: error.message });
  }
};
exports.getMyOrders = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const [rows] = await require('../config/db').execute(
      'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Erreur', error: error.message });
  }
};
