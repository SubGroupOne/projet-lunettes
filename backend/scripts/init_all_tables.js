require('dotenv').config();
const mysql = require('mysql2/promise');

async function initAllTables() {
    let connection;
    try {
        connection = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'eyeglasses_shop',
            port: process.env.DB_PORT || 3306
        });

        console.log('✅ Connexion réussie à la base de données');

        // Table frames
        console.log('📦 Création de la table frames...');
        await connection.execute(`
      CREATE TABLE IF NOT EXISTS frames (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL,
        brand VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        description TEXT,
        image_url VARCHAR(500),
        stock INT DEFAULT 0,
        category ENUM('soleil', 'optique', 'luxe') DEFAULT 'optique',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

        // Table orders
        console.log('📦 Création de la table orders...');
        await connection.execute(`
      CREATE TABLE IF NOT EXISTS orders (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT NOT NULL,
        frame_id INT NOT NULL,
        prescription_data JSON,
        insurance_data JSON,
        total_price DECIMAL(10, 2) NOT NULL,
        status ENUM('pending', 'validated', 'rejected', 'shipped', 'delivered') DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (frame_id) REFERENCES frames(id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

        console.log('🎉 Toutes les tables sont créées avec succès !');
    } catch (error) {
        console.error('❌ Erreur:', error);
    } finally {
        if (connection) await connection.end();
        process.exit();
    }
}

initAllTables();
