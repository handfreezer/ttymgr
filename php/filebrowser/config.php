<?php

$use_auth = false;
$theme = 'dark';

$use_highlightjs = true;
$highlightjs_style = 'ir-black';
$edit_files = true;
$default_timezone = 'Europe/Paris';
$root_path = '/filebrowser/' . $_SERVER['TTYMGR_AUTH'];
$root_url = 'ttymgr/filebrowser';
$http_host = $_SERVER['HTTP_HOST'];
$directories_users = array();
$iconv_input_encoding = 'UTF-8';
$datetime_format = 'Ymd-His';
$allowed_file_extensions = '';
$allowed_upload_extensions = '';
$favicon_path = '?favicon=tinyfilemanager';
$exclude_items = array();
// Availabe rules are 'google', 'microsoft' or false
// google => View documents using Google Docs Viewer
// microsoft => View documents using Microsoft Web Apps Viewer
// false => disable online doc viewer
$online_viewer = false;
$sticky_navbar = true;
$max_upload_size_bytes = 2048;

// Possible rules are 'OFF', 'AND' or 'OR'
// OFF => Don't check connection IP, defaults to OFF
// AND => Connection must be on the whitelist, and not on the blacklist
// OR => Connection must be on the whitelist, or not on the blacklist
$ip_ruleset = 'OFF';
$ip_silent = false;
$ip_whitelist = array(
    '127.0.0.1'
);
$ip_blacklist = array(
    '0.0.0.0',
    '::'
);

function is_dir_ ($file) {
	if ( true ) {
		#return ((fileperms("$file") & 0x4000) == 0x4000);
		return is_dir($file);
	} else {
		$cwd=getcwd();
		$result=chdir($file);
		chdir($cwd);
		return $result;
	}
}

?>
