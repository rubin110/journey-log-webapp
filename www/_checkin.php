<?
error_reporting(E_ERROR | E_WARNING | E_PARSE);
include('mobile-friendly.html');
include('functions.php');

$cid = $_GET['cid']; // Get the cid
$runner_id = clean_runner_id($_GET['rid']);


if (!isset($_COOKIE["jlog-cid"])) {
	//Oops, you don't have a cookie, return to checkpoint registration
	header("Location: /_cid");
}
$jlogCID = intval($_COOKIE["jlog-cid"]);

if ($cid == "0" || $jlogCID == "0") {
	//print 'HEY LOOK YOU ARE CHECKPOINT 0';
	//header("Location: /agent/autoregistration/?rid=".$runner_id);
	include('_autoregistration.php');
}

if ($runner_id) {
	//print "Look here motherfuckers, we're checking you into a checkpoint. Good job<br /><br />";
	print '<h2>Journey Log - Checkin<br>'.get_checkpoint_name($jlogCID).'</h2>
	';

	print 'Going to try to check in runner '.$runner_id.'<br />';	
	if (check_runner_in($jlogCID, $runner_id)) {
		print '
		<p><strong><big>Runner '.$runner_id.' is checked in.</big></strong>
		<div style="font-size:14em;color:green;text-align: center;">&#10003;</div>
		';
	} else {
		//We should probably check and see if the runner's already been checked in and return a more descriptive message
		if (is_already_checked_in($jlogCID, $runner_id)) {
			print '
			<p><strong><big>Runner '.$runner_id.' is already checked in.</big></strong>
			<div style="font-size:14em;color:green;text-align: center;">&#10003;</div>
			';
		} else {
			print '
			<h3>Whoops, something went wrong. Runner '.$runner_id.' might already be checked in.</h3>
			<div style="font-size:14em;color:red;text-align: center;">?</div>
			';
		}
	}
} else {
	print "Runner id missing";
}

?>
