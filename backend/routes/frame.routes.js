const express = require('express');
const router = express.Router();
const frameController = require('../controllers/frame.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Routes publiques
router.get('/', frameController.getAllFrames);
router.get('/:id', frameController.getFrameById);

// Routes protégées (opticien ou admin)
router.post('/', authenticate, authorize(['opticien', 'admin']), frameController.createFrame);
router.put('/:id', authenticate, authorize(['opticien', 'admin']), frameController.updateFrame);
router.delete('/:id', authenticate, authorize(['admin']), frameController.deleteFrame);

module.exports = router;
