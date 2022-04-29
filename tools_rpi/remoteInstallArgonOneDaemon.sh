#!/bin/bash
set -x

URL_TTYMGR="https://[URL]/ttymgr"

if [ 0 -ne "$(id -u)" ]
then
        echo "ArgonOne Daemon should be installed by root, stopping. [current id = $(id -u)]"
        exit 1
fi

DATE=$(date +%Y%m%d-%H%M%S)
DIR_CWD="/root/${DATE}"
PATH_LOG="${DIR_CWD}/argononed.log"
TTY_NAME=$(hostname -s)

mkdir -p "${DIR_CWD}"

exec 3>&1
exec 4>&2
exec 1>"${PATH_LOG}" 2>&1
tail -f "${PATH_LOG}" >&3 &
PID_TAIL_LOG=${!}

cd "${DIR_CWD}"

result=0
removeArgon=0
installArgon=0

is_rpi=$(grep -ci raspberry /proc/cpuinfo)
if [ 0 -eq "${is_rpi}" ]
then
	echo "This tty is NOT a Rpi, so no ArgonOne Daemon, stopping"
	exit 1
fi

while [ 0 -lt ${#} ]
do
	cmd=${1}
	shift
	case ${cmd} in
		--remove)
			removeArgon=1
			;;
		--install)
			installArgon=1
			;;
		--debug)
			set -x
			;;
		*)
			echo "unknown [${cmd}]"
			;;
	esac
done

if [ 1 -eq "${removeArgon}" ]
then
	if [ ! -f "/usr/bin/argonone-uninstall" ]
	then
		echo "No [/usr/bin/argonone-uninstall] to remove ArgonOne Daemon"
	else
		/usr/bin/argonone-uninstall <<<"y"
	fi
fi

if [ 1 -eq "${installArgon}" ]
then
	echo "Installing ArgonOne Daemon..."
	wget -O /root/argon1.sh https://download.argon40.com/argon1.sh
	chmod u+x /root/argon1.sh
	/root/argon1.sh

	wget -O /etc/argononed.conf ${URL_TTYMGR}/rpi/argononed.conf
	systemctl restart argononed.service
fi

echo ""
sleep 1
kill "${PID_TAIL_LOG}"
exit ${result}

