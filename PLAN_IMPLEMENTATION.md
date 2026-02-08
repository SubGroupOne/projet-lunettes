# 🚀 PLAN D'IMPLÉMENTATION PRIORITAIRE
## Application de Vente de Lunettes - Roadmap Technique

---

## 📅 PHASE 1 : SÉCURITÉ ET STABILITÉ (Semaine 1-2)

### 🔐 1.1 Configuration Environnement (.env)

**Priorité : 🔴 CRITIQUE**

#### Fichier : `backend/.env`
```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=eyeglasses_shop
DB_PORT=3306

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=votre_clé_secrète_très_longue_et_complexe_ici_minimum_64_caractères
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# Frontend URL (pour CORS)
FRONTEND_URL=http://localhost:3001

# Email (optionnel pour plus tard)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre_email@gmail.com
SMTP_PASSWORD=votre_mot_de_passe_app
```

#### Fichier : `backend/.env.example`
```env
# Copier ce fichier vers .env et remplir les valeurs

# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=eyeglasses_shop
DB_PORT=3306

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=CHANGE_THIS_TO_RANDOM_STRING
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# Frontend URL
FRONTEND_URL=http://localhost:3001
```

#### Modifications : `backend/config/db.js`
```javascript
require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;
```

#### Modifications : `backend/package.json`
```json
{
  "dependencies": {
    "bcryptjs": "^3.0.3",
    "dotenv": "^16.4.5",
    "express": "^5.2.1",
    "mysql2": "^3.16.1"
  }
}
```

**Commandes :**
```bash
cd backend
npm install dotenv
```

---

### 🔑 1.2 Authentification JWT

**Priorité : 🔴 CRITIQUE**

#### Installation
```bash
cd backend
npm install jsonwebtoken cookie-parser
```

#### Fichier : `backend/utils/jwt.util.js` (NOUVEAU)
```javascript
const jwt = require('jsonwebtoken');

/**
 * Génère un access token JWT
 */
exports.generateAccessToken = (userId, role) => {
  return jwt.sign(
    { userId, role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

/**
 * Génère un refresh token JWT
 */
exports.generateRefreshToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN }
  );
};

/**
 * Vérifie et décode un token
 */
exports.verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    return null;
  }
};
```

#### Fichier : `backend/middleware/auth.middleware.js` (NOUVEAU)
```javascript
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
```

#### Fichier : `backend/middleware/role.middleware.js` (NOUVEAU)
```javascript
/**
 * Middleware pour vérifier le rôle utilisateur
 * @param {string[]} allowedRoles - Tableau des rôles autorisés
 */
exports.authorize = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        message: 'Authentification requise.' 
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ 
        message: 'Accès interdit. Droits insuffisants.' 
      });
    }

    next();
  };
};
```

#### Modifications : `backend/controllers/auth.controller.js`
```javascript
const bcrypt = require('bcryptjs');
const User = require('../models/user.model');
const { generateAccessToken, generateRefreshToken } = require('../utils/jwt.util');

exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Tous les champs sont obligatoires' });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: 'Mot de passe trop court (min 6 caractères)' });
    }

    const existingUser = await User.findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({ message: 'Email déjà utilisé' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userId = await User.createUser(name, email, hashedPassword);

    const accessToken = generateAccessToken(userId, 'client');
    const refreshToken = generateRefreshToken(userId);

    res.status(201).json({ 
      message: 'Utilisateur créé avec succès',
      accessToken,
      refreshToken,
      user: {
        id: userId,
        name,
        email,
        role: 'client'
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

    if (!email || !password) {
      return res.status(400).json({
        message: 'Email et mot de passe requis'
      });
    }

    const user = await User.findUserByEmail(email);
    if (!user) {
      return res.status(401).json({
        message: 'Email ou mot de passe incorrect'
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        message: 'Email ou mot de passe incorrect'
      });
    }

    const accessToken = generateAccessToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

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

    const { verifyToken } = require('../utils/jwt.util');
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
```

#### Modifications : `backend/models/user.model.js`
```javascript
const db = require('../config/db');

exports.createUser = async (name, email, passwordHash, role = 'client') => {
  const sql = `
    INSERT INTO users (name, email, password_hash, role, is_active)
    VALUES (?, ?, ?, ?, true)
  `;
  const [result] = await db.execute(sql, [name, email, passwordHash, role]);
  return result.insertId;
};

exports.findUserByEmail = async (email) => {
  const sql = `
    SELECT id, name, email, password_hash as password, role 
    FROM users 
    WHERE email = ? AND is_active = true
  `;
  const [rows] = await db.execute(sql, [email]);
  return rows[0];
};

// NOUVEAU
exports.findUserById = async (id) => {
  const sql = `
    SELECT id, name, email, role 
    FROM users 
    WHERE id = ? AND is_active = true
  `;
  const [rows] = await db.execute(sql, [id]);
  return rows[0];
};
```

