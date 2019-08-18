#! /bin/bash
DOMAIN=$1
EMAIL=$2
add-apt-repository -y ppa:certbot/certbot
apt install -y  python-certbot-apache
certbot --apache -d ${DOMAIN} -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL}
echo "testing cert renewal"
certbot renew --dry-run
