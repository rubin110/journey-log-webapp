<?php
require_once('functions.php');

$cid = $command[1];
list($checkpoint_name, $checked_in_so_far) = get_checkpoint_name_and_status($cid);
$cookie_rid = $_COOKIE["jlog-rid"];

# echo "got cid ", $cid, " with runner id in cookie ", $cookie_rid, " and name ", $checkpoint_name, " and checked in so far ", $checked_in_so_far, "<br />\n";

if (!$cookie_rid) {
	# TODO: would be nice to tell someone they failed to check in before telling them to log in
	redirect_to('/instructions');
} elseif (!$checkpoint_name) {
	# TODO: this should never happen, unless someone tries entering a bad checkpoint code, so a confusing redirect/not mentioning the error is probably okay...but printing errors is usually better
	redirect_to('/instructions');
} else {
	if (checkin($cookie_rid, $cid, $checked_in_so_far)) {
		echo "<p>You successfully checked in at " , $checkpoint_name , ". Only " , $checked_in_so_far , " runners checked in here before you did.</p>";		
	} else {
		echo "<p>You FAILED to check in at " , $checkpoint_name , "!</p>";				
	}
}

?>