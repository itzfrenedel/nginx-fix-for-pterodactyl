# Nginx Fix pour Pterodactyl Panel

## Introduction

Ce script est conçu pour résoudre des problèmes communs liés à l'installation et la configuration de Pterodactyl Panel avec Nginx et PHP-FPM. Il résout également un bug fréquent lié au téléchargement de fichiers.

### Prérequis

1. Vous devez avoir un serveur avec **Nginx** et **PHP-FPM** installés.
2. Vous devez disposer d'un accès SSH à votre serveur avec des privilèges **root**.

### Utilisation du script

Pour utiliser ce script sans avoir à l'installer sur votre VPS, vous pouvez l'exécuter directement depuis GitHub via une commande SSH.

#### Commande SSH pour exécuter le script sans installation

Copiez et exécutez cette commande SSH dans votre terminal. Elle télécharge le script, le rend exécutable, puis l'exécute sans l'installer sur votre VPS :

```bash
bash <(wget -qO- https://raw.githubusercontent.com/itzfrenedel/nginx-fix-for-pterodactyl/refs/heads/main/nginx-fix.sh) && sudo systemctl restart nginx
