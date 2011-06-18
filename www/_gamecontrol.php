<?
include('mobile-friendly.html');
include('functions.php');
if ($_SERVER['REQUEST_METHOD'] == 'POST'){
	$mysql = connectdb(true);
	if ($_POST['action'] == "START") {
		//start the game
		print "<h1>Start running bitches!</h1>";
		if (mysql_query("INSERT INTO ".OTHER_TBL." (event, time) VALUES ('start',NOW())", $mysql)) {
			_logger(LOG_GAME, "START", "Journey has started!");	
		}
		print "Start time recorded as:<br />".get_start_time();
	} else if ($_POST['action'] == "END") {
		print "<h1>The game has ended!</h1>";
		if (mysql_query("INSERT INTO ".OTHER_TBL." (event, time) VALUES ('end',NOW())", $mysql)) {
			_logger(LOG_GAME, "END", "Journey has ended!");
		}
		print "End time recorded as:<br />".get_end_time();
		print "<br />";
		print "<p>The game lasted: ".time_between(get_start_time(), get_end_time())."</p>";
		print "<p>Total Runners Tagged: ".total_runners_tagged()."</p>";
		$checkpoints = get_all_checkpoint_ids();
		foreach ($checkpoints as $checkpoint_id) {
			print "<p>".get_checkpoint_name($checkpoint_id).":<br />";
			print "&nbsp;&nbsp&nbsp;Checkins: ".total_checkpoint_checkins($checkpoint_id)."</p>";
		print "<br />";
}

	}
} else {
?>
<h1>Are you ready?</h1>
<div align="center">
<form action="" method="post">
<input type="submit" name="action" value="START" style="width: 50%; height: 75px; font-size: 20pt;">
<br /><br /><br /><br />
<input type="submit" name="action" value="END" style="width: 50%; height: 75px; font-size: 20pt;">
</form>
</div>
<?
}
?>