#!/usr/bin/python
# Borrowed from https://gist.github.com/wolfg1969/4653340 gps_demo.py
import getopt
import os, time
import sys
from gps import *
from pprint import pprint

(options, arguments) = getopt.getopt(sys.argv[1:], "v")
streaming = False
verbose = False
for (switch, val) in options:
    if switch == '-v':
        verbose = True
if len(arguments) > 2:
    print('Usage: gps.py [-v] [host [port]]')
    sys.exit(1)

opts = {"verbose": verbose}
if len(arguments) > 0:
    opts["host"] = arguments[0]
if len(arguments) > 1:
    opts["port"] = arguments[1]

session = gps(**opts)
#session = gps()

session.stream(WATCH_ENABLE|WATCH_NEWSTYLE)
try:
  while 1:
    print 'clear'
    os.system('clear')
    session.next()
    # a = altitude, d = date/time, m=mode,  
    # o=postion/fix, s=status, y=satellites
    if session.data.get("class") == 'DEVICE':
       # Clean up our current connection.
       session.close()
       # Tell gpsd we're ready to receive messages.
       session = gps(mode=WATCH_ENABLE)
    if session.data.get("class") == 'TPV_no':
        print
        print 'fix         ' , session.fix.mode
        print 'longitude   ' , session.fix.longitude
        print 'latitude    ' , session.fix.latitude
        print 'time utc    ' , session.utc
        print 'altitude    ' , session.fix.altitude
        print 'epv         ' , session.fix.epv
        print 'ept         ' , session.fix.ept
        print 'speed       ' , session.fix.speed
        print 'climb       ' , session.fix.climb
        print
        print ' Satellites (total of', len(session.satellites) , ' in view)'
        for i in session.satellites:
            print '\t', i
            print i['PRN']
        pprint(session.satellites)
    if session.data.get("class") == 'SKY':
        #print ' Satellites (total of', len(session.satellites) , ' in view)'
        sats=''
        for i in session.satellites:
            # print '\t', i
            if i.used :
                sats += str(i.PRN) + ',' + str(i.ss) + ';'
        print sats
        f = open("/tmp/satellites.dump", "w")
        f.write(sats[:-1])
        f.close()
        #pprint(session.satellites)

        time.sleep(3)
except KeyboardInterrupt:
  exit
