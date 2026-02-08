const jwt = require('jsonwebtoken');

/**
 * Génère un access token JWT
 * @param {number} userId - ID de l'utilisateur
 * @param {string} role - Rôle de l'utilisateur (client, opticien, admin)
 * @returns {string} Access token
 */
exports.generateAccessToken = (userId, role) => {
    return jwt.sign(
        { userId, role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );
};

/**
 * Génère un refresh token JWT
 * @param {number} userId - ID de l'utilisateur
 * @returns {string} Refresh token
 */
exports.generateRefreshToken = (userId) => {
    return jwt.sign(
        { userId },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
    );
};

/**
 * Vérifie et décode un token
 * @param {string} token - Token à vérifier
 * @returns {object|null} Payload décodé ou null si invalide
 */
exports.verifyToken = (token) => {
    try {
        return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
        return null;
    }
};
