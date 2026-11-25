<?php

/**
 * Modèle de configuration.
 * Copier ce fichier en config/config.php, puis renseigner les valeurs.
 * Ne jamais committer config.php ni écrire de valeur réelle dans ce modèle.
 */

declare(strict_types=1);

// Les dates des relevés sont en heure de Paris
date_default_timezone_set('Europe/Paris');

// Base de données
define('DB_HOST', ''); // Docker : db / Laragon : 127.0.0.1
define('DB_PORT', 3306);
define('DB_NAME', '');
define('DB_USER', ''); // Laragon par défaut : root
define('DB_PASS', ''); // Laragon par défaut : vide

// API de données
define('API_BASE_URL', ''); // API sur la machine hôte avec Docker : http://host.docker.internal:3000
define('API_KEY', '');
