<?php
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
	$rid = $_GET['rid'];
	echo 'this is totally a form for new runner with id ', $rid;
} else {
	echo 'um...getting post parameters and validating?';
	setcookie("jlog-rid", $rid, time()+60*60*24*60, "/", $_SERVER['SERVER_NAME']);
}
?>