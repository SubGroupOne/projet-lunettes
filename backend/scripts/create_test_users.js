require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function createTestUsers() {
    let connection;
    try {
        // 1. Connexion à MySQL
        connection = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'eyeglasses_shop', // Utiliser la base correcte créée par init_insurances
            port: process.env.DB_PORT || 3306
        });

        console.log('Connexion établie.');

        // 2. Création de la table 'users'
        console.log("Création de la table 'users' si elle n'existe pas (avec rôle ENUM)...");
        await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        role ENUM('client', 'admin', 'opticien') DEFAULT 'client',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

        // 3. Création des utilisateurs
        const users = [
            {
                name: 'Administrateur Principal',
                email: 'admin@smartvision.com', // Admin
                password: 'admin123',
                role: 'admin'
            },
            {
                name: 'Opticien Expert',
                email: 'opticien@smartvision.com', // Opticien
                password: 'opticien123',
                role: 'opticien'
            },
            {
                name: 'Jean Dupont',
                email: 'client@gmail.com', // Client
                password: 'client123',
                role: 'client'
            }
        ];

        for (const user of users) {
            // Vérifier existence
            const [existing] = await connection.execute('SELECT id FROM users WHERE email = ?', [user.email]);

            if (existing.length === 0) {
                const hashedPassword = await bcrypt.hash(user.password, 10);
                await connection.execute(
                    'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
                    [user.name, user.email, hashedPassword, user.role]
                );
                console.log(`✅ Créé: ${user.role} -> ${user.email} (MDP: ${user.password})`);
            } else {
                console.log(`ℹ️ Déjà existant: ${user.email} (MDP inchangé)`);
            }
        }

        console.log('\n🎉 Tout est prêt !');
    } catch (error) {
        console.error('❌ Erreur:', error);
    } finally {
        if (connection) await connection.end();
        process.exit();
    }
}

createTestUsers();
