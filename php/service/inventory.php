<?php
require_once('/www_ttyMgr/_config.php');

$cn=$_GET['cn'];
$frame=$_GET['frame'];
$request_inventory=$_GET['request'];

$inventory=array();
$inventory_dttime="";

switch ($frame) {
case "last":
	if ( 0 == strcmp($cn, "") ) {
	        echo "Bad call (no CN)";
	} else {
		$output_sudo=null;
		$res_sudo=null;
		if ( 1 != $request_inventory )
			$res_sudo = 0;
		else
			exec ("sudo /KioskAndMgr/tools_fusioninventory/doCallAction.sh $cn 'getInventory' >>/tmp/do_fusioninventory_callAction_getInventory.log 2>&1",$output_sudo,$res_sudo);
		if ( 0 != $res_sudo ) {
			echo "failed to sudo call [$res_sudo]";
		} else {
			//$q = $pdo->prepare("select ifnull(inventory,'') from enrolled_inventory where cn=? order by dttime desc limit 1");
			$q = $pdo->prepare("select dttime,ifnull(inventory,'') as inventory from enrolled_inventory where cn=? order by dttime desc limit 1");
			$q->execute(array($cn));
			$result = $q->fetch(PDO::FETCH_ASSOC);
			if ( 2 != count($result) ) {
				echo "Failed to get last inventory";
			} else {
				$inventory_dttime = $result['dttime'];
				$inventory_xml = simplexml_load_string($result['inventory']);
				if ( False === $inventory_xml ) {
					echo "Failed to load XML";
				} else {
					foreach($inventory_xml as $key => $value) {
						#echo "$key - " . $value->getName() . "<br>";
						if ( "CONTENT" === $key ) {
							foreach($value as $key2 => $value2) {
								$contenu=array();
								foreach($value2 as $key3 => $value3) {
									$contenu[$key3] = $value3->__toString();
								}
								if ( array_key_exists($key2, $inventory) ) {
									$inventory[$key2][] = $contenu;
								} else {
									$inventory[$key2] = array($contenu);
								}
							}
						}
					}
					#var_dump($inventory);
				}
			}
		}
	}
	break;
default:
	break;
}

?>

<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {font-family: Arial;}

/* Style the tab */
.tab {
  overflow: hidden;
  border: 1px solid #ccc;
  background-color: #f1f1f1;
}

/* Style the buttons inside the tab */
.tab button {
  background-color: inherit;
  float: left;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 14px 16px;
  transition: 0.3s;
  font-size: 17px;
}

/* Change background color of buttons on hover */
.tab button:hover {
  background-color: #ddd;
}

/* Create an active/current tablink class */
.tab button.active {
  background-color: #ccc;
}

/* Style the tab content */
.tabcontent {
  display: none;
  padding: 6px 12px;
  border: 1px solid #ccc;
  border-top: none;
}
</style>
</head>
<body>
<h2>Last inventory : <?php echo $inventory_dttime; ?></h2>

<?php
echo '<div class="tab">';
foreach($inventory as $key=>$value) {
  echo '<button class="tablinks" onmouseover="openCity(event, \'' . $key . '\')">' . $key . '</button>';
}
echo '</div>';

foreach($inventory as $key=>$value) {
	echo "<div id='$key' class='tabcontent'><table border=1>";
	foreach($value as $index=>$elements) {
		echo "<tr><td>$index</td><td>";
		foreach($elements as $tag_name=>$tag_value){
			echo "$tag_name : $tag_value<br>";
		}
		echo "</td></tr>";
	}
	echo "</table></div>";
}

?>

<div id="London" class="tabcontent">
  <h3>London</h3>
  <p>London is the capital city of England.</p>
</div>

<div id="Paris" class="tabcontent">
  <h3>Paris</h3>
  <p>Paris is the capital of France.</p> 
</div>

<div id="Tokyo" class="tabcontent">
  <h3>Tokyo</h3>
  <p>Tokyo is the capital of Japan.</p>
</div>

<script>
function openCity(evt, cityName) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(cityName).style.display = "block";
  evt.currentTarget.className += " active";
}
</script>
	   
</body>
</html> 

