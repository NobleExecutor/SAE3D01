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
| **`web`** | Construit depuis `Dockerfile` (PHP 8.3 Apache + Xdebug) | Serveur HTTP Apache servant le dossier `public/` | `80:80` |
| **`db`** | `mariadb:10.11` | Serveur de base de données relationnelle | `3306` *(interne au réseau Docker)* |
| **`phpmyadmin`** | `phpmyadmin/phpmyadmin` | Interface web pour gérer la base de données MariaDB | `8080:80` |

---

## 🚀 Installation et démarrage rapide

### 1. Récupérer le projet
Clonez le dépôt Git sur votre machine locale si ce n'est pas déjà fait :
```bash
git clone https://github.com/NobleExecutor/SAE3D01
cd SAE3D01
```

### 2. Démarrer les conteneurs
Depuis la racine du projet, exécutez la commande suivante :

```bash
docker compose up -d --build
```
> *(Selon votre installation Docker, la commande peut également s'écrire avec un tiret : `docker-compose up -d --build`)*

Cette commande va :
1. Construire l'image du conteneur `web` avec PHP 8.3, Apache, les extensions nécessaires (PDO, MySQLi) et Xdebug.
2. Télécharger les images MariaDB 10.11 et phpMyAdmin.
3. Démarrer l'ensemble des conteneurs en tâche de fond (`-d`).

### 3. Vérifier que les conteneurs tournent
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
- **Dossier servi :** Le dossier local `./public/` est directement monté dans `/var/www/html`. Toute modification apportée aux fichiers dans `public/` est prise en compte instantanément sans avoir besoin de redémarrer le conteneur.

### 2. phpMyAdmin
- **URL :** [http://localhost:8080](http://localhost:8080)
- Permet d'administrer graphiquement les bases de données, d'exécuter des scripts SQL ou d'importer des tables.

---

## 🔑 Identifiants de la base de données

Depuis votre code PHP (ou via phpMyAdmin), utilisez les paramètres de connexion suivants :

| Paramètre | Valeur | Remarque |
| :--- | :--- | :--- |
| **Hôte (Host)** | `db` | Nom du service défini dans `docker-compose.yml` |
| **Port** | `3306` | Port standard MariaDB / MySQL |
| **Base de données** | `sae3d01_db` | Nom de la base créée automatiquement |
| **Utilisateur standard** | `user` | Droits complets sur `sae3d01_db` |
| **Mot de passe** | `user` | Mot de passe de l'utilisateur standard |
| **Utilisateur root** | `root` | Administrateur du serveur MariaDB |
| **Mot de passe root** | `root` | Mot de passe super-administrateur |

### Exemple de connexion PDO en PHP :
```php
<?php
$host     = 'db';
$dbname   = 'sae3d01_db';
$user     = 'user';
$password = 'user';
$charset  = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$dbname;charset=$charset";

try {
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (\PDOException $e) {
    throw new \PDOException($e->getMessage(), (int)$e->getCode());
}
```

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
├── app/                    # Architecture applicative (MVC)
│   ├── controller/         # Contrôleurs PHP
│   ├── model/              # Modèles et accès aux données
│   └── view/               # Vues et templates PHP
├── config/                 # Fichiers de configuration (base de données, constantes...)
├── data/                   # Fichiers de données sources (ex: ruche-data.js)
└── public/                 # Racine publique web servie par Apache (/var/www/html)
    ├── index.php           # Point d'entrée de l'application
    ├── css/                # Feuilles de styles
    └── js/                 # Scripts JavaScript client
```

---

## ❓ Dépannage (FAQ)

### Conflit de port (ex: `bind: address already in use` sur le port 80 ou 8080)
Si un autre serveur local (Apache natif, Nginx, Skype, etc.) utilise déjà le port `80` ou `8080` :
1. Arrêtez le service en conflit sur votre machine hôte, ou
2. Modifiez le port hôte dans `docker-compose.yml` (par exemple `"8081:80"` au lieu de `"80:80"`).

### MariaDB met du temps à démarrer
Au premier lancement, MariaDB initialise les fichiers de base de données. Il se peut que la connexion échoue pendant quelques secondes. Attendez 10 à 15 secondes puis rechargez phpMyAdmin ou votre application.
