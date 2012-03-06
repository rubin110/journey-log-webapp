<?php
require_once('functions.php');

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
	$rid = clean_runner_id($_GET['rid']);
	# TODO: if pre-generating ids, probably check that this id is valid
	echo <<<NEW_RUNNER_FORM
	<form method="POST">
	<input type="hidden" name="rid" value="$rid" />
	Public Player Name: <input type="text" name="name" /><br />
	Email address: <input type="text" name="email" /><br />
	Twitter handle (optional): <input type="text" name="twitter" /><br />
	<input type="submit" value="Submit" />
	</form>
NEW_RUNNER_FORM;
} else {
	# TODO: validation/errors
	$rid = clean_runner_id($_POST['rid']);
	$name = $_POST['name'];
	$email = $_POST['email'];
	$twitter = $_POST['twitter'];
	# TODO: validation/email uniqeness, twitter uniqueness if present
	if (update_or_create_new_runner($rid,$name,$email,$twitter,$rid)) {
		login($rid);
		redirect_to('/runners/' . $rid);			
	} else {
		# TODO: error!
	}
}
?>