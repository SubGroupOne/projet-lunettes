const db = require('../config/db');

exports.createUser = async (name, email, passwordHash, role = 'client') => {
  const sql = `
    INSERT INTO users (name, email, password, role)
    VALUES (?, ?, ?, ?)
  `;
  const [result] = await db.execute(sql, [name, email, passwordHash, role]);
  return result.insertId;
};

exports.findUserByEmail = async (email) => {
  const sql = `
    SELECT id, name, email, password, role FROM users WHERE email = ?
  `;
  const [rows] = await db.execute(sql, [email]);
  return rows[0];
};

exports.findUserById = async (id) => {
  const sql = `
    SELECT id, name, email, role 
    FROM users 
    WHERE id = ?
  `;
  const [rows] = await db.execute(sql, [id]);
  return rows[0];
};
