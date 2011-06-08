<?
/*
Thomas's registration app will send us a runner id and an image
We need to rename image to matche runner_id and place it in images folder
We should also put an entry in the runners table and check them in to checkpoint 0
*/
include('mobile-friendly.html');
include('functions.php');
$jlogRID = $_COOKIE["jlog-rid"];
$runner_id = clean_runner_id($_GET['rid']);
if (empty($runner_id)) {
	$runner_id = $jlogRID;
};
$act = $_GET['act'];
print '<h2>Journey Log</h2>';
if ($_SERVER['REQUEST_METHOD'] == 'POST'){
	//form was posted, register the runner
	$runner_id = $_POST['runner_id'];
	$runner_name = $_POST['runner_name'];
	$email_address = $_POST['email_address'];
	
	if ($act == "reg") {
		register_runner($runner_id, $runner_name, $email_address);
		print '
		<h3>Successfully registered '.$runner_id.'!</h3>
		<p>Your device is now bound to your Runner ID, do not let anyone else use your phone to scan codes unless you <a href="/clear">unbind your phone</a>!. Please scan your code again to view your stats, edit your registration info, or to unbind your phone from your Runner ID.
		<h3>How to checkin tags</h3>
		<p>This is optional but we encourage all players to participate in logging their tags!
		<p><b>When you are tagged by someone chasing you:</b> Give them your Runner ID code for them to scan.
		<p><b>When you tag someone else as a chaser:</b> Scan their Runner ID code on your own phone.
		';
		//set cookie
		setcookie("jlog-rid", $runner_id, time()+86400, "/", $_SERVER['SERVER_NAME']);
	}
	else if ($act == "up") {
		update_runner($runner_id, $runner_name, $email_address);
		print '
		<h3>Successfully updated '.$runner_id.'!</h3>
		<p>Your device is now bound to your Runner ID, do not let anyone else use your phone to scan codes unless you <a href="/clear">unbind your phone</a>!. Please scan your code again to view your stats, edit your registration info, or to unbind your phone from your Runner ID.
		<h3>How to checkin tags</h3>
		<p>This is optional but we encourage all players to participate in logging their tags!
		<p><b>When you are tagged by someone chasing you:</b> Give them your Runner ID code for them to scan.
		<p><b>When you tag someone else as a chaser:</b> Scan their Runner ID code on your own phone.
		';
		//set cookie
			setcookie("jlog-rid", $runner_id, time()+86400, "/", $_SERVER['SERVER_NAME']);
		}
	else if ($act == "bind") {
		print '
		<h3>Successfully bound '.$runner_id.'!</h3>
		<p>Your device is now bound to your Runner ID, do not let anyone else use your phone to scan codes unless you <a href="/clear">unbind your phone</a>!. Please scan your code again to view your stats, edit your registration info, or to unbind your phone from your Runner ID.
		<h3>How to checkin tags</h3>
		<p>This is optional but we encourage all players to participate in logging their tags!
		<p><b>When you are tagged by someone chasing you:</b> Give them your Runner ID code for them to scan.
		<p><b>When you tag someone else as a chaser:</b> Scan their Runner ID code on your own phone.
		';
		//set cookie
			setcookie("jlog-rid", $runner_id, time()+86400, "/", $_SERVER['SERVER_NAME']);
		}
	else if ($act = "hand") {
		header("Location: /_reg.php?rid=".$runner_id);
	}
		else {
		print "Oops, something went horribly wrong.";
	}


} else {

	if (empty($runner_id)) {
		print $runner_id;
		print 'Please scan your Runner ID code to register, or type it in here...
		<form name="runner" action="'.$_SERVER['PHP_SELF'].'?act=hand" method="post">
		<p><input type="text" name="runner_id" value="'.$runner_id.'">
		<p><input type="submit" value="Submit"></p>
		</form>
		';
		die();
	}

	if (!is_valid_runner($runner_id)) {
		print "Invalid runner";
		die();
	}
	
	if ($runner_id == $jlogRID) {
		print '
			<h3>Runner ID: '.$runner_id.'</h3>
			<p>Your phone is bound to Runner ID '.$runner_id.', you can now scan another player\'s Runner ID code to claim them as a tag.<br />

			<form name="bind_runner" action="/clear" method="post">
			<p><input type="submit" value="Unbind phone from Runner ID"></p>
			</form>

			

			<form name="update_runner" action="'.$_SERVER['PHP_SELF'].'?act=up" method="post">
			<input type="hidden" name="runner_id" value="'.$runner_id.'">
			<p>Name: <input type="text" name="runner_name" value="'.get_runner_name($runner_id).'"></p>
			<p>Email: <input type="text" name="email_address" value="'.get_runner_email($runner_id).'"></p>
			<p><input type="submit" value="Update Info"></p>
			</form>
			';
		die ();
	}
	
	if (is_runner_registered($runner_id)) {
		print '
		<h3>Runner ID: '.$runner_id.'</h3>
		<p>Your phone is not bound to a Runner ID, you must bind your phone first before you can check in a tag against another player.<br />
		
		<form name="bind_runner" action="'.$_SERVER['PHP_SELF'].'?act=bind" method="post">
		<input type="hidden" name="runner_id" value="'.$runner_id.'">
		<p><input type="submit" value="Bind phone to '.$runner_id.'"></p>
		</form>
		
		<form name="update_runner" action="'.$_SERVER['PHP_SELF'].'?act=up" method="post">
		<input type="hidden" name="runner_id" value="'.$runner_id.'">
		<p>Name: <input type="text" name="runner_name" value="'.get_runner_name($runner_id).'"></p>
		<p>Email: <input type="text" name="email_address" value="'.get_runner_email($runner_id).'"></p>
		<p><input type="submit" value="Update Info"></p>
		</form>
		';
		// .get_checkpoint_name($checkpoint_id).
		//maybe we can print a form that says "If you tagged this person, enter your serial number here" and then reset their cookie?
		die();
	}
	//show form
?>
Looks like you aren't registered yet!<br />
<form name="register_runner" action="<?= $_SERVER['PHP_SELF']; ?>?act=reg" method="post">
<input type="hidden" name="runner_id" value="<?= $runner_id ?>">
<p>Name: <input type="text" name="runner_name"></p>
<p>Email: <input type="text" name="email_address"></p>
<p><input type="submit" value="submit"></p>
</form>

<i>If you have tried to register already, maybe you don't have cookies enabled?</i>
<? } ?>
