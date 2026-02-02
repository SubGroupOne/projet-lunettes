const Order = require('../models/order.model');

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

exports.updateStatus = async (req, res) => {
    try {
        const { status } = req.body;
        if (!['pending', 'validated', 'rejected', 'shipped', 'delivered'].includes(status)) {
            return res.status(400).json({ message: 'Statut invalide' });
        }
        await Order.updateOrderStatus(req.params.id, status);

        // Simulation de notification client
        console.log(`Notification envoyée au client pour la commande ${req.params.id} : Nouveau statut - ${status}`);

        res.status(200).json({ message: 'Statut de la commande mis à jour et client notifié' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la mise à jour du statut', error: error.message });
    }
};
