<?php
require_once('/www_ttyMgr/_config.php');

$cn=$_GET['cn'];
$action=$_GET['action'];
$idx=$_GET['display'];
$url=$_GET['url'];
$slider =(0 == strcmp('true', $_GET['slider']))?1:0;
$incognito=(0 == strcmp('true', $_GET['incognito']))?1:0;
$clearCache=(0 == strcmp('true', $_GET['cc']))?1:0;
$clearData=(0 == strcmp('true', $_GET['cd']))?1:0;

exec ("sudo /KioskAndMgr/tools_kiosk/doCallAction.sh '$cn' '$action' '$idx' '$url' '$clearCache' '$clearData' '$incognito' '$slider' >>/tmp/do_kiosk_".$action."_call_php.log 2>&1 &");
echo "Action [".$action."] launch on [".$cn.":".$idx."] with url=[".$url."] Clear [cache=".$clearCache."|data=".$clearData."|incognito=".$incognito."|slider=".$slider."]";

?>
