#!/bin/bash

set -x

DIR_BIN=$(cd $(dirname ${0}) && pwd -P)
SSH_KEY_FILE="${DIR_BIN}/../keys/ttymgr_key"

. /KioskAndMgr/config_db.sh

if [ 2 -ne ${#} ]
then
	echo "Call : ${0} [CN of tty] [action]"
	exit 1
fi

TTY_CN=$(tr 'A-Z' 'a-z' <<<"${1}")
SHORT_CN=$(cut -d. -f1 <<<${TTY_CN})
action=${2}

TTY_IP=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select ip from enrolled where cn='${TTY_CN}'"|column -t|sed '1d')
if [ -z "${TTY_IP}" ]
then
	echo "No IP for CN=[${TTY_CN}]"
	exit 1
fi

case $action in
	getInventory)
		DIR_TMP=$(mktemp -d)
		FILE_INVENTORY="${DIR_TMP}/inventory.xml"
		ssh root@${TTY_IP} -i ${SSH_KEY_FILE} "fusioninventory-inventory -t ${TTY_CN} --no-category=process,printer,software,user,environment" > ${FILE_INVENTORY}
		res_ssh=${?}
		if [ 0 -ne ${res_ssh} ]
		then
			echo "Failed to get inventory"
			exit 1
		else
			chmod +rx ${DIR_TMP}
			chmod +rx ${FILE_INVENTORY}
			mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_inventory(cn,inventory) values (\"${TTY_CN}\", LOAD_FILE(\"${FILE_INVENTORY}\"))"
			res_mysql=${?}
			if [ 0 -ne "${res_mysql}" ]
			then
				echo "Failed to save inventory"
				exit 1
			else
				rm ${FILE_INVENTORY}
				rmdir ${DIR_TMP}
			fi
		fi
		;;
	*)
		;;
esac

exit 0

