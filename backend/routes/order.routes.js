const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');

// Routes pour les commandes (Côté Opticien)
router.get('/', orderController.getAllOrders);
router.get('/:id', orderController.getOrderDetails);
router.patch('/:id/status', orderController.updateStatus);

module.exports = router;
