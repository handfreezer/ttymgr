<?php
require_once('/www_ttyMgr/_config.php');
$cn=$_GET['cn_name'];
$username="filer";
$dir_mount_point="/filebrowser/" . $_SERVER['TTYMGR_AUTH'];

$q = $pdo->prepare("select ip from enrolled where cn=?");
$q->execute(array($cn));
$ip = $q->fetchColumn();

exec ("mkdir -p ${dir_mount_point} >>/tmp/filer_launch_php.log 2>&1");
sleep(2);
exec ("fusermount -u $dir_mount_point >>/tmp/filer_launch_php.log 2>&1");
exec ("sshfs $username@$ip:/ $dir_mount_point -o IdentityFile=/KioskAndMgr/keys/ttymgr_filer -C -oLogLevel=DEBUG3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/KioskAndMgr/keys/known_hosts >>/tmp/filer_launch_php.log 2>&1");
sleep(2);
header('Location: /ttymgr/filebrowser/tinyfilemanager.php');

?>
