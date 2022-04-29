#!/bin/bash

set -x

DIR_BIN=$(cd $(dirname ${0}) && pwd -P)

. /KioskAndMgr/config_db.sh

if [ 2 -ne ${#} ]
then
	echo "Call : ${0} [action] [cn]"
	exit 1
fi

action=${1}
cn=${2}
tty_ip=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select ip from enrolled where cn='${cn}'"|column -t|sed '1d')

if [ -z "${action}" -o -z "${cn}" -o -z "${tty_ip}" ]
then
	echo "Suspect params [${action}|${cn}]"
	exit 1
fi

case ${action} in
	"reboot"|"poweroff")
		ssh root@${tty_ip} -i ${DIR_BIN}/../keys/ttymgr_key -o StrictHostKeyChecking=no -o ConnectTimeout=4 -- "${action}"
		res_ssh=${?}
		if [ 0 -ne "${res_ssh}" ]
		then
			echo "Failed to connect through SSH"
			exit 1
		fi
		;;
	*)
		echo "Action unknown [${action}] for [${cn}]"
		exit 1
		;;
esac

exit 0

