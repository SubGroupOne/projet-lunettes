const Insurance = require('../models/insurance.model');

/**
 * Récupérer toutes les assurances (public)
 */
exports.getAllInsurances = async (req, res) => {
    try {
        const insurances = await Insurance.getAllInsurances();
        res.json(insurances);
    } catch (error) {
        console.error('Get insurances error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Récupérer toutes les assurances (admin)
 */
exports.getAllInsurancesAdmin = async (req, res) => {
    try {
        const insurances = await Insurance.getAllInsurancesAdmin();
        res.json(insurances);
    } catch (error) {
        console.error('Get insurances admin error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Récupérer une assurance par ID
 */
exports.getInsuranceById = async (req, res) => {
    try {
        const insurance = await Insurance.getInsuranceById(req.params.id);

        if (!insurance) {
            return res.status(404).json({ message: 'Assurance non trouvée' });
        }

        res.json(insurance);
    } catch (error) {
        console.error('Get insurance error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Créer une nouvelle assurance (admin)
 */
exports.createInsurance = async (req, res) => {
    try {
        const { name, coverage_rate, conditions } = req.body;

        // Validation
        if (!name || !coverage_rate) {
            return res.status(400).json({
                message: 'Nom et taux de couverture requis'
            });
        }

        if (coverage_rate < 0 || coverage_rate > 1) {
            return res.status(400).json({
                message: 'Le taux de couverture doit être entre 0 et 1'
            });
        }

        const insuranceId = await Insurance.createInsurance(
            name,
            coverage_rate,
            conditions || ''
        );

        res.status(201).json({
            message: 'Assurance créée avec succès',
            insuranceId
        });
    } catch (error) {
        console.error('Create insurance error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Mettre à jour une assurance (admin)
 */
exports.updateInsurance = async (req, res) => {
    try {
        const { name, coverage_rate, conditions } = req.body;
        const { id } = req.params;

        // Validation
        if (!name || !coverage_rate) {
            return res.status(400).json({
                message: 'Nom et taux de couverture requis'
            });
        }

        if (coverage_rate < 0 || coverage_rate > 1) {
            return res.status(400).json({
                message: 'Le taux de couverture doit être entre 0 et 1'
            });
        }

        const affected = await Insurance.updateInsurance(
            id,
            name,
            coverage_rate,
            conditions || ''
        );

        if (affected === 0) {
            return res.status(404).json({ message: 'Assurance non trouvée' });
        }

        res.json({ message: 'Assurance mise à jour avec succès' });
    } catch (error) {
        console.error('Update insurance error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Activer/Désactiver une assurance (admin)
 */
exports.toggleInsuranceStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { is_active } = req.body;

        const affected = await Insurance.toggleInsuranceStatus(id, is_active);

        if (affected === 0) {
            return res.status(404).json({ message: 'Assurance non trouvée' });
        }

        res.json({
            message: `Assurance ${is_active ? 'activée' : 'désactivée'} avec succès`
        });
    } catch (error) {
        console.error('Toggle insurance status error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Supprimer une assurance (admin)
 */
exports.deleteInsurance = async (req, res) => {
    try {
        const { id } = req.params;

        const affected = await Insurance.deleteInsurance(id);

        if (affected === 0) {
            return res.status(404).json({ message: 'Assurance non trouvée' });
        }

        res.json({ message: 'Assurance supprimée avec succès' });
    } catch (error) {
        console.error('Delete insurance error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

/**
 * Valider une assurance par nom et calculer la couverture
 */
exports.validateInsurance = async (req, res) => {
    try {
        const { insuranceName, totalPrice } = req.body;

        if (!insuranceName || !totalPrice) {
            return res.status(400).json({
                message: 'Nom de l\'assurance et prix total requis'
            });
        }

        // Chercher l'assurance par nom
        const insurances = await Insurance.getAllInsurances();
        const insurance = insurances.find(
            ins => ins.name.toLowerCase().includes(insuranceName.toLowerCase())
        );

        if (!insurance) {
            return res.status(404).json({
                message: 'Assurance non trouvée',
                coverage: 0,
                amountCovered: 0,
                finalPrice: totalPrice
            });
        }

        const coverage = insurance.coverage_rate * 100; // Convertir en pourcentage
        const amountCovered = totalPrice * insurance.coverage_rate;
        const finalPrice = totalPrice - amountCovered;

        res.json({
            message: 'Assurance validée',
            insuranceName: insurance.name,
            coverage: coverage,
            amountCovered: amountCovered.toFixed(2),
            finalPrice: finalPrice.toFixed(2),
            insuranceId: insurance.id
        });
    } catch (error) {
        console.error('Validate insurance error:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
