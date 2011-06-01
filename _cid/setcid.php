<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php
$cid = $_GET['cid']; // Get the cid
$possiblecid = array("CP0", "CP1A", "CP1B", "CP2A", "CP2B", "CP3", "CP4", "CP5", "CP6", "CP7", "BA", "BB"); // List of valid cids
if (in_array($cid, $possiblecid)) // Is it valid? If so go.
	{
		setcookie("jlog-cid", $cid, time()+86400, "/", $_SERVER['SERVER_NAME']); // Set cookies
	}
	elseif ($cid == "X") // If $cid is X, then kill the cookie
	{
		setcookie("jlog-cid", $cid, time()-86400, "/", $_SERVER['SERVER_NAME'])
	}
?>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>index</title>
</head>
<body>
<a href="/_cog">Back</a><br><br>
<?php
if (in_array($cid, $possiblecid)) // Is cid populated?
	{
		echo "<p><b><big>Your designation is now set to: $cid</b></big><br><br>"; // State new cid
	};
	?>
Set your designation:<br>
<a href="setcid.php?cid=CP0">CP0</a><br>
<a href="setcid.php?cid=CP1A">CP1A</a><br>
<a href="setcid.php?cid=CP1B">CP1B</a><br>
<a href="setcid.php?cid=CP2A">CP2A</a><br>
<a href="setcid.php?cid=CP2B">CP2B</a><br>
<a href="setcid.php?cid=CP3">CP3</a><br>
<a href="setcid.php?cid=CP4">CP4</a><br>
<a href="setcid.php?cid=CP5">CP5</a><br>
<a href="setcid.php?cid=CP6">CP6</a><br>
<a href="setcid.php?cid=CP7">CP7</a><br>
<a href="setcid.php?cid=BA">BA</a><br>
<a href="setcid.php?cid=BB">BB</a><br>
<a href="setcid.php?cid=X">X</a><br>

</body>
</html>