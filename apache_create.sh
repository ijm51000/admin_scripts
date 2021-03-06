#! /bin/bash
DOMAIN=$1
APACHE_LOG_DIR=/var/log/apache
DOC_ROOT=/var/www/${DOMAIN}
sudo_user=$(who am i | awk '{print $1}')
sudo apt update
sudo apt install -y apache2
sudo mkdir -p ${APACHE_LOG_DIR}
sudo mkdir -p ${DOC_ROOT}
sudo chown -R ${sudo_user}:${sudo_user} ${DOC_ROOT}
chmod -R 755 ${DOC_ROOT}
cat << EOF > ${DOC_ROOT}/index.html 
<html>
    <head>
        <title>Welcome to ${DOMAIN}!</title>
    </head>
    <body>
        <h1>Success!  The ${DOMAIN}  virtual host is working!</h1>
    </body>
</html> 
EOF

cat << EOF > /etc/apache2/sites-available/${DOMAIN}.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName ${DOMAIN}
    ServerAlias ${DOMAIN}
    DocumentRoot ${DOC_ROOT}
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
sudo a2ensite "${DOMAIN}.conf"
sudo a2dissite 000-default.conf

if apache2ctl configtest; then
    sudo systemctl restart apache2
else
    echo "Apache config test failed"
fi
curl http://${DOMAIN}
