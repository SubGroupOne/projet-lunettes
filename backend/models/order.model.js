const db = require('../config/db');

exports.getAllOrders = async () => {
    const sql = `
    SELECT o.*, u.name as client_name, f.name as frame_name 
    FROM orders o
    JOIN users u ON o.user_id = u.id
    JOIN frames f ON o.frame_id = f.id
    ORDER BY o.created_at DESC
  `;
    const [rows] = await db.execute(sql);
    return rows;
};

exports.getOrderById = async (id) => {
    const sql = `
    SELECT o.*, u.name as client_name, u.email as client_email, f.name as frame_name 
    FROM orders o
    JOIN users u ON o.user_id = u.id
    JOIN frames f ON o.frame_id = f.id
    WHERE o.id = ?
  `;
    const [rows] = await db.execute(sql, [id]);
    return rows[0];
};

exports.updateOrderStatus = async (id, status) => {
    const sql = 'UPDATE orders SET status = ? WHERE id = ?';
    await db.execute(sql, [status, id]);
};

exports.createOrder = async (userId, frameId, prescriptionData, insuranceData, totalPrice) => {
    const sql = `
    INSERT INTO orders (user_id, frame_id, prescription_data, insurance_data, total_price, status)
    VALUES (?, ?, ?, ?, ?, 'pending')
  `;
    const [result] = await db.execute(sql, [userId, frameId, JSON.stringify(prescriptionData), JSON.stringify(insuranceData), totalPrice]);
    return result.insertId;
};
