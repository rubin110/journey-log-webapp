<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php
include('functions.php');

/* require_once('mobile_device_detect.php');
mobile_device_detect(true,false,true,true,true,true,true,'mobile/',false); */
$runner_id = clean_runner_id($_GET['rid']);

$jlogCID = $_COOKIE["jlog-cid"];
$jlogRID = $_COOKIE["jlog-rid"];

if ($jlogCID == 0) {
	//This is registration
	print "Welcome to registration";
	header("Location: /_reg/?rid=".$jlogRID);
} else if (is_valid_checkpoint($jlogCID)) {
	//this is a valid checkpoint
	print "Hello checkpoint ".$jlogCID;
	header("Location: /_checkin.php?rid=".$runner_id);
}

if (is_valid_runner($jlogRID)) {
	//This is a runner who tagged someone
	print "Go to the tag page";
} else if (empty($jlogRID)) {
	//This is a runner that hasn't registered, i.e. doesn't have a cookie
	print "Go to the runner bind page";
}

?>
