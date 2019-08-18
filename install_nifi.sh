#! /bin/bash
NIFI_VERSION=1.9.2
NIFI_TAR=nifi-1.9.2-bin.tar.gz
GET_VERSION=$NIFI_VERSION/$NIFI_TAR
NIFI_DIR=/opt/nifi
CHECKSUM_PASS=good
MIN_JAVA="-Xms1024m"
MAX_JAVA="-Xmx1024m"
wget http://apache.mirror.anlx.net/nifi/$GET_VERSION -O /tmp/${NIFI_TAR}
# the below returns the checksum and the file name then converts to bash array
checksum=$(sha256sum "/tmp/${NIFI_TAR}"| cut -d' ' -f1)
checksum_test=$(curl -L "https://checker.apache.org/mk_page.cgi?CSUM=${checksum}&BUT_CSUM=search" | grep  "the file has a good.*signature" | grep -o "good" )
if [ "$checksum_test" == "$CHECKSUM_PASS" ]; then
    echo "good checksum" 
else
    echo "checksum failed; exiting" 
    exit 1
fi
sudo mkdir -p ${NIFI_DIR}
sudo_user=$(who am i | awk '{print $1}')
sudo chown -R ${sudo_user}:${sudo_user} ${NIFI_DIR}
tar xzf /tmp/${NIFI_TAR} --strip-components=1 -C ${NIFI_DIR}
cp ${NIFI_DIR}/conf/bootstrap.conf ${NIFI_DIR}/conf/bootstrap.orig
sed -i -e "/java.arg.2=/ s/=.*/=${MIN_JAVA}/" -e "/java.arg.3=/ s/=.*/=${MAX_JAVA}/" ${NIFI_DIR}/conf/bootstrap.conf
