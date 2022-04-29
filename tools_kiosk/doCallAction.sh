#!/bin/bash

set -x

DIR_BIN=$(cd $(dirname ${0}) && pwd -P)
SSH_KEY_FILE="${DIR_BIN}/../keys/ttymgr_kiosk"

. /KioskAndMgr/config_db.sh

if [ 8 -ne ${#} ]
then
	echo "Call : ${0} [CN of tty] [action] [idx] [url] [cc] [cd] [incognito] [slider]"
	exit 1
fi

TTY_CN=$(tr 'A-Z' 'a-z' <<<"${1}")
SHORT_CN=$(cut -d. -f1 <<<${TTY_CN})
action=${2}
idx=${3}
url=${4}
ccache=${5}
cdata=${6}
incognito=${7}
slider=${8}

TTY_IP=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select ip from enrolled where cn='${TTY_CN}'"|column -t|sed '1d')
if [ -z "${TTY_IP}" ]
then
	echo "No IP for CN=[${TTY_CN}]"
	exit 1
fi

case $action in
	setUrl)
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.url.${idx}', '${url}') on duplicate key update value='${url}'"
		res_mysql=${?}
		if [ 0 -ne "${res_mysql}" ]
		then
			echo "Failed to backup URL"
			exit 1
		fi
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${idx}.clear.cache', '${ccache}') on duplicate key update value='${ccache}'"
		res_mysql=${?}
		if [ 0 -ne "${res_mysql}" ]
		then
			echo "Failed to backup clear cache"
			exit 1
		fi
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${idx}.clear.data', '${cdata}') on duplicate key update value='${cdata}'"
		res_mysql=${?}
		if [ 0 -ne "${res_mysql}" ]
		then
			echo "Failed to backup clear data"
			exit 1
		fi
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${idx}.incognito', '${incognito}') on duplicate key update value='${incognito}'"
		res_mysql=${?}
		if [ 0 -ne "${res_mysql}" ]
		then
			echo "Failed to backup incognito"
			exit 1
		fi
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${idx}.slider', '${slider}') on duplicate key update value='${slider}'"
		res_mysql=${?}
		if [ 0 -ne "${res_mysql}" ]
		then
			echo "Failed to backup slider mode"
			exit 1
		fi
		;;
	*)
		;;
esac

if [ 0 -ne "${slider}" ]
then
	url_json=${url}
	url="https://${URL_NS}/ttymgr/slider/slider.php?url=${url_json}"
fi

ssh kiosk@${TTY_IP} -i ${SSH_KEY_FILE} "~/action.sh '${action}' '${idx}' '${url}' '${ccache}' '${cdata}' '${incognito}'"
res_ssh=${?}
if [ 0 -ne "${res_ssh}" ]
then
	echo "Invocation Kiosk [${action}] for display index [${idx}]"
	exit 1
fi

exit 0

