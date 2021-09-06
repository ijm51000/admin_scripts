#!/bin/bash

###############################################################################
# Install single user nifi on ubuntu
#
###############################################################################
# Copyright 2021 Ian J Macdonald
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License. 
###############################################################################

log_file=/tmp/nifi_config.log
function log {
	printf "%s %s \n" "$(date -Ins)" "$*" | tee -a ${log_file}
}

version=1.14.0 # nifi version
HOSTNAME=$(hostname) #grab the hostname 
set -x 
log "Install nifi & nifi toolkit ${version} single user system on ${HOSTNAME}" 
settle_time=60  #Time to settle - nifi unpacks over 1gb so slow systems will need longer
os_user=$(who am i | awk '{print $1}') #use user that called script     
network=192.168.0  #network regex
password=16charatersOrMore
sensitive_props_key=${password}
nifi_user=${os_user} #I want the same user 

log "log file in ${log_file}"
# Check for root 
if [[ ${EUID} > 0 ]]
  then echo "Please run as root"
  exit 1
fi
# Install nifi toolkit as we need it for setting up certs, skip if exists
log "Downloading nifi toolkit if required "
wget -nc https://apache.mirrors.nublue.co.uk/nifi/${version}/nifi-toolkit-${version}-bin.tar.gz -O /tmp/nifi-toolkit-${version}-bin.tar.gz
log "Unpacking nifi toolkit"
logit=$(tar -xvf /tmp/nifi-toolkit-${version}-bin.tar.gz -C /tmp)
for i in ${logit}; do log ${i}; done
exit 1

mv /tmp/nifi-toolkit-${version} /opt/nifi-toolkit
chown -R ${os_user}.${os_user} /opt/nifi-toolkit

# Install java if needed and set JAVA_HOME
[ -z $(java -version) ] || apt install default-jdk
#JAVA_DIR=/usr/lib/jvm/java-11-openjdk-amd64
# the JAVA_DIR assignment could be quite brittle but works for me
JAVA_DIR=$(dirname $(dirname $(update-alternatives --list java)))
printf "export JAVA_HOME=%s\n" ${JAVA_DIR} > /etc/profile.d/java_home.sh
printf 'export PATH=$PATH:$JAVA_HOME/bin\n' >> /etc/profile.d/java_home.sh
export JAVA_HOME=$JAVA_DIR
log "java home set to  $JAVA_HOME"

# Download and install nifi, skip download if tar file exists 
wget -nc https://dlcdn.apache.org/nifi/${version}/nifi-${version}-bin.tar.gz -O /tmp/nifi-${version}-bin.tar.gz

# get ip address
IP=$(ip -o -4 addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done|grep ${network})

tar -xf /tmp/nifi-${version}-bin.tar.gz -C /tmp
mv /tmp/nifi-${version} /opt/nifi

# Set up directories outside of nifi to enable easier upgrades
mkdir -p /var/nifi/flow_config/conf
mkdir -p /var/nifi/flow_archive/
mkdir -p /var/nifi/config_resources/
mkdir -p /var/nifi/templates
mkdir -p /var/nifi/database_repository
mkdir -p /var/nifi/flowfile_repository
mkdir -p /var/nifi/content_repository
mkdir -p /var/nifi/provenance_repository
mkdir -p /var/nifi/certs

# change hosts file ubuntu sets ip of hostname = 127.0.1.1 which breaks nifi
sed -i "s:127\.0\.1\.1.*:${IP}    ${HOSTNAME}:" /etc/hosts
# Configure nifi properties to point to external directories
chown -R ${os_user}.${os_user} /opt/nifi
chown -R ${os_user}.${os_user} /var/nifi

#
sed -i "s:\(nifi.web.https.host=\).*:\1${HOSTNAME}:" /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.flow.configuration.file=\).*:\1/var/nifi/flow_config/conf/flow.xml.gz:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.flow.configuration.archive.dir=\).*:\1/var/nifi/flow_archive/:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.authorizer.configuration.file=\).*:\1/var/nifi/config_resources/authorizers.xml:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.login.identity.provider.configuration.file=\).*:\1/var/nifi/config_resources/login-identity-providers.xml:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.templates.directory=\).*:\1/opt/nifi/templates:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.state.management.configuration.file=\).*:\1/var/nifi/config_resources/state-management.xml:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.database.directory=\).*:\1/var/nifi/database_repository:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.flowfile.repository.directory=\).*:\1/var/nifi/flowfile_repository:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.content.repository.directory.default=\).*:\1/var/nifi/content_repository:' /opt/nifi/conf/nifi.properties
sed -i 's:\(nifi.provenance.repository.directory.default=\).*:\1/var/nifi/provenance_repository:' /opt/nifi/conf/nifi.properties

# Move files from nifi home to external directories
[ ! -f /opt/nifi/conf/authorizers.xml ] || mv /opt/nifi/conf/authorizers.xml /var/nifi/config_resources/
[ ! -f /opt/nifi/conf/login-identity-providers.xml ] || mv /opt/nifi/conf/login-identity-providers.xml /var/nifi/config_resources/
[ ! -f /opt/nifi/conf/state-management.xml ] || mv /opt/nifi/conf/state-management.xml /var/nifi/config_resources/state-management.xml

# first time start
sudo -u ian /opt/nifi/bin/nifi.sh set-sensitive-properties-key ${sensitive_props_key}
sudo -u ian /opt/nifi/bin/nifi.sh start
echo "one minute sleep while we let the system settle"
sleep ${settle_time}
sudo -u ian /opt/nifi/bin/nifi.sh stop

# Stop and set password and restart
echo "Creating user login"
sudo -u ian /opt/nifi/bin/nifi.sh set-sensitive-properties-key ${sensitive_props_key}
sudo -u ian /opt/nifi/bin/nifi.sh set-single-user-credentials ${nifi_user} ${password}
sudo -u ian /opt/nifi/bin/nifi.sh start # && tail -F /opt/nifi/logs/nifi-app.log
echo "Apache nifi Version: ${version}" > /opt/nifi/.nifi_version
echo "Apache nifi ${version} now available at https://${IP}:8443/nifi or https://${HOSTNAME}:8443/nifi"
echo "User name: ${nifi_user} Password ${password}"
chown ${os_user}.${os_user} ${log_file}
