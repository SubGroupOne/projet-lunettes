const db = require('../config/db');

exports.createUser = async (email, passwordHash) => {
  const sql = `
    INSERT INTO users (email, password_hash, role, is_active)
    VALUES (?, ?, 'client', true)
  `;
  const [result] = await db.execute(sql, [email, passwordHash]);
  return result.insertId;
};

exports.findUserByEmail = async (email) => {
  const sql = `
    SELECT * FROM users WHERE email = ? AND is_active = true
  `;
  const [rows] = await db.execute(sql, [email]);
  return rows[0];
};
