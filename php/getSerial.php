<?php

$ip=$_GET['ip'];
exec("sudo /KioskAndMgr/tools_enroll/getSerial.sh torecord $ip");

?>
