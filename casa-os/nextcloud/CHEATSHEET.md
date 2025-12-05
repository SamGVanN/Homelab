# Nextcloud – Rappel sur le stockage des données et le rôle de MariaDB

## 1. Répartition des données : fichiers vs base de données

Nextcloud utilise deux types de stockage distincts :

### A. Dossier `/data`
Contient les fichiers physiques stockés par les utilisateurs :
- photos
- vidéos
- documents
- PDF
- fichiers divers

Il s'agit uniquement du stockage brut.  
Aucune logique d'application n'est présente dans ce dossier.

### B. Base MariaDB
Contient les informations nécessaires au fonctionnement de Nextcloud :
- métadonnées des fichiers (nom, taille, dates, type MIME)
- emplacement logique dans l'arborescence interne
- comptes utilisateurs (email, identifiants, mots de passe hashés)
- groupes d'utilisateurs
- permissions et partages
- journaux internes
- paramètres de configuration interne
- données des applications installées
- index et caches

La base est indispensable pour que Nextcloud comprenne ce qui existe dans `/data`.

## 2. Conséquence en cas de perte de MariaDB

Si la base MariaDB est perdue :
- les fichiers restent présents physiquement dans `/data`
- mais Nextcloud ne peut plus les associer à des utilisateurs
- l'application devient inutilisable
- les fichiers deviennent orphelins et impossibles à récupérer automatiquement via l'interface

En résumé : perdre la base détruit la logique, mais pas les fichiers.

## 3. Ce qu'il faut sauvegarder

Une sauvegarde complète de Nextcloud doit inclure :
1. Le dossier `/data` (fichiers réels)
2. La base MariaDB (dump SQL ou backup MariaDB)
3. Le dossier `/config` (configuration de Nextcloud)

Les trois éléments sont nécessaires pour restaurer un environnement complet.

## 4. Résumé

| Élément | Stocké dans `/data` | Stocké dans MariaDB |
|--------|----------------------|----------------------|
| Fichiers physiques | Oui | Non |
| Métadonnées | Non | Oui |
| Comptes utilisateurs | Non | Oui |
| Partages | Non | Oui |
| Configuration système | Non | Oui |
| Documents, photos, vidéos | Oui | Non |
