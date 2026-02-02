-- =====================================================
-- Base de données : Application de vente de verres correcteurs
-- Version complète et production-ready
-- =====================================================

DROP DATABASE IF EXISTS eyeglasses_shop;
CREATE DATABASE eyeglasses_shop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eyeglasses_shop;

-- =====================================================
-- TABLE: users (Utilisateurs génériques)
-- =====================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('client', 'opticien', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- =====================================================
-- TABLE: sessions (Tokens d'authentification)
-- =====================================================
CREATE TABLE sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(500) NOT NULL,
    refresh_token VARCHAR(500),
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token(255)),
    INDEX idx_user (user_id),
    INDEX idx_expires (expires_at)
);

-- =====================================================
-- TABLE: clients
-- =====================================================
CREATE TABLE clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20),
    adresse TEXT,
    ville VARCHAR(100),
    code_postal VARCHAR(10),
    pays VARCHAR(100) DEFAULT 'Burkina Faso',
    date_naissance DATE,
    photo_profil VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_nom (nom),
    INDEX idx_prenom (prenom)
);

-- =====================================================
-- TABLE: opticiens
-- =====================================================
CREATE TABLE opticiens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    nom_entreprise VARCHAR(255) NOT NULL,
    numero_licence VARCHAR(100) UNIQUE,
    telephone VARCHAR(20),
    adresse TEXT,
    ville VARCHAR(100),
    code_postal VARCHAR(10),
    pays VARCHAR(100) DEFAULT 'Burkina Faso',
    horaires_ouverture TEXT,
    description TEXT,
    logo_url VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    note_moyenne DECIMAL(3,2) DEFAULT 0.00,
    nombre_avis INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_ville (ville),
    INDEX idx_verified (is_verified)
);

-- =====================================================
-- TABLE: administrateurs
-- =====================================================
CREATE TABLE administrateurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- TABLE: assurances
-- =====================================================
CREATE TABLE assurances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_compagnie VARCHAR(255) NOT NULL,
    numero_contact VARCHAR(20),
    email VARCHAR(255),
    adresse TEXT,
    taux_remboursement DECIMAL(5,2) DEFAULT 0.00,
    plafond_annuel DECIMAL(10,2),
    conditions_remboursement TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nom_compagnie (nom_compagnie)
);

-- =====================================================
-- TABLE: client_assurances
-- =====================================================
CREATE TABLE client_assurances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    assurance_id INT NOT NULL,
    numero_police VARCHAR(100) NOT NULL,
    date_debut DATE,
    date_fin DATE,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (assurance_id) REFERENCES assurances(id) ON DELETE CASCADE,
    INDEX idx_client (client_id),
    INDEX idx_numero_police (numero_police)
);

-- =====================================================
-- TABLE: categories_montures
-- =====================================================
CREATE TABLE categories_montures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    ordre INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: montures
-- =====================================================
CREATE TABLE montures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    opticien_id INT NOT NULL,
    categorie_id INT,
    reference VARCHAR(100) UNIQUE NOT NULL,
    nom VARCHAR(255) NOT NULL,
    marque VARCHAR(100),
    description TEXT,
    prix DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    couleur VARCHAR(50),
    materiau VARCHAR(100),
    forme VARCHAR(50),
    genre ENUM('homme', 'femme', 'mixte', 'enfant') DEFAULT 'mixte',
    taille VARCHAR(50),
    poids DECIMAL(5,2),
    image_principale VARCHAR(255),
    modele_3d_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    nombre_vues INT DEFAULT 0,
    nombre_essayages INT DEFAULT 0,
    note_moyenne DECIMAL(3,2) DEFAULT 0.00,
    nombre_avis INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (opticien_id) REFERENCES opticiens(id) ON DELETE CASCADE,
    FOREIGN KEY (categorie_id) REFERENCES categories_montures(id) ON DELETE SET NULL,
    INDEX idx_reference (reference),
    INDEX idx_prix (prix),
    INDEX idx_marque (marque),
    INDEX idx_genre (genre),
    INDEX idx_popularite (nombre_vues, nombre_essayages)
);

