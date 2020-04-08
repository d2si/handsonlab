#/bin/sh
set -e
set -x

mv /home/ubuntu/site/* /var/www/html
chown -R www-data:www-data /var/www/html
