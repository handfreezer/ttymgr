#!/bin/bash

FILE_LOG="/tmp/start_browsers.log"

date +%Y%m%d-%H%M%S >> ${FILE_LOG}
echo "Starting [${*}]" >> ${FILE_LOG}

kiosk_idx=0
kiosk_force_conf=0
kiosk_force_clear_cache=1
kiosk_force_clear_data=1

if [ 1 -le "${#}" ]
then
	kiosk_idx=${1}
fi
if [ 3 -le "${#}" ]
then
	kiosk_force_conf=1
	kiosk_force_clear_cache=${2}
	kiosk_force_clear_data=${3}
	echo "Forced conf [cc=${kiosk_force_clear_cache}|cd=${kiosk_force_clear_data}]" >> ${FILE_LOG}
fi

for pid in $(ps faux | grep "kiosk-${kiosk_idx}" | grep -v grep | awk '{print $2}')
do
	kill -9 ${pid}
done

export DISPLAY=$(ps aux|sed -e '/^.*Xorg[[:space:]]*:[[:digit:]]* .*$/!d' -e 's/.* :\([[:digit:]]*\) .*/:\1/g')

max_nb_display=$(xrandr|grep -c "\-${kiosk_idx} connected ")
if [ 1 -ne "${max_nb_display}" ]
then
	echo "Incorrect display nb count [max=${max_nb_display} and kiosk_idx=${kiosk_idx}]"
	exit 0
fi

case ${kiosk_idx} in
	1)
		kiosk_url="https://[default_url_1]/"
		;;
	2)
		kiosk_url="https://[default_url_2]"
		;;
	*)
		kiosk_url="https://www.ulukai.net"
		;;
esac
kiosk_incognito=1
kiosk_clear_cache=1
kiosk_clear_data=1
kiosk_classname="kiosk-${kiosk_idx}"

DIR_HOME=${HOME}
FILE_DISPLAY_CONF="${DIR_HOME}/display_${kiosk_idx}.conf"
if [ -e "${FILE_DISPLAY_CONF}" ]
then
	. "${FILE_DISPLAY_CONF}"
fi

if [ 1 -eq ${kiosk_force_conf} ]
then
	kiosk_clear_cache=${kiosk_force_clear_cache}
	kiosk_clear_data=${kiosk_force_clear_data}
fi

datadir="${DIR_HOME}/data/b${kiosk_idx}"
cachedir="${DIR_HOME}/cache/b${kiosk_idx}"
OPTS_CHROME="\
--new-window ${kiosk_url} \
--class=${kiosk_classname} \
--disk-cache-dir=${cachedir} \
--user-data-dir=${datadir} \
--no-sandbox \
--kiosk \
--start-fullscreen \
--noerrdialogs \
--no-first-run \
--no-default-browser-check \
--disable-infobars \
--disable-java \
--disable-translate \
--disable-features=TranslateUI \
--disable-restore-session-state \
--disable-save-password-bubble \
--disable-suggestions-service \
--fast --fast-start \
--password-store=basic \
"
if [ -e "/usr/bin/chromium-browser" ]
then
	BIN_CHROME="/usr/bin/chromium-browser"
else
	BIN_CHROME="/usr/bin/chromium"
fi

if [ 0 -ne ${kiosk_incognito} ]
then
	echo "Mode incognito" >> ${FILE_LOG}
	OPTS_CHROME="${OPTS_CHROME} \
--incognito \
"
fi

if [ 0 -ne ${kiosk_clear_cache} ]
then
	echo "Cleaning cache dir" >> ${FILE_LOG}
	rm -rf "${cachedir}"
fi
if [ ! -d "${cachedir}" ]
then
	mkdir -p "${cachedir}"
fi

if [ 0 -ne ${kiosk_clear_data} ]
then
	echo "Cleaning data dir" >> ${FILE_LOG}
	rm -rf "${datadir}"
fi
if [ ! -d "${datadir}" ]
then
	mkdir -p "${datadir}"
fi

target="${BIN_CHROME} \
${OPTS_CHROME}"
echo "$target" >> ${FILE_LOG}

# start app for left screen
#i3-msg 'workspace 1'
$target &

# hide mouse pointer
killall unclutter
unclutter -root -idle 1 &

