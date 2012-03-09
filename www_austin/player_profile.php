<?php
require_once('functions.php');

$rid = $command[1];
$cookie_rid = $_COOKIE["jlog-rid"];

# check to make sure you're logged in as you and not let other players see your info
if ($cookie_rid != $rid) {
	echo "<p>If you are trying to tag this person, you must first <a href='/tagged/" . $cookie_rid . "'>mark yourself as tagged</a>.</p>";
	echo "<p>If you are trying to log in as this person, you must first <a href='/logout'>logout</a>.</p>";	
} else {
	$dtzone = new DateTimeZone($tz);

	$runner_name = get_runner_name($rid);

	echo "<br />player profile for runner id " , $rid, " (", $runner_name, ")";
	$checkin_stats = get_runner_checkin_info($rid);
	if (sizeof($checkin_stats) > 0) {
		echo "<p><table><tr><th>Checkpoint name</th><th>Checked in Before You</th><th>Checkin Time</th></tr>\n";
		foreach ($checkin_stats as &$row) {
			$dt = new DateTime($row[2], $dtzone);
			echo "<tr><td>",$row[0],"</td><td>",$row[1],"</td><td>",$dt->format("h:i:s"),"</td></tr>\n";
		}
		echo "</table></p>\n";
	} else {
		echo "<p>No checkins yet.</p>";
	}

	if (is_chaser($rid)) {
		$num_tagged = get_num_tagged_by($rid);
		echo "<br />You have recorded $num_tagged tags so far.\n";
		echo "<br />To record that you tagged someone, scan their QR code.\n";
		echo "<br />Or, if you accidentally marked yourself as tagged, you can <a href='/resurrected'>un-tag yourself</a>.";
	} else {
		echo "<br /><a href='/tagged/", $rid, "'>I Got Tagged</a>\n";
	}	
	echo "<br /><a href='/logout'>Logout</a>\n";
	echo "<br /><a href='/edit'>Edit Info</a>\n";
}

?>