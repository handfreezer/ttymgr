#!/bin/bash

set -x

DIR_BIN=$(cd $(dirname ${0}) && pwd -P)
DIR_TOOL_GENERATE_OVPN="${DIR_BIN}/../tools_ovpn"
SSH_KEY_FILE="${DIR_BIN}/../keys/ttymgr_key"
DIR_OVPN_FILES="${DIR_TOOL_GENERATE_OVPN}/ovpn"
BIN_TOOL_GENERATE_OVPN="${DIR_TOOL_GENERATE_OVPN}/generateOvpnClient.sh"
TIMEOUT_OVPN_CNX=30

. /KioskAndMgr/config_db.sh
db_table='enrolled'

if [ 3 -ne ${#} ]
then
	echo "Call : ${0} [IP to deploy to] [Name of console used as hostanme and CN] [IP cible]"
	exit 1
fi

IP_CURRENT=${1}
CONSOLE_NAME=$(tr 'A-Z' 'a-z' <<<"${2}")
IP_CIBLE=${3}
PATH_CONSOLE_OVPN="${DIR_OVPN_FILES}/${CONSOLE_NAME}.ovpn"

mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${db_table}(cn,ip) values ('${CONSOLE_NAME}.labs.ulukai.net', '${IP_CIBLE}')"
res_mysql=${?}
if [ 0 -ne ${res_mysql} ]
then
	echo "Failed to insert enrolled console"
	exit 1
fi
${DIR_BIN}/getSerial.sh enrolling ${IP_CURRENT} ${IP_CIBLE}

mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params(cn,param,value) values ('${CONSOLE_NAME}.labs.ulukai.net', 'vpn.enabled', '1')"
res_mysql=${?}
if [ 0 -ne ${res_mysql} ]
then
	echo "Failed to enable vpn"
	exit 1
fi

${BIN_TOOL_GENERATE_OVPN} ${CONSOLE_NAME}
if [ ! -e "${PATH_CONSOLE_OVPN}" ]
then
	echo "OVPN file for console is absent [${PATH_CONSOLE_OVPN}]"
	exit 1
fi

ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${IP_CURRENT}"
scp -o IdentityFile=${SSH_KEY_FILE} -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${PATH_CONSOLE_OVPN}" root@${IP_CURRENT}:/root/
res_scp=${?}
if [ 0 -ne "${res_scp}" ]
then
	echo "Failed to send OVPN file to console"
	exit 1
fi

ssh root@${IP_CURRENT} -i ${SSH_KEY_FILE} "bash -s -- --debug" < ${DIR_BIN}/remoteEnrollDeploy.sh
res_ssh=${?}
if [ 0 -ne "${res_ssh}" ]
then
	echo "Invocation of enroll on console to deploy new OVPN profile failed"
	exit 1
fi

echo "Waiting cnx of ${CONSOLE_NAME}: "
while [ 0 -lt "${TIMEOUT_OVPN_CNX}" ]
do
	sleep 1
	echo -n "."
	countIp=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select count(ip) from ovpn_status where ip='${IP_CIBLE}'"|column -t|sed '1d')
	if [ 0 -lt "${countIp}" ]
	then
		echo "Deployment connected"
		break
	else
		(( TIMEOUT_OVPN_CNX = TIMEOUT_OVPN_CNX - 1 ))
	fi
done
if [ 0 -ge "${TIMEOUT_OVPN_CNX}" ]
then
	echo "Deployment failed, no cnx on OpenVPN"
	exit 1
fi

ssh root@${IP_CIBLE} -i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no -o ConnectTimeout=5 "bash -s -- --debug" < ${DIR_BIN}/remoteEnrollDisableTtyToRecord.sh
res_ssh=${?}
if [ 0 -ne "${res_ssh}" ]
then
	echo "Disabling ttyToRecord on console to deploy failed"
	exit 1
fi

CN="${CONSOLE_NAME}.labs.ulukai.net"
CNX_ID=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "guacamole_db" -e "call addConnectionSsh('${CONSOLE_NAME}-ssh', '${IP_CIBLE}', 'users_RO', @cnxid); select @cnxid;"|column -t|sed '1d')
mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${CN}','guacamole.ssh.id','${CNX_ID}')"
res_mysql=${?}
if [ 0 -ne "${res_mysql}" ]
then
	echo "Failed to record param [guacamole.ssh.id = ${CNX_ID}] for [${CN}]"
	exit 1
fi

echo "Enrollment ended"
exit 0

