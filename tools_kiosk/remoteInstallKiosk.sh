#!/bin/bash
set -x

URL_TTYMGR="https://[URL]/ttymgr"

if [ 0 -ne "$(id -u)" ]
then
        echo "Kiosk should be installed by root, stopping. [current id = $(id -u)]"
        exit 1
fi

DATE=$(date +%Y%m%d-%H%M%S)
DIR_CWD="/root/${DATE}"
PATH_LOG="${DIR_CWD}/kiosk.log"
TTY_NAME=$(hostname -s)

mkdir -p "${DIR_CWD}"

exec 3>&1
exec 4>&2
exec 1>"${PATH_LOG}" 2>&1
tail -f "${PATH_LOG}" >&3 &
PID_TAIL_LOG=${!}

cd "${DIR_CWD}"

result=1
kiosk_username="kiosk"
resetInit=0
installDisplay=0
vncPwd=""
doReboot=0

while [ 0 -lt ${#} ]
do
	cmd=${1}
	shift
	case ${cmd} in
		--reset)
			resetInit=1
			;;
		--install)
			installDisplay=1
			;;
		--set-vnc-password)
			vncPwd="${1}"
			shift
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
	userdel -rf ${kiosk_username}
	systemctl stop kiosk
	systemctl disable kiosk
	rm /etc/systemd/system/kiosk.service
	#apt-get remove -y supervisor x11vnc psmisc xdotool unclutter i3 chromium-browser openvpn 
	#apt-get -y autoremove
fi

if [ 1 -eq ${installDisplay} ]
then
	echo "Updating and installing packages..."
	apt-get update
	apt-get upgrade -y
	apt-get install -y xserver-xorg x11-xserver-utils xinit i3 x11vnc psmisc xdotool unclutter login iptables-persistent
	apt-get install -y chromium-browser
	apt-get install -y chromium
	apt-get autoremove -y

	systemctl stop wpa_supplicant
	systemctl disable wpa_supplicant
	systemctl stop bluetooth
	systemctl disable bluetooth
	systemctl stop hciuart.service
	systemctl disable hciuart.service
	systemctl stop bluealsa.service
	systemctl disable bluealsa.service

	useradd -m -s /bin/bash ${kiosk_username}
	passwd -l ${kiosk_username}
	dir_home_kiosk=$(grep -e "^${kiosk_username}:.*" /etc/passwd|cut -d: -f6)
	if [ ! -d "${dir_home_kiosk}" ]
	then
		echo "Failed to find home dir of [${kiosk_username}]"
		result=1
	else
		cd "${dir_home_kiosk}"
		if [ ! -z "${vncPwd}" ]
		then
			x11vnc -storepasswd "${vncPwd}" .vnc_passwd
		fi
		mkdir -p cache
		mkdir -p .config/i3
		wget -O .config/i3/config ${URL_TTYMGR}/kiosk/i3_config
		wget -O .xinitrc ${URL_TTYMGR}/kiosk/xinitrc
		wget -O start_browsers.sh ${URL_TTYMGR}/kiosk/start_browsers.sh
		wget -O start_kiosk.sh ${URL_TTYMGR}/kiosk/start_kiosk.sh
		wget -O action.sh ${URL_TTYMGR}/kiosk/action.sh
		wget -O service.sh ${URL_TTYMGR}/kiosk/service.sh
		wget -O /etc/systemd/system/kiosk.service ${URL_TTYMGR}/kiosk/kiosk.service
		find . -exec chown ${kiosk_username}: {} \;
		chmod u+x .xinitrc start_browsers.sh start_kiosk.sh service.sh action.sh
		sed '/allowed_users/d' -i /etc/X11/Xwrapper.config
		echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config
		sed '/needs_root_rights/d' -i /etc/X11/Xwrapper.config
		echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config
		systemctl daemon-reload
		systemctl enable kiosk.service
		systemctl start kiosk.service

		mkdir -p ${dir_home_kiosk}/.ssh
		wget -O ${dir_home_kiosk}/.ssh/authorized_keys ${URL_TTYMGR}/kiosk/ttymgr_kiosk.pub
		chown -R ${kiosk_username}: ${dir_home_kiosk}/.ssh
		chmod -R go-rwx ${dir_home_kiosk}/.ssh

		result=0
	fi

	is_rpi=$(grep -ci raspberry /proc/cpuinfo)
	if [ 0 -lt "${is_rpi}" ]
	then
		cp /boot/config.txt /boot/config.txt.$(date +%Y%m%d-%H%M%S)
		wget -O /boot/config.txt ${URL_TTYMGR}/kiosk/rpi/config.txt
		doReboot=1
	fi
fi

if [ 1 -eq "${doReboot}" ]
then
	(/usr/bin/sleep 6 && reboot) 1>/dev/null 2>&1 &
fi

echo ""
sleep 1
kill "${PID_TAIL_LOG}"
exit ${result}

