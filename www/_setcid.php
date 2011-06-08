<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php
include('mobile-friendly.html');
include('functions.php');

print '<h2>Journey Log</h2>';
$cid = $_GET['cid']; // Get the cid

$possibleCIDs = get_all_checkpoint_ids();
$possibleCIDs[] = 9999;


if (!in_array($cid, $possibleCIDs)) {
	print '<h3>Checkpoint ID not found</h3>
	<div style="font-size:14em;color:red;text-align: center;">?</div>';
	die();
}

if ($cid == 9999) {
	//delete the cookie
	setcookie("jlog-cid", $cid, time()-86400, "/", $_SERVER['SERVER_NAME']);
	print "Cookie removed";
} else {
	//set the cookie
	setcookie("jlog-cid", $cid, time()+86400, "/", $_SERVER['SERVER_NAME']); //Set cookies
	print '<h3>Phone bound to '.get_checkpoint_name($cid).'</h3>
	<div style="font-size:14em;color:green;text-align: center;">&#9676;</div>';
}


?>