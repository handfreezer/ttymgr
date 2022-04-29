#!/bin/bash

set -x

DIR_BIN=$(cd $(dirname ${0}) && pwd -P)
SSH_KEY_FILE="${DIR_BIN}/../keys/ttymgr_key"

. /KioskAndMgr/config_db.sh
db_table='enrolled_params'
vnc_port_base=5900
vnc_pwd=$(date +%d%H%M%S)
kiosk_nb_screen=2

if [ 1 -ne ${#} ]
then
	echo "Call : ${0} [CN of tty]"
	exit 1
fi

TTY_CN=$(tr 'A-Z' 'a-z' <<<"${1}")
SHORT_CN=$(cut -d. -f1 <<<${TTY_CN})

TTY_IP=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select ip from enrolled where cn='${TTY_CN}'"|column -t|sed '1d')
if [ -z "${TTY_IP}" ]
then
	echo "No IP for CN=[${TTY_CN}]"
	exit 1
fi

mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "delete from enrolled_params where cn='${TTY_CN}' and param like 'guacamole.vnc.%'"
res_mysql=${?}
if [ 0 -ne "${res_mysql}" ]
then
	echo "Failed to remove param [guacamole.vnc.*] for [${TTY_CN}]"
	exit 1
fi

mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "guacamole_db" -e "delete from guacamole_connection where connection_name like '${SHORT_CN}-vnc-%'"
res_mysql=${?}
if [ 0 -ne "${res_mysql}" ]
then
	echo "Failed to remove Guacamole VNC profiles for [${TTY_CN}]"
	exit 1
fi

ssh root@${TTY_IP} -i ${SSH_KEY_FILE} "bash -s -- --debug --reset --install --set-vnc-password ${vnc_pwd}" < ${DIR_BIN}/remoteInstallKiosk.sh
res_ssh=${?}
if [ 0 -ne "${res_ssh}" ]
then
	echo "Invocation for installing Kiosk failed"
	exit 1
fi

mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${db_table} values ('${TTY_CN}','service.kiosk.installed','1') on duplicate key update value='1'"
res_mysql=${?}
if [ 0 -ne "${res_mysql}" ]
then
	echo "Failed to record param [service.kiosk.installed = 1] for [${TTY_CN}]"
	exit 1
fi

for i in $(seq 1 $kiosk_nb_screen)
do
	(( vnc_port = vnc_port_base + i ))
	idx=$(printf "%02d" $i)
	CNX_ID=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "guacamole_db" -e "call addConnectionVnc('${SHORT_CN}-vnc-${idx}', '${TTY_IP}', '${vnc_port}', '${vnc_pwd}', 'users_RO', @cnxid); select @cnxid;"|column -t|sed '1d')
	mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}','guacamole.vnc.${idx}','${CNX_ID}') on duplicate key update value='${CNX_ID}'"
	res_mysql=${?}
	if [ 0 -ne "${res_mysql}" ]
	then
		echo "Failed to record param [guacamole.ssh.id = ${CNX_ID}] for [${CN}]"
		exit 1
	fi
	url="https://www.google.com"
	mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.url.${idx}', '${url}') on duplicate key update value='${url}'"
	res_mysql=${?}
	if [ 0 -ne "${res_mysql}" ]
	then
		echo "Failed to backup URL"
		exit 1
	fi
	mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${i}.slider', '0') on duplicate key update value='0'"
	res_mysql=${?}
	if [ 0 -ne "${res_mysql}" ]
	then
		echo "Failed to backup slider mode to off"
		exit 1
	fi
	mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${i}.incognito', '1') on duplicate key update value='1'"
	res_mysql=${?}
	if [ 0 -ne "${res_mysql}" ]
	then
		echo "Failed to backup incognito mode to on"
		exit 1
	fi
	mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${i}.clear.cache', '1') on duplicate key update value='1'"
	res_mysql=${?}
	if [ 0 -ne "${res_mysql}" ]
	then
		echo "Failed to backup clear cache"
		exit 1
	fi
	mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into enrolled_params values ('${TTY_CN}', 'service.kiosk.disp${i}.clear.data', '1') on duplicate key update value='1'"
	res_mysql=${?}
	if [ 0 -ne "${res_mysql}" ]
	then
		echo "Failed to backup clear data"
		exit 1
	fi
done

echo "Install of Kiosk service ended"
exit 0

