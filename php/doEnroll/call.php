<?php

# /KioskAndMgr/tools_enroll/doEnroll.sh

$ip_current=$_GET['ip_current'];
$ip_cible=$_GET['ip_cible'];
$cn_name=$_GET['cn_name'];
$action="enroll";

if ( ( 0 == strcmp($ip_current, "") )
	or ( 0 == strcmp($ip_cible, "") )
	or ( 0 == strcmp($cn_name, "") ) ) {
	echo "Bad form";
} else {
	exec ("sudo /KioskAndMgr/tools_".$action."/doCall.sh $ip_current $cn_name $ip_cible >>/tmp/do_".$action."_call_php.log 2>&1 &");
	sleep(5);
	header('Location: /ttymgr/service.php');
}

?>
