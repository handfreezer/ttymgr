#!/bin/bash

. /KioskAndMgr/config_db.sh
tbl_ovpn_status='ovpn_status'

cmd=$(basename ${0} .sh)
echo "Notification of cmd=[${cmd}]" >> /tmp/ovpn-learn.log

op=${1}
ip=${2}
cn=${3}
/bin/echo "$(date +%Y%m%d-%H%M%S) - ${cmd} - op=${op} - ip=${ip} - cn=${cn}" >> /tmp/ovpn-learn.log

case ${op} in
	add)
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${cn}','${op}','${ip}')" >> /tmp/ovpn-learn.log 2>&1
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "delete from ${tbl_ovpn_status} where ip='${ip}'" >> /tmp/ovpn-learn.log 2>&1
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_ovpn_status}(cn,ip,serial,last_seen) values('${cn}','${ip}','',now()) on duplicate key update ip='${ip}', last_seen=now()" >> /tmp/ovpn-learn.log 2>&1
		nohup sh -c "sleep 5 && sudo /KioskAndMgr/tools_enroll/getSerial.sh torecord ${ip}" 1>>/tmp/ovpn-learn.log 2>&1 &
		;;
	update)
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${cn}','${op}','${ip}')" >> /tmp/ovpn-learn.log 2>&1
		if [ "ttyToRecord.labs.ulukai.net" = "${cn}" ]
		then
			/bin/echo " => update not used" >> /tmp/ovpn-learn.log
		else
			/bin/echo " => [${cn}] moved to [${ip}]" >> /tmp/ovpn-learn.log
			mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "update ${tbl_ovpn_status} set ip='${ip}' where cn='${cn}'" >> /tmp/ovpn-learn.log 2>&1
		fi
		;;
	delete)
		CN=$(mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "select cn from ${tbl_ovpn_status} where ip='${ip}'"|column -t|sed '1d')
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${CN}','${op}','${ip}')" >> /tmp/ovpn-learn.log 2>&1
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "delete from ${tbl_ovpn_status} where ip='${ip}'" >> /tmp/ovpn-learn.log 2>&1
		;;
	*)
		mysql -h ${db_host} -u "${db_user}" --password="${db_pwd}" "$db_name" -e "insert into ${tbl_cnx_hist} (cn,step,detail) values ('${cn}','${op}','Unknown op cmd=${cmd} - ip=${ip}')" >> /tmp/ovpn-learn.log 2>&1
		echo "unknown learn op[${op}]" >> /tmp/ovpn-learn.log
		;;
esac

exit 0

