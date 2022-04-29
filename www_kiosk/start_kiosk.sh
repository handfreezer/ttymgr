#!/bin/bash

display=2

startx -- :${display} -nolisten tcp 1>/tmp/kiosk_startx.log 2>&1 &

#sleep 3
#x11vnc -noipv6 -nolookup -forever -noncache -display :${display} -rfbport 5900 -clip xinerama0 1>/root/x11vnc_5900.log 2>&1 &
#x11vnc -noipv6 -nolookup -forever -noncache -display :${display} -rfbport 5901 -clip xinerama1 1>/root/x11vnc_5901.log 2>&1 &
#sleep 3
#echo "everything started"
#tail -f /root/startx.log /root/x11vnc_*.log &

