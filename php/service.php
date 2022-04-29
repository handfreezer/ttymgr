<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<!--meta http-equiv="refresh" content="60;"-->

<head>

<link href="service/tabulator/dist/css/tabulator.min.css" rel="stylesheet">
<script type="text/javascript" src="service/tabulator/dist/js/tabulator.min.js"></script>

<link rel="stylesheet" type="text/css" href="service/style.css"/>

</head>

<body>
<?php include('service/javascript.js'); ?>
<?php include('menu.html'); ?>

<?php include('service/form_logs.html'); ?>
<?php include('service/form_actions.html'); ?>
<?php include('service/form_kiosk.html'); ?>
<?php include('service/form_monitoring.html'); ?>
<?php include('service/form_inventory.html'); ?>

<?php
require_once('/www_ttyMgr/_config.php');

function genGuacamoleLink($profil) {
	$hlink="guacamole/#/client/";
	return $hlink.base64_encode($profil."\0c\0mysql");
}

function isConnected($pdo, $cn_name) {
	$result = 0;
	if ( 0 == strcmp("127.0.0.1", $cn_name) )
		$result = 1;
	else {
		$q = $pdo->prepare("select count(cn) from ovpn_status where cn=?");
		$q->execute(array($cn_name));
		$result = $q->fetchColumn();
	}
	return $result;
}


function getEnrolledParam($pdo, $cn_name, $param_key) {
    $q = $pdo->prepare("select ifnull(value,0) from enrolled_params where cn=? and param=?");
    $q->execute(array($cn_name, $param_key));
    $result = $q->fetchColumn();
    $result = ( 0 == strcmp($result, "") )?"0":$result;
    return $result;
}

