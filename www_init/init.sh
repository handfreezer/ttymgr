#!/bin/bash

export URL_BASE_TTYMGR="https://[URL]/ttymgr"

if [ 0 -ne "$(id -u)" ]
then
	echo "Init should be done as root, stopping. [current id = $(id -u)]"
	exit 1
fi

doReset=0
doInstall=0
doSplash=0
new_hostname=""

if [ 0 -eq "${#}" ]
then
	echo "Usage : ${0} [--reset] [--install] [--setHostname new_hostanme] [--splash]"
	exit 1
fi

while [ 0 -lt ${#} ]
do
	cmd=${1}
	shift
	case ${cmd} in
		--reset)
			doReset=1
			;;
		--install)
			doInstall=1
			;;
		--setHostname)
			new_hostname=${1}
			shift
			;;
		--splash)
			doSplash=1
			;;
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



if [ 1 -eq "${doReset}" ]
then
	rm /etc/iptables/rules.v6
	rm /etc/iptables/rules.v4
	rm /root/.ssh/authorized_keys
	apt-get remove -y openvpn
	systemctl enable getty@tty1.service
	systemctl disable openvpn-client@ttyToRecord
	service netfilter-persistent flush
	service netfilter-persistent save
fi

if [ 1 -eq "${doInstall}" ]
then
	echo "Patching sources.list"
	PATH_SL="/etc/apt/sources.list"
	cp "${PATH_SL}" "${PATH_SL}.${DATE}"
	sed -e 's/^[[:space:]]*deb cdrom/#deb cdrom/g' -i "${PATH_SL}"

	echo "Updating and installing packages..."
	apt-get update
	apt-get upgrade -y
	apt-get install -y vim gpm net-tools psmisc wget iptables-persistent
	apt-get install -y --no-install-recommends openvpn
	apt-get install -y chrony
	apt-get autoremove -y

	systemctl stop systemd-timesyncd.service
	systemctl disable systemd-timesyncd.service
	wget -O /etc/chrony/chrony.conf ${URL_BASE_TTYMGR}/init/chrony.conf
	ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
	systemctl enable chrony
	systemctl restart chrony

	wget -O /etc/openvpn/client/ttyToRecord.conf ${URL_BASE_TTYMGR}/init/ttyToRecord.ovpn

	mkdir -p /root/.ssh
	wget -O /root/.ssh/authorized_keys ${URL_BASE_TTYMGR}/init/ttymgr_key.pub
	chown -R root: /root/.ssh
	chmod -R go-rwx /root/.ssh

	wget -O /etc/iptables/rules.v6 ${URL_BASE_TTYMGR}/init/rules.v6
	wget -O /etc/iptables/rules.v4 ${URL_BASE_TTYMGR}/init/rules.v4

	systemctl enable openvpn-client@ttyToRecord
	systemctl restart openvpn-client@ttyToRecord
	systemctl restart netfilter-persistent

	systemctl enable ssh && systemctl start ssh
	systemctl disable getty@tty1.service
fi

if [ 1 -eq "${doSplash}" ]
then
	apt-get update
	apt-get install --no-install-recommends figlet toilet toilet-fonts
	for font in big graceful ghost smkeyboard letters morse standard
	do
		wget -O /usr/share/figlet/${font}.flf ${URL_BASE_TTYMGR}/init/figlet_fonts/${font}.flf
	done
	wget -O /root/splash_tty1.sh ${URL_BASE_TTYMGR}/init/splash_tty1.sh
	chmod u+x /root/splash_tty1.sh
	wget -O /etc/systemd/system/splash_tty1.service ${URL_BASE_TTYMGR}/init/splash_tty1.service
	systemctl daemon-reload
	systemctl enable splash_tty1.service
	systemctl stop splash_tty1.service
	systemctl start splash_tty1.service
fi

if [ ! "" = "${new_hostname}" ]
then
	hostname=$(hostname -s)
	echo "Changing hostname from [${hostname}] to [${new_hostname}]"
	#for fic in $(grep -rli ${hostname} /etc/)
	for fic in /etc/hosts /etc/hostname
	do
		echo "Updating hostname in [${fic}]"
		sed -e "s/${hostname}/${new_hostname}/g" -i ${fic}
	done
fi

kill "${PID_TAIL_LOG}"

