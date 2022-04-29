#!/usr/bin/python3

import time
import datetime
import sys
import json
import mariadb
from easysnmp import Session
from influxdb import InfluxDBClient

snmpdWifiScanFrequency = 5

def stupidMonitOfMem(session):
    print('MonitOfMem')
    cpupoints={
            "tags": {
                "domain": "OS",
                "sujet": "MEM",
                "type": "memory"
                },
            "fields" : {}
            }
    cpuloads = session.walk('iso.3.6.1.4.1.2021.4')
    for oid in cpuloads:
        sujet = ''
        if ( oid.oid == 'iso.3.6.1.4.1.2021.4.3.0' ) :
            sujet="swap_total"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.4.4.0' ) :
            sujet="swap_available"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.4.5.0' ) :
            sujet="ram_total"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.4.6.0' ) :
            sujet="ram_used"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.4.11.0' ) :
            sujet="ram_free"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.4.13.0' ) :
            sujet="ram_shared"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.4.14.0' ) :
            sujet="ram_buffered"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.4.15.0' ) :
            sujet="cached_memory"
        if ( '' != sujet ) :
            cpupoints['fields'][sujet] = float(oid.value)
    return [cpupoints]

def stupidMonitOfCpu(session):
    print('MonitOfCpu')
    cpupoints={
            "tags": {
                "domain": "OS",
                "sujet": "CPU",
                "type": "load_average"
                },
            "fields" : {}
            }
    cpuloads = session.walk('iso.3.6.1.4.1.2021.10.1.3')
    for oid in cpuloads:
        if ( oid.oid == 'iso.3.6.1.4.1.2021.10.1.3.1' ) :
            sujet="Load01"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.10.1.3.2' ) :
            sujet="Load05"
        elif ( oid.oid == 'iso.3.6.1.4.1.2021.10.1.3.3' ) :
            sujet="Load15"
        cpupoints['fields'][sujet] = float(oid.value)
    return [cpupoints]

def stupidMonitOfUptime(session):
    print('MonitOfUptime')
    uptimepoint={
            "tags": {
                "domain": "OS",
                "sujet": "Uptime",
                "type": "uptime"
            },
            "fields" : {}
            }
    uptime = session.get('iso.3.6.1.2.1.25.1.1.0')
    uptimepoint['fields']['uptime'] = int(int(uptime.value)/100)
    return [uptimepoint]

def stupidMonitOfGpsSatellites(session):
    print('MonitOfGpsSatellite')
    sats = session.get('iso.3.6.1.4.1.12345.1.1.1.0')
    dicsat = []
    #print(sats)
    if ( sats.snmp_type != 'NOSUCHOBJECT' ) :
        for sat in sats.value.split(';') :
            #print (sat)
            dsat = sat.split(',')
            uptimepoint={
                    "tags": {
                        "domain": "GPS",
                        "sujet": "Satellite",
                        "type": "signalStrength",
                        "satellite" : int(dsat[0])
                    },
                    "fields" : {
                        "signalStrength" : int(dsat[1])
                        }
                    }
            #print(uptimepoint)
            dicsat.append(uptimepoint)
    #print(dicsat)
    return dicsat

def stupidMonitOfWifi(session):
    dicsat = []
    if ( (0 == snmpdWifiScanFrequency) or (0 == (datetime.datetime.now().minute)%(snmpdWifiScanFrequency)) ) :
        print('MonitOfWifi')
        sats = session.get('iso.3.6.1.4.1.12345.1.2.1.0')
        #print(sats)
        if ( sats.snmp_type != 'NOSUCHOBJECT' ) :
            for sat in sats.value.split(';') :
                #print (sat)
                dsat = sat.split(',')
                if ( 7 == len(dsat) ) :
                    uptimepoint={
                            "tags": {
                                "domain": "WIFI",
                                "sujet": "List",
                                "type": "scan",
                                "ap_ssid" : dsat[0],
                                "ap_mac" : dsat[1],
                                "ap_mode" : dsat[2],
                                "ap_channel" : int(dsat[3]),
                                "ap_signal" : int(dsat[4]),
                                "ap_quality" : int(dsat[5]),
                                "ap_encrypted" : bool(dsat[6])
                            },
                            "fields" : {
                                "ap_ssid" : dsat[0],
                                "ap_mac" : dsat[1],
                                "ap_channel" : int(dsat[3]),
                                "ap_signal" : int(dsat[4]),
                                "ap_quality" : int(dsat[5]),
                                "ap_encrypted" : bool(dsat[6])
                            }
                    }
                    print(uptimepoint)
                    dicsat.append(uptimepoint)
    #print(dicsat)
    return dicsat