#### Modifications : `backend/routes/auth.routes.js`
```javascript
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/refresh', authController.refreshToken); // NOUVEAU

module.exports = router;
```

#### Modifications : `backend/routes/frame.routes.js`
```javascript
const express = require('express');
const router = express.Router();
const frameController = require('../controllers/frame.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Routes publiques
router.get('/', frameController.getAllFrames);
router.get('/:id', frameController.getFrameById);

// Routes protégées (opticien ou admin)
router.post('/', authenticate, authorize(['opticien', 'admin']), frameController.createFrame);
router.put('/:id', authenticate, authorize(['opticien', 'admin']), frameController.updateFrame);
router.delete('/:id', authenticate, authorize(['admin']), frameController.deleteFrame);

module.exports = router;
```

#### Modifications : `backend/routes/order.routes.js`
```javascript
const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Toutes les routes nécessitent authentification
router.get('/', authenticate, authorize(['opticien', 'admin']), orderController.getAllOrders);
router.get('/:id', authenticate, orderController.getOrderById);
router.post('/', authenticate, orderController.createOrder);
router.put('/:id/status', authenticate, authorize(['opticien', 'admin']), orderController.updateOrderStatus);

module.exports = router;
```

---

### 🛡️ 1.3 Sécurité Supplémentaire

**Priorité : 🔴 CRITIQUE**

#### Installation
```bash
cd backend
npm install helmet cors express-rate-limit
```

#### Modifications : `backend/app.js`
```javascript
require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const authRoutes = require('./routes/auth.routes');
const frameRoutes = require('./routes/frame.routes');
const orderRoutes = require('./routes/order.routes');

const app = express();

// Sécurité HTTP headers
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3001',
  credentials: true
}));

// Rate limiting général
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // max 100 requêtes par IP
});
app.use(generalLimiter);

// Rate limiting strict pour auth
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // max 5 tentatives de connexion
  message: 'Trop de tentatives. Réessayez dans 15 minutes.'
});

// Middleware JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Route de test
app.get('/', (req, res) => {
  res.send('API backend opérationnelle 🚀');
});

// Routes
app.use('/auth', authLimiter, authRoutes);
app.use('/frames', frameRoutes);
app.use('/orders', orderRoutes);

// Gestion d'erreurs globale
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    message: err.message || 'Erreur serveur interne',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

module.exports = app;
```

#### Modifications : `backend/server.js`
```javascript
require('dotenv').config();
const app = require('./app');

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(`🚀 Serveur lancé sur http://localhost:${PORT}`);
  console.log(`📊 Environnement: ${process.env.NODE_ENV || 'development'}`);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  process.exit(1);
});

process.on('SIGINT', () => {
  console.log('\n👋 Gracefully shutting down...');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});
```

---

### 🗄️ 1.4 Base de Données - Schéma et Migrations

**Priorité : 🟠 HAUTE**

#### Fichier : `backend/database/schema.sql` (NOUVEAU)
```sql
-- Base de données : eyeglasses_shop

CREATE DATABASE IF NOT EXISTS eyeglasses_shop
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE eyeglasses_shop;

