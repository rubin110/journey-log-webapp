<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php
$rid = $_GET['rid'];
$rid = strtoupper($rid);
?>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>index</title>
</head>
<body>
<h2>Journey Log</h2>
<?php
$con = mysql_connect("localhost","jloguser","y6kaYsHjW48ZRD");
if (!$con) { die('Could not connect: ' . mysql_error()); }
elseif (($_COOKIE["jlog-cid"]) !== "CP0") {
	echo "Error: Your device isn't designated to a checkpoint yet.";
}
elseif (mysql_query("SELECT * FROM jlog_data WHERE rid = '$rid'")) {
	echo "Error: Runner already exists!";
}
else 
	echo "Create a new runner profile.";
?>
<p><a href="setcid.php">Set your designation</a>
</body>
</html>