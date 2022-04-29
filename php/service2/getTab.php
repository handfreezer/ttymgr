<?php

$tab = $_GET['tab'];

require_once('/www_ttyMgr/_config.php');
require_once '/KioskAndMgr/php/service2/vendor/autoload.php';

use Twig\Environment;
use Twig\Loader\FilesystemLoader;

$loader = new FilesystemLoader('/KioskAndMgr/php/service2/templates');
$twig = new \Twig\Environment($loader, [
    'cache' => false,
]);

$params=array();
$templateFile = 'template_not_defined.ts';

switch ($tab) {
case 'ovpn-status':
	$templateFile = $tab . '.ts';
	$query = mysqli_query($dbconnect, "SELECT os.cn,os.serial,os.last_seen,os.ip,count(en.id) as enrolled FROM ovpn_status os left outer join enrolled en on os.cn = en.cn group by os.ip order by cn,ip")
		or die (mysqli_error($dbconnect));
	$params['ttys'] = mysqli_fetch_all($query, MYSQLI_ASSOC);
	break;
case 'enrolled':
	$templateFile = $tab . '.ts';
	$query = mysqli_query($dbconnect, "
SELECT
        en.cn,
        en.ip,
        en.serial,
        ifnull(MAX(CASE WHEN ep.param='service.kiosk.installed'    THEN ep.value END),0) as kiosk,
        ifnull(MAX(CASE WHEN ep.param='service.snmpd.installed'    THEN ep.value END),0) as snmpd_os,
        ifnull(MAX(CASE WHEN ep.param='service.snmpd.temp.scan'    THEN ep.value END),0) as snmpd_temp,
        ifnull(MAX(CASE WHEN ep.param='service.snmpd.wifi.scan'    THEN ep.value END),0) as snmpd_wifi,
        ifnull(MAX(CASE WHEN ep.param='service.snmpd.gps'    THEN ep.value END),0) as snmpd_gps,
        ifnull(MAX(CASE WHEN ep.param='service.fusioninventory.installed'    THEN ep.value END),0) as inventory,
        ifnull(MAX(CASE WHEN ep.param='service.filer.installed'   THEN ep.value END),0) as filer
FROM
        enrolled en,
        enrolled_params ep
where
        en.cn != ''
        and en.cn = ep.cn
GROUP BY
        en.cn,
        en.ip,
        en.serial
order by
        en.cn
")
		or die (mysqli_error($dbconnect));
	$params['ttys'] = mysqli_fetch_all($query, MYSQLI_ASSOC);
	break;
case 'accesdistant':
	$templateFile = 'iframe.ts';
	$params['url'] = 'https://' . $url_ns . '/ttymgr/guacamole/';
	break;
case 'grafana':
	$templateFile = 'iframe.ts';
	$params['url'] = 'https://' . $url_ns . '/ttymgr/grafana/';
	break;
default:
	break;
}

$template = $twig->load($templateFile);
echo $template->render($params);

?>

