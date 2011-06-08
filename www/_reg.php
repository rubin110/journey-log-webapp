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

if ($_SERVER['REQUEST_METHOD'] == 'POST'){
	//form was posted, register the runner
	$runner_id = $_POST['runner_id'];
	$runner_name = $_POST['runner_name'];
	$email_address = $_POST['email_address'];
	
	if (register_runner($runner_id, $runner_name, $email_address)) {
		print "Successfully registered! Your device is now bound to your Runner ID. Please scan your code again to view your stats, edit your registration info, or to unbind your phone from your Runner ID. Optional When you are tagged by someone chasing you: Give them your Runner ID code for them to scan. When you tag someone else as a chaser: Scan their Runner ID code on your own phone.";
		//set cookie
		setcookie("jlog-rid", $runner_id, time()+86400, "/", $_SERVER['SERVER_NAME']);
	} else {
		print "Oops, something went wrong registering you.";
	}
	
} else {

	if ($runner_id == "") {
		print "Please scan your QR code to register";
		die();
	}

	if (!is_valid_runner($runner_id)) {
		print "Invalid runner";
		die();
	}
	
	if ($runner_id == $jlogRID) {
		print "You are you! Display some stats here, log out button, edit registration info.";
		die ();
	}
	
	if (is_runner_registered($runner_id)) {
		print $runner_id." is already registered<br />";
		print "Did you just tag this person? If so, please scan your QR code and register and then rescan their QR code so we can give you credit.<br />";
		//maybe we can print a form that says "If you tagged this person, enter your serial number here" and then reset their cookie?
		die();
	} */
	//show form
?>
Looks like you aren't registered yet!<br />
<form name="register_runner" action="<?= $_SERVER['PHP_SELF']; ?>" method="post">
<input type="hidden" name="runner_id" value="<?= $runner_id ?>"
<p>Name: <input type="text" name="runner_name"></p>
<p>Email: <input type="text" name="email_address"></p>
<p><input type="submit" value="submit"></p>
</form>

<i>If you have tried to register already, maybe you don't have cookies enabled?</i>
<? } ?>

<? /*
$con = mysql_connect("localhost","jloguser","y6kaYsHjW48ZRD");
if (!$con) { die('Could not connect: ' . mysql_error()); }
elseif (($_COOKIE["jlog-cid"]) !== "CP0") {
	echo "Error: Your device isn't designated to a checkpoint yet.";
}
elseif (mysql_query("SELECT * FROM jlog_data WHERE rid = '$rid'")) {
	echo "Error: Runner already exists!";
}
else 
	echo "Create a new runner profile.";
?>
<p><a href="setcid.php">Set your designation</a>
</body>
</html>
*/ ?>