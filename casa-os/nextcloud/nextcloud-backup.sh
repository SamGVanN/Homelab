#!/bin/bash

###############################################################################
# Script de sauvegarde Nextcloud + MariaDB
# Fonctionne avec Docker (LinuxServer Nextcloud + container MariaDB)
# Sauvegarde : base SQL + fichiers users + configuration
###############################################################################

### Configuration ##############################################################

# Nom des containers
NEXTCLOUD_CONTAINER="nextcloud"
MARIADB_CONTAINER="mariadb"

# Base de données
DB_NAME="nextcloud"
DB_USER="root"
DB_PASSWORD="TON_MDP_MARIADB"

# Chemin des données à sauvegarder
DATA_DIR="/DATA/AppData/ExternalStorage/nextcloud/data"
CONFIG_DIR="/DATA/AppData/nextcloud/config"

# Répertoire de sauvegarde final
BACKUP_DIR="/mnt/backups/nextcloud"

###############################################################################

DATE=$(date +'%Y-%m-%d_%H-%M-%S')

echo "=== Sauvegarde Nextcloud – $DATE ==="

mkdir -p "$BACKUP_DIR/db"
mkdir -p "$BACKUP_DIR/data"
mkdir -p "$BACKUP_DIR/config"

### 1. Activer le mode maintenance ############################################

echo "Activation du mode maintenance..."
docker exec "$NEXTCLOUD_CONTAINER" occ maintenance:mode --on

### 2. Sauvegarde de la base de données #######################################

echo "Sauvegarde de la base MariaDB..."
docker exec "$MARIADB_CONTAINER" bash -c \
"mysqldump -u $DB_USER -p\"$DB_PASSWORD\" $DB_NAME" \
> "$BACKUP_DIR/db/nextcloud_${DATE}.sql"

if [ $? -ne 0 ]; then
    echo "ERREUR : Échec du dump SQL."
    docker exec "$NEXTCLOUD_CONTAINER" occ maintenance:mode --off
    exit 1
fi

### 3. Sauvegarde des fichiers utilisateurs ###################################

echo "Sauvegarde du dossier DATA..."
rsync -avh --delete "$DATA_DIR/" "$BACKUP_DIR/data/"

### 4. Sauvegarde de la configuration #########################################

echo "Sauvegarde du dossier CONFIG..."
rsync -avh --delete "$CONFIG_DIR/" "$BACKUP_DIR/config/"

### 5. Désactivation du mode maintenance ######################################

echo "Désactivation du mode maintenance..."
docker exec "$NEXTCLOUD_CONTAINER" occ maintenance:mode --off

### 6. Suppression des sauvegardes anciennes (facultatif) ######################

# conserve 14 jours
find "$BACKUP_DIR/db" -type f -mtime +14 -delete
find "$BACKUP_DIR/data" -type f -mtime +14 -delete
find "$BACKUP_DIR/config" -type f -mtime +14 -delete

echo "Sauvegarde terminée : $BACKUP_DIR"
echo "====================================================================="
