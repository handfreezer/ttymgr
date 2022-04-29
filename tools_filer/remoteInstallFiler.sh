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
	userdel -rf ${filer_username}
fi

if [ 1 -eq ${installFiler} ]
then
	useradd -m -s /bin/bash ${filer_username}
	passwd -l ${filer_username}
	dir_home_filer=$(grep -e "^${filer_username}:.*" /etc/passwd|cut -d: -f6)
	if [ ! -d "${dir_home_filer}" ]
	then
		echo "Failed to find home dir of [${filer_username}]"
		result=1
	else
		cd "${dir_home_filer}"
		mkdir -p ${dir_home_filer}/.ssh
		wget -O ${dir_home_filer}/.ssh/authorized_keys ${URL_BASE_TTYMGR}/filer/ttymgr_filer.pub
		chown -R ${filer_username}: ${dir_home_filer}/.ssh
		chmod -R go-rwx ${dir_home_filer}/.ssh
		result=0
	fi
fi

kill "${PID_TAIL_LOG}"
exit ${result}

