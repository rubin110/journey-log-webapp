<?
include('functions.php');

$runner_id = clean_runner_id($_GET['rid']);
$jlogCID = intval($_COOKIE["jlog-cid"]);

print "Look here motherfuckers, we're checking you into a checkpoint. Good job<br /><br />";

print "Runner is: ".$runner_id."<br />";

print "You wanted to check them in to ".get_checkpoint_name($jlogCID).", right?<br />";

if (check_runner_in($jlogCID, $runner_id)) {
	print "Successfully checked in!";
} else {
	print "Well shit, something went wrong.";
}


?>