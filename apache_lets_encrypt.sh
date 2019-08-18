#! /bin/bash
DOMAIN=$1
EMAIL=$2
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt install -y  python-certbot-apache
sudo certbot --apache -d ${DOMAIN} -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL}
echo "testing cert renewal"
certbot renew --dry-run
curl https://${DOMAIN}
