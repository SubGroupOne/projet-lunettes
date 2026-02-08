# 🕶️ Smart Vision - Application de Vente de Lunettes avec IA

Application mobile et web complète pour la vente de lunettes avec essai virtuel AR, reconnaissance faciale et scan d'ordonnance par intelligence artificielle.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)](https://nodejs.org)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?logo=mysql)](https://www.mysql.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 Table des Matières

- [Fonctionnalités](#-fonctionnalités)
- [Technologies](#️-technologies)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#️-configuration)
- [Utilisation](#-utilisation)
- [API Documentation](#-api-documentation)
- [Structure du Projet](#-structure-du-projet)
- [Contribution](#-contribution)
- [Licence](#-licence)

---

## ✨ Fonctionnalités

### 👤 Espace Client

- ✅ **Essai Virtuel AR** - Essayez des lunettes en temps réel avec reconnaissance faciale 3D
- ✅ **Scan d'Ordonnance** - Extraction automatique des données de prescription (OCR)
- ✅ **Catalogue de Montures** - Parcourez et filtrez par catégorie (Soleil, Optique, Luxe)
- ✅ **Panier et Paiement** - Processus de commande complet
- ✅ **Vérification Assurance** - Intégration avec les mutuelles
- ✅ **Profil Utilisateur** - Gestion du compte et historique des commandes

### 👨‍⚕️ Espace Opticien

- ✅ **Dashboard** - Statistiques et aperçu des ventes
- ✅ **Gestion Montures** - CRUD complet (Créer, Lire, Modifier, Supprimer)
- ✅ **Gestion Commandes** - Suivi et validation des prescriptions
- ⚠️ **Validation Prescriptions** - Vérification des ordonnances scannées

### 👨‍💼 Espace Administrateur

- ⚠️ **Gestion Utilisateurs** - Administration des comptes
- ⚠️ **Statistiques Globales** - Revenus, ventes, analytics
- ⚠️ **Gestion Rôles** - Attribution des droits

**Légende :** ✅ Implémenté | ⚠️ En cours | ❌ Planifié

---

## 🛠️ Technologies

### Backend
- **Runtime :** Node.js 18+
- **Framework :** Express.js 5.2.1
- **Base de Données :** MySQL 8.0+
- **ORM :** mysql2 (Promises)
- **Authentification :** bcryptjs, JWT (à implémenter)
- **Sécurité :** helmet, cors, express-rate-limit

### Frontend
- **Framework :** Flutter 3.0+ (Dart)
- **Plateforme :** Mobile (Android, iOS), Web
- **State Management :** Provider, GetX
- **IA/ML :**
  - Google ML Kit Face Detection (Mobile)
  - MediaPipe Face Landmarker (Web)
  - Google ML Kit Text Recognition (OCR)
- **UI/UX :**
  - animate_do, flutter_staggered_animations
  - carousel_slider, smooth_page_indicator
  - fl_chart, syncfusion_flutter_charts
- **Networking :** http, dio
- **Storage :** shared_preferences
- **Images :** image_picker, cached_network_image

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                 FRONTEND (Flutter)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │   Client     │  │  Opticien    │  │  Admin   │  │
│  │   Mobile/Web │  │  Dashboard   │  │  Panel   │  │
│  └──────┬───────┘  └──────┬───────┘  └────┬─────┘  │
│         │                 │                │        │
│         └─────────────────┼────────────────┘        │
│                           │                         │
│                    REST API (JSON)                  │
│                           │                         │
└───────────────────────────┼─────────────────────────┘
                            │
┌───────────────────────────┼─────────────────────────┐
│                 BACKEND (Node.js/Express)           │
│  ┌─────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │   Routes    │→ │Controllers │→ │    Models    │ │
│  │ auth.routes │  │  auth.ctrl │  │  user.model  │ │
│  │frame.routes │  │ frame.ctrl │  │ frame.model  │ │
│  │order.routes │  │ order.ctrl │  │ order.model  │ │
│  └─────────────┘  └────────────┘  └──────┬───────┘ │
│         ↑                                 │         │
│  ┌──────┴────────┐                        │         │
│  │  Middleware   │                        ▼         │
│  │ · auth.js     │              ┌──────────────┐   │
│  │ · role.js     │              │    MySQL     │   │
│  └───────────────┘              │   Database   │   │
│                                 └──────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## 📦 Prérequis

### Logiciels Requis

- **Node.js** >= 18.0.0 ([Télécharger](https://nodejs.org))
- **MySQL** >= 8.0 ([Télécharger](https://dev.mysql.com/downloads/mysql/))
- **Flutter SDK** >= 3.0.0 ([Installation](https://docs.flutter.dev/get-started/install))
- **Git** ([Télécharger](https://git-scm.com/downloads))

### Vérification des versions
```bash
node --version  # v18.0.0 ou supérieur
npm --version   # 8.0.0 ou supérieur
mysql --version # 8.0 ou supérieur
flutter --version # 3.0.0 ou supérieur
```

---

## 🚀 Installation

### 1. Cloner le Repository

```bash
git clone https://github.com/votre-org/projet-lunettes.git
cd projet-lunettes
```

### 2. Installation Backend

```bash
cd backend

# Installer les dépendances
npm install

# Copier le fichier d'environnement
cp .env.example .env

# Éditer .env avec vos paramètres
nano .env
```

### 3. Configuration Base de Données

```bash
# Se connecter à MySQL
mysql -u root -p

# Créer la base de données et les tables
mysql -u root -p < database/schema.sql

# Insérer les données de test
mysql -u root -p < database/seeds.sql
```

### 4. Démarrer le Backend

```bash
# Mode développement (avec nodemon)
npm run dev

# OU Mode production
npm start
```

Le serveur démarre sur `http://localhost:3000`

### 5. Installation Frontend

```bash
cd ../frontend

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

**Choix de plateforme :**
- **Mobile Android :** Connecter un appareil ou lancer un émulateur
- **Mobile iOS :** Nécessite macOS + Xcode
- **Web :** `flutter run -d chrome`

---

## ⚙️ Configuration

### Variables d'Environnement Backend

Créer un fichier `backend/.env` :

```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=votre_mot_de_passe
DB_NAME=eyeglasses_shop
DB_PORT=3306

# Server
PORT=3000
NODE_ENV=development

# JWT (à implémenter)
JWT_SECRET=votre_clé_secrète_très_longue_minimum_64_caracteres
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# Frontend URL (CORS)
FRONTEND_URL=http://localhost:3001

# Email (optionnel)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre_email@gmail.com
SMTP_PASSWORD=votre_mot_de_passe_app
```

### Configuration Frontend

Éditer `frontend/lib/config/api_config.dart` :

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const String apiUrl = '$baseUrl/api';
}
```

---

## 🎮 Utilisation

### Comptes de Test

Après avoir exécuté `seeds.sql`, utilisez ces comptes :

| Rôle | Email | Mot de passe |
|------|-------|-------------|
| **Admin** | admin@smartvision.com | admin123 |
| **Opticien** | opticien@smartvision.com | opticien123 |
| **Client** | client@gmail.com | client123 |

### Scénarios d'Utilisation

#### 1. Essai Virtuel (Client)
1. Ouvrir l'application mobile
2. Autoriser l'accès à la caméra
3. Sélectionner une monture dans la galerie
4. Le visage est détecté automatiquement
5. Les lunettes s'affichent en 3D en temps réel
6. Ajuster la taille avec le slider
7. Ajouter au panier

#### 2. Scan d'Ordonnance (Client)
1. Naviguer vers "Scanner Ordonnance"
2. Pointer la caméra vers l'ordonnance
3. L'IA extrait automatiquement :
   - OD (Œil Droit) : Sphère, Cylindre, Axe
   - OS (Œil Gauche) : Sphère, Cylindre, Axe
4. Vérifier les données extraites
5. Valider et passer à l'assurance

#### 3. Gestion Montures (Opticien)
1. Connexion avec compte opticien
2. Dashboard → Gestion Montures
3. Ajouter/Modifier/Supprimer des montures
4. Gérer le stock et les prix

---

## 📡 API Documentation

### Authentification

#### POST `/auth/register`
Créer un nouveau compte utilisateur.

**Body :**
```json
{
  "name": "Jean Dupont",
  "email": "jean@example.com",
  "password": "MotDePasse123!"
}
```

**Response (201) :**
```json
{
  "message": "Utilisateur créé avec succès",
  "user": {
    "id": 1,
    "name": "Jean Dupont",
    "email": "jean@example.com",
    "role": "client"
  }
}
```

#### POST `/auth/login`
Connexion utilisateur.

**Body :**
```json
{
  "email": "jean@example.com",
  "password": "MotDePasse123!"
}
```

**Response (200) :**
```json
{
  "message": "Connexion réussie 🎉",
  "user": {
    "id": 1,
    "name": "Jean Dupont",
    "email": "jean@example.com",
    "role": "client"
  }
}
```

### Montures

#### GET `/frames`
Récupérer toutes les montures.

**Response (200) :**
```json
[
  {
    "id": 1,
    "name": "Aviator Classic",
    "brand": "Ray-Ban",
    "price": 149.99,
    "description": "Lunettes aviateur iconiques",
    "image_url": "/images/aviator.jpg",
    "stock": 25,
    "category": "soleil"
  }
]
```

#### GET `/frames/:id`
Récupérer une monture spécifique.

#### POST `/frames` 🔒
Créer une nouvelle monture (Opticien/Admin uniquement).

**Headers :**
```
Authorization: Bearer <token_jwt>
```

**Body :**
```json
{
  "name": "Nouvelle Monture",
  "brand": "Gucci",
  "price": 299.99,
  "description": "Description",
  "image_url": "/images/nouvelle.jpg",
  "stock": 10
}
```

#### PUT `/frames/:id` 🔒
Modifier une monture (Opticien/Admin uniquement).

#### DELETE `/frames/:id` 🔒
Supprimer une monture (Admin uniquement).

### Commandes

#### GET `/orders` 🔒
Récupérer toutes les commandes (Opticien/Admin).

#### GET `/orders/:id` 🔒
Récupérer une commande spécifique.

#### POST `/orders` 🔒
Créer une nouvelle commande (Client authentifié).

**Body :**
```json
{
  "frameId": 1,
  "prescriptionData": {
    "od": { "sphere": -2.50, "cylinder": 0.75, "axis": 165 },
    "os": { "sphere": -2.25, "cylinder": 1.00, "axis": 15 }
  },
  "insuranceData": {
    "provider": "Mutuelle Santé",
    "coverage": 0.60
  },
  "totalPrice": 149.99
}
```

#### PUT `/orders/:id/status` 🔒
Mettre à jour le statut d'une commande (Opticien/Admin).

**Body :**
```json
{
  "status": "confirmed"
}
```

**Statuts possibles :** `pending`, `confirmed`, `processing`, `delivered`, `cancelled`

🔒 = Authentication requise

---

## 📂 Structure du Projet

```
projet-lunettes/
├── backend/                    # API Node.js/Express
│   ├── config/
│   │   └── db.js              # Configuration MySQL
│   ├── controllers/
│   │   ├── auth.controller.js # Authentification
│   │   ├── frame.controller.js # Gestion montures
│   │   └── order.controller.js # Gestion commandes
│   ├── models/
│   │   ├── user.model.js
│   │   ├── frame.model.js
│   │   └── order.model.js
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── frame.routes.js
│   │   └── order.routes.js
│   ├── middleware/            # À implémenter
│   │   ├── auth.middleware.js
│   │   └── role.middleware.js
│   ├── database/
│   │   ├── schema.sql         # Schéma de base de données
│   │   └── seeds.sql          # Données de test
│   ├── app.js                 # Configuration Express
│   ├── server.js              # Point d'entrée
│   ├── package.json
│   └── .env.example
│
├── frontend/                  # Application Flutter
│   ├── lib/
│   │   ├── main.dart          # Point d'entrée (8,950 lignes)
│   │   ├── models/            # Modèles de données
│   │   │   ├── glasses_models.dart
│   │   │   ├── models.dart
│   │   │   └── product.dart
│   │   ├── screens/           # Pages client
│   │   │   ├── products_page.dart
│   │   │   ├── cart.dart
│   │   │   ├── profile_page.dart
│   │   │   └── payment_confirmation_page.dart
│   │   ├── optician/          # Pages opticien
│   │   │   ├── dashboard_page.dart
│   │   │   ├── manage_frames_page.dart
│   │   │   └── manage_orders_page.dart
│   │   ├── services/          # Services (API, OCR)
│   │   ├── widgets/           # Composants réutilisables
│   │   ├── virtual_try_on_page.dart # Essai virtuel AR (700 lignes)
│   │   ├── scanner_ordonnance_page.dart # OCR
│   │   ├── mobile_detection_helper.dart # ML Kit
│   │   └── web_detection_helper.dart # MediaPipe
│   ├── assets/
│   │   ├── images/
│   │   ├── icons/
│   │   └── glasses/
│   ├── pubspec.yaml
│   └── README.md
│
├── photos/                    # Images de montures
├── RAPPORT_CONFORMITE.md      # Analyse détaillée du projet
├── PLAN_IMPLEMENTATION.md     # Guide d'implémentation
└── README.md                  # Ce fichier
```

---

## 🧪 Tests

### Backend

```bash
cd backend

# Installer Jest
npm install --save-dev jest supertest

# Lancer les tests
npm test

# Tests avec coverage
npm run test:coverage
```

### Frontend

```bash
cd frontend

# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

---

## 🚨 Problèmes Connus et Limitations

### ⚠️ En Cours d'Implémentation

1. **JWT Authentication** - Authentification par token non implémentée
2. **OCR Réel** - Interface scanner présente mais extraction simulée
3. **Admin Panel** - Interface administrateur limitée
4. **Tests** - Coverage à 0% actuellement

### 📋 Roadmap

**Phase 1 (Priorité Critique) - Semaines 1-2**
- [ ] Implémenter JWT + Refresh Tokens
- [ ] Créer middleware d'authentification
- [ ] Ajouter .env et variables d'environnement
- [ ] Configurer CORS, Helmet, Rate Limiting

**Phase 2 (Priorité Haute) - Semaines 3-4**
- [ ] Intégrer Google ML Kit Text Recognition (OCR réel)
- [ ] Développer interface Admin complète
- [ ] Tests unitaires backend (Jest)
- [ ] Tests widgets Flutter

**Phase 3 (Priorité Moyenne) - Semaines 5-6**
- [ ] Intégration système assurance
- [ ] Notifications email (Nodemailer)
- [ ] Historique et favoris
- [ ] Docker + CI/CD

Voir `PLAN_IMPLEMENTATION.md` pour les détails complets.

---

## 📊 Rapport de Conformité

Le projet a été audité en profondeur. Résultats :

- ✅ **Backend Node.js :** 100% fonctionnel (contrôleurs, modèles, routes)
- ✅ **IA Reconnaissance Faciale :** 100% opérationnel (ML Kit + MediaPipe)
- ✅ **Frontend Flutter :** 85% complet
- ⚠️ **Sécurité :** 40% (bcrypt OK, JWT manquant)
- ⚠️ **OCR :** Interface seulement (0% backend)
- ❌ **Tests :** 0%

**Score Global : 70%**

Voir `RAPPORT_CONFORMITE.md` pour l'analyse détaillée.

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Suivez ces étapes :

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

### Guidelines

- Suivre les conventions de code existantes
- Ajouter des tests pour les nouvelles fonctionnalités
- Mettre à jour la documentation
- Un commit = Une fonctionnalité logique

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👥 Auteurs

- **Équipe SubGroupOne** - *Développement initial*

---

## 📞 Support

Pour toute question ou problème :

- 📧 Email : support@eyeglasses.com
- 🐛 Issues : [GitHub Issues](https://github.com/votre-org/projet-lunettes/issues)
- 📖 Documentation : [Wiki](https://github.com/votre-org/projet-lunettes/wiki)

---

## 🙏 Remerciements

- [Flutter Team](https://flutter.dev) pour le framework exceptionnel
- [Google ML Kit](https://developers.google.com/ml-kit) pour les API d'IA
- [MediaPipe](https://mediapipe.dev) pour la reconnaissance faciale web
- [Express.js](https://expressjs.com) pour le framework backend

---

<div align="center">

**Développé avec ❤️ par l'équipe SubGroupOne**

⭐ Si vous aimez ce projet, n'oubliez pas de lui donner une étoile ! ⭐

</div>
