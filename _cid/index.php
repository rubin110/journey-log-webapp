<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<?php
include('../functions.php');
if (isset($_COOKIE["jlog-cid"])) {
	$cid = intval($_COOKIE["jlog-cid"]);
}
?>

<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>index</title>
</head>
<body>
<h2>Journey Log</h2>
<? if (isset($cid)) { ?>
<p>You are currently registered to <?php print get_checkpoint_name($cid); ?></p>
<? } else { ?>
<p>You are not currently registered to a checkpoint</p>
<? } ?>
<p>Set your checkpoint:</p>
<p>
<?
	$all_checkpoints = get_all_checkpoint_ids();
	foreach ($all_checkpoints as $checkpoint_id) {
		print '<a href="setcid.php?cid='.$checkpoint_id.'">'.get_checkpoint_name($checkpoint_id).'</a><br />';
	}
?>
</p>
<a href="setcid.php?cid=9999">Clear your checkpoint cookies</a>
</body>
</html>