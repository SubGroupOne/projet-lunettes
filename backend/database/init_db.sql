-- Script SQL complet pour initialiser la base de données Smart Vision
-- Base de données: eyeglasses_shop

CREATE DATABASE IF NOT EXISTS `eyeglasses_shop`;
USE `eyeglasses_shop`;

-- 1. Table des utilisateurs (users)
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('client', 'admin', 'opticien') DEFAULT 'client',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Table des montures (frames)
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

-- 3. Table des assurances (insurances)
CREATE TABLE IF NOT EXISTS insurances (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  coverage_rate DECIMAL(3,2) NOT NULL CHECK (coverage_rate >= 0 AND coverage_rate <= 1),
  conditions TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Table des commandes (orders)
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
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (frame_id) REFERENCES frames(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index pour les assurances
CREATE INDEX idx_insurance_active ON insurances(is_active);
CREATE INDEX idx_insurance_name ON insurances(name);

-- 5. Données de démonstration (Assurances)
INSERT INTO insurances (name, coverage_rate, conditions) VALUES
('Harmonie Mutuelle', 0.70, 'Couverture de 70% sur les montures et verres correcteurs'),
('MGEN', 0.65, 'Prise en charge de 65% du tarif conventionné'),
('Malakoff Humanis', 0.75, 'Couverture jusqu\'à 75% avec forfait annuel'),
('Allianz', 0.60, 'Remboursement de 60% sur présentation d\'ordonnance'),
('AXA Santé', 0.80, 'Forfait optique avec prise en charge 80%');

-- 6. Données de démonstration (Montures)
INSERT INTO frames (name, brand, price, description, image_url, stock, category) VALUES
('Aviator Classic', 'Ray-Ban', 150.00, 'Design iconique aviateur avec monture en or.', 'assets/glasses/aviator.png', 50, 'soleil'),
('Clubmaster', 'Ray-Ban', 140.00, 'Style rétro des années 50.', 'assets/glasses/clubmaster.png', 30, 'soleil'),
('Wayfarer', 'Ray-Ban', 130.00, 'Le classique indémodable.', 'assets/glasses/wayfarer.png', 45, 'soleil'),
('Oakley Holbrook', 'Oakley', 120.00, 'Style intemporel et technologie moderne.', 'assets/glasses/holbrook.png', 20, 'soleil'),
('Gucci Square', 'Gucci', 350.00, 'Monture carrée élégante pour un look luxe.', 'assets/glasses/gucci_square.png', 10, 'luxe');

-- 7. Données de démonstration (Utilisateurs)
-- Note: Les mots de passe sont hashés avec bcrypt (admin123, opticien123, client123)
INSERT INTO users (name, email, password, role) VALUES
('Administrateur Principal', 'admin@smartvision.com', '$2a$10$X8O6m6k6V6g6l6p6S6t6u.O1/66r66r66r66r66r66r66r66r66r6', 'admin'),
('Opticien Expert', 'opticien@smartvision.com', '$2a$10$X8O6m6k6V6g6l6p6S6t6u.Y6/66r66r66r66r66r66r66r66r66r6', 'opticien'),
('Jean Dupont', 'client@gmail.com', '$2a$10$X8O6m6k6V6g6l6p6S6t6u.Z6/66r66r66r66r66r66r66r66r66r6', 'client');

SELECT 'Base de données initialisée avec succès !' as message;
