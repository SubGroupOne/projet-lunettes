const Order = require('../models/order.model');
const emailService = require('../services/email.service');
const db = require('../config/db'); // Pour récupérer l'email utilisateur si nécessaire

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
        res.status(500).json({ message: 'Erreur lors de la récupération des détails de la commande', error: error.message });
    }
};

exports.createOrder = async (req, res) => {
    try {
        const { frameId, prescriptionData, insuranceData, totalPrice } = req.body;
        // req.user est peuplé par authMiddleware qui décode le token
        const userId = req.user.id || req.user.userId;
        const userEmail = req.user.email; // Assurez-vous que le token contient l'email
        const userName = req.user.name || 'Client';

        if (!frameId || !totalPrice) {
            return res.status(400).json({ message: 'Monture et prix requis' });
        }

        const orderId = await Order.createOrder(
            userId,
            frameId,
            JSON.stringify(prescriptionData || {}),
            JSON.stringify(insuranceData || {}),
            totalPrice
        );

        // Notification Client (Confirmation)
        if (userEmail) {
            await emailService.sendOrderNotification(userEmail, userName, orderId, 'pending');
        }

        // Notification Opticien (Nouvelle commande)
        // Pour l'instant on envoie à l'admin/opticien principal défini dans .env ou en dur
        const opticianEmail = process.env.OPTICIAN_EMAIL || 'opticien@smartvision.com';
        await emailService.sendNewOrderToOptician(opticianEmail, orderId, userName);

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

        // Récupérer les infos de la commande pour notifier le client
        // On a besoin de l'email du client joint à la commande
        const order = await Order.getOrderById(orderId);

        if (order) {
            // Si getOrderById ne retourne pas l'email user, il faudrait faire une jointure dans le modèle
            // Supposons pour l'instant que order.email ou order.user_email est disponible
            // Sinon on fait une requête rapide pour avoir l'email
            let clientEmail = order.email || order.user_email;
            let clientName = order.name || order.user_name || 'Client';

            if (!clientEmail) {
                // Fallback: fetch user email via userId if available in order object
                if (order.user_id) {
                    const [users] = await db.execute('SELECT email, name FROM users WHERE id = ?', [order.user_id]);
                    if (users.length > 0) {
                        clientEmail = users[0].email;
                        clientName = users[0].name;
                    }
                }
            }

            if (clientEmail) {
                await emailService.sendOrderNotification(clientEmail, clientName, orderId, status);
                console.log(`Notification email envoyée à ${clientEmail} pour la commande ${orderId}`);
            } else {
                console.warn(`Impossible d'envoyer l'email : adresse introuvable pour la commande ${orderId}`);
            }
        }

        res.status(200).json({ message: 'Statut de la commande mis à jour et client notifié' });
    } catch (error) {
        console.error('Update status error:', error);
        res.status(500).json({ message: 'Erreur lors de la mise à jour du statut', error: error.message });
    }
};
