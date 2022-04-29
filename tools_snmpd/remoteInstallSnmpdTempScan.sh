#!/bin/bash
set -x

URL_TTYMGR="https://[URL]/ttymgr"

if [ 0 -ne "$(id -u)" ]
then
	echo "Init should be done as root, stopping. [current id = $(id -u)]"
	exit 1
fi

while [ 0 -lt ${#} ]
do
	cmd=${1}
	shift
	case ${cmd} in
		--debug)
			set -x
			;;
		*)
			echo "unknown [${cmd}]"
			;;
	esac
done

DATE=$(date +%Y%m%d-%H%M%S)
DIR_CWD="/root/${DATE}"
PATH_LOG="${DIR_CWD}/init.log"
TTY_NAME=$(hostname -s)

mkdir -p "${DIR_CWD}"

exec 3>&1
exec 4>&2
exec 1>"${PATH_LOG}" 2>&1
tail -f "${PATH_LOG}" >&3 &
PID_TAIL_LOG=${!}

cd "${DIR_CWD}"

echo "Updating and installing packages..."
apt-get update
apt-get upgrade -y
apt-get install -y lm-sensors
apt-get autoremove -y

which vcgencmd 1>/dev/null 2>&1
if [ 0 -eq ${?} ]
then
	usermod -a -G video Debian-snmp
else
	echo "" >> /etc/modules
	echo "coretemp" >> /etc/modules
fi

wget -O /etc/snmp/temp_scan.sh ${URL_TTYMGR}/snmpd/temp_scan/temp_scan.sh
chmod +x /etc/snmp/temp_scan.sh

CONF_SNMPD="/etc/snmp/snmpd.conf"
TMP_CONF_SNMPD="${CONF_SNMPD}.${DATE}"
cp ${CONF_SNMPD} ${TMP_CONF_SNMPD}
sed '/.*.1.3.6.1.4.1.12345.1.3.*/d' -i ${CONF_SNMPD}
wget -O- ${URL_TTYMGR}/snmpd/temp_scan/temp_scan.snmpd.conf >> ${CONF_SNMPD}
systemctl restart snmpd

#(/usr/bin/sleep 6 && reboot) 1>/dev/null 2>&1 &

echo ""
sleep 1
kill "${PID_TAIL_LOG}"
exit 0



