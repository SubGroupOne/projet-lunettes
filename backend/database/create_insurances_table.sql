-- Script SQL pour créer la table insurances
-- Base de données: eyeglasses_shop

-- Table des assurances
CREATE TABLE IF NOT EXISTS insurances (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  coverage_rate DECIMAL(3,2) NOT NULL CHECK (coverage_rate >= 0 AND coverage_rate <= 1),
  conditions TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index pour optimisation
CREATE INDEX idx_insurance_active ON insurances(is_active);
CREATE INDEX idx_insurance_name ON insurances(name);

-- Données de démonstration
INSERT INTO insurances (name, coverage_rate, conditions) VALUES
('Harmonie Mutuelle', 0.70, 'Couverture de 70% sur les montures et verres correcteurs'),
('MGEN', 0.65, 'Prise en charge de 65% du tarif conventionné'),
('Malakoff Humanis', 0.75, 'Couverture jusqu\'à 75% avec forfait annuel'),
('Allianz', 0.60, 'Remboursement de 60% sur présentation d\'ordonnance'),
('AXA Santé', 0.80, 'Forfait optique avec prise en charge 80%');

-- Afficher les assurances créées
SELECT * FROM insurances;
