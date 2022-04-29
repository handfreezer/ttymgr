#!/bin/bash

set -x

DIR_BIN=$(cd $(dirname ${0}) && pwd -P)

. /KioskAndMgr/config_db.sh

if [ 2 -gt ${#} ]
then
	echo "Call : ${0} [torecord|enrolling] [IP of which serial should be get from] [IP of enrolling]"
	exit 1
fi

CIBLE=${1}
IP_CURRENT="$(sed -e '/^[0-9.]*$/!d' <<<"${2}")"
IP_CIBLE=""
if [ -z "${IP_CURRENT}" ]
then
	echo "IP is suspect [${1}]"
	exit 1
fi
case ${CIBLE} in
	torecord)
		db_table='ovpn_status'
		;;
	enrolling)
		db_table='enrolled'
		IP_CIBLE="$(sed -e '/^[0-9.]*$/!d' <<<"${3}")"
		;;
	*)
		echo "Target of serial unknown"
		exit 1
		;;
esac		

ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${IP_CURRENT}"
#serial=$(ssh root@${IP_CURRENT} -i ${DIR_BIN}/../keys/ttymgr_key -o StrictHostKeyChecking=no -o ConnectTimeout=4 -- "cat /proc/cpuinfo |grep Serial|sed -e 's/^Serial.*: //'")
serial=$(ssh root@${IP_CURRENT} -i ${DIR_BIN}/../keys/ttymgr_key -o StrictHostKeyChecking=no -o ConnectTimeout=4 -- "ip link"|grep link/ether|head -n1|awk '{print $2;}')
res_ssh=${?}
if [ 0 -ne "${res_ssh}" ]
then
	echo "Failed to connect through SSH"
	exit 1
else
	mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "update ${db_table} set serial='${serial}' where ip in ('${IP_CURRENT}','${IP_CIBLE}')"
fi

exit 0

