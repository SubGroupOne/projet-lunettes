const Frame = require('../models/frame.model');

exports.getAllFrames = async (req, res) => {
    try {
        const frames = await Frame.getAllFrames();
        res.status(200).json(frames);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la récupération des montures', error: error.message });
    }
};

exports.getFrameById = async (req, res) => {
    try {
        const frame = await Frame.getFrameById(req.params.id);
        if (!frame) return res.status(404).json({ message: 'Monture non trouvée' });
        res.status(200).json(frame);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la récupération de la monture', error: error.message });
    }
};

exports.createFrame = async (req, res) => {
    try {
        const { name, brand, price, description, imageUrl, stock } = req.body;
        const frameId = await Frame.createFrame(name, brand, price, description, imageUrl, stock);
        res.status(201).json({ message: 'Monture ajoutée avec succès', frameId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de l\'ajout de la monture', error: error.message });
    }
};

exports.updateFrame = async (req, res) => {
    try {
        const { name, brand, price, description, imageUrl, stock } = req.body;
        await Frame.updateFrame(req.params.id, name, brand, price, description, imageUrl, stock);
        res.status(200).json({ message: 'Monture mise à jour avec succès' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la mise à jour de la monture', error: error.message });
    }
};

exports.deleteFrame = async (req, res) => {
    try {
        await Frame.deleteFrame(req.params.id);
        res.status(200).json({ message: 'Monture supprimée avec succès' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la suppression de la monture', error: error.message });
    }
};
