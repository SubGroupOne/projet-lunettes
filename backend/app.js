const express = require('express');
const authRoutes = require('./routes/auth.routes');


const app = express();

// Middleware pour lire le JSON envoyé par le client
app.use(express.json());

// Route de test globale
app.get('/', (req, res) => {
  res.send('API backend opérationnelle 🚀');
});
app.use('/auth', authRoutes);


module.exports = app;
