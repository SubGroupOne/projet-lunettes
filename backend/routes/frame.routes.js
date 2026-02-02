const express = require('express');
const router = express.Router();
const frameController = require('../controllers/frame.controller');

// Toutes les routes pour les montures
router.get('/', frameController.getAllFrames);
router.get('/:id', frameController.getFrameById);
router.post('/', frameController.createFrame);
router.put('/:id', frameController.updateFrame);
router.delete('/:id', frameController.deleteFrame);

module.exports = router;
