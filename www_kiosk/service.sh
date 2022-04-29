#!/bin/bash

#very sad service file, to be tuned!

output="/dev/tty1"
if [ ${#} -ne 1 ]
then
	echo "Missong command start or stop"
	exit 1
fi

case ${1} in
	start)
		nb_print=3
		for i in $(seq ${nb_print} 1)
		do
			echo "Turn ${i}" >> ${output}
			echo "Hostname : $(hostname -s)" >> ${output}
			ip ad >> ${output}
			sleep 5
		done
		~/start_kiosk.sh
		;;
	stop)
		killall i3
		;;
	*)
		echo "Unknown command [${1}]"
		exit 1
		;;
esac

exit 0

