# Nextcloud – Guide de sauvegarde (fichiers, base MariaDB, configuration)

Ce document décrit les bonnes pratiques pour sauvegarder complètement une instance Nextcloud fonctionnant avec MariaDB et des volumes bindés.

Une restauration complète nécessite trois éléments :
1. Les fichiers utilisateurs (`/data`)
2. La base MariaDB
3. La configuration Nextcloud (`/config`)

---

## 1. Structure typique des volumes

- `/data` : fichiers réels des utilisateurs (documents, photos, etc.)
- `/config` : configuration de Nextcloud (config.php, certificats, apps)
- `/var/lib/mysql` : dossiers de la base MariaDB (si bindé)

Si la base MariaDB est dans un container dédié, il faut utiliser un dump SQL ou un backup basé sur mariabackup.

---

## 2. Sauvegarder la base MariaDB (méthode recommandée : `mysqldump`)

Commande classique (à exécuter sur l'hôte, dans un script, ou via `docker exec`) :

```bash
docker exec mariadb bash -c 'mysqldump -u root -p"TON_MDP" nextcloud' > nextcloud.sql
```

Explications :
mysqldump exporte toute la base sous forme SQL
ce fichier est indispensable pour restaurer les utilisateurs, les partages, les métadonnées et toute la logique interne

Pour automatiser avec un timestamp :
```bash
docker exec mariadb bash -c 'mysqldump -u root -p"TON_MDP" nextcloud' \
    > /mnt/sauvegardes/nextcloud/db_$(date +'%Y-%m-%d').sql
```

## 3. Sauvegarder les fichiers Nextcloud (/data)

La sauvegarde doit copier le contenu réel du volume data.

Exemple simple :
```bash
rsync -avh --delete /DATA/AppData/ExternalStorage/nextcloud/data/ /mnt/sauvegardes/nextcloud/data/
```

Pour une sauvegarde incrémentale plus sûre :
```bash
rsync -avh --progress \
  /DATA/AppData/ExternalStorage/nextcloud/data/ \
  /mnt/sauvegardes/nextcloud/data/
```

Remarque importante :
Ne jamais modifier les fichiers pendant que la base évolue.
Idéalement, placer Nextcloud en maintenance mode (voir section 5).

##  4. Sauvegarder la configuration (/config)

Simple copie du dossier :
```bash
rsync -avh /DATA/AppData/nextcloud/config/ /mnt/sauvegardes/nextcloud/config/
```

Ce dossier contient :
- config.php
- paramètres de l’instance
- certificats éventuels
- apps installées


## 5. Placer Nextcloud en mode maintenance (fortement conseillé)

Avant de faire une sauvegarde complète :
```bash
docker exec nextcloud occ maintenance:mode --on
```

Après la sauvegarde :
```bash
docker exec nextcloud occ maintenance:mode --off
```

Ainsi, aucun utilisateur ne modifie les fichiers ou la base pendant la sauvegarde.

## 6. Script d'exemple (backup complet automatisé)

Exemple simple :
```bash
#!/bin/bash

BACKUP_DIR="/mnt/sauvegardes/nextcloud"
DATE=$(date +'%Y-%m-%d')

mkdir -p "$BACKUP_DIR/db"
mkdir -p "$BACKUP_DIR/data"
mkdir -p "$BACKUP_DIR/config"


# 1. Mode maintenance
docker exec nextcloud occ maintenance:mode --on

# 2. Dump SQL
docker exec mariadb bash -c 'mysqldump -u root -p"TON_MDP" nextcloud' \
    > "$BACKUP_DIR/db/nextcloud_$DATE.sql"

# 3. Fichiers data
rsync -avh --delete /DATA/AppData/ExternalStorage/nextcloud/data/ \
    "$BACKUP_DIR/data/"

# 4. Config
rsync -avh /DATA/AppData/nextcloud/config/ \
    "$BACKUP_DIR/config/"

# 5. Maintenance off
docker exec nextcloud occ maintenance:mode --off
```

##  7. Rotation automatique des backups (optionnel)

Supprimer les sauvegardes de plus de 14 jours :
```bash
find /mnt/sauvegardes/nextcloud/db -type f -mtime +14 -delete
find /mnt/sauvegardes/nextcloud/data -type f -mtime +14 -delete
find /mnt/sauvegardes/nextcloud/config -type f -mtime +14 -delete
```

##  8. Restauration (résumé)

Pour restaurer :

1. Recréer les dossiers /data et /config depuis les backups
2. Recréer la base avec :
```bash
mysql -u root -p"TON_MDP" nextcloud < nextcloud.sql
```
3. Redémarrer les containers
4. Exécuter ces commandes Nextcloud :
```bash
docker exec nextcloud occ maintenance:mode --off
docker exec nextcloud occ files:scan --all
```

##  9. Résumé rapide

- /data = fichiers réels → backup via rsync
- MariaDB = logique interne → backup via dump SQL
- /config = paramètres Nextcloud → backup via rsync
- Utiliser le mode maintenance pour éviter les incohérences
- Sauvegarder les trois éléments ensemble


---