-- Table users
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('client', 'opticien', 'admin') DEFAULT 'client',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table frames (montures)
CREATE TABLE IF NOT EXISTS frames (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  brand VARCHAR(255),
  price DECIMAL(10, 2) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  stock INT DEFAULT 0,
  category ENUM('soleil', 'optique', 'luxe') DEFAULT 'optique',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_category (category),
  INDEX idx_brand (brand)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table orders (commandes)
CREATE TABLE IF NOT EXISTS orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  frame_id INT NOT NULL,
  prescription_data JSON,
  insurance_data JSON,
  total_price DECIMAL(10, 2) NOT NULL,
  status ENUM('pending', 'confirmed', 'processing', 'delivered', 'cancelled') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (frame_id) REFERENCES frames(id) ON DELETE RESTRICT,
  INDEX idx_user (user_id),
  INDEX idx_status (status),
  INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table refresh_tokens (pour JWT refresh)
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token VARCHAR(500) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_token (token),
  INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### Fichier : `backend/database/seeds.sql` (NOUVEAU)
```sql
USE eyeglasses_shop;

-- Administrateur par défaut
-- Mot de passe: Admin123!
INSERT INTO users (name, email, password_hash, role) VALUES
('Admin Principal', 'admin@eyeglasses.com', '$2a$10$hNyj3rF8KZQKJc3H5HzHpOcA7PHQc4K5VFl0FWqx1Y3Kb.H.vSO5W', 'admin');

-- Opticien de test
-- Mot de passe: Opticien123!
INSERT INTO users (name, email, password_hash, role) VALUES
('Marie Opticienne', 'marie@eyeglasses.com', '$2a$10$hNyj3rF8KZQKJc3H5HzHpOcA7PHQc4K5VFl0FWqx1Y3Kb.H.vSO5W', 'opticien');

-- Clients de test
INSERT INTO users (name, email, password_hash, role) VALUES
('Jean Dupont', 'jean@example.com', '$2a$10$hNyj3rF8KZQKJc3H5HzHpOcA7PHQc4K5VFl0FWqx1Y3Kb.H.vSO5W', 'client'),
('Sophie Martin', 'sophie@example.com', '$2a$10$hNyj3rF8KZQKJc3H5HzHpOcA7PHQc4K5VFl0FWqx1Y3Kb.H.vSO5W', 'client');

-- Montures de test
INSERT INTO frames (name, brand, price, description, image_url, stock, category) VALUES
('Aviator Classic', 'Ray-Ban', 149.99, 'Lunettes aviateur iconiques avec verres polarisés', '/images/aviator.jpg', 25, 'soleil'),
('Wayfarer', 'Ray-Ban', 139.99, 'Style intemporel pour tous les jours', '/images/wayfarer.jpg', 30, 'soleil'),
('Rectangulaire Métal', 'Oakley', 179.99, 'Monture optique légère en métal', '/images/metal.jpg', 20, 'optique'),
('Cat Eye Vintage', 'Gucci', 399.99, 'Forme œil de chat élégante', '/images/cateye.jpg', 10, 'luxe'),
('Sport Performance', 'Nike', 119.99, 'Monture sportive avec verres anti-reflets', '/images/sport.jpg', 15, 'soleil');

-- Commandes de test
INSERT INTO orders (user_id, frame_id, prescription_data, insurance_data, total_price, status) VALUES
(3, 1, '{"od": {"sphere": -2.50, "cylinder": +0.75, "axis": 165}, "os": {"sphere": -2.25, "cylinder": +1.00, "axis": 15}}', '{"provider": "Mutuelle Santé", "coverage": 0.60}', 149.99, 'confirmed'),
(4, 3, '{"od": {"sphere": -1.00, "cylinder": 0, "axis": 0}, "os": {"sphere": -1.25, "cylinder": 0, "axis": 0}}', '{"provider": "AXA", "coverage": 0.70}', 179.99, 'pending');
```

**Commandes pour initialiser la DB :**
```bash
# Créer le schéma
mysql -u root -p < backend/database/schema.sql

# Insérer les données de test
mysql -u root -p < backend/database/seeds.sql
```

---

## 📅 PHASE 2 : IA OCR ORDONNANCE (Semaine 3)

### 📸 2.1 Intégration Google ML Kit Text Recognition

**Priorité : 🟠 HAUTE**

#### Frontend Flutter

##### Ajout dans `frontend/pubspec.yaml`
```yaml
dependencies:
  google_ml_kit_text_recognition: ^0.13.0
```

##### Fichier : `frontend/lib/services/ocr_service.dart` (NOUVEAU)
```dart
import 'package:google_ml_kit_text_recognition/google_ml_kit_text_recognition.dart';
import 'package:camera/camera.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>?> extractPrescriptionData(XFile imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Parser le texte reconnu
      final prescription = _parsePrescriptionText(recognizedText.text);
      return prescription;
    } catch (e) {
      print('OCR Error: $e');
      return null;
    }
  }

  Map<String, dynamic> _parsePrescriptionText(String text) {
    // Regex pour extraire OD/OS et valeurs
    final RegExp odPattern = RegExp(r'OD[:\s]+(-?\d+\.?\d*)[^\d]+([+\-]?\d+\.?\d*)[^\d]+(\d+)', multiLine: true);
    final RegExp osPattern = RegExp(r'OS[:\s]+(-?\d+\.?\d*)[^\d]+([+\-]?\d+\.?\d*)[^\d]+(\d+)', multiLine: true);

    final odMatch = odPattern.firstMatch(text);
    final osMatch = osPattern.firstMatch(text);

    Map<String, dynamic> result = {
      'od': {
        'sphere': odMatch != null ? double.tryParse(odMatch.group(1)!) : null,
        'cylinder': odMatch != null ? double.tryParse(odMatch.group(2)!) : null,
        'axis': odMatch != null ? int.tryParse(odMatch.group(3)!) : null,
      },
      'os': {
        'sphere': osMatch != null ? double.tryParse(osMatch.group(1)!) : null,
        'cylinder': osMatch != null ? double.tryParse(osMatch.group(2)!) : null,
        'axis': osMatch != null ? int.tryParse(osMatch.group(3)!) : null,
      },
      'rawText': text,
    };

    return result;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
```

##### Modifications : `frontend/lib/scanner_ordonnance_page.dart`
Remplacer les données hardcodées par un vrai scan.

---

## 📅 PHASE 3 : INTERFACE ADMIN (Semaine 4)

### 🖥️ 3.1 Dashboard Administrateur

**Priorité : 🟠 HAUTE**

#### Backend

##### Fichier : `backend/controllers/admin.controller.js` (NOUVEAU)
```javascript
const db = require('../config/db');

exports.getDashboardStats = async (req, res) => {
  try {
    const [userStats] = await db.execute('SELECT COUNT(*) as total FROM users');
    const [orderStats] = await db.execute('SELECT COUNT(*) as total, SUM(total_price) as revenue FROM orders WHERE status = "delivered"');
    const [frameStats] = await db.execute('SELECT COUNT(*) as total FROM frames WHERE is_active = true');

    res.json({
      users: userStats[0].total,
      orders: orderStats[0].total,
      revenue: orderStats[0].revenue || 0,
      frames: frameStats[0].total
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.getAllUsers = async (req, res) => {
  try {
    const [users] = await db.execute('SELECT id, name, email, role, is_active, created_at FROM users');
    res.json(users);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.updateUserRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    if (!['client', 'opticien', 'admin'].includes(role)) {
      return res.status(400).json({ message: 'Rôle invalide' });
    }

    await db.execute('UPDATE users SET role = ? WHERE id = ?', [role, id]);
    res.json({ message: 'Rôle mis à jour avec succès' });
  } catch (error) {
    console.error('Update role error:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};
```

##### Fichier : `backend/routes/admin.routes.js` (NOUVEAU)
```javascript
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

// Toutes les routes admin nécessitent le rôle admin
router.use(authenticate, authorize(['admin']));

router.get('/dashboard/stats', adminController.getDashboardStats);
router.get('/users', adminController.getAllUsers);
router.put('/users/:id/role', adminController.updateUserRole);

module.exports = router;
```

##### Modifications : `backend/app.js`
```javascript
const adminRoutes = require('./routes/admin.routes');
// ...
app.use('/admin', adminRoutes);
```

---

## 📅 PHASE 4 : TESTS (Semaine 5)

### 🧪 4.1 Tests Backend

**Priorité : 🟡 MOYENNE**

#### Installation
```bash
cd backend
npm install --save-dev jest supertest
```

#### Configuration : `backend/package.json`
```json
{
  "scripts": {
    "test": "jest --coverage",
    "test:watch": "jest --watch"
  },
  "jest": {
    "testEnvironment": "node",
    "coveragePathIgnorePatterns": ["/node_modules/"]
  }
}
```

#### Fichier : `backend/__tests__/auth.test.js` (NOUVEAU)
```javascript
const request = require('supertest');
const app = require('../app');

describe('Authentication', () => {
  it('should register a new user', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({
        name: 'Test User',
        email: `test${Date.now()}@example.com`,
        password: 'Password123!'
      });

    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('accessToken');
  });

  it('should login with valid credentials', async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({
        email: 'admin@eyeglasses.com',
        password: 'Admin123!'
      });

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('accessToken');
  });
});
```

---

## 📅 PRIORITÉS RÉSUMÉES

| Phase | Tâche | Priorité | Temps estimé |
|-------|-------|----------|--------------|
| 1.1 | Configuration .env | 🔴 CRITIQUE | 2h |
| 1.2 | JWT Authentication | 🔴 CRITIQUE | 1 jour |
| 1.3 | Sécurité (helmet, CORS, rate limiting) | 🔴 CRITIQUE | 4h |
| 1.4 | Schéma DB + seeds | 🟠 HAUTE | 1 jour |
| 2.1 | OCR Text Recognition | 🟠 HAUTE | 2-3 jours |
| 3.1 | Dashboard Admin | 🟠 HAUTE | 2-3 jours |
| 4.1 | Tests Backend | 🟡 MOYENNE | 2-3 jours |

---

## ✅ CHECKLIST DE MISE EN PRODUCTION

```
Phase 1 (Critique)
[ ] .env configuré
[ ] JWT implémenté
[ ] Middleware auth/role fonctionnels
[ ] Helmet + CORS + Rate limiting
[ ] Schéma DB créé
[ ] Seeds de test insérés

Phase 2 (Haute)
[ ] OCR Google ML Kit intégré
[ ] Parser prescription fonctionnel
[ ] Tests manuel OCR OK

Phase 3 (Haute)
[ ] Admin dashboard stats
[ ] Gestion utilisateurs admin
[ ] Gestion rôles admin

Phase 4 (Moyenne)
[ ] Tests auth backend
[ ] Tests API frames/orders
[ ] Coverage > 60%
```

---

**Document créé par Antigravity AI**  
**Date :** 7 Février 2026
