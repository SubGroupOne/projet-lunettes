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

- ✅ **Essai Virtuel AR** - Essayez des lunettes en temps réel avec reconnaissance faciale (MediaPipe/ML Kit)
- ✅ **Scan d'Ordonnance** - Interface de scan avec extraction simulée (OCR prêt pour intégration)
- ✅ **Catalogue de Montures** - Parcourez et filtrez par catégorie (Soleil, Optique, Luxe)
- ✅ **Panier et Paiement** - Processus complet avec simulation de paiement sécurisé
- ✅ **Vérification Assurance** - Simulateur de remboursement mutuelle intégré
- ✅ **Suivi de Commande** - Interface de suivi en temps réel du statut de la commande
- ✅ **Profil Utilisateur** - Gestion du compte et historique

### 👨‍⚕️ Espace Opticien / Admin

- ✅ **Dashboard** - Statistiques et aperçu des indicateurs clés (CA, Commandes, Clients)
- ✅ **Gestion Montures** - CRUD complet (Créer, Lire, Modifier, Supprimer)
- ✅ **Gestion Commandes** - Suivi et validation des prescriptions
- ✅ **Gestion Utilisateurs** - Administration des comptes et rôles
- ✅ **Gestion Assurances** - Configuration des organismes et taux de couverture

**Légende :** ✅ Implémenté | ⚠️ En cours | ❌ Planifié

---

## 🛠️ Technologies

### Backend
- **Runtime :** Node.js 18+
- **Framework :** Express.js 4.x
- **Base de Données :** MySQL 8.0+
- **Authentification :** Bcryptjs & **JWT (Access + Refresh Tokens avec rotation)**
- **Sécurité :** Helmet, CORS, Express-Rate-Limit

### Frontend
- **Framework :** Flutter 3.x (Dart) - **Architecture Modulaire**
- **State Management :** Provider (Cart, Session, UI)
- **IA/ML :**
  - Google ML Kit Face Detection (Mobile)
  - MediaPipe Face Landmarker (Web)
- **UI/UX :**
  - Google Fonts (Inter, Outfit)
  - Animations (Animate Do)
  - Charts (Syncfusion)
- **Services :**
  - SessionService (Persistence sécurisée)
  - ApiService (Centralisation des appels REST)
  - NotificationService (In-app notifications)

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
│                           ▼                         │
│                    REST API (JSON)                  │
│                           │                         │
└───────────────────────────┼─────────────────────────┘
                            │
┌───────────────────────────┼─────────────────────────┐
│                 BACKEND (Node.js/Express)           │
│  ┌─────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │   Routes    │→ │Controllers │→ │    Models    │ │
│  │  /api/auth  │  │  AuthCtrl   │  │  User        │ │
│  │  /api/frames│  │  FrameCtrl  │  │  Frame       │ │
│  │  /api/orders│  │  OrderCtrl  │  │  Order       │ │
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

## 🚀 Installation

*Note: Voir `GUIDE_IMPLEMENTATION_COMPLETE.md` pour des instructions plus détaillées.*

1. **Cloner le projet**
2. **Backend**: 
   - `cd backend && npm install`
   - Configurer le `.env` (voir exemple ci-dessous)
   - Lancer avec `npm run dev`
3. **Frontend**:
   - `cd frontend && flutter pub get`
   - Lancer avec `flutter run`

---

## ⚙️ Configuration

### Variables d'Environnement (backend/.env)
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=votre_password
DB_NAME=eyeglasses_shop
PORT=3000
JWT_SECRET=votre_cle_secrete_ultra_longue
JWT_REFRESH_SECRET=votre_cle_secrete_refresh
```

---

## 📂 Structure du Projet

```
projet-lunettes/
├── backend/                   # API Node.js/Express
│   ├── config/                # DB connection
│   ├── controllers/           # Logique métier
│   ├── middleware/            # Auth & RBAC
│   ├── models/                # Schémas MySQL
│   ├── routes/                # Endpoints API
│   ├── scripts/               # Initialisation (users, insurances)
│   └── utils/                 # JWT, helpers
│
├── frontend/                  # Application Flutter
│   ├── lib/
│   │   ├── admin/             # Gestion Admin (Users, Insurances, Stats)
│   │   ├── screens/           # Écrans principaux (Home, Shop, AR, Scan)
│   │   ├── services/          # API, Auth, Cart, Notifications
│   │   ├── models/            # Modèles de données Dart
│   │   ├── widgets/           # Composants réutilisables
│   │   └── main.dart          # Initialisation Providers & Thème
│   └── assets/                # Modèles 3D, Images
│
└── RAPPORT_CONFORMITE.md      # État détaillé de conformité
```

---

## 🛡️ Sécurité Implémentée

1.  **Authentification Robuste** : Utilisation de JWT avec expiration courte (Access Token) et Refresh Tokens stockés de manière sécurisée.
2.  **Gestion des Rôles (RBAC)** : Middlewares côté backend pour restreindre l'accès (`client`, `opticien`, `admin`).
3.  **Hachage des Mots de Passe** : Utilisation de `bcryptjs` avec 10 rounds de sel.
4.  **Protection API** :
    *   **Helmet** pour les headers HTTP sécurisés.
    *   **CORS** configuré pour les domaines autorisés.
    *   **Rate Limiting** pour prévenir les attaques par force brute.

---

## 📊 Rapport de Conformité (Mis à jour)

- ✅ **Backend Node.js :** 100% fonctionnel (Architecture MVC, Routes 2A sécurisées)
- ✅ **Sécurité :** 95% (JWT complet, RBAC, Protection API)
- ✅ **IA Reconnaissance Faciale :** 100% opérationnel (Essai Virtuel prêt)
- ✅ **Interface Admin :** 90% (Gestion complète implémentée)
- ✅ **Frontend Flutter :** 95% (Architecture modulaire, Clean Code)
- ⚠️ **OCR :** 50% (Interface UI complète, extraction réelle en attente de clé API)

**Score Global Estimé : 92%**

---

## 👥 Auteurs

- **Équipe SubGroupOne** - *Développement et Design*

<div align="center">
**Développé avec ❤️ par SubGroupOne**
</div>
