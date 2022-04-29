<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<meta http-equiv="refresh" content="60;">

<head>
<link rel="stylesheet" type="text/css" href="doEnroll/form.css"/>
</head>

<body>

<?php include('menu.html'); ?>
<?php include('doEnroll/form.html'); ?>

<script type="text/javascript">
function callGetSerial(ip) {
	var req;
	alert(ip);
	req = new XMLHttpRequest();
	req.open('GET','/ttymgr/getSerial.php?ip='+ip, true);
	req.send(null);
}
</script>

<?php
require_once('/www_ttyMgr/_config.php');
?>

<table border="1" align="center">
<tr>
  <td>CN</td>
  <td>Serial Number</td>
  <td>Last Seen</td>
  <td>last IP</td>
  <td>Enroll</td>
</tr>

<?php

$query = mysqli_query($dbconnect, "SELECT cn,serial,last_seen,ip FROM ovpn_status order by cn")
   or die (mysqli_error($dbconnect));

while ($row = mysqli_fetch_array($query)) {
	if ( 0 == strcmp($row['cn'], "ttyToRecord.labs.ulukai.net") )
		$strButtonEnroll="<td><button class=\"open-button\" onclick=\"openDoEnroll('{$row['ip']}')\">Enroll</button></td>";
	else
		$strButtonEnroll="<td>Done</td>";
	if ( 0 != strcmp($row['serial'],"") ) {
		echo
			"<tr>
			<td>{$row['cn']}</td>
			<td>{$row['serial']}</td>
			<td>{$row['last_seen']}</td>
			<td>{$row['ip']}</td>
			$strButtonEnroll
			</tr>\n";
	} else {
		if ( 0 == strcmp($row['ip'], "") ) {
			echo
				"<tr>
				<td>{$row['cn']}</td>
				<td><button disabled=true>Not connected</button></td>
				<td>{$row['last_seen']}</td>
				<td>{$row['ip']}</td>
				$strButtonEnroll
				</tr>\n";
		} else {
			echo
				"<tr>
				<td>{$row['cn']}</td>
				<td><button onclick=\"callGetSerial('{$row['ip']}')\">Get serial</button></td>
				<td>{$row['last_seen']}</td>
				<td>{$row['ip']}</td>
				$strButtonEnroll
				</tr>\n";
		}
	}
}

?>
</table>
</body>
</html>

