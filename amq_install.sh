set -x
JAVA_LOCATION=/usr/java/az_jdk-8/bin/java
WRAPPER=/apps/u01/activemq/bin/linux-x86-64/wrapper.conf
AMQ_CLIENT_ALL=activemq-all-5.13.4.jar
AMQ_CLIENT_CLIENT=activemq-client-5.13.4.jar
JAVA_FILE=amazon-corretto-8-x64-linux-jdk.tar.gz
AMQ_FILE=apache-activemq-5.13.4-bin.tar.gz
AMQ_VERSION=5.13.4
AMQ_PATH=https://archive.apache.org/dist/activemq
#sudo -u uat1 /apps/u01/activemq/bin/linux-x86-64/activemq stop
sudo systemctl stop activemq.service
sudo rm -rf /usr/java/az_jdk-8
sudo rm -rf /apps/u01/activemq
sudo rm -rf /apps/u01/mule
sudo userdel -r uat1
#rm -f ${HOME}/amazon-corretto-8-x64-linux-jdk.tar.gz 
#rm -f ${HOME}/apache-activemq-5.13.4-bin.tar.gz
if [[ ! -e "/tmp/${JAVA_FILE}" ]]
	then 
		wget https://corretto.aws/downloads/latest/${JAVA_FILE} -O /tmp/${JAVA_FILE} 
	fi
if [[ ! -e "/tmp/${AMQ_FILE}" ]]
	then
		wget ${AMQ_PATH}/${AMQ_VERSION}/${AMQ_FILE} -O /tmp/${AMQ_FILE}
	fi

# wget https://archive.apache.org/dist/activemq/5.13.4/apache-activemq-5.13.4-bin.tar.gz
echo "Unpacking JDK"
tar -xf /tmp/${JAVA_FILE} -C /tmp

echo  "Unpacking ActiveMQ"
tar -xf /tmp/${AMQ_FILE} -C /tmp #apache-activemq-5.13.4-bin.tar.gz
sudo mkdir -p /usr/java
sudo mv /tmp/amazon-corretto-8.252.09.1-linux-x64 /usr/java/az_jdk-8

sudo useradd -m  -s $(which bash)  -d /apps/u01 uat1
sudo mv /tmp/apache-activemq-5.13.4 /apps/u01/activemq
sudo chown -R uat1:uat1 /apps/u01/activemq
#sudo sed -i.orig 's|\(wrapper.java.command=\).*|\1/usr/java/az_jdk-8/bin/java|g' ${WRAPPER} 
sudo sed -i.orig "s|\(wrapper.java.command=\).*|\1${JAVA_LOCATION}|g" ${WRAPPER} 
sudo tee /etc/systemd/system/activemq.service << EOF
[Unit]
Description=Apache ActiveMQ
After=network-online.target

[Service]
Type=forking
WorkingDirectory=/apps/u01/activemq
ExecStart=/apps/u01/activemq/bin/linux-x86-64/activemq start
ExecStop=/apps/u01/activemq/bin/linux-x86-64/activemq stop
Restart=on-abort
User=uat1
Group=uat1

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable activemq.service
sudo systemctl start activemq.service
# sudo -u uat1 /apps/u01/activemq/bin/linux-x86-64/activemq start
# create dummy mule environment
sudo -u uat1 mkdir -p /apps/u01/mule/{apps,domain,conf}
sudo -u uat1 mkdir -p /apps/u01/mule/apps/{test1,test2}
sudo -u uat1 mkdir -p /apps/u01/mule/domain/{test1,test2}
sudo -u uat1 touch /apps/u01/mule/apps/{test1,test2}/${AMQ_CLIENT_ALL}
sudo -u uat1 touch /apps/u01/mule/apps/{test1,test2}/${AMQ_CLIENT_CLIENT}

sudo -u uat1 touch /apps/u01/mule/domain/{test1,test2}/${AMQ_CLIENT_ALL}
sudo -u uat1 touch /apps/u01/mule/domain/{test1,test2}/${AMQ_CLIENT_CLIENT}
sudo systemctl start activemq 
