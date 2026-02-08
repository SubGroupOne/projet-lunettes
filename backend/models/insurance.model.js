const db = require('../config/db');

/**
 * Créer une nouvelle assurance
 */
exports.createInsurance = async (name, coverageRate, conditions) => {
    const sql = `
    INSERT INTO insurances (name, coverage_rate, conditions, is_active)
    VALUES (?, ?, ?, true)
  `;
    const [result] = await db.execute(sql, [name, coverageRate, conditions]);
    return result.insertId;
};

/**
 * Récupérer toutes les assurances actives
 */
exports.getAllInsurances = async () => {
    const sql = `
    SELECT id, name, coverage_rate, conditions, is_active, created_at
    FROM insurances
    WHERE is_active = true
    ORDER BY name ASC
  `;
    const [rows] = await db.execute(sql);
    return rows;
};

/**
 * Récupérer toutes les assurances (admin)
 */
exports.getAllInsurancesAdmin = async () => {
    const sql = `
    SELECT id, name, coverage_rate, conditions, is_active, created_at
    FROM insurances
    ORDER BY created_at DESC
  `;
    const [rows] = await db.execute(sql);
    return rows;
};

/**
 * Récupérer une assurance par ID
 */
exports.getInsuranceById = async (id) => {
    const sql = `
    SELECT id, name, coverage_rate, conditions, is_active, created_at
    FROM insurances
    WHERE id = ?
  `;
    const [rows] = await db.execute(sql, [id]);
    return rows[0];
};

/**
 * Mettre à jour une assurance
 */
exports.updateInsurance = async (id, name, coverageRate, conditions) => {
    const sql = `
    UPDATE insurances
    SET name = ?, coverage_rate = ?, conditions = ?
    WHERE id = ?
  `;
    const [result] = await db.execute(sql, [name, coverageRate, conditions, id]);
    return result.affectedRows;
};

/**
 * Activer/Désactiver une assurance
 */
exports.toggleInsuranceStatus = async (id, isActive) => {
    const sql = `
    UPDATE insurances
    SET is_active = ?
    WHERE id = ?
  `;
    const [result] = await db.execute(sql, [isActive, id]);
    return result.affectedRows;
};

/**
 * Supprimer une assurance
 */
exports.deleteInsurance = async (id) => {
    const sql = `DELETE FROM insurances WHERE id = ?`;
    const [result] = await db.execute(sql, [id]);
    return result.affectedRows;
};

/**
 * Valider une assurance pour une commande
 */
exports.validateInsurance = async (insuranceId, orderId) => {
    const insurance = await exports.getInsuranceById(insuranceId);

    if (!insurance || !insurance.is_active) {
        return {
            valid: false,
            message: 'Assurance non valide ou inactive'
        };
    }

    return {
        valid: true,
        insurance: insurance,
        coverageRate: insurance.coverage_rate
    };
};
