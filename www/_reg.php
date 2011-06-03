<?
/*
Thomas's registration app will send us a runner id and an image
We need to rename image to matche runner_id and place it in images folder
We should also put an entry in the runners table and check them in to checkpoint 0
*/
include('functions.php');

$runner_id = clean_runner_id($_GET['rid']);

if ($_SERVER['REQUEST_METHOD'] == 'POST'){
	//form was posted, register the runner
	$runner_id = $_POST['runner_id'];
	$runner_name = $_POST['runner_name'];
	$email_address = $_POST['email_address'];
	
	if (register_runner($runner_id, $runner_name, $email_address)) {
		print "Successfully registered!";
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