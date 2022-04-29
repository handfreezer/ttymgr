#!/bin/sh -f

echo $(date) >> /tmp/test_snmp.log
echo ${*} >> /tmp/test_snmp.log

PLACE=".1.3.6.1.4.1.12345.1.1"
CMD="$1"
REQ="$2"    # Requested OID

#
#  Process SET requests by simply logging the assigned value
#      Note that such "assignments" are not persistent,
#      nor is the syntax or requested value validated
#
if [ "$CMD" = "-s" ]; then
  echo $* > /tmp/test_snmp.log
  exit 0
fi

#
#  GETNEXT requests - determine next valid instance
#
if [ "$CMD" = "-n" ]; then
  case "$REQ" in
    $PLACE|             \
    $PLACE.0|           \
    $PLACE.0.*|         \
    $PLACE.1)       RET=$PLACE.1.0 ;;     # netSnmpPassString.0
    *)              exit 0 ;;
  esac
else
#
#  GET requests - check for valid instance
#
  case "$REQ" in
    $PLACE.1.0|         \
    $PLACE.6.0)     RET=$REQ ;;
    *)              exit 0 ;;
  esac
fi

#
#  "Process" GET* requests - return hard-coded value
#
echo "$RET"
case "$RET" in
  $PLACE.1.0)     echo "string";    cat /tmp/satellites.dump; exit 0 ;;
  $PLACE.2.1.2.1) echo "integer";   echo "42";                                 exit 0 ;;
  $PLACE.2.1.3.1) echo "objectid";  echo "$PLACE.99";                          exit 0 ;;
  $PLACE.3.0)     echo "timeticks"; echo "363136200";                          exit 0 ;;
  $PLACE.4.0)     echo "ipaddress"; echo "127.0.0.1";                          exit 0 ;;
  $PLACE.5.0)     echo "counter";   echo "42";                                 exit 0 ;;
  $PLACE.6.0)     echo "gauge";     echo "42";                                 exit 0 ;;
  *)              echo "string";    echo "ack... $RET $REQ";                   exit 0 ;;  # Should not happen
esac