function setEnrolledTableLine($pdo, $cn, $ip, $serial) {
	$tab_line = "";
	$line_color = "style='background-color:#FF0000;'";
	if ( 1 == isConnected($pdo, $cn) )
		$line_color = "style='background-color:#00FF00;'";
	$txt_vpn_style="disabled";
	if (1 == getEnrolledParam($pdo, $cn, "vpn.enabled"))
		$txt_vpn_style="enabled";
	$ssh_id = getEnrolledParam($pdo, $cn, "guacamole.ssh.id");
	$snmpd_installed = getEnrolledParam($pdo, $cn, 'service.snmpd.installed');
	$tab_line .= "<tr><td><button class=\"action-button open-button\" onclick=\"openLogs('{$cn}')\"><center><img src='icons/log.svg' alt='Log' width='32' height='32'/></center></button></td>";
	$tab_line .= "<td $line_color><button class=\"action-button open-button\" onclick=\"openActions('{$cn}',".getEnrolledParam($pdo,$cn,"vpn.enabled").",".$snmpd_installed.")\"><center>Actions</center></button></td>";
	$tab_line .= "<td class=\"txt-vpn-{$txt_vpn_style}\">{$cn}</td><td>{$ip}</td><td>{$serial}</td>";
	if ( 0 == $ssh_id )
		$tab_line .= "<td><center><img src='icons/not_installed.svg' alt='Not Installed' width='32' height='32'/></center></td>";
	else
		$tab_line .= "<td><a href='".genGuacamoleLink($ssh_id)."' target='_blank'><button class=\"icon-button\"><center><img src='icons/ssh.svg' alt='SSH' width='32' height='32'/></center></button></a></td>";
	$snmp_button_sat = ( 1 == getEnrolledParam($pdo, $cn, 'service.snmpd.gps') )?"<button class=\"icon-button\" onclick=\"openGraph('{$cn}',8)\"><center><img src='icons/satellite.svg' alt='Gps_Satellite' width='32' height='32'/><center></button>":"";
	$snmp_button_wifi_scan = ( 1 == getEnrolledParam($pdo, $cn, 'service.snmpd.wifi.scan') )?"<button class=\"icon-button\" onclick=\"openGraphMultiPanel('{$cn}',9,11)\"><center><img src='icons/wifi_scan.svg' alt='Wifi_Scan' width='32' height='32'/><center></button>":"";
	$tab_line .= ( 1 == $snmpd_installed )?
		"<td><button class=\"icon-button\" onclick=\"openGraph('{$cn}',12)\"><center><img src='icons/cpu.svg' alt='CPU' width='32' height='32'/></center></button>
		<button class=\"icon-button\" onclick=\"openGraph('{$cn}',4)\"><center><img src='icons/mem.svg' alt='MEM' width='32' height='32'/><center></button> ".$snmp_button_sat." ".$snmp_button_wifi_scan."</td>":"<td><center><img src='icons/not_installed.svg' alt='Not Installed' width='32' height='32'/></center></td>";
	if ( 1 == getEnrolledParam($pdo, $cn, 'service.kiosk.installed') ) {
		$u1 = getEnrolledParam($pdo, $cn, 'service.kiosk.url.1');
		$u2 = getEnrolledParam($pdo, $cn, 'service.kiosk.url.2');
		$vnc1 = getEnrolledParam($pdo, $cn, 'guacamole.vnc.01');
		$vnc2 = getEnrolledParam($pdo, $cn, 'guacamole.vnc.02');
		$slider1 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp1.slider');
		$slider2 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp2.slider');
		$incognito1 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp1.incognito');
		$incognito2 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp2.incognito');
		$cc1 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp1.clear.cache');
		$cc2 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp2.clear.cache');
		$cd1 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp1.clear.data');
		$cd2 = getEnrolledParam($pdo, $cn, 'service.kiosk.disp2.clear.data');
		$tab_line .= "<td><center><button class=\"icon-button\" onclick=\"openKiosk('{$cn}','{$u1}','{$u2}','".genGuacamoleLink($vnc1)."','".genGuacamoleLink($vnc2)."',{$slider1},{$incognito1},{$cc1},{$cd1},{$slider2},{$incognito2},{$cc2},{$cd2})\"><img src='icons/configuration.svg' alt='Kiosk' width='32' height='32'/></button></center></td>";
	} else {
		$tab_line .= "<td><center><img src='icons/not_installed.svg' alt='Not Installed' width='32' height='32'/></center></td>";
	}
	$tab_line .= ( 1 == getEnrolledParam($pdo, $cn, 'service.filer.installed') )?
		"<td><a href='filebrowser/launch.php?cn_name={$cn}' target='_blank'><button class=\"icon-button\"><img src='icons/filebrowser.svg' alt='File Brower' width='32' height='32'/></button></a></td>" : "<td><center><img src='icons/not_installed.svg' alt='Not Installed' width='32' height='32'/></center></td>";
	$tab_line .= ( 1 == getEnrolledParam($pdo, $cn, 'service.fusioninventory.installed') )?
		"<td><center><button class=\"icon-button\" onclick=\"openInventoryRequest('{$cn}')\"><img src='icons/start.svg' alt='Request inventory' width='32' height='32'/></button> <button class=\"icon-button\" onclick=\"openInventoryLast('{$cn}')\"><img src='icons/inventaire.svg' alt='Last inventory' width='32' height='32'/></button></center></td>" : "<td><center><img src='icons/not_installed.svg' alt='Not Installed' width='32' height='32'/></center></td>";
	$tab_line .= "</tr>";
	echo "$tab_line\n";
}
?>


<table border="1" align="center">
<tr>
  <td valign="middle"><b>Global:</b></td>
  <td colspan="9"><button class="action-button open-button" onclick='openLogs("")'><center><img src='icons/log.svg' alt='Log' width='32' height='32'/></center></button></td>
</tr>
<tr>
  <td>Logs</td>
  <td>Connected</td>
  <td>CN</td>
  <td>IP</td>
  <td>Serial</td>
  <td>SSH</td>
  <td>Monitoring</td>
  <td>Kiosk</td>
  <td>Filer</td>
  <td>Last Inventory</td>
</tr>

<?php
setEnrolledTableLine($pdo, '127.0.0.1', '127.0.0.1', '11:22:33:44:55:66');

$query = mysqli_query($dbconnect, "select e.cn as cn,e.ip as ip,e.serial as serial from enrolled e order by e.cn")
   or die (mysqli_error($dbconnect));

while ($row = mysqli_fetch_array($query)) {
	setEnrolledTableLine($pdo, $row['cn'], $row['ip'], $row['serial']);
}
?>
</table>
</body>
</html>

