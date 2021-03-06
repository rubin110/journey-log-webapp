<?
error_reporting(E_ERROR | E_WARNING | E_PARSE);
include('mobile-friendly.html');
include('functions.php');

$cid = clean_checkpoint_id($_GET['cid']); // Get the cid
$runner_id = clean_runner_id($_GET['rid']);
$device_id = $_GET['did'];
$lat = $_GET['lat'];
$long = $_GET['lon'];
if (empty($long)) {
	$long = $_GET['long'];
}
if (empty($long)) {
	$long = $_GET['lng'];
}
$timestamp = $_GET['ts'];

$user_agent = $_SERVER['HTTP_USER_AGENT'];
//Hello iPhone app!!
if (strpos($user_agent, "JourneyLog") === 0) {
	_logger(LOG_DEBUGGING,"","Hello iPhone app! Fetching POST: runner_id=".$_POST['rid']);
	if (empty($cid)) {
		$cid = clean_checkpoint_id($_POST['cid']);
	}
	if (empty($runner_id)) {
		$runner_id = clean_runner_id($_POST['rid']);
	}
	#TODO: Clean this shit against injections
	$device_id = $_POST['did'];
	$lat = $_POST['lat'];
	$long = $_POST['lon'];
	if (empty($long)) {
		$long = $_POST['long'];
	}
	if (empty ($long)) {
		$long = $_POST['lng'];
	}
	$timestamp = $_POST['ts'];
	$timestamp = $timestamp - 25200;	//fix for Pacific time zone, i.e. GMT -7
	//convert timestamp to datetime
	$timestamp = time_php2sql($timestamp);
}

if (empty($timestamp)) {
	_logger(LOG_DEBUGGING, "", "Timestamp not passed, generate one");
	$timestamp = date('Y-m-d H:i:s');
}

//Get checkpoint id cookie value
$jlogCID = intval($_COOKIE["jlog-cid"]);

/* Disabled because the Android app might not be passing a cookie and hitting this page directly :(
if (!isset($_COOKIE["jlog-cid"])) {
	//Oops, you don't have a cookie, return to checkpoint registration
	#TODO: Disable this? We don't want someone guessing the url and registering with a checkpoint by accident
	header("Location: /agent/set/");
}
*/

if ($cid == "0" || $jlogCID == "0") {
	//print 'HEY LOOK YOU ARE CHECKPOINT 0';
	//header("Location: /agent/autoregistration/?rid=".$runner_id);
	include('_autoregistration.php');
	exit;
}

if ($runner_id) {
	//print "Look here motherfuckers, we're checking you into a checkpoint. Good job<br /><br />";
	print '<h2>Journey Log - Checkin<br>'.get_checkpoint_name($jlogCID).'</h2>
	';

	//print 'Going to try to check in runner '.$runner_id.'<br />';
	//print $jlogCID.", ".$runner_id.",".$device_id.",".$lat.",".$long.",".$timestamp."<br />";
	if (check_runner_in($jlogCID, $runner_id, $device_id, $lat, $long, $timestamp)) {
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
</body>
</html>