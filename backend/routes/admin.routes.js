const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Toutes les routes admin nécessit le rôle admin
router.use(authenticate, authorize(['admin']));

// Dashboard
router.get('/dashboard/stats', adminController.getDashboardStats);
router.get('/orders/statistics', adminController.getOrdersStatistics);
router.get('/frames/top', adminController.getTopFrames);

// Gestion utilisateurs
router.get('/users', adminController.getAllUsers);
router.put('/users/:id/role', adminController.updateUserRole);
router.put('/users/:id/status', adminController.toggleUserStatus);
router.delete('/users/:id', adminController.deleteUser);

module.exports = router;
