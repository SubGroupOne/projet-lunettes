const express = require('express');
const authRoutes = require('./routes/auth.routes');
const frameRoutes = require('./routes/frame.routes');
const orderRoutes = require('./routes/order.routes');

const app = express();

// Middleware pour lire le JSON envoyé par le client
app.use(express.json());

// Route de test globale
app.get('/', (req, res) => {
  res.send('API backend opérationnelle 🚀');
});

app.use('/auth', authRoutes);
app.use('/frames', frameRoutes);
app.use('/orders', orderRoutes);


module.exports = app;