-- =====================================================
-- TABLE: images_montures
-- =====================================================
CREATE TABLE images_montures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    monture_id INT NOT NULL,
    url VARCHAR(255) NOT NULL,
    type ENUM('principale', 'galerie', 'detail') DEFAULT 'galerie',
    ordre INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (monture_id) REFERENCES montures(id) ON DELETE CASCADE,
    INDEX idx_monture (monture_id)
);

-- =====================================================
-- TABLE: ordonnances
-- =====================================================
CREATE TABLE ordonnances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    fichier_url VARCHAR(255) NOT NULL,
    date_ordonnance DATE,
    nom_medecin VARCHAR(255),
    
    -- Œil droit
    od_sphere DECIMAL(5,2),
    od_cylindre DECIMAL(5,2),
    od_axe INT,
    od_addition DECIMAL(5,2),
    
    -- Œil gauche
    og_sphere DECIMAL(5,2),
    og_cylindre DECIMAL(5,2),
    og_axe INT,
    og_addition DECIMAL(5,2),
    
    -- Informations supplémentaires
    ecart_pupillaire DECIMAL(5,2),
    notes TEXT,
    
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by INT,
    verified_at TIMESTAMP NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_client (client_id),
    INDEX idx_date (date_ordonnance)
);

-- =====================================================
-- TABLE: commandes
-- =====================================================
CREATE TABLE commandes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_commande VARCHAR(50) UNIQUE NOT NULL,
    client_id INT NOT NULL,
    opticien_id INT NOT NULL,
    ordonnance_id INT,
    assurance_id INT,
    
    montant_total DECIMAL(10,2) NOT NULL,
    montant_assurance DECIMAL(10,2) DEFAULT 0.00,
    montant_client DECIMAL(10,2) NOT NULL,
    frais_livraison DECIMAL(10,2) DEFAULT 0.00,
    
    statut ENUM('en_attente', 'validee', 'en_preparation', 'expediee', 'livree', 'annulee', 'rejetee') DEFAULT 'en_attente',
    
    adresse_livraison TEXT NOT NULL,
    ville_livraison VARCHAR(100),
    code_postal_livraison VARCHAR(10),
    telephone_livraison VARCHAR(20),
    
    notes_client TEXT,
    notes_opticien TEXT,
    raison_rejet TEXT,
    
    date_commande TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_validation TIMESTAMP NULL,
    date_expedition TIMESTAMP NULL,
    date_livraison TIMESTAMP NULL,
    
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (opticien_id) REFERENCES opticiens(id) ON DELETE CASCADE,
    FOREIGN KEY (ordonnance_id) REFERENCES ordonnances(id) ON DELETE SET NULL,
    FOREIGN KEY (assurance_id) REFERENCES assurances(id) ON DELETE SET NULL,
    
    INDEX idx_numero (numero_commande),
    INDEX idx_client (client_id),
    INDEX idx_opticien (opticien_id),
    INDEX idx_statut (statut),
    INDEX idx_date (date_commande)
);

-- =====================================================
-- TABLE: historique_statuts_commande
-- =====================================================
CREATE TABLE historique_statuts_commande (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_id INT NOT NULL,
    ancien_statut VARCHAR(50),
    nouveau_statut VARCHAR(50) NOT NULL,
    commentaire TEXT,
    modifie_par INT,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    FOREIGN KEY (modifie_par) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_commande (commande_id),
    INDEX idx_date (date_modification)
);

-- =====================================================
-- TABLE: details_commande
-- =====================================================
CREATE TABLE details_commande (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_id INT NOT NULL,
    monture_id INT NOT NULL,
    quantite INT DEFAULT 1,
    prix_unitaire DECIMAL(10,2) NOT NULL,
    prix_total DECIMAL(10,2) NOT NULL,
    personnalisation TEXT,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    FOREIGN KEY (monture_id) REFERENCES montures(id) ON DELETE CASCADE,
    INDEX idx_commande (commande_id)
);

-- =====================================================
-- TABLE: paiements
-- =====================================================
CREATE TABLE paiements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_id INT NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    methode_paiement ENUM('carte_bancaire', 'mobile_money', 'virement', 'especes', 'paypal') NOT NULL,
    statut ENUM('en_attente', 'complete', 'echoue', 'rembourse', 'annule') DEFAULT 'en_attente',
    reference_transaction VARCHAR(255) UNIQUE,
    details_transaction TEXT,
    date_paiement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_confirmation TIMESTAMP NULL,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    INDEX idx_commande (commande_id),
    INDEX idx_statut (statut),
    INDEX idx_reference (reference_transaction)
);

