const nodemailer = require('nodemailer');

// Configuration du transporteur email
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT) || 587,
  secure: false, // true pour 465, false pour les autres ports
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASSWORD,
  },
});

/**
 * Envoyer un email
 */
const sendEmail = async (to, subject, html) => {
  try {
    const info = await transporter.sendMail({
      from: `"Smart Vision" <${process.env.SMTP_USER}>`,
      to,
      subject,
      html,
    });

    console.log('Email envoyé:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Erreur envoi email:', error);
    return { success: false, error: error.message };
  }
};

/**
 * Envoyer notification de commande au client
 */
exports.sendOrderNotification = async (clientEmail, clientName, orderId, status) => {
  const statusMessages = {
    confirmed: 'Votre commande a été confirmée par l\'opticien',
    processing: 'Votre commande est en cours de préparation',
    shipped: 'Votre commande a été expédiée',
    delivered: 'Votre commande a été livrée',
    rejected: 'Votre commande a été rejetée',
  };

  const message = statusMessages[status] || 'Le statut de votre commande a été mis à jour';

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>👓 Smart Vision</h1>
          <p>Notification de commande</p>
        </div>
        <div class="content">
          <h2>Bonjour ${clientName},</h2>
          <p><strong>${message}</strong></p>
          <p>Numéro de commande : <strong>#${orderId}</strong></p>
          <p>Nouveau statut : <strong>${status}</strong></p>
          <a href="${process.env.FRONTEND_URL || 'http://localhost:3001'}/orders/${orderId}" class="button">
            Voir ma commande
          </a>
        </div>
        <div class="footer">
          <p>© 2026 Smart Vision - Application de vente de lunettes</p>
          <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  return await sendEmail(clientEmail, `Commande #${orderId} - ${message}`, html);
};

/**
 * Envoyer email de bienvenue
 */
exports.sendWelcomeEmail = async (userEmail, userName) => {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>👓 Bienvenue sur Smart Vision !</h1>
        </div>
        <div class="content">
          <h2>Bonjour ${userName},</h2>
          <p>Merci de vous être inscrit sur <strong>Smart Vision</strong>, votre application de vente de lunettes avec intelligence artificielle !</p>
          <h3>Fonctionnalités disponibles :</h3>
          <ul>
            <li>✨ Essai virtuel avec reconnaissance faciale</li>
            <li>📸 Scan automatique d'ordonnance (OCR)</li>
            <li>🛒 Commande en ligne sécurisée</li>
            <li>📦 Suivi de commande en temps réel</li>
          </ul>
          <a href="${process.env.FRONTEND_URL || 'http://localhost:3001'}" class="button">
            Commencer mon essai virtuel
          </a>
        </div>
      </div>
    </body>
    </html>
  `;

  return await sendEmail(userEmail, 'Bienvenue sur Smart Vision ! 👓', html);
};

/**
 * Notification pour l'opticien (nouvelle commande)
 */
exports.sendNewOrderToOptician = async (opticianEmail, orderId, clientName) => {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #10b981; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 12px 30px; background: #10b981; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🔔 Nouvelle Commande !</h1>
        </div>
        <div class="content">
          <h2>Une nouvelle commande nécessite votre attention</h2>
          <p>Client : <strong>${clientName}</strong></p>
          <p>Commande N° : <strong>#${orderId}</strong></p>
          <p>Veuillez consulter l'ordonnance et valider ou rejeter la commande.</p>
          <a href="${process.env.FRONTEND_URL || 'http://localhost:3001'}/optician/orders/${orderId}" class="button">
            Voir la commande
          </a>
        </div>
      </div>
    </body>
    </html>
  `;

  return await sendEmail(opticianEmail, `Nouvelle commande #${orderId}`, html);
};

module.exports = {
  sendEmail,
  sendOrderNotification: exports.sendOrderNotification,
  sendWelcomeEmail: exports.sendWelcomeEmail,
  sendNewOrderToOptician: exports.sendNewOrderToOptician,
};
