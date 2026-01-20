const bcrypt = require('bcryptjs');
exports.register = async (req, res) => {
  const { name, email, password } = req.body;

  // 1️⃣ Vérification des champs
  if (!name || !email || !password) {
    return res.status(400).json({
      message: 'Tous les champs sont obligatoires'
    });
  }

  // 2️⃣ Vérification mot de passe
  if (password.length < 6) {
    return res.status(400).json({
      message: 'Le mot de passe doit contenir au moins 6 caractères'
    });
  }

  // 3️⃣ HASH du mot de passe
  const hashedPassword = await bcrypt.hash(password, 10);

  // 4️⃣ Réponse (simulation sauvegarde)
  res.status(201).json({
    message: 'Inscription réussie 🎉',
    user: {
      name,
      email,
      password: hashedPassword
    }
  });
};
exports.login = async (req, res) => {
  const { email, password } = req.body;

  // 1️⃣ Vérification des champs
  if (!email || !password) {
    return res.status(400).json({
      message: 'Email et mot de passe sont obligatoires'
    });
  }

  // 2️⃣ Réponse (simulation vérification)
  res.status(200).json({
    message: 'Connexion réussie 🎉',
    user: {
      email,
      password
    }
  });
};