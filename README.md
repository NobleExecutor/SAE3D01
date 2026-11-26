# SAE 3D01 - Environnement de développement local (Docker)

Ce dépôt contient le projet pour la **SAE 3D01**. L'environnement de développement complet (serveur Web Apache, PHP 8.3, MariaDB et phpMyAdmin) est conteneurisé à l'aide de **Docker** et **Docker Compose**.

---

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé sur votre machine :
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS / Windows) ou [Docker Engine](https://docs.docker.com/engine/install/) avec le plugin [Docker Compose](https://docs.docker.com/compose/) (Linux).
- [Git](https://git-scm.com/) pour cloner et gérer les versions du projet.

> ℹ️ **Important :** Assurez-vous que Docker Desktop (ou le démon Docker) est bien démarré sur votre machine avant de lancer les commandes ci-dessous.

---

## 🏗️ Architecture des services

Le fichier `docker-compose.yml` orchestre trois services interconnectés :

| Service | Image / Build | Rôle | Port hôte : Port conteneur |
| :--- | :--- | :--- | :--- |
| **`web`** | Construit depuis `Dockerfile` (PHP 8.3 Apache + Xdebug) | Serveur HTTP Apache servant le dossier `public/` | `127.0.0.1:80:80` |
| **`db`** | `mariadb:10.11` | Serveur de base de données relationnelle | `3306` *(interne au réseau Docker)* |
| **`phpmyadmin`** | `phpmyadmin/phpmyadmin` | Interface web pour gérer la base de données MariaDB | `127.0.0.1:8080:80` |

---

## 🚀 Installation et démarrage rapide

### 1. Récupérer le projet
Clonez le dépôt Git sur votre machine locale si ce n'est pas déjà fait :
```bash
git clone https://github.com/NobleExecutor/SAE3D01
cd SAE3D01
```

### 2. Créer les fichiers de configuration
```bash
cp config/config.example.php config/config.php
```
```bash
cp .env.example .env
```
- `config/config.php` : configuration de l'application (base de données et API). Avec Docker, `DB_HOST` vaut `db`.
- `.env` : **réservé à Docker**, il sert à créer la base MariaDB. Renseignez `DB_NAME`, `DB_USER`, `DB_PASS` et `DB_ROOT_PASS`. Les trois premières valeurs doivent être identiques dans `config.php`.

Ces deux fichiers sont ignorés par Git.

### 3. Démarrer les conteneurs
Depuis la racine du projet, exécutez la commande suivante :

```bash
docker compose up -d --build
```
> *(Selon votre installation Docker, la commande peut également s'écrire avec un tiret : `docker-compose up -d --build`)*

Cette commande va :
1. Construire l'image du conteneur `web` avec PHP 8.3, Apache, les extensions nécessaires (PDO, MySQLi) et Xdebug.
2. Télécharger les images MariaDB 10.11 et phpMyAdmin.
3. Démarrer l'ensemble des conteneurs en tâche de fond (`-d`).

### 4. Vérifier que les conteneurs tournent
Pour vérifier l'état des conteneurs :
```bash
docker compose ps
```
Tous les conteneurs (`web`, `db`, `phpmyadmin`) doivent être à l'état `Up` ou `running`.

---

## 🌐 Accès aux applications

Une fois les conteneurs démarrés, vous pouvez accéder aux services depuis votre navigateur :

### 1. Application Web
- **URL :** [http://localhost](http://localhost) (ou [http://localhost:80](http://localhost:80))
- **Dossier servi :** Tout le projet est monté dans `/var/www/html`, mais Apache ne sert que `/var/www/html/public`. PHP peut donc charger `app/` et `config/`, qui restent inaccessibles depuis le navigateur. Les modifications sont prises en compte sans redémarrer le conteneur.
- Les ports ne sont ouverts que sur votre machine (`127.0.0.1`) : le site n'est pas accessible depuis le réseau local.

### 2. phpMyAdmin
- **URL :** [http://localhost:8080](http://localhost:8080)
- Permet d'administrer graphiquement les bases de données, d'exécuter des scripts SQL ou d'importer des tables.

---

## 🔑 Connexion à la base de données

L'application lit ses identifiants dans `config/config.php`, qui les déclare sous forme de constantes avec `define()`.

| Constante | Avec Docker | Avec Laragon (valeurs par défaut) |
| :--- | :--- | :--- |
| `DB_HOST` | `db` | `127.0.0.1` |
| `DB_PORT` | `3306` | `3306` |
| `DB_NAME` | valeur de `DB_NAME` dans `.env` | nom de la base que vous créez |
| `DB_USER` | valeur de `DB_USER` dans `.env` | `root` |
| `DB_PASS` | valeur de `DB_PASS` dans `.env` | vide |

> ℹ️ Avec Docker, MariaDB n'applique les identifiants du `.env` qu'à la création de la base. Pour les modifier ensuite, changez-les dans phpMyAdmin ou réinitialisez la base (`docker compose down -v`, **les données sont perdues**).

### Exemple de connexion PDO en PHP :
```php
<?php
require_once __DIR__ . '/../config/config.php'; // depuis public/index.php

$dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', DB_HOST, DB_PORT, DB_NAME);

$pdo = new PDO($dsn, DB_USER, DB_PASS, [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
]);
```

---

## 🪟 Installation avec Laragon (sans Docker)

Les sections Docker de ce guide ne vous concernent pas. Il faut PHP 8.3 avec les extensions `pdo_mysql` et `curl`.

1. Clonez le dépôt.
2. Faites pointer la racine web de Laragon sur le dossier `public/` du projet (**Menu > Preferences > General > Document Root**), puis redémarrez Apache.
3. Créez la base de données (par exemple `sae3d01_db`) avec phpMyAdmin ou HeidiSQL.
4. Copiez `config/config.example.php` en `config/config.php`, puis renseignez-le avec les valeurs Laragon du tableau ci-dessus.

Le fichier `.env` n'est pas nécessaire.

---

## 🛠️ Commandes Docker courantes

Voici les commandes les plus utiles pour travailler avec le projet :

- **Démarrer les conteneurs** :
  ```bash
  docker compose up -d
  ```

- **Arrêter les conteneurs** (sans supprimer les données stockées) :
  ```bash
  docker compose stop
  ```

- **Arrêter et supprimer les conteneurs et réseaux** :
  ```bash
  docker compose down
  ```

- **Réinitialiser complètement la base de données** (supprime le volume persistant) :
  ```bash
  docker compose down -v
  ```

- **Afficher les logs en continu** :
  ```bash
  # Tous les services
  docker compose logs -f

  # Un service spécifique (ex: web ou db)
  docker compose logs -f web
  ```

- **Exécuter un terminal interactif dans le conteneur Web** :
  ```bash
  docker compose exec web bash
  ```

- **Reconstruire les images après modification du `Dockerfile`** :
  ```bash
  docker compose up -d --build
  ```

---

## 🐞 Configuration Xdebug

Xdebug est déjà préconfiguré dans le conteneur `web` :
- **Mode :** `develop,debug`
- **Port client :** `9003`
- **Hôte client :** `host.docker.internal`
- **Démarrage automatique :** `start_with_request=yes`

Pour écouter les sessions de débogage dans votre éditeur (VS Code, PhpStorm), configurez votre écouteur Xdebug sur le port `9003` et associez le chemin local du projet au chemin dans le conteneur (`/var/www/html`).

---

## 📁 Structure du projet

```text
.
├── Dockerfile              # Configuration de l'image Apache + PHP 8.3 + Xdebug
├── docker-compose.yml      # Définition des services Docker (web, db, phpmyadmin)
├── README.md               # Ce guide d'installation et d'utilisation
├── .env.example            # Modèle du .env, réservé à Docker
├── app/                    # Architecture applicative (MVC)
│   ├── controller/         # Contrôleurs PHP
│   ├── model/              # Modèles et accès aux données
│   └── view/               # Vues et templates PHP
├── config/                 # Configuration : config.example.php (modèle) et config.php (local, ignoré)
├── data/                   # Fichiers de données sources (ex: ruche-data.js)
└── public/                 # Racine publique web servie par Apache (/var/www/html/public)
    ├── index.php           # Point d'entrée de l'application
    ├── css/                # Feuilles de styles
    └── js/                 # Scripts JavaScript client
```

---

## ❓ Dépannage (FAQ)

### Conflit de port (ex: `bind: address already in use` sur le port 80 ou 8080)
Si un autre serveur local (Apache natif, Nginx, Skype, etc.) utilise déjà le port `80` ou `8080` :
1. Arrêtez le service en conflit sur votre machine hôte, ou
2. Modifiez le port hôte dans `docker-compose.yml` (par exemple `"127.0.0.1:8081:80"` au lieu de `"127.0.0.1:80:80"`).

### MariaDB met du temps à démarrer
Au premier lancement, MariaDB initialise les fichiers de base de données. Les conteneurs `web` et `phpmyadmin` attendent que la base soit prête (`healthcheck`) avant de démarrer.
