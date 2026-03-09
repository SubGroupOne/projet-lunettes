/**
 * Smart Vision - Script de configuration automatique
 * Lance avec : node setup.js
 */

require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

const DB_CONFIG = {
  host:     process.env.DB_HOST     || 'localhost',
  user:     process.env.DB_USER     || 'root',
  password: process.env.DB_PASSWORD || 'password123',
};

const DB_NAME = process.env.DB_NAME || 'eyeglasses_shop';

async function setup() {
  console.log('');
  console.log('╔══════════════════════════════════════════╗');
  console.log('║      Smart Vision - Setup automatique    ║');
  console.log('╚══════════════════════════════════════════╝');
  console.log('');

  let connection;

  try {
    // ── Connexion MySQL ─────────────────────────────────
    console.log('🔌 Connexion à MySQL...');
    connection = await mysql.createConnection(DB_CONFIG);
    console.log('✅ Connecté à MySQL\n');

    // ── Créer la base de données ────────────────────────
    console.log(`🗄️  Création de la base de données "${DB_NAME}"...`);
    await connection.execute(`CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
    await connection.execute(`USE \`${DB_NAME}\``);
    console.log(`✅ Base de données "${DB_NAME}" prête\n`);

    // ── Créer la table users ────────────────────────────
    console.log('👤 Création de la table users...');
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id         INT AUTO_INCREMENT PRIMARY KEY,
        name       VARCHAR(255)                          NOT NULL,
        email      VARCHAR(255)                          NOT NULL UNIQUE,
        password   VARCHAR(255)                          NOT NULL,
        role       ENUM('client','opticien','admin')     NOT NULL DEFAULT 'client',
        phone      VARCHAR(20)                           DEFAULT NULL,
        address    TEXT                                  DEFAULT NULL,
        created_at TIMESTAMP                             DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log('✅ Table users créée\n');

    // ── Créer la table frames ───────────────────────────
    console.log('👓 Création de la table frames...');
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS frames (
        id          INT AUTO_INCREMENT PRIMARY KEY,
        name        VARCHAR(255)                              NOT NULL,
        brand       VARCHAR(255)                              NOT NULL,
        price       DECIMAL(10,2)                             NOT NULL,
        description TEXT                                      DEFAULT NULL,
        image_url   VARCHAR(500)                              DEFAULT NULL,
        stock       INT                                       DEFAULT 0,
        category    ENUM('soleil','optique','luxe')           DEFAULT 'optique',
        created_at  TIMESTAMP                                 DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log('✅ Table frames créée\n');

    // ── Créer la table orders ───────────────────────────
    console.log('📦 Création de la table orders...');
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS orders (
        id         INT AUTO_INCREMENT PRIMARY KEY,
        user_id    INT                                        NOT NULL,
        frame_id   INT                                        NOT NULL,
        quantity   INT                                        DEFAULT 1,
        total      DECIMAL(10,2)                              NOT NULL,
        status     ENUM('pending','confirmed','delivered')    DEFAULT 'pending',
        created_at TIMESTAMP                                  DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (frame_id) REFERENCES frames(id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log('✅ Table orders créée\n');

    // ── Créer la table insurances ───────────────────────
    console.log('🏥 Création de la table insurances...');
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS insurances (
        id         INT AUTO_INCREMENT PRIMARY KEY,
        name       VARCHAR(255)   NOT NULL,
        coverage   DECIMAL(10,2)  DEFAULT 0,
        created_at TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log('✅ Table insurances créée\n');

    // ── Insérer les utilisateurs ────────────────────────
    console.log('👥 Création des utilisateurs...');
    const users = [
      { name: 'Client Test',       email: 'client@gmail.com',          password: 'client123',   role: 'client'   },
      { name: 'Opticien Smart',    email: 'opticien@smartvision.com',   password: 'opticien123', role: 'opticien' },
      { name: 'Admin Smart',       email: 'admin@smartvision.com',      password: 'admin123',    role: 'admin'    },
    ];

    for (const user of users) {
      const hash = await bcrypt.hash(user.password, 10);
      await connection.execute(`
        INSERT INTO users (name, email, password, role)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE password = VALUES(password), role = VALUES(role)
      `, [user.name, user.email, hash, user.role]);
      console.log(`  ✅ ${user.role}: ${user.email} / ${user.password}`);
    }
    console.log('');

    // ── Insérer les lunettes ────────────────────────────
    console.log('👓 Insertion des 12 montures...');
    const frames = [
      { name: 'Aviator Classic',   brand: 'Ray-Ban', price: 145, image: 'assets/glasses/img1.jpg',  stock: 15, category: 'soleil'  },
      { name: 'Clubmaster',        brand: 'Ray-Ban', price: 120, image: 'assets/glasses/img2.jpg',  stock: 10, category: 'optique' },
      { name: 'Wayfarer',          brand: 'Ray-Ban', price: 130, image: 'assets/glasses/img3.jpg',  stock: 12, category: 'soleil'  },
      { name: 'Oakley Holbrook',   brand: 'Oakley',  price: 110, image: 'assets/glasses/img4.jpg',  stock: 8,  category: 'soleil'  },
      { name: 'Gucci Square',      brand: 'Gucci',   price: 750, image: 'assets/glasses/img5.jpg',  stock: 5,  category: 'luxe'    },
      { name: 'Black Classic',     brand: 'Smart',   price: 145, image: 'assets/glasses/img6.jpg',  stock: 10, category: 'optique' },
      { name: 'Eyeglasses',        brand: 'Smart',   price: 120, image: 'assets/glasses/img7.jpg',  stock: 10, category: 'optique' },
      { name: 'Modele A01',        brand: 'Smart',   price: 110, image: 'assets/glasses/img8.jpg',  stock: 10, category: 'optique' },
      { name: 'Specs Pro',         brand: 'Oakley',  price: 135, image: 'assets/glasses/img9.jpg',  stock: 10, category: 'optique' },
      { name: 'Eyewear Luxe',      brand: 'Cartier', price: 750, image: 'assets/glasses/img10.jpg', stock: 5,  category: 'luxe'    },
      { name: 'Ray-Ban Classic',   brand: 'Ray-Ban', price: 155, image: 'assets/glasses/img11.jpg', stock: 10, category: 'optique' },
      { name: 'Wayfarer Elite',    brand: 'Ray-Ban', price: 170, image: 'assets/glasses/img12.jpg', stock: 10, category: 'optique' },
    ];

    // Vider la table d'abord pour éviter les doublons
    await connection.execute('DELETE FROM frames');
    await connection.execute('ALTER TABLE frames AUTO_INCREMENT = 1');

    for (const frame of frames) {
      await connection.execute(`
        INSERT INTO frames (name, brand, price, image_url, stock, category)
        VALUES (?, ?, ?, ?, ?, ?)
      `, [frame.name, frame.brand, frame.price, frame.image, frame.stock, frame.category]);
      console.log(`  ✅ ${frame.name} - ${frame.brand} - ${frame.price}€`);
    }
    console.log('');

    // ── Résumé final ────────────────────────────────────
    console.log('╔══════════════════════════════════════════╗');
    console.log('║           ✅ SETUP TERMINÉ !             ║');
    console.log('╠══════════════════════════════════════════╣');
    console.log('║  Comptes de test :                       ║');
    console.log('║  client@gmail.com        / client123     ║');
    console.log('║  opticien@smartvision.com/ opticien123   ║');
    console.log('║  admin@smartvision.com   / admin123      ║');
    console.log('╠══════════════════════════════════════════╣');
    console.log('║  Lancer l\'application :                  ║');
    console.log('║  node server.js                          ║');
    console.log('╚══════════════════════════════════════════╝');
    console.log('');

  } catch (err) {
    console.error('❌ Erreur durant le setup :', err.message);
    console.error('');
    console.error('Vérifiez que :');
    console.error('  1. MySQL est démarré : sudo systemctl start mysql');
    console.error('  2. Les identifiants dans .env sont corrects');
    console.error('  3. npm install a été lancé');
    process.exit(1);
  } finally {
    if (connection) await connection.end();
  }
}

setup();