# 🚀 GUIDE DE DÉPLOIEMENT
## Smart Vision - Application de Vente de Lunettes

---

## 📋 Table des Matières

1. [Prérequis Production](#-prérequis-production)
2. [Déploiement Backend](#-déploiement-backend)
3. [Déploiement Frontend](#-déploiement-frontend)
4. [Base de Données Production](#️-base-de-données-production)
5. [Configuration HTTPS/SSL](#-configuration-httpsssl)
6. [Monitoring et Logs](#-monitoring-et-logs)
7. [Sauvegarde et Restauration](#-sauvegarde-et-restauration)
8. [CI/CD Pipeline](#-cicd-pipeline)

---

## 🛠️ Prérequis Production

### Serveur Recommandé

**Option 1 : VPS Cloud (Recommandé)**
- **Provider :** DigitalOcean, AWS EC2, Google Cloud, Azure
- **Specs minimales :**
  - CPU : 2 vCPUs
  - RAM : 4 GB
  - Storage : 50 GB SSD
  - OS : Ubuntu 22.04 LTS

**Option 2 : Shared Hosting**
- Node.js support requis
- MySQL 8.0+
- SSH access

### Services Externes

- **Domaine :** example.com (Namecheap, GoDaddy, etc.)
- **SSL :** Let's Encrypt (gratuit) ou Certificat payant
- **CDN (optionnel) :** Cloudflare, AWS CloudFront
- **Stockage Images :** AWS S3, Cloudinary, ou local

---

## 🖥️ Déploiement Backend

### Option A : VPS avec PM2 (Recommandé)

#### 1. Connexion au Serveur

```bash
ssh root@votre-ip-serveur
```

#### 2. Installation des Dépendances

```bash
# Mettre à jour le système
apt update && apt upgrade -y

# Installer Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Installer MySQL
apt install -y mysql-server

# Installer PM2 (Process Manager)
npm install -g pm2

# Installer Nginx (Reverse Proxy)
apt install -y nginx

# Installer Certbot (SSL)
apt install -y certbot python3-certbot-nginx
```

#### 3. Configuration MySQL

```bash
# Sécuriser MySQL
mysql_secure_installation

# Se connecter à MySQL
mysql -u root -p

# Créer la base de données
CREATE DATABASE eyeglasses_shop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Créer un utilisateur dédié
CREATE USER 'eyeglasses_user'@'localhost' IDENTIFIED BY 'MOT_DE_PASSE_FORT';
GRANT ALL PRIVILEGES ON eyeglasses_shop.* TO 'eyeglasses_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 4. Déploiement du Code Backend

```bash
# Créer un dossier pour l'application
mkdir -p /var/www/eyeglasses
cd /var/www/eyeglasses

# Cloner le repository (ou utiliser FTP/SFTP)
git clone https://github.com/votre-org/projet-lunettes.git .

# Aller dans le dossier backend
cd backend

# Installer les dépendances (production seulement)
npm ci --only=production

# Créer le fichier .env
nano .env
```

**Contenu de `.env` pour production :**
```env
# Database
DB_HOST=localhost
DB_USER=eyeglasses_user
DB_PASSWORD=MOT_DE_PASSE_FORT
DB_NAME=eyeglasses_shop
DB_PORT=3306

# Server
PORT=3000
NODE_ENV=production

# JWT
JWT_SECRET=GENERER_UNE_CLE_ALEATOIRE_TRES_LONGUE_64_CARACTERES_MINIMUM
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# Frontend URL
FRONTEND_URL=https://votre-domaine.com

# Email (configurer avec vraies credentials)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=votre-mot-de-passe-app
```

**Générer une clé JWT sécurisée :**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

#### 5. Importer le Schéma de Base de Données

```bash
mysql -u eyeglasses_user -p eyeglasses_shop < database/schema.sql
mysql -u eyeglasses_user -p eyeglasses_shop < database/seeds.sql
```

#### 6. Démarrer avec PM2

```bash
# Démarrer l'application
pm2 start server.js --name eyeglasses-api

# Configurer le démarrage automatique
pm2 startup systemd
pm2 save

# Vérifier le statut
pm2 status
pm2 logs eyeglasses-api
```

#### 7. Configuration Nginx (Reverse Proxy)

```bash
nano /etc/nginx/sites-available/eyeglasses
```

**Contenu du fichier :**
```nginx
server {
    listen 80;
    server_name api.votre-domaine.com;

    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.votre-domaine.com;

    # SSL certificates (sera configuré par Certbot)
    ssl_certificate /etc/letsencrypt/live/api.votre-domaine.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.votre-domaine.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Logs
    access_log /var/log/nginx/eyeglasses-access.log;
    error_log /var/log/nginx/eyeglasses-error.log;

    # Proxy to Node.js
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    # Client max body size (pour uploads)
    client_max_body_size 10M;
}
```

**Activer le site :**
```bash
ln -s /etc/nginx/sites-available/eyeglasses /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

#### 8. Obtenir un Certificat SSL (Let's Encrypt)

```bash
# Obtenir le certificat
certbot --nginx -d api.votre-domaine.com

# Renouvellement automatique (test)
certbot renew --dry-run
```

---

### Option B : Déploiement avec Docker

#### 1. Créer un Dockerfile

**Fichier : `backend/Dockerfile`**
```dockerfile
FROM node:18-alpine

# Créer le répertoire de l'app
WORKDIR /usr/src/app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances de production
RUN npm ci --only=production

# Copier le code source
COPY . .

# Exposer le port
EXPOSE 3000

# Variables d'environnement par défaut (à override)
ENV NODE_ENV=production
ENV PORT=3000

# Démarrer l'application
CMD ["node", "server.js"]
```

#### 2. Créer docker-compose.yml

**Fichier : `docker-compose.yml` (à la racine du projet)**
```yaml
version: '3.8'

services:
  # Backend API
  backend:
    build: ./backend
    container_name: eyeglasses-api
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_USER=eyeglasses_user
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=eyeglasses_shop
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - mysql
    networks:
      - eyeglasses-network

  # MySQL Database
  mysql:
    image: mysql:8.0
    container_name: eyeglasses-db
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=eyeglasses_shop
      - MYSQL_USER=eyeglasses_user
      - MYSQL_PASSWORD=${DB_PASSWORD}
    volumes:
      - mysql-data:/var/lib/mysql
      - ./backend/database/schema.sql:/docker-entrypoint-initdb.d/1-schema.sql
      - ./backend/database/seeds.sql:/docker-entrypoint-initdb.d/2-seeds.sql
    networks:
      - eyeglasses-network

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: eyeglasses-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - /etc/letsencrypt:/etc/letsencrypt
    depends_on:
      - backend
    networks:
      - eyeglasses-network

volumes:
  mysql-data:

networks:
  eyeglasses-network:
    driver: bridge
```

#### 3. Créer .env pour Docker

```bash
# .env à la racine
MYSQL_ROOT_PASSWORD=root_password_tres_securise
DB_PASSWORD=user_password_securise
JWT_SECRET=cle_jwt_aleatoire_64_caracteres
```

#### 4. Déployer avec Docker

```bash
# Build et démarrer
docker-compose up -d

# Vérifier les logs
docker-compose logs -f backend

# Voir les containers actifs
docker-compose ps

# Arrêter
docker-compose down
```

---

## 📱 Déploiement Frontend

### Option 1 : Web (Flutter Web)

#### Build Production

```bash
cd frontend

# Build optimisé pour le web
flutter build web --release

# Les fichiers sont dans build/web/
```

#### Déploiement avec Nginx

```bash
# Copier les fichiers build vers le serveur
scp -r build/web/* root@votre-serveur:/var/www/eyeglasses/frontend/

# Configuration Nginx
nano /etc/nginx/sites-available/eyeglasses-frontend
```

**Configuration Nginx pour Flutter Web :**
```nginx
server {
    listen 80;
    server_name votre-domaine.com www.votre-domaine.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name votre-domaine.com www.votre-domaine.com;

    ssl_certificate /etc/letsencrypt/live/votre-domaine.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/votre-domaine.com/privkey.pem;

    root /var/www/eyeglasses/frontend;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
}
```

```bash
# Activer le site
ln -s /etc/nginx/sites-available/eyeglasses-frontend /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# SSL
certbot --nginx -d votre-domaine.com -d www.votre-domaine.com
```

---

### Option 2 : Mobile (Android)

#### Build APK/AAB

```bash
cd frontend

# Build APK (pour distribution directe)
flutter build apk --release

# OU Build App Bundle (pour Google Play Store)
flutter build appbundle --release
```

**Fichiers générés :**
- APK : `build/app/outputs/flutter-apk/app-release.apk`
- AAB : `build/app/outputs/bundle/release/app-release.aab`

#### Publication sur Google Play Store

1. **Créer un compte Google Play Developer** (25$ one-time fee)
2. **Créer une nouvelle application** dans la Play Console
3. **Uploader le fichier AAB**
4. **Remplir les informations** :
   - Description
   - Screenshots (minimum 2)
   - Icône (512x512 px)
   - Feature Graphic (1024x500 px)
   - Classification du contenu
5. **Soumettre pour révision**

---

### Option 3 : Mobile (iOS)

#### Build IPA

```bash
cd frontend

# Build pour iOS
flutter build ios --release
```

#### Publication sur Apple App Store

1. **Compte Apple Developer** (99€/an)
2. **Xcode** sur macOS
3. **Archive l'application** via Xcode
4. **Upload vers App Store Connect**
5. **Soumettre pour révision**

---

## 🗄️ Base de Données Production

### Sécurisation MySQL

```bash
# Se connecter à MySQL
mysql -u root -p

# Désactiver l'accès root distant
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

# Créer utilisateur avec privilèges limités
CREATE USER 'readonly_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON eyeglasses_shop.* TO 'readonly_user'@'localhost';
FLUSH PRIVILEGES;
```

### Optimisation

```bash
# Éditer la configuration MySQL
nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

**Optimisations :**
```ini
[mysqld]
# Performance
innodb_buffer_pool_size = 2G
max_connections = 200
query_cache_size = 64M

# Security
bind-address = 127.0.0.1
skip-name-resolve

# Logs
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2
```

```bash
systemctl restart mysql
```

---

## 🔒 Configuration HTTPS/SSL

### Let's Encrypt (Gratuit)

```bash
# Installation Certbot
apt install certbot python3-certbot-nginx

# Obtenir certificat pour domaine principal
certbot --nginx -d votre-domaine.com -d www.votre-domaine.com

# Obtenir certificat pour sous-domaine API
certbot --nginx -d api.votre-domaine.com

# Test renouvellement automatique
certbot renew --dry-run
```

**Certbot configure automatiquement :**
- Redirection HTTP → HTTPS
- Certificats SSL
- Renouvellement automatique (cron job)

### Certificat SSL Payant (Optionnel)

Si vous achetez un certificat :

```bash
# Copier les fichiers sur le serveur
scp certificate.crt root@serveur:/etc/ssl/certs/
scp private.key root@serveur:/etc/ssl/private/

# Dans Nginx config
ssl_certificate /etc/ssl/certs/certificate.crt;
ssl_certificate_key /etc/ssl/private/private.key;
```

---

## 📊 Monitoring et Logs

### PM2 Monitoring

```bash
# Dashboard en temps réel
pm2 monit

# Logs en temps réel
pm2 logs eyeglasses-api

# Logs sauvegardés
pm2 logs eyeglasses-api --lines 100

# Métriques
pm2 describe eyeglasses-api
```

### Logs Nginx

```bash
# Accès en temps réel
tail -f /var/log/nginx/eyeglasses-access.log

# Erreurs
tail -f /var/log/nginx/eyeglasses-error.log

# Analyser les logs
cat /var/log/nginx/eyeglasses-access.log | grep "POST /auth/login" | wc -l
```

### Monitoring Avancé (Optionnel)

**Option 1 : PM2 Plus (gratuit pour petit projet)**
```bash
pm2 link <secret> <public>
```

**Option 2 : Outils Open Source**
- **Prometheus + Grafana** - Métriques et dashboards
- **ELK Stack** - Logs centralisés
- **New Relic / Datadog** - Monitoring payant

---

## 💾 Sauvegarde et Restauration

### Sauvegarde Automatique MySQL

```bash
# Créer un script de backup
nano /usr/local/bin/backup-eyeglasses.sh
```

**Script :**
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/eyeglasses"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="eyeglasses_shop"
DB_USER="eyeglasses_user"
DB_PASSWORD="MOT_DE_PASSE"

# Créer le dossier si inexistant
mkdir -p $BACKUP_DIR

# Dump de la base
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Garder seulement les 7 derniers backups
ls -t $BACKUP_DIR/backup_*.sql.gz | tail -n +8 | xargs rm -f

echo "Backup effectué: backup_$DATE.sql.gz"
```

**Rendre exécutable et automatiser :**
```bash
chmod +x /usr/local/bin/backup-eyeglasses.sh

# Ajouter au cron (tous les jours à 2h du matin)
crontab -e

# Ajouter cette ligne :
0 2 * * * /usr/local/bin/backup-eyeglasses.sh >> /var/log/backup-eyeglasses.log 2>&1
```

### Restauration

```bash
# Décompresser le backup
gunzip /var/backups/eyeglasses/backup_20260207_020000.sql.gz

# Restaurer
mysql -u eyeglasses_user -p eyeglasses_shop < /var/backups/eyeglasses/backup_20260207_020000.sql
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions

**Fichier : `.github/workflows/deploy.yml`**

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: |
          cd backend
          npm ci
      
      - name: Run tests
        run: |
          cd backend
          npm test
      
      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /var/www/eyeglasses/backend
            git pull origin main
            npm ci --only=production
            pm2 restart eyeglasses-api

  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Build web
        run: |
          cd frontend
          flutter pub get
          flutter build web --release
      
      - name: Deploy to server
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          source: "frontend/build/web/*"
          target: "/var/www/eyeglasses/frontend/"
```

**Configuration des secrets GitHub :**
- `SERVER_IP` : Adresse IP du serveur
- `SERVER_USER` : Utilisateur SSH
- `SSH_PRIVATE_KEY` : Clé privée SSH

---

## ✅ Checklist Déploiement

### Avant Déploiement

- [ ] Tests unitaires passent (backend + frontend)
- [ ] .env configuré avec valeurs production
- [ ] JWT_SECRET généré (64+ caractères aléatoires)
- [ ] Schéma DB testé localement
- [ ] CORS configuré avec domaine production
- [ ] Rate limiting activé
- [ ] Logs configurés

### Après Déploiement

- [ ] Backend accessible via HTTPS
- [ ] Frontend accessible via HTTPS
- [ ] Certificat SSL valide
- [ ] Base de données accessible seulement localement
- [ ] PM2 démarre au boot
- [ ] Backup automatique configuré
- [ ] Monitoring actif
- [ ] Test manuel complet :
  - [ ] Inscription/Connexion
  - [ ] Récupération montures
  - [ ] Création commande
  - [ ] Upload image
  - [ ] Essai virtuel

---

**Document créé par Antigravity AI**  
**Date :** 7 Février 2026
