<?php
include('mobile-friendly.html');
include('functions.php');

print '<h2>Journey Log</h2>';

/* require_once('mobile_device_detect.php');
mobile_device_detect(true,false,true,true,true,true,true,'mobile/',false); */
$runner_id = clean_runner_id($_GET['rid']);

$jlogCID = $_COOKIE["jlog-cid"];
$jlogRID = $_COOKIE["jlog-rid"];

if (empty($jlogRID)) {
	if (DEBUG) print "RID cookie is empty<br />";
}
if (empty($jlogCID)) {
	if (DEBUG) print "CID cookie is empty<br />";
}

//Is the checkpoint registered in cookies?
if (empty($jlogCID)) {
	//Checkpoint is not registered on device
	if (DEBUG) print "You're not a checkpoint<br />";
	if (!empty($jlogRID)) {
		//runner id is set in cookie
		if (DEBUG) print "You've got a runner id cookie<br />";
		if ($jlogRID == $runner_id) {
			//the cookie matches the scanned id
			if (DEBUG) print "You can't tag yourself!";
			header("Location: /_reg.php?rid=".$runner_id);
		} else {
			//looks like someone got tagged!
			if (DEBUG) print "You tagged someone!<br />";
			header("Location: /_tag.php?rid=".$runner_id."&tid=".$jlogRID);
		}
	} else {
		//we need to register this runner
		if (DEBUG) print "You don't have a cookie!<br />";
		header("Location: /_reg.php?rid=".$runner_id);
	}
} else if (is_valid_checkpoint($jlogCID)) {
	//Checkpoint is registered on device and is a valid checkpoint
	if (DEBUG) print "Hello checkpoint ".$jlogCID;
	header("Location: /_checkin.php?rid=".$runner_id);
}

?>
