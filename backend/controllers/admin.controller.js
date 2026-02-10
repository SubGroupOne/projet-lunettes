const db = require('../config/db');

/**
 * Récupérer les statistiques globales du dashboard
 */
exports.getDashboardStats = async (req, res) => {
    try {
        const [[userStats]] = await db.execute('SELECT COUNT(*) as total FROM users');
        const [[orderStats]] = await db.execute('SELECT COUNT(*) as total, COALESCE(SUM(total_price), 0) as revenue FROM orders WHERE status = "delivered"');
        const [[frameStats]] = await db.execute('SELECT COUNT(*) as total FROM frames');
        const [[pendingOrders]] = await db.execute('SELECT COUNT(*) as total FROM orders WHERE status = "pending"');

        res.json({
            users: userStats.total,
            orders: orderStats.total || 0,
            revenue: parseFloat(orderStats.revenue) || 0,
            frames: frameStats.total,
            pendingOrders: pendingOrders.total
        });
    } catch (error) {
        console.error('Dashboard stats error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Récupérer tous les utilisateurs
 */
exports.getAllUsers = async (req, res) => {
    try {
        const [users] = await db.execute('SELECT id, name, email, role, created_at FROM users ORDER BY created_at DESC');
        res.json(users);
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Mettre à jour le rôle d'un utilisateur
 */
exports.updateUserRole = async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;

        if (!['client', 'opticien', 'admin'].includes(role)) {
            return res.status(400).json({ message: 'Rôle invalide' });
        }

        await db.execute('UPDATE users SET role = ? WHERE id = ?', [role, id]);
        res.json({ message: 'Rôle mis à jour avec succès' });
    } catch (error) {
        console.error('Update role error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Activer/Désactiver un utilisateur (optionnel si colonne is_active existe)
 */
exports.toggleUserStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { is_active } = req.body;

        // Vérifier si la colonne existe d'abord
        try {
            await db.execute('UPDATE users SET is_active = ? WHERE id = ?', [is_active, id]);
            res.json({ message: `Utilisateur ${is_active ? 'activé' : 'désactivé'} avec succès` });
        } catch (err) {
            // Si la colonne n'existe pas, retourner une erreur friendly
            res.json({ message: 'Fonctionnalité non disponible (colonne is_active manquante)' });
        }
    } catch (error) {
        console.error('Toggle user status error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Supprimer un utilisateur
 */
exports.deleteUser = async (req, res) => {
    try {
        const { id } = req.params;

        // Empêcher la suppression de son propre compte
        if (req.user && parseInt(id) === req.user.userId) {
            return res.status(400).json({ message: 'Vous ne pouvez pas supprimer votre propre compte' });
        }

        await db.execute('DELETE FROM users WHERE id = ?', [id]);
        res.json({ message: 'Utilisateur supprimé avec succès' });
    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Récupérer les statistiques des commandes
 */
exports.getOrdersStatistics = async (req, res) => {
    try {
        const [stats] = await db.execute(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN status = 'validated' THEN 1 ELSE 0 END) as validated,
        SUM(CASE WHEN status = 'shipped' THEN 1 ELSE 0 END) as shipped,
        SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as delivered,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
        COALESCE(SUM(total_price), 0) as totalRevenue
      FROM orders
    `);

        res.json(stats[0]);
    } catch (error) {
        console.error('Orders statistics error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Récupérer le top des montures vendues
 */
exports.getTopFrames = async (req, res) => {
    try {
        const [topFrames] = await db.execute(`
      SELECT f.id, f.name, f.brand, f.price, COUNT(o.id) as sales
      FROM frames f
      LEFT JOIN orders o ON f.id = o.frame_id
      GROUP BY f.id, f.name, f.brand, f.price
      ORDER BY sales DESC
      LIMIT 10
    `);

        res.json(topFrames);
    } catch (error) {
        console.error('Top frames error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
