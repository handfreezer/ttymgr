<?php
require_once('/www_ttyMgr/_config.php');

$cn=$_GET['cn'];
$action=$_GET['action'];

switch ($action) {
case "delete_tty":
	if ( 0 == strcmp($cn, '127.0.0.1') ) {
		echo "This tty can't be clean >:-(";
	} else {
		$q = $pdo->prepare("select ifnull(value,0) from enrolled_params where cn=? and param=?");
		$q->execute(array($cn, 'guacamole.ssh.id'));
		$result = $q->fetchColumn();
		if ( 0 != strcmp($result, "") ) {
			$q = $pdo->prepare("delete from guacamole_db.guacamole_connection where connection_id = ?");
			$q->execute(array($result));
		}
		$q = $pdo->prepare("delete from enrolled_params where cn=?");
		$q->execute(array($cn));
		$q = $pdo->prepare("delete from enrolled where cn=?");
		$q->execute(array($cn));
		echo "Cleaning of ".$cn." done (TODO : form to confirm)";
	}
	break;
case "kiosk":
case "filer":
case "snmpd":
case "snmpd-wifiscan":
case "snmpd-tempscan":
case "rpi-argononed":
case "fusioninventory":
	if ( 0 == strcmp($cn, "") ) {
	        echo "Bad call (no CN)";
	} else {
		$dir_tools = $action;
		$docall = "doCall.sh";
		switch ($action) {
		case "snmpd-wifiscan":
			$dir_tools = "snmpd";
			$docall="doCallWifiScan.sh";
			break;
		case "snmpd-tempscan":
			$dir_tools = "snmpd";
			$docall="doCallTempScan.sh";
			break;
		case "rpi-argononed":
			$dir_tools = "rpi";
			$docall="doCallArgonOneDaemon.sh";
		default:
			break;
		}
	        exec ("sudo /KioskAndMgr/tools_".$dir_tools."/$docall $cn >>/tmp/do_".$action."_call_php.log 2>&1 &");
	        echo "Action [".$action."] launch on [".$cn."]";
	}
	break;
case "reboot":
case "poweroff":
	exec ("sudo /KioskAndMgr/tools_service/doCall.sh $action $cn >>/tmp/do_".$action."_call_php.log 2>&1 &");
	echo "Action [".$action."] launch on [".$cn."]";
	break;
case "vpn_access_enable":
case "vpn_access_disable":
	$vpn_enabled = (0 == strcmp("vpn_access_enable", $action))?1:0;
	$q = $pdo->prepare("update enrolled_params set value = $vpn_enabled where cn=? and param='vpn.enabled'");
	$q->execute(array($cn));
	if ( 1 != $vpn_enabled ) {
		echo "Changing VPN access of [$cn] to $vpn_enabled\n";
		$sock = stream_socket_client('tcp://127.0.01:65500', $errno, $errstr);
		fwrite($sock, "$ovpn_pwd_mgt\r\nkill $cn\r\n");
		echo fread($sock, 4096)."\n";
		fclose($sock);
	}
	break;
case "getLogs":
	$q = $pdo->prepare("select cn,dttime,step,detail from enrolled_cnx_history where cn like ? order by dttime desc");
	if ( 0 == strcmp('', $cn) ) $cn = '%%';
	$q->execute(array($cn));
	$result = $q->fetchAll(PDO::FETCH_ASSOC);
	echo json_encode($result);
	break;
default:
	echo "Action [".$action."] unknown.";
	break;
}

?>
