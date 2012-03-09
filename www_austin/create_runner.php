<?php
require_once('functions.php');

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
	$rid = clean_runner_id($_GET['rid']);
	# print out a new form with this rid
	echo form_results($rid, "", "", "", "");
} else {
	$rid = clean_runner_id($_POST['rid']);
	$name = $_POST['name'];
	$email = $_POST['email'];
	$twitter = $_POST['twitter'];
	$form = form_results($rid, $name, $email, $twitter, true);
	if (!$form) {
		# passed validation
		update_or_create_new_runner($rid,$name,$email,$twitter,$rid);
		login($rid);
		redirect_to('/runners/' . $rid);			
	} else {
		# had errors; redisplay form
		echo $form;
	}
}
?>