<?php

$hostname = "localhost";
$username = "username";
$password = "password";
$db = "dbname";
$url_ns = "NS";

$dbconnect=mysqli_connect($hostname,$username,$password,$db);

if ($dbconnect->connect_error) {
  die("Database connection failed: " . $dbconnect->connect_error);
}

?>

