<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php

	
?>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>index</title>
</head>
<body>
<h2>Journey Log</h2>
<p>Designation: <?php echo $_COOKIE["jlog-cid"]; ?>
<p><a href="setcid.php">Set your designation</a>
<?
	$all_checkpoints = get_all_checkpoint_ids();
	foreach ($all_checkpoints as $checkpoint_id) {
		print '<a href="setcid.php?cid='.$checkpoint_id.'">'.get_checkpoint_name($checkpoint_id).'</a>';
	}

?>
</body>
</html>