def stupidMonitOfTemp(session):
    dictemp = []
    #print('MonitOfTemp')
    temps = session.get('iso.3.6.1.4.1.12345.1.3.1.0')
    #print(temps)
    if ( temps.snmp_type != 'NOSUCHOBJECT' ) :
        for temp in temps.value.split(';') :
            #print (temp)
            tempkv = temp.split('=')
            if ( 2 == len(tempkv) ) :
                uptimepoint={
                        "tags": {
                            "domain": "OS",
                            "sujet": "Temp",
                            "type": tempkv[0]
                            },
                        "fields" : {
                            "temperature" : float(tempkv[1])
                        }
                }
                #print(uptimepoint)
                dictemp.append(uptimepoint)
    #print(dictemp)
    return dictemp

def stupidMonitOf(ip, community):
    session = Session(hostname=ip,
            community=community,
            version=2,
            timeout=2,
            retries=1)
    dic = []
    dic.extend(stupidMonitOfCpu(session=session))
    dic.extend(stupidMonitOfMem(session=session))
    dic.extend(stupidMonitOfUptime(session=session))
    dic.extend(stupidMonitOfGpsSatellites(session=session))
    dic.extend(stupidMonitOfWifi(session=session))
    dic.extend(stupidMonitOfTemp(session=session))
    #print(dic)
    return dic

with open('/KioskAndMgr/tools_snmpd/config.json') as config_file:
    config = json.load(config_file)

snmpdWifiScanFrequency = config["snmpd"]["wifi"]["scan"]["frequency"]

print("Connect to MariaDB")
try:
        dbcnx = mariadb.connect(
                user=config['db']['user'],
                password=config['db']['password'],
                host=config['db']['host'],
                port=config['db']['port'],
                database=config['db']['database']
                )
except mariadb.error as e:
    print(f"Error connection to MariaDB {e}")
    sys.exit(1)
dbcursor = dbcnx.cursor()

client = InfluxDBClient(
        host=config['influxdb']['host'],
        port=config['influxdb']['port'],
        username=config['influxdb']['username'],
        password=config['influxdb']['password'],
        database=config['influxdb']['database'])
print("Get enrolled tty list")
dbcursor.execute("select cn,ip,serial from enrolled order by cn")
for (cn, ip, serial) in dbcursor:
    print(f"tty: {cn}|{ip}|{serial}")
    try:
        dic=stupidMonitOf(ip=ip, community=config['snmpd']['co'])
    except Exception as e:
        print(f"Failed to do stupidMonitoring of {cn}|{ip}")
        print(f"{e}")
        pass
    else:
        for el in dic:
            el["measurement"] = "stupidMonitoring"
            el["time"]=int(time.time())
            el["tags"]["cn"]=cn
            el["tags"]["cn_short"] = cn.split('.',1)[0]
            el["tags"]["ip"]=ip
            el["tags"]["serial"]=serial
        #print(dic)
        client.write_points(dic,time_precision='s',protocol='json')
localip='127.0.0.1'
print(f"tty: {localip}|{localip}|NA")
dic=stupidMonitOf(ip=localip, community=config['snmpd']['co'])
#print(dic)
for el in dic:
    el["measurement"] = "stupidMonitoring"
    el["time"] = int(time.time())
    el["tags"]["cn"] = localip
    el["tags"]["cn_short"] = localip
    el["tags"]["ip"] = localip
    el["tags"]["serial"] = serial
#print(dic)
client.write_points(dic,time_precision='s',protocol='json')

dbcnx.close()
sys.exit(0)
