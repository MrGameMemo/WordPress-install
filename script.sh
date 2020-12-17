apt update && apt full-upgrade

echo "Installation de LAMP & des pré-requis"
echo ""
sleep 3
apt install -y apache2 curl mariadb-server php libapache2-mod-php php-mysql snapd wget php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
echo ""
echo ""
echo "Votre pile LAMP est installée avec succès !"
echo ""
echo ""
sleep 5
clear

echo "Création de la BDD WordPress & Ptero"
echo ""
sleep 3
curl https://gist.githubusercontent.com/hilja/10497734/raw/006ea8f54efa34d8a3e8a007ae67f0b70836adae/create-mysql-db.sh
chmod 755 mysql-db-create.sh
create-mysql-db.sh wordpress user password
create-mysql-db.sh pterodactyl user password
echo ""
echo ""
echo "Création des bases de données réussie !"
echo ""
echo ""
sleep 5
clear

echo "Installation de WordPress"
echo ""
sleep 3
a2enmod rewrite && systemctl restart apache2
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/html
chown -R www-data:www-data /var/www/html
find /var/www/html/ -type d -exec chmod 750 {} \;
find /var/www/html/ -type f -exec chmod 640 {} \;
echo ""
echo ""
echo "WordPress est installé avec succès !"
echo ""
echo ""
sleep 5
clear

echo "Installation de Pterodactyl"
echo ""
sleep 3
apt update
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:chris-lea/redis-server
apt update && apt upgrade -y
apt -y install php7.4 php7.4-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
mkdir -p /var/html/panel
cd /var/www/html/panel
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/download/v1.1.3/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan p:environment:setup
php artisan p:environment:database
php artisan p:environment:mail
php artisan migrate --seed --force
php artisan p:user:make
chown -R www-data:www-data *
(crontab -l && echo "* * * * * php /var/www/html/panel/artisan schedule:run >> /dev/null 2>&1") | crontab -
cd /etc/systemd/system
curl https://github.com/MrGameMemo/WordPress-install/raw/main/data/pteroq.service
systemctl enable --now redis-server
systemctl enable --now pteroq.service
echo ""
echo ""
echo "Pterodactyl (panel) est installé avec succès !"
echo ""
echo ""
sleep 5
clear

echo "Installation de Certbot"
echo ""
sleep 3
snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --apache
echo ""
echo ""
echo "Certbot (SSL) est installé avec succès !"
echo ""
echo ""
sleep 5
clear

echo "Installation de Wings"
echo ""
sleep 3
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/download/v1.1.3/wings_linux_amd64
chmod u+x /usr/local/bin/wings
echo ""
echo ""
echo "Wings est installé avec succès !"
echo ""
echo ""
sleep 5
clear
echo ""
echo ""
echo ""
echo ""
echo "Il vous suffit désormais de configurer WordPress en accédant directement à la racine du serveur web depuis un navigateur."
echo "Pour Pterodactyl, il vous suffit d'ajouter le \"node\" en précisant bien l\'option SSL."
echo ""
echo ""
echo ""
echo ""
sleep 20
clear
echo "Installations terminées !"
