#!/bin/bash

FONT_LIST=( "big" "graceful" "ghost" "smkeyboard" "letters" "morse" "standard" )
FONT_LIST_SIZE=${#FONT_LIST[@]}
SLEEP_TIMEOUT=120

printf "\033c"
printf "\e[1;36m"
figlet -f smkeyboard -c <<<"Starting..."
tput civis
sleep 15

iFont=0
while true
do
	width=$(tput cols)
	font="${FONT_LIST[${iFont}]}"
	(( iFont = (iFont + 1)%FONT_LIST_SIZE ))
	printf "\033c"
	printf "\e[1;36m"
	figlet -w ${width} -f ${font} -c <<<"Hostname: $(hostname -s)"
	printf "\e[1;34m"
	toilet -w ${width} -f ${font} --filter border <<<"Serial: $(ip link|grep link/ether|head -n1|awk '{print $2;}'|tr 'a-z' 'A-Z')"
	tput civis
	printf "\e[0m"
	printf "\nIP list : $(hostname -I)\n\n"

	curl 'http://wttr.in/Paris?m3FA' --silent --connect-timeout 5
	sleep ${SLEEP_TIMEOUT}
done
