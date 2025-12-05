# Configuration des liens symboliques:

## /DATA/Media

destination : /mnt/Storage/DATA/Media

sudo ln -s /mnt/Storage/DATA/Media /DATA/Media

##  /DATA/AppData/ExternalStorage

destination : /mnt/Storage/DATA/AppData/Storage

sudo ln -s /mnt/Storage/DATA/AppData/Storage /DATA/AppData/ExternalStorage


## Attendu:
![alt text](/resources/images/symlinks.png )



## Explications


### /DATA/Media
- Pour les fichiers volumineux de type Media (Movies, TVShows etc)
- Ainsi les fichiers sont physiquement stockées sur /mnt/Storage/DATA/Media 
- Permet de garder la fluidité des apps (containers sur ssd) + ne pas saturer le ssd


### /DATA/AppData/ExternalStorage
- A utilsier pour les /data de container volumineux, à la palce de l'habituel /DATA/AppData/container/data
- Utilisé par nextcloud : permet de garder les fichiers sur le disque dur (/mnt/Storage de 2To) donc décorrelés de l'OS et du ssd