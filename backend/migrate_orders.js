const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  try {
    console.log('Migrating database...');
    
    // 1. Drop foreign key first to allow modifying the column
    try {
      await connection.execute('ALTER TABLE orders DROP FOREIGN KEY orders_ibfk_2');
    } catch (e) {
      console.log('Foreign key might not exist or has a different name, continuing...');
    }

    // 2. Modify frame_id to be nullable
    await connection.execute('ALTER TABLE orders MODIFY frame_id INT NULL');

    // 3. Add frame_name column
    try {
      await connection.execute('ALTER TABLE orders ADD COLUMN frame_name VARCHAR(255) AFTER frame_id');
      console.log('Column frame_name added.');
    } catch (e) {
      console.log('Column frame_name might already exist.');
    }

    console.log('Migration successful!');
  } catch (err) {
    console.error('Migration failed:', err);
  } finally {
    await connection.end();
  }
}

migrate();
