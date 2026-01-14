const express = require('express');
const app = express();

// Middleware pour lire le JSON
app.use(express.json());

// Route de test
app.get('/', (req, res) => {
  res.send('Backend fonctionne 🚀');
});

// Démarrer le serveur
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Serveur lancé sur http://localhost:${PORT}`);
});
