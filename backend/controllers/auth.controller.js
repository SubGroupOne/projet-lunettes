const bcrypt = require('bcryptjs');
const User = require('../models/user.model');
const { generateAccessToken, generateRefreshToken, verifyToken } = require('../utils/jwt.util');

exports.register = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    // 1️⃣ Vérification
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Tous les champs sont obligatoires' });
    }

    // 2️⃣ Mot de passe
    if (password.length < 6) {
      return res.status(400).json({ message: 'Mot de passe trop court (min 6 caractères)' });
    }

    // 3️⃣ Vérifier si email existe
    const existingUser = await User.findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({ message: 'Email déjà utilisé' });
    }

    // 4️⃣ Hash
    const hashedPassword = await bcrypt.hash(password, 10);

    // 5️⃣ Création utilisateur
    const userRole = role || 'client'; // Par défaut client
    const userId = await User.createUser(name, email, hashedPassword, userRole);

    // 6️⃣ Générer tokens
    const accessToken = generateAccessToken(userId, userRole);
    const refreshToken = generateRefreshToken(userId);

    res.status(201).json({
      message: 'Utilisateur créé avec succès',
      accessToken,
      refreshToken,
      user: {
        id: userId,
        name,
        email,
        role: userRole
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Erreur serveur lors de l\'inscription' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1️⃣ Vérification
    if (!email || !password) {
      return res.status(400).json({
        message: 'Email et mot de passe requis'
      });
    }

    // 2️⃣ Chercher l'utilisateur
    const user = await User.findUserByEmail(email);
    if (!user) {
      return res.status(401).json({
        message: 'Email ou mot de passe incorrect'
      });
    }

    // 3️⃣ Comparer les mots de passe
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        message: 'Email ou mot de passe incorrect'
      });
    }

    // 4️⃣ Générer tokens
    const accessToken = generateAccessToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    // 5️⃣ Succès
    res.status(200).json({
      message: 'Connexion réussie 🎉',
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Erreur serveur lors de la connexion' });
  }
};

exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ message: 'Refresh token manquant' });
    }

    const decoded = verifyToken(refreshToken);

    if (!decoded || !decoded.userId) {
      return res.status(401).json({ message: 'Refresh token invalide' });
    }

    const user = await User.findUserById(decoded.userId);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    const newAccessToken = generateAccessToken(user.id, user.role);

    res.status(200).json({
      accessToken: newAccessToken
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const user = await User.findUserById(req.user.userId);

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    res.status(200).json({
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email requis' });
    }

    // Vérifier si l'utilisateur existe
    const user = await User.findUserByEmail(email);
    if (!user) {
      // On retourne quand même un succès pour sécurité (user enumeration)
      return res.status(200).json({ message: 'Si cet email existe, un lien de réinitialisation a été envoyé.' });
    }

    // Simulation envoi email (utiliser emailService ici si souhaité)
    console.log(`Lien de réinitialisation envoyé à ${email}`);

    res.status(200).json({ message: 'Si cet email existe, un lien de réinitialisation a été envoyé.' });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};
