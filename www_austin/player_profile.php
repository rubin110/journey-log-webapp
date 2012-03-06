<?php
require_once('functions.php');

$rid = $command[1];
$cookie_rid = $_COOKIE["jlog-rid"];

#TODO: maybe check to make sure you're logged in as you and not let other players see your info?

$runner_name = get_runner_name($rid);

echo "<br />player profile for runner id " , $rid, " (", $runner_name, ")";
$checkin_stats = get_runner_checkin_info();
if (sizeof($checkin_stats) > 0) {
	echo "<p><table><tr><th>Checkpoint name</th><th>Checked in Before You</th><th>Checkin Time</th></tr>\n";
	foreach ($checkin_stats as &$row) {
		echo "<tr><td>",$row[0],"</td><td>",$row[1],"</td><td>",$row[2],"</td></tr>\n";
	}
	echo "</table></p>\n";
} else {
	echo "<p>No checkins yet.</p>";
}
echo "<br /><a href='/logout'>Logout</a>\n";
echo "<br /><a href='/edit'>Edit Info</a>\n";

if (is_chaser($rid)) {
	echo "<br />To record that you tagged someone, scan their QR code.\n";
} else {
	echo "<br /><a href='/tagged/", $rid, "'>I Got Tagged</a>\n";
}

?>