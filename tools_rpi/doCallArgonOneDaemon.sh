#!/bin/bash

set -x

. /KioskAndMgr/config_db.sh
DIR_BIN=$(cd $(dirname ${0}) && pwd -P)

SUBJECT="ArgonOne Daemon"
SCRIPT_REMOTE_INSTALL="${DIR_BIN}/remoteInstallArgonOneDaemon.sh"
SCRIPT_REMOTE_OPTS="--debug --remove --install"
SERVICE_KEY="rpi.argononed"

SSH_KEY_FILE="${DIR_BIN}/../keys/ttymgr_key"
SERVICE_KEY_FULLPATH="service.${SERVICE_KEY}"
db_table='enrolled_params'

if [ 1 -ne ${#} ]
then
	echo "Call : ${0} [CN of tty]"
	exit 1
fi

TTY_CN=$(tr 'A-Z' 'a-z' <<<"${1}")

TTY_IP=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select ip from enrolled where cn='${TTY_CN}'"|column -t|sed '1d')
if [ -z "${TTY_IP}" ]
then
	echo "No IP for CN=[${TTY_CN}]"
	exit 1
fi

ssh root@${TTY_IP} -i ${SSH_KEY_FILE} "bash -s -- ${SCRIPT_REMOTE_OPTS}" < ${SCRIPT_REMOTE_INSTALL}
res_ssh=${?}
if [ 0 -ne "${res_ssh}" ]
then
	echo "Invocation for installing ${SUBJECT} failed"
	exit 1
fi

mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${db_table} values ('${TTY_CN}','${SERVICE_KEY_FULLPATH}','1') on duplicate key update value='1'"
res_mysql=${?}
if [ 0 -ne "${res_mysql}" ]
then
	echo "Failed to record param [${SERVICE_KEY_FULLPATH} = 1] for [${TTY_CN}]"
	exit 1
fi

echo "Install of ${SUBJECT} service ended"
exit 0

