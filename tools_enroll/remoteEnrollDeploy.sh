#!/bin/bash
set -x

URL_TTYMGR="https://[URL]/ttymgr"

if [ 0 -ne "$(id -u)" ]
then
	echo "Init should be done as root, stopping. [current id = $(id -u)]"
	exit 1
fi

new_hostname=""

while [ 0 -lt ${#} ]
do
	cmd=${1}
	shift
	case ${cmd} in
		--setHostname)
			new_hostname=${1}
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

if [ -z "${new_hostname}" ]
then
	new_hostname="$(basename $(ls -1 /root/*.ovpn|head -n1) .ovpn)"
fi

PATH_OVPN="/root/${new_hostname}.ovpn"
if [ ! -e "${PATH_OVPN}" ]
then
	echo "No ovpn file [${PATH_OVPN}]"
	exit 1
fi


echo "Updating and installing packages..."
apt-get update
apt-get upgrade -y
apt-get install -y wget iptables-persistent
apt-get install -y --no-install-recommends openvpn
apt-get autoremove -y

cp "${PATH_OVPN}" /etc/openvpn/client/${new_hostname}.conf
systemctl start openvpn-client@${new_hostname}
systemctl enable openvpn-client@${new_hostname}
res_ovpn=${?}
if [ 0 -ne "${res_ovpn}" ]
then
	echo "Failed to start OpenVPN for enrolled console"
	exit 1
fi

wget -O /root/.ssh/authorized_keys ${URL_TTYMGR}/enroll/ttymgr_key.pub
wget -O /etc/iptables/rules.v4 ${URL_TTYMGR}/enroll/rules.v4
wget -O /etc/iptables/rules.v6 ${URL_TTYMGR}/enroll/rules.v6
systemctl restart netfilter-persistent
systemctl disable getty@tty1.service

hostname=$(hostname -s)
echo "Changing hostname from [${hostname}] to [${new_hostname}]"
#for fic in $(grep -rli ${hostname} /etc/)
for fic in /etc/hosts /etc/hostname
do
	echo "Updating hostname in [${fic}]"
	sed -e "s/${hostname}/${new_hostname}/g" -i ${fic}
done

kill "${PID_TAIL_LOG}"
exit 0