-- =====================================================
-- TABLE: essayages_virtuels
-- =====================================================
CREATE TABLE essayages_virtuels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    monture_id INT NOT NULL,
    photo_essayage_url VARCHAR(255),
    session_id VARCHAR(100),
    duree_essayage INT,
    date_essayage TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_favori BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (monture_id) REFERENCES montures(id) ON DELETE CASCADE,
    INDEX idx_client (client_id),
    INDEX idx_monture (monture_id),
    INDEX idx_favori (is_favori),
    INDEX idx_session (session_id)
);

-- =====================================================
-- TABLE: comparaisons_montures
-- =====================================================
CREATE TABLE comparaisons_montures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    INDEX idx_client (client_id),
    INDEX idx_session (session_id)
);

-- =====================================================
-- TABLE: details_comparaison
-- =====================================================
CREATE TABLE details_comparaison (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comparaison_id INT NOT NULL,
    monture_id INT NOT NULL,
    ordre INT DEFAULT 0,
    FOREIGN KEY (comparaison_id) REFERENCES comparaisons_montures(id) ON DELETE CASCADE,
    FOREIGN KEY (monture_id) REFERENCES montures(id) ON DELETE CASCADE,
    INDEX idx_comparaison (comparaison_id)
);

-- =====================================================
-- TABLE: favoris
-- =====================================================
CREATE TABLE favoris (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    monture_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (monture_id) REFERENCES montures(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favori (client_id, monture_id),
    INDEX idx_client (client_id)
);

-- =====================================================
-- TABLE: notifications
-- =====================================================
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    titre VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'commande', 'paiement', 'systeme', 'promotion') DEFAULT 'info',
    lien VARCHAR(255),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_date (created_at)
);

-- =====================================================
-- TABLE: avis_clients
-- =====================================================
CREATE TABLE avis_clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    monture_id INT,
    opticien_id INT,
    commande_id INT,
    note INT CHECK (note BETWEEN 1 AND 5),
    commentaire TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    reponse_opticien TEXT,
    date_reponse TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (monture_id) REFERENCES montures(id) ON DELETE CASCADE,
    FOREIGN KEY (opticien_id) REFERENCES opticiens(id) ON DELETE CASCADE,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE SET NULL,
    INDEX idx_note (note),
    INDEX idx_monture (monture_id),
    INDEX idx_opticien (opticien_id),
    INDEX idx_verified (is_verified)
);

-- =====================================================
-- TABLE: promotions
-- =====================================================
CREATE TABLE promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    type ENUM('pourcentage', 'montant_fixe') NOT NULL,
    valeur DECIMAL(10,2) NOT NULL,
    montant_minimum DECIMAL(10,2),
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NOT NULL,
    utilisations_max INT,
    utilisations_actuelles INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_dates (date_debut, date_fin)
);

-- =====================================================
-- TABLE: utilisations_promotions
-- =====================================================
CREATE TABLE utilisations_promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id INT NOT NULL,
    commande_id INT NOT NULL,
    client_id INT NOT NULL,
    montant_reduction DECIMAL(10,2) NOT NULL,
    date_utilisation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    INDEX idx_promotion (promotion_id),
    INDEX idx_client (client_id)
);

-- =====================================================
-- TABLE: parametres_systeme
-- =====================================================
CREATE TABLE parametres_systeme (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cle VARCHAR(100) UNIQUE NOT NULL,
    valeur TEXT NOT NULL,
    type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_cle (cle)
);

-- =====================================================
-- TABLE: logs_systeme
-- =====================================================
CREATE TABLE logs_systeme (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    table_affectee VARCHAR(100),
    record_id INT,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_table (table_affectee),
    INDEX idx_date (created_at)
);

-- =====================================================
-- VUES POUR LES STATISTIQUES
-- =====================================================

