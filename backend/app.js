require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const authRoutes = require('./routes/auth.routes');
const frameRoutes = require('./routes/frame.routes');
const orderRoutes = require('./routes/order.routes');
const adminRoutes = require('./routes/admin.routes');
const insuranceRoutes = require('./routes/insurance.routes');

const app = express();

// Sécurité HTTP headers
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3001',
  credentials: true
}));

// Rate limiting général (DÉSACTIVÉ pour tests)
// const generalLimiter = rateLimit({
//   windowMs: 1000,
//   max: 10000,
//   message: { message: 'Trop de requêtes' }
// });
// app.use(generalLimiter);

// Rate limiting spécifique auth (DÉSACTIVÉ pour tests)
// const authLimiter = rateLimit({
//   windowMs: 1000,
//   max: 10000,
//   message: { message: 'Trop de tentatives' }
// });

// Middleware JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Route de test
app.get('/', (req, res) => {
  res.json({
    message: 'API backend opérationnelle 🚀',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Routes (sans rate limiter)
app.use('/auth', authRoutes);
app.use('/frames', frameRoutes);
app.use('/orders', orderRoutes);
app.use('/admin', adminRoutes);
app.use('/insurances', insuranceRoutes);

// Gestion d'erreurs globale
app.use((err, req, res, next) => {
  console.error('❌ Error:', err);
  res.status(err.status || 500).json({
    message: err.message || 'Erreur serveur interne',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Route 404
app.use((req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

module.exports = app;
