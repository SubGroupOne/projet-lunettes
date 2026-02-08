require('dotenv').config();
const mysql = require('mysql2/promise');

async function initDatabase() {
    let connection;
    try {
        console.log('Connexion à MySQL...');
        // Connexion sans spécifier de base de données pour pouvoir la créer
        connection = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            port: process.env.DB_PORT || 3306
        });

        console.log(`Création de la base de données ${process.env.DB_NAME || 'eyeglasses_shop'}...`);
        await connection.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME || 'eyeglasses_shop'}\`;`);
        console.log('✅ Base de données créée ou existante.');

        console.log(`Sélection de la base de données...`);
        await connection.query(`USE \`${process.env.DB_NAME || 'eyeglasses_shop'}\`;`);

        console.log('Création de la table insurances...');
        await connection.execute(`
      CREATE TABLE IF NOT EXISTS insurances (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL,
        coverage_rate DECIMAL(3,2) NOT NULL CHECK (coverage_rate >= 0 AND coverage_rate <= 1),
        conditions TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);
        console.log('✅ Table insurances prête.');

        // Index
        try {
            await connection.execute(`CREATE INDEX idx_insurance_active ON insurances(is_active)`);
        } catch (e) {
            if (e.errno !== 1061) console.log('Info index active:', e.message);
        }

        try {
            await connection.execute(`CREATE INDEX idx_insurance_name ON insurances(name)`);
        } catch (e) {
            if (e.errno !== 1061) console.log('Info index name:', e.message);
        }

        // Données
        const [rows] = await connection.execute('SELECT COUNT(*) as count FROM insurances');

        if (rows[0].count === 0) {
            console.log('Insertion des données de démonstration...');
            const insertSql = `
        INSERT INTO insurances (name, coverage_rate, conditions) VALUES
        ('Harmonie Mutuelle', 0.70, 'Couverture de 70% sur les montures et verres correcteurs'),
        ('MGEN', 0.65, 'Prise en charge de 65% du tarif conventionné'),
        ('Malakoff Humanis', 0.75, 'Couverture jusqu\\'à 75% avec forfait annuel'),
        ('Allianz', 0.60, 'Remboursement de 60% sur présentation d\\'ordonnance'),
        ('AXA Santé', 0.80, 'Forfait optique avec prise en charge 80%');
      `;
            await connection.execute(insertSql);
            console.log('✅ Données insérées.');
        } else {
            console.log('⚠️ Table déjà initialisée.');
        }

        console.log('🎉 Initialisation terminée avec succès !');

    } catch (error) {
        console.error('❌ Erreur:', error);
    } finally {
        if (connection) await connection.end();
        process.exit();
    }
}

initDatabase();