-- Vue: Statistiques globales
CREATE VIEW vue_statistiques_globales AS
SELECT 
    (SELECT COUNT(*) FROM clients) as total_clients,
    (SELECT COUNT(*) FROM opticiens WHERE is_verified = TRUE) as total_opticiens_actifs,
    (SELECT COUNT(*) FROM commandes) as total_commandes,
    (SELECT COUNT(*) FROM commandes WHERE statut = 'livree') as commandes_livrees,
    (SELECT SUM(montant_total) FROM commandes WHERE statut != 'annulee') as chiffre_affaires_total,
    (SELECT COUNT(*) FROM montures WHERE is_active = TRUE) as total_montures_actives;

-- Vue: Top montures
CREATE VIEW vue_top_montures AS
SELECT 
    m.id,
    m.reference,
    m.nom,
    m.marque,
    m.prix,
    m.nombre_vues,
    m.nombre_essayages,
    m.note_moyenne,
    o.nom_entreprise as opticien,
    (SELECT COUNT(*) FROM details_commande dc 
     JOIN commandes c ON dc.commande_id = c.id 
     WHERE dc.monture_id = m.id AND c.statut != 'annulee') as nombre_ventes
FROM montures m
JOIN opticiens o ON m.opticien_id = o.id
WHERE m.is_active = TRUE
ORDER BY nombre_ventes DESC, m.nombre_essayages DESC
LIMIT 50;

-- Vue: Commandes en cours par opticien
CREATE VIEW vue_commandes_opticien AS
SELECT 
    o.id as opticien_id,
    o.nom_entreprise,
    COUNT(CASE WHEN c.statut = 'en_attente' THEN 1 END) as commandes_en_attente,
    COUNT(CASE WHEN c.statut = 'validee' THEN 1 END) as commandes_validees,
    COUNT(CASE WHEN c.statut = 'en_preparation' THEN 1 END) as commandes_en_preparation,
    COUNT(CASE WHEN c.statut = 'expediee' THEN 1 END) as commandes_expediees,
    SUM(CASE WHEN c.statut != 'annulee' AND c.statut != 'rejetee' THEN c.montant_total ELSE 0 END) as ca_total
FROM opticiens o
LEFT JOIN commandes c ON o.id = c.opticien_id
GROUP BY o.id, o.nom_entreprise;

-- =====================================================
-- INSERTION DE DONNÉES DE TEST
-- =====================================================

-- Admin par défaut
INSERT INTO users (email, password_hash, role) VALUES 
('admin@eyeglasses.com', '$2a$10$examplehashedpassword', 'admin');

INSERT INTO administrateurs (user_id, nom, prenom, telephone) VALUES 
(1, 'TRAORE', 'Mohamed', '+226 70 00 00 00');

-- Catégories de montures
INSERT INTO categories_montures (nom, description, ordre) VALUES 
('Sport', 'Montures sportives et résistantes', 1),
('Classique', 'Montures élégantes et intemporelles', 2),
('Tendance', 'Montures modernes et à la mode', 3),
('Enfant', 'Montures adaptées aux enfants', 4),
('Solaire', 'Lunettes de soleil', 5);

-- Assurances
INSERT INTO assurances (nom_compagnie, numero_contact, email, taux_remboursement, plafond_annuel) VALUES 
('SONAR Assurance', '+226 25 30 00 00', 'contact@sonar.bf', 70.00, 150000.00),
('ALLIANZ Burkina', '+226 25 31 00 00', 'contact@allianz.bf', 80.00, 200000.00),
('RAYNAL Assurance', '+226 25 32 00 00', 'contact@raynal.bf', 60.00, 100000.00);

-- Paramètres système par défaut
INSERT INTO parametres_systeme (cle, valeur, type, description) VALUES 
('frais_livraison_standard', '2000', 'number', 'Frais de livraison standard en FCFA'),
('frais_livraison_express', '5000', 'number', 'Frais de livraison express en FCFA'),
('delai_annulation_commande', '24', 'number', 'Délai d''annulation en heures'),
('taux_tva', '18', 'number', 'Taux de TVA en pourcentage'),
('email_contact', 'support@eyeglasses.bf', 'string', 'Email de contact support'),
('telephone_contact', '+226 25 00 00 00', 'string', 'Téléphone support client');