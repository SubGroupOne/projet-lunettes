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
    SELECT id, name, email, password_hash as password, role FROM users WHERE email = ? AND is_active = true
  `;
  const [rows] = await db.execute(sql, [email]);
  return rows[0];
};
