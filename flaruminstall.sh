#!/bin/bash -       
#title         :flaruminstall.sh
#description   :This script is the updated version of flaruminstall.sh which is originally written by Nartamus.
#author		     :rawados - nginx@hotmail.com
#date          :04/15/20
#version       :1.0
#usage		     :sudo bash flaruminstall.sh
#notes         :Tested with Ubuntu 18
#==============================================================================

#Change below to what you'd like
MY_DOMAIN_NAME=cheesy.wtf
MY_EMAIL=nginx@hotmail.com
DB_NAME=flarum
DB_PSWD=flarum321

SITES_AVAILABLE='/etc/apache2/sites-available/'

clear

echo "***************************************"
echo "*          Flarum Installer           *"
echo "*  Should work on any Ubuntu Distro   *"  
echo "*            By: Nartamus             *"
echo "***************************************"

read -p "Are you sure?(y/n) " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes ppa:ondrej/php
    sudo apt-get update
    sudo apt-get -y install apache2 mariadb-server mariadb-client
    sudo apt install -y php7.4 libapache2-mod-php7.4 php7.4-common php7.4-mbstring php7.4-xmlrpc php7.4-soap php7.4-gd php7.4-xml php7.4-intl php7.4-mysql php7.4-cli php7.4-mcrypt php7.4-zip php7.4-curl php7.4-dom openssl
   
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
    
    sudo mkdir -p /var/www/$MY_DOMAIN_NAME
    cd /var/www/$MY_DOMAIN_NAME
    composer create-project flarum/flarum .

    chown -R www-data:www-data /var/www/$MY_DOMAIN_NAME    
    chmod 775 /var/www/$MY_DOMAIN_NAME
    chmod 775 -R /var/www/$MY_DOMAIN_NAME/public/assets
    chmod 775 /var/www/$MY_DOMAIN_NAME/storage


    sudo echo " <VirtualHost *:80>
                    ServerAdmin $MY_EMAIL
                    ServerName $MY_DOMAIN_NAME
                    ServerAlias www.$MY_DOMAIN_NAME
                    DocumentRoot /var/www/$MY_DOMAIN_NAME/public
                    <Directory /var/www/$MY_DOMAIN_NAME/public>                    
                        AllowOverride all
                    </Directory>
                    ErrorLog /var/log/apache2/$MY_DOMAIN_NAME-error.log
                    LogLevel error
                    CustomLog /var/log/apache2/$MY_DOMAIN_NAME-access.log combined
		        </VirtualHost>" > $SITES_AVAILABLE$MY_DOMAIN_NAME.conf

    sudo a2ensite $MY_DOMAIN_NAME
    sudo a2enmod rewrite
    sudo a2dissite 000-default.conf
    sudo systemctl restart apache2

    sudo chmod -R 775 /var/www/$MY_DOMAIN_NAME

    sudo mysql -uroot -p$DB_PSWD -e "CREATE DATABASE $DB_NAME"
    sudo mysql -uroot -p$DB_PSWD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'root'@'localhost' IDENTIFIED BY '$DB_PSWD'"
    
    #configure ssl
    sudo apt install certbot python3-certbot-apache
    sudo ufw allow 'Apache Full'
    sudo ufw delete allow 'Apache'
    sudo certbot --apache

else
    clear
fi
