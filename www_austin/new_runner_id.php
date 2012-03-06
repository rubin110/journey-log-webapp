<?php
require_once('functions.php');

$jlogRID = $_COOKIE["jlog-rid"];

if ($jlogRID) {
	# they already have a runner id cookie -- redirect to their player profile rather than generating a new one
	redirect_to('/runner/' . $jlogRID);
} else {
	$jlogRID = new_runner_id();
	redirect_to('/create_runner?rid=' . $jlogRID);
}
?>

