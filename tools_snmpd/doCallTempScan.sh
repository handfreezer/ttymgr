#!/bin/bash

set -x

DIR_BIN=$(cd $(dirname ${0}) && pwd -P)
SSH_KEY_FILE="${DIR_BIN}/../keys/ttymgr_key"

. /KioskAndMgr/config_db.sh
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

ssh root@${TTY_IP} -i ${SSH_KEY_FILE} "bash -s -- --debug" < ${DIR_BIN}/remoteInstallSnmpdTempScan.sh
res_ssh=${?}
if [ 0 -ne "${res_ssh}" ]
then
	echo "Invocation for installing SNMPD TempScan failed"
	exit 1
fi

mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${db_table} values ('${TTY_CN}','service.snmpd.temp.scan','1') on duplicate key update value='1'"
res_mysql=${?}
if [ 0 -ne "${res_mysql}" ]
then
	echo "Failed to record param [service.snmpd.temp.scan = 1] for [${TTY_CN}]"
	exit 1
fi

echo "Install of SNMPD TempScan service ended"
exit 0

