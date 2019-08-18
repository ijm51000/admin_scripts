#! /bin/bash
DOMAIN=$1
mkdir -p /var/www/${DOMAIN}
chown -R $USER:$USER /var/www/${DOMAIN}
chmod -R 755 /var/www/${DOMAIN}
cat << EOF > /var/www/${DOMAIN}/index.html 
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
    DocumentRoot /var/www/${DOMAIN}
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
a2ensite ${DOMAIN}.conf
a2dissite 000-default.conf

if apache2ctl configtest; then
    sudo systemctl restart apache2
else
    echo "Apache config test failed"
fi

