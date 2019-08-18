#! /bin/bash
git config --global user.name "ijm51000"
git config --global user.email "@gmail.com"
git config --global color.ui true
git config --global core.editor vim
ssh-keygen -N "" -f ~/.ssh/rsa_$(hostnamectl --static)_git -t rsa -C "ijm51000@github"
echo "copy this key to github account ssh keys"
cat  ~/.ssh/rsa_$(hostnamectl --static)_git.pub
read -p "Press enter to continue"
ssh -i ~/.ssh/rsa_$(hostnamectl --static)_git -T git@github.com
mkdir admin_scripts
cd admin_scripts
git init
git remote add origin git@github.com:ijm51000/admin_scripts
git pull origin master
