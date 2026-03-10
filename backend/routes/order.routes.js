const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Toutes les routes nécessitent authentification
router.get('/', authenticate, authorize(['opticien', 'admin']), orderController.getAllOrders);
router.get('/my-orders', authenticate, orderController.getMyOrders);
router.get('/:id', authenticate, orderController.getOrderDetails);
router.post('/', authenticate, orderController.createOrder);
router.patch('/:id/status', authenticate, authorize(['opticien', 'admin']), orderController.updateStatus);

module.exports = router;
