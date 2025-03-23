#!/bin/bash

echo "========== SCRIPT ULTIME PTERODACTYL FIX =========="
echo ""

# 1. Vérification de la version PHP
echo "[1] ➤ Détection de la version PHP installée..."
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
SOCKET="/run/php/php${PHP_VERSION}-fpm.sock"
echo "[✔] Version détectée : PHP ${PHP_VERSION}"
echo "[✔] Socket détecté : ${SOCKET}"

# 2. (Ré)installation de PHP-FPM, PHP-CLI, NGINX, etc.
echo "[2] ➤ Installation des paquets nécessaires..."
apt update -y && apt install -y nginx php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-mysql unzip curl

# 3. Correction des permissions
echo "[3] ➤ Correction des permissions sur /var/www/pterodactyl"
mkdir -p /var/www/pterodactyl/public
chown -R www-data:www-data /var/www/pterodactyl
chmod -R 755 /var/www/pterodactyl

# 4. Configuration complète de NGINX
echo "[4] ➤ Génération du fichier nginx.conf"
cat > /etc/nginx/nginx.conf <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;

    gzip on;
    gzip_disable "msie6";

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

# 5. Configuration complète du VirtualHost Pterodactyl
echo "[5] ➤ Création de la configuration de Pterodactyl"
cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name localhost;

    root /var/www/pterodactyl/public;
    index index.php index.html index.htm;

    access_log /var/log/nginx/pterodactyl.access.log;
    error_log /var/log/nginx/pterodactyl.error.log warn;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${SOCKET};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# 6. Activation du site
echo "[6] ➤ Activation du site Pterodactyl"
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf

# 7. Redémarrage des services
echo "[7] ➤ Redémarrage de PHP-FPM et NGINX"
systemctl enable php${PHP_VERSION}-fpm
systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx

# 8. Test final : vérification si le PHP est bien exécuté
echo "[8] ➤ Test final : création d'un fichier phpinfo"
echo "<?php phpinfo(); ?>" > /var/www/pterodactyl/public/info.php
chmod 644 /var/www/pterodactyl/public/info.php

echo "[✔] Fichier /info.php créé. Teste dans ton navigateur :"
echo "http://TON-IP/info.php"

echo ""
echo "========== FIN DU SCRIPT ULTIME ✅ =========="
echo "Si tu vois la page PHPInfo, tout fonctionne parfaitement."
