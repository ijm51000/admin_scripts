NIFI_TAR=nifi-1.9.2-bin.tar.gz
NIFI_DIR=/opt/nifi
CHECKSUM_PASS=good
wget http://apache.mirror.anlx.net/nifi/1.9.2/${NIFI_TAR}
# the below returns the checksum and the file name then converts to bash array
# echo ${checksum} is the same as echo ${checksum[0]}
checksum=($(sha256sum ${NIFI_TAR}))
checksum_test=$(curl -L "https://checker.apache.org/mk_page.cgi?CSUM=${checksum}&BUT_CSUM=search" | grep  "the file has a good.*signature" | grep -o "good" )

if [[ ${checksum_test} = ${CHECKSUM_PASS} ]]
then
    echo good checksum 
else
    echo checksum failed 
    exit 1
fi
mkdir -p ${NIFI_DIR}
chown -R ${USER}:${USER} ${NIFI_DIR}
tar xzf ${NIFI_TAR} --strip-components=1 -C ${NIFI_DIR}


