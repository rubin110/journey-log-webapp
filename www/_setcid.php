<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php
include('functions.php');
$cid = $_GET['cid']; // Get the cid

$possibleCIDs = get_all_checkpoint_ids();
$possibleCIDs[] = 9999;


if (!in_array($cid, $possibleCIDs)) {
	print "Checkpoint ID not found";
	die();
}

if ($cid == 9999) {
	//delete the cookie
	setcookie("jlog-cid", $cid, time()-86400, "/", $_SERVER['SERVER_NAME']);
	print "Cookie removed";
} else {
	//set the cookie
	setcookie("jlog-cid", $cid, time()+86400, "/", $_SERVER['SERVER_NAME']); //Set cookies
	print "Cookie set to ".get_checkpoint_name($cid);
}


?>