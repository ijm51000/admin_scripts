# admin scripts
scripts to save a bit of time when setting up servers\
as many commands for admin need sudo run all scripts \
with sudo \
for first config typing th password every time is a pain\
run this command first to allow sudo without password\

echo "${USER} ALL = (root) NOPASSWD:ALL"  | sudo tee -a  /etc/sudoers.d/${USER} > /dev/null
remove when finished\
sudo rm /etc/sudoers.d/${USER}

## scripts
apache_create.sh -- install & configure apache on ubuntu\
apache_lets_encrypt.sh -- install & configure lets encypt for apache

## setup git for first time use on new host
git config --global user.name "ijm51000"\
git config --global user.email "@gmail.com"\
git config --global color.ui true\
git config --global core.editor vim\
ssh-keygen -t rsa -C "@gmail.com"\
**add the key here on GH account -> settings -> on the left ssh keys then test**\
ssh -T git@github.com\
mkdir admin_scripts\
cd admin_scripts\
git init\
git remote add origin git@github.com:ijm51000/admin_scripts\
git pull origin master

## usage
sudo  apache_create.sh my.domain.com\
sudo apache_lets_encrypt.sh my.domain.com me@me.com
