#!/bin/bash

# === CONFIGURATION ===
MOUNT_POINT="/mnt/backup"
DEVICE="/dev/sda1"
BACKUP_ROOT="$MOUNT_POINT/Homelab/backup-data"
DATE=$(date +%F)
DEST="$BACKUP_ROOT/backup-$DATE"
LOGFILE="$BACKUP_ROOT/backup-$DATE.log"
KEEP=3  # Nombre de sauvegardes à conserver

# === DOSSIERS À EXCLURE ===
EXCLUDES=(
  "/dev/*"
  "/proc/*"
  "/sys/*"
  "/tmp/*"
  "/run/*"
  "/mnt/*"
  "/media/*"
  "/lost+found"
  "/DATA/Media"
  "/home/homelab/downloads"
)


# === MONTAGE DU DISQUE SI NÉCESSAIRE ===
if ! mountpoint -q "$MOUNT_POINT"; then
  echo "Montage du disque $DEVICE sur $MOUNT_POINT..."
  sudo mount "$DEVICE" "$MOUNT_POINT" || { echo "Échec du montage"; exit 1; }
fi
# Vérification que le montage a bien réussi
mountpoint -q "$MOUNT_POINT" || { echo "Le point de montage n'est pas disponible."; exit 1; }

# === CRÉATION DU DOSSIER DE LOG AVANT TOUT ===
mkdir -p "$BACKUP_ROOT"
touch "$LOGFILE" || { echo "Impossible de créer le fichier de log : $LOGFILE"; exit 1; }


# === CRÉATION DU DOSSIER DE DESTINATION ===
mkdir -p "$DEST"
touch "$LOGFILE" || { echo "Impossible de créer le fichier de log : $LOGFILE"; exit 1; }

# === CONSTRUCTION DES PARAMÈTRES D'EXCLUSION ===
EXCLUDE_STRING=""
for path in "${EXCLUDES[@]}"; do
    EXCLUDE_STRING+="--exclude=$path "
done


# === INFOS SYSTÈME ===
{
  echo "=== INFOS SYSTÈME ==="
  echo "Date               : $(date)"
  echo "Hostname           : $(hostname)"
  echo "Utilisateur        : $(whoami)"
  echo "Ubuntu version     : $(lsb_release -d | cut -f2)"
  echo "Kernel version     : $(uname -r)"
  echo "Architecture       : $(uname -m)"
  echo "======================="
  echo ""
} >> "$LOGFILE"

#=== POUR REINSTALLER CET ENVIRONNEMENT ===
UBUNTU_VERSION=$(lsb_release -d | cut -f2)
KERNEL_VERSION=$(uname -r)

{
  echo "=== POUR REINSTALLER CET ENVIRONNEMENT ==="
  echo "# Télécharger Ubuntu $UBUNTU_VERSION depuis https://releases.ubuntu.com"
  echo "# Installer manuellement ce noyau si besoin :"
  echo "sudo apt install linux-image-$KERNEL_VERSION linux-headers-$KERNEL_VERSION"
  echo "sudo apt-mark hold linux-image-$KERNEL_VERSION linux-headers-$KERNEL_VERSION"
  echo ""
} | tee -a "$LOGFILE"

echo "=== SOURCES APT ACTUELLES ===" | tee -a "$LOGFILE"
grep ^deb /etc/apt/sources.list | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "=== NOYAUX INSTALLÉS ===" | tee -a "$LOGFILE"
dpkg --list | grep linux-image | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"


# === LANCEMENT DE LA SAUVEGARDE ===
echo "=== DÉBUT SAUVEGARDE [$DATE] ===" | tee "$LOGFILE"
eval rsync -aAXHv --max-size=2G $EXCLUDE_STRING / "$DEST" 2> "$BACKUP_ROOT/backup-$DATE-errors.log" | tee -a "$LOGFILE"
echo "=== SAUVEGARDE TERMINÉE ===" | tee -a "$LOGFILE"


# === SUPPRESSION DES SAUVEGARDES LES PLUS ANCIENNES ===
echo "Nettoyage des anciennes sauvegardes (conservation des $KEEP plus récentes)..." | tee -a "$LOGFILE"
cd "$BACKUP_ROOT" || exit 1
ls -1d backup-* | sort -r | tail -n +$((KEEP + 1)) | while read old; do
    echo "Suppression de : $old" | tee -a "$LOGFILE"
    rm -rf "$old"
done
