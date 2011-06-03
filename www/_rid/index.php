<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php
/* require_once('mobile_device_detect.php');
mobile_device_detect(true,false,true,true,true,true,true,'mobile/',false); */
$rid = $_GET['rid'];
$rid = strtoupper($rid);
?>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>index</title>
</head>
<body>
	<h1>Journey Log - Runner ID Binding</h1>
	<p>Your mobile device isn't bound to a Runner ID yet, please fill out the following information to bind.
	<p>Journey Runner ID:<br><?php echo $rid ?>
	<p>Journey registered email address:
		
	</br>
</body>
</html>
