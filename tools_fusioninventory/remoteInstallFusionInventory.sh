#!/bin/bash
set -x

URL_BASE_TTYMGR="https://[URL]/ttymgr"

if [ 0 -ne "$(id -u)" ]
then
        echo "Kiosk should be installed by root, stopping. [current id = $(id -u)]"
        exit 1
fi

DATE=$(date +%Y%m%d-%H%M%S)
DIR_CWD="/root/${DATE}"
PATH_LOG="${DIR_CWD}/filer.log"
TTY_NAME=$(hostname -s)

mkdir -p "${DIR_CWD}"

exec 3>&1
exec 4>&2
exec 1>"${PATH_LOG}" 2>&1
tail -f "${PATH_LOG}" >&3 &
PID_TAIL_LOG=${!}

cd "${DIR_CWD}"

result=1
filer_username="filer"
resetInit=0
installFiler=0

while [ 0 -lt ${#} ]
do
	cmd=${1}
	shift
	case ${cmd} in
		--reset)
			resetInit=1
			;;
		--install)
			installFiler=1
			;;
		--debug)
			set -x
			;;
		*)
			echo "unknown [${cmd}]"
			;;
	esac
done

if [ 1 -eq ${resetInit} ]
then
	apt-get -y remove fusioninventory-agent
	apt-get -y autoremove
fi

if [ 1 -eq ${installFiler} ]
then
	apt-get -y install fusioninventory-agent
	systemctl stop fusioninventory-agent
	systemctl disable fusioninventory-agent
	result=0
fi

kill "${PID_TAIL_LOG}"
exit ${result}

