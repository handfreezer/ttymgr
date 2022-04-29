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
apt-get install -y --no-install-recommends snmpd
apt-get autoremove -y

mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig
wget -O /etc/snmp/snmpd.conf ${URL_TTYMGR}/snmpd/snmpd.conf
systemctl enable snmpd
systemctl restart snmpd

kill "${PID_TAIL_LOG}"
exit 0



