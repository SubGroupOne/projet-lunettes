const { verifyToken } = require('../utils/jwt.util');

/**
 * Middleware pour vérifier l'authentification JWT
 */
exports.authenticate = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            message: 'Accès refusé. Token manquant.'
        });
    }

    const token = authHeader.substring(7); // Remove "Bearer "
    const decoded = verifyToken(token);

    if (!decoded) {
        return res.status(401).json({
            message: 'Token invalide ou expiré.'
        });
    }

    // Ajouter les infos utilisateur à la requête
    req.user = {
        userId: decoded.userId,
        role: decoded.role
    };

    next();
};

/**
 * Middleware optionnel (permet accès même sans token)
 */
exports.optionalAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
        const token = authHeader.substring(7);
        const decoded = verifyToken(token);

        if (decoded) {
            req.user = {
                userId: decoded.userId,
                role: decoded.role
            };
        }
    }

    next();
};
