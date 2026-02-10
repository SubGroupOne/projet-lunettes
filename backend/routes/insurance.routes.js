const express = require('express');
const router = express.Router();
const insuranceController = require('../controllers/insurance.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Routes publiques
router.get('/', insuranceController.getAllInsurances);
router.get('/:id', insuranceController.getInsuranceById);

// Routes admin
router.get('/admin/all', authenticate, authorize(['admin']), insuranceController.getAllInsurancesAdmin);
router.post('/', authenticate, authorize(['admin']), insuranceController.createInsurance);
router.put('/:id', authenticate, authorize(['admin']), insuranceController.updateInsurance);
router.patch('/:id/status', authenticate, authorize(['admin']), insuranceController.toggleInsuranceStatus);
router.delete('/:id', authenticate, authorize(['admin']), insuranceController.deleteInsurance);

// Validation (public pour permettre aux clients de vérifier leur assurance)
router.post('/validate', insuranceController.validateInsurance);

module.exports = router;
