# Introduction

1. Brancher le disque dur externe
2. voir son nom avec lsblk (toutes les commandes de ce guide sont faite avec un avec sda1 comme disque cible pour la sauvegarde)

## ‼️A SAVOIR

## ⚠️ Rule #1

Arrêter tous les conteneurs qui utilisent des bdd avant de lancer le script, sinon risque de BDD corrompue. 

Je recommande de couper tous les conteneurs tout cours afin de les retoruver dans le même état qu’au lancement du backup

Une fois le backup terminé ou le restore fait, suffira de les relancer via portainer

## ⚠️ Rule #2

Lire chaque commande avant de les exécuter, faire cette manip calmement est le meilleur moyen de pas se tromper.

## ⚠️ Ce qu’il vaut mieux éviter pendant la sauvegarde :

| Action | Pourquoi c’est risqué |
| --- | --- |
| Écriture massive sur disque | Tu risques de copier un fichier partiellement écrit ou modifié pendant la sauvegarde. |
| Mise à jour système | Ça peut modifier des fichiers que `rsync` est en train de lire ou copier. |
| Lancement ou arrêt de conteneurs critiques | Peut perturber les fichiers de volume en cours de copie. |
| Grosse installation logicielle | Risque d’incohérences si `rsync` copie au même moment. |

## 📂 Où sauvegarder le script de backup ?

Place-le dans un dossier système **non sauvegardé** et propre, par exemple :

```bash
sudo mkdir -p /usr/local/bin
sudo nano /usr/local/bin/backup-homelab.sh
```

Ce dossier est fait pour des scripts personnels ou locaux, **hors `/home` ou `/etc`** pour éviter toute confusion dans les sauvegardes/restaurations.

## 🔐 Rendre le script exécutable

```bash
sudo chmod +x /usr/local/bin/backup-homelab.sh
```

Ensuite l’exécuter simplement :

```bash
sudo /usr/local/bin/backup-homelab.sh
```

### Bonus : créer un alias plus court (ex : `backupserver`)

Si tu veux un **raccourci encore plus pratique**, tu peux ajouter un alias à ton shell.

### 1. Ouvre ton fichier de configuration de shell

```bash
nano ~/.bash_aliases
```

### 2. Ajoute cette ligne tout en bas :

```bash
alias backupserver='sudo backup-homelab.sh'
```

### 3. Recharge la config :

```bash
source ~/.bashrc
```

---

## ✅ Tu peux maintenant exécuter :

```bash
backupserver
```

> Ce sera équivalent à faire sudo /usr/local/bin/backup-homelab.sh, mais en plus rapide.
> 

## **ℹ️ Procédure sécurisée** pour débrancher un disque dur externe

## ✅ 1. S’assurer qu’aucun processus n’utilise le disque

Pour voir ce qui utilise le point de montage `/mnt/backup` :

```bash
sudo lsof +f -- /mnt/backup
```

Si rien n’est affiché, on peut débrancher le disque externe.

> S’il y a des fichiers ouverts, arrête les processus correspondants (par exemple un terminal, un script ou rsync encore en cours).
> 

---

## ✅ 2. Démonter proprement le disque

```bash
sudo umount /mnt/backup
```

Si c’est occupé, mais que tu veux ABSOLUMENT démonter, alors :

```bash
#lazy
sudo umount -l /mnt/backup
```

> lazy unmount : Détache immédiatement le système de fichiers, mais attend que les accès ouverts soient terminés avant de libérer réellement. Cela « détache » le point de montage immédiatement, même si certains fichiers sont encore ouverts.
> 

---

## 🔁 Optionnel : forcer le démontage (⚠️ à utiliser avec précaution)

Si jamais le disque refuse de se démonter et tu es sûr que rien ne l’utilise :

```bash
sudo umount -l /mnt/backup
```

- `l` = **lazy unmount** : démonte dès que possible (utile si un processus bloque, mais risqué en cas d’écriture en cours).

---

## ✅ 3. Une fois démonté, tu peux débrancher le disque USB

Tu peux maintenant retirer ton disque externe sans risque.

---

## ✅ Tu veux vérifier si le disque est bien démonté ?

```bash
mount | grep /mnt/backup
```

Si rien n’est affiché, il n’est plus monté.