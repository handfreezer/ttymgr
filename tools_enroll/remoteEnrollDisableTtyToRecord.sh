#!/bin/bash
set -x

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

mkdir -p "${DIR_CWD}"

exec 3>&1
exec 4>&2
exec 1>"${PATH_LOG}" 2>&1
tail -f "${PATH_LOG}" >&3 &
PID_TAIL_LOG=${!}

cd "${DIR_CWD}"

sed 's/.*NAutoVTs.*/NAutoVTs=0/g' -i /etc/systemd/logind.conf

#Specific Raspberry
grep -ci raspberry /proc/cpuinfo 1>/dev/null && sed 's/console=tty1//g' -i /boot/cmdline.txt

systemctl stop openvpn-client@ttyToRecord
sleep 1
systemctl disable openvpn-client@ttyToRecord
sleep 1
mv /etc/openvpn/client/tty[tT]o[rR]ecord.conf /root/

kill "${PID_TAIL_LOG}"
exit 0



