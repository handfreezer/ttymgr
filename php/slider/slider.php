<?php

// https://[URL]/slider.php?url=https://[URL]/[nameOfJsonFile]

$json_url = $_GET['url'];

$slides = json_decode(
		file_get_contents($json_url),
		true);

require_once '/KioskAndMgr/php/slider/vendor/autoload.php';

use Twig\Environment;
use Twig\Loader\FilesystemLoader;

$loader = new FilesystemLoader('/KioskAndMgr/php/slider/templates');
$twig = new \Twig\Environment($loader, [
    'cache' => false,
]);

$template = $twig->load('slider.ts');
echo $template->render($slides);

?>
