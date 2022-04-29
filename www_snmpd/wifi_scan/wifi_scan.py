#!/usr/bin/python

from wifi import Cell, Scheme
import os

os.system('/usr/sbin/rfkill unblock wlan')
os.system('[ -e /usr/sbin/ifconfig/ ] && /usr/sbin/ifconfig wlan0 up')
os.system('[ -e /sbin/ifconfig/ ] && /sbin/ifconfig wlan0 up')
os.system('[ -e /usr/sbin/ip ] && /usr/sbin/ip link set wlan0 up')

res_scan=''
for cell in Cell.all('wlan0'):
    res_scan += ','.join((cell.ssid,cell.address,cell.mode,str(cell.channel),str(cell.signal),str(cell.quality).split('/')[0],str(cell.encrypted))) + ';'

print res_scan
