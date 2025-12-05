#!/bin/bash

# =======================================================
# Script de Restauration des Liens Symboliques pour CasaOS
# Auteur: SamGVanN
# Date: Décembre 2025
# Description: Recrée le lien symbolique /DATA qui pointe 
# vers le point de montage du disque de stockage externe.
# =======================================================

# --- Variables de Configuration ---
# /!\ Remplacez "/DATA" par l'emplacement réel de l'ancien répertoire DATA 
#    utilisé par défaut par vos conteneurs avant la migration
#    (ex: /var/lib/docker/volumes/data/_data, /home/user/data, etc.)
#    par défaut sur casaos c'est /DATA
ANCIEN_CHEMIN="/DATA" 
# Ce chemin est le point de montage de votre disque externe que vous avez défini dans CasaOS
NOUVEAU_CHEMIN="/mnt/Storage/DATA"

# --- Vérification de l'existence du nouveau point de montage ---
if [ ! -d "/mnt/Storage" ]; then
    echo "/!\ ERREUR /!\: Le disque de stockage externe n'est pas monté sous /mnt/Storage."
    echo "   Veuillez d'abord ajouter le disque (exemple sda1) dans l'interface CasaOS (Système > Stockage) et le nommer 'Storage'."
    exit 1
fi

# --- Vérification de l'existence du répertoire DATA sur le disque externe ---
if [ ! -d "$NOUVEAU_CHEMIN" ]; then
    echo "/!\ AVERTISSEMENT: Le répertoire de données principal ($NOUVEAU_CHEMIN) n'existe pas."
    echo "   Tentative de création..."
    sudo mkdir -p "$NOUVEAU_CHEMIN"
    if [ $? -ne 0 ]; then
        echo "/!\ ERREUR /!\: Impossible de créer le répertoire $NOUVEAU_CHEMIN. Vérifiez les droits."
        exit 1
    fi
    echo "OK Répertoire $NOUVEAU_CHEMIN créé."
fi

# --- Création du Lien Symbolique ---

# 1. Suppression de l'ancien chemin s'il existe (pour le remplacer par le lien)
if [ -e "$ANCIEN_CHEMIN" ] && [ ! -L "$ANCIEN_CHEMIN" ]; then
    echo "/!\ Le répertoire $ANCIEN_CHEMIN existe. Il sera renommé en ${ANCIEN_CHEMIN}_OLD pour la sécurité."
    sudo mv "$ANCIEN_CHEMIN" "${ANCIEN_CHEMIN}_OLD"
elif [ -L "$ANCIEN_CHEMIN" ]; then
    echo "Le lien symbolique $ANCIEN_CHEMIN existe déjà. Suppression du lien obsolète..."
    sudo rm "$ANCIEN_CHEMIN"
fi

# 2. Création du lien
echo "🔗 Création du lien symbolique: $ANCIEN_CHEMIN -> $NOUVEAU_CHEMIN"
# Syntaxe: ln -s [CIBLE] [NOM_DU_LIEN]
sudo ln -s "$NOUVEAU_CHEMIN" "$ANCIEN_CHEMIN"

if [ $? -eq 0 ]; then
    echo "OK Succès! Le lien symbolique a été créé."
else
    echo "/!\ ERREUR /!\ lors de la création du lien. Code de sortie : $?"
    exit 1
fi

#Création du lien pour les /data "lourd" des containers, par exemple nextcloud
sudo ln -s /mnt/Storage/DATA/AppData/Storage /DATA/AppData/ExternalStorage

# --- Réajustement des Permissions (Sécurité) ---
# Ceci garantit que CasaOS (UID/GID 1000) peut lire/écrire sur le disque
echo "Réajustement des permissions du répertoire de données principal..."
sudo chown -R 1000:1000 "$NOUVEAU_CHEMIN"
sudo chmod -R 775 "$NOUVEAU_CHEMIN"
echo "OK Permissions (1000:1000, 775) appliquées."

echo "---"
echo "RESTAURATION TERMINÉE. Vos conteneurs peuvent maintenant être redémarrés."

exit 0