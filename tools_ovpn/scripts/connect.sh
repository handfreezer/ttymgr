#!/bin/bash

. /KioskAndMgr/config_db.sh

cmd=$(basename ${0} .sh)
echo "Notification of cmd=[${cmd}] for [${common_name}]" >> /tmp/ovpn-connect.log

case ${cmd} in
	connect)
		IP=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select e.ip from ${tbl_enrolled} e, ${tbl_params} p where e.cn='${common_name}' and e.cn=p.cn and p.param='vpn.enabled' and p.value='1'"|column -t|sed '1d')
		if [ -z "${IP}" ]
		then
			mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${common_name}','${cmd}','Refused - No IP')" >> /tmp/ovpn-connect.log 2>&1
			echo "No IP for [${common_name}]" >> /tmp/ovpn-connect.log
			exit 1
		else
			mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${common_name}','${cmd}','Accepted - IP=${IP}')" >> /tmp/ovpn-connect.log 2>&1
			echo "Generating conf for [${common_name}|${IP}] in ${1}" >> /tmp/ovpn-connect.log
			cat - <<EOF >${1}
ifconfig-push ${IP} 255.255.0.0
push "explicit-exit-notify"
EOF
		fi
		;;
	disconnect)
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${common_name}','${cmd}','Accepted')" >> /tmp/ovpn-connect.log 2>&1
		;;
	*)
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${common_name}','${cmd}','Refused - unknwon command')" >> /tmp/ovpn-connect.log 2>&1
		/bin/echo "$(date +%Y%m%d-%H%M%S) - ${cmd} - ${username} - ${common_name} - ${ifconfig_local} - ${ifconfig_remote} - ${1}" >> /tmp/ovpn-connect.log
		exit 1
		;;
esac


exit 0

