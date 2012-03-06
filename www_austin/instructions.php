<?php
require_once('functions.php');

$cookie_rid = $_COOKIE["jlog-rid"];

if ($cookie_rid) {
	echo "<p>You are logged in with runner id " , $cookie_rid , "</p>\n";
} else {
	echo "<p>Scan your QR code to log in.</p>\n";
}

echo "Your instructions...(TODO)";

if ($cookie_rid) {
	if (get_runner_twitter($cookie_rid)) {
		echo "<p>(link to tweet this)</p>";
	}
	echo "<p><a href='/runners/" , $cookie_rid , "'>View your stats</a></p>\n";
} else {
	echo "<p>Scan your QR code to log in.</p>\n";
}

?>