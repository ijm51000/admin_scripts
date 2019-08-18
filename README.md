# admin_scripts
scripts to save a bit of time when setting up servers\

## setup git for first time use
git config --global user.name "ijm51000"\
git config --global user.email "@gmail.com"\
git config --global color.ui true\
git config --global core.editor vim\
ssh-keygen -t rsa -C "@gmail.com"\
**add the key here on GH account -> settings -> on the left ssh keys\
test**\
ssh -T git@github.com\
**on local host**\
mkdir admin_scripts\
cd admin_scripts\
git init\
git remote add origin git@github.com:ijm51000/admin_scripts\
git pull origin master\

