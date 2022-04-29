#!/bin/bash

if [ 2 -gt "${#}" ]
then
	echo "Missing params"
	echo "Usage : ${0} [action] [display index]"
	exit 1
fi

export DISPLAY=$(ps aux|sed -e '/^.*Xorg[[:space:]]*:[[:digit:]]* .*$/!d' -e 's/.* :\([[:digit:]]*\) .*/:\1/g')
action=${1}
idx=${2}

case ${action} in
	refresh)
		for wid in $(xdotool search --onlyvisible --class kiosk-$idx)
		do
			xdotool windowfocus $wid
			xdotool key 'F5'
		done
		;;
	restart)
		if [ 2 -eq "${#}" ]
		then
			~/start_browsers.sh $idx
		else
			kiosk_cc=${4}
			kiosk_cd=${5}
			~/start_browsers.sh $idx ${kiosk_cc} ${kiosk_cd}
		fi
		;;
	setUrl)
		kiosk_url=${3}
		kiosk_cc=${4}
		kiosk_cd=${5}
		kiosk_incognito=${6}
		echo "export kiosk_url='${kiosk_url}'" > ~/display_${idx}.conf
		echo "export kiosk_incognito='${kiosk_incognito}'" >> ~/display_${idx}.conf
		echo "export kiosk_clear_cache='${kiosk_cc}'" >> ~/display_${idx}.conf
		echo "export kiosk_clear_data='${kiosk_cd}'" >> ~/display_${idx}.conf
		${0} restart ${idx}
		;;
	*)
		echo "Unknown action [${action}]"
		exit 1
		;;
esac

exit 0

