const db = require('../config/db');

exports.getAllFrames = async () => {
    const [rows] = await db.execute('SELECT * FROM frames');
    return rows;
};

exports.getFrameById = async (id) => {
    const [rows] = await db.execute('SELECT * FROM frames WHERE id = ?', [id]);
    return rows[0];
};

exports.createFrame = async (name, brand, price, description, imageUrl, stock) => {
    const sql = `
    INSERT INTO frames (name, brand, price, description, image_url, stock)
    VALUES (?, ?, ?, ?, ?, ?)
  `;
    const [result] = await db.execute(sql, [name, brand, price, description, imageUrl, stock]);
    return result.insertId;
};

exports.updateFrame = async (id, name, brand, price, description, imageUrl, stock) => {
    const sql = `
    UPDATE frames 
    SET name = ?, brand = ?, price = ?, description = ?, image_url = ?, stock = ?
    WHERE id = ?
  `;
    await db.execute(sql, [name, brand, price, description, imageUrl, stock, id]);
};

exports.deleteFrame = async (id) => {
    await db.execute('DELETE FROM frames WHERE id = ?', [id]);
};
