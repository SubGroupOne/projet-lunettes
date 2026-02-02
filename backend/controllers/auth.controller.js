const bcrypt = require('bcryptjs');
const User = require('../models/user.model');

exports.register = async (req, res) => {
  const { name, email, password } = req.body;

  // 1️⃣ Vérification
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Tous les champs sont obligatoires' });
  }

  // 2️⃣ Mot de passe
  if (password.length < 6) {
    return res.status(400).json({ message: 'Mot de passe trop court' });
  }

  // 3️⃣ Vérifier si email existe
  const existingUser = await User.findUserByEmail(email);
  if (existingUser) {
    return res.status(409).json({ message: 'Email déjà utilisé' });
  }

  // 4️⃣ Hash
  const hashedPassword = await bcrypt.hash(password, 10);

  // 5️⃣ Création utilisateur
  await User.createUser(name, email, hashedPassword);

  res.status(201).json({ message: 'Utilisateur créé avec succès' });
};
exports.login = async (req, res) => {
  const { email, password } = req.body;

  // 1️⃣ Vérification
  if (!email || !password) {
    return res.status(400).json({
      message: 'Email et mot de passe requis'
    });
  }

  // 2️⃣ Chercher l’utilisateur
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

  // 4️⃣ Succès
  res.status(200).json({
    message: 'Connexion réussie 🎉',
    user: {
      id: user.id,
      name: user.name,
      email: user.email
    }
  });
};
