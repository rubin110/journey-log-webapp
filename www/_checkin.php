<?
error_reporting(E_ERROR | E_WARNING | E_PARSE);
include('mobile-friendly.html');
include('functions.php');

$cid = clean_checkpoint_id($_GET['cid']); // Get the cid
$runner_id = clean_runner_id($_GET['rid']);
$device_id = $_GET['did'];
$lat = $_GET['lat'];
$long = $_GET['long'];
$timestamp = $_GET['ts'];


if (empty($_GET)) {
	$cid = clean_checkpoint_id($_POST['cid']);
	$runner_id = clean_runner_id($_POST['rid']);
	#TODO: Clean this shit against injections
	$device_id = $_POST['did'];
	$lat = $_POST['lat'];
	$long = $_POST['long'];
	$timestamp = $_POST['ts'];
}

if (empty($timestamp)) {
	$timestamp = date('Y-m-d H:i:s');
}

//Get checkpoint id cookie value
$jlogCID = intval($_COOKIE["jlog-cid"]);


// Disabled because the Android app might not be passing a cookie and hitting this page directly :(
//if (!isset($_COOKIE["jlog-cid"])) {
	//Oops, you don't have a cookie, return to checkpoint registration
	#TODO: Disable this? We don't want someone guessing the url and registering with a checkpoint by accident
//	header("Location: /agent/set/");
//}

$photo_name = $runner_id.".jpg";

if ($_FILES["player_photo"]["error"] > 0)
{
	echo "Error Code: " . $_FILES["player_photo"]["error"] . "<br />";
} else {
	if (move_uploaded_file($_FILES["player_photo"]["tmp_name"],"photos/" . $photo_name)) {
		print "Successfully processed image<br />";
	} else {
		// print "Error processing image<br />";
		// die();
	}
}


//if ($cid == "0" || $jlogCID == "0" || clean_runner_id($_POST['rid']) == "0") {
	//print 'HEY LOOK YOU ARE CHECKPOINT 0';
	//header("Location: /agent/autoregistration/?rid=".$runner_id);
//	include('_autoregistration.php');
//	exit;
//}

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