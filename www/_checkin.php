<?
include('functions.php');

$runner_id = clean_runner_id($_GET['rid']);
if (!isset($_COOKIE["jlog-cid"])) {
	//Oops, you don't have a cookie, return to checkpoint registration
	header("Location: /_cid");
}
$jlogCID = intval($_COOKIE["jlog-cid"]);

if ($runner_id) {
	print "Look here motherfuckers, we're checking you into a checkpoint. Good job<br /><br />";

	print "Runner is: ".$runner_id."<br />";

	print "You wanted to check them in to ".get_checkpoint_name($jlogCID).", right?<br />";
	
	if (check_runner_in($jlogCID, $runner_id)) {
		print "Successfully checked in!";
	} else {
		//We should probably check and see if the runner's already been checked in and return a more descriptive message
		if (is_already_checked_in($jlogCID, $runner_id)) {
			print "Don't worry, this runner is already checked in here";
		} else {
			print "Well shit, something went wrong.";
		}
	}
} else {
	print "Runner id missing";
}

?>