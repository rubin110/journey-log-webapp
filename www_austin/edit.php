<?php
require_once('functions.php');

$rid = $_COOKIE["jlog-rid"];

# confirm that cookie is set properly
if (!$rid) {
	echo "<p>You must log in first. Scan your QR code.</p>";
} else {
	if ($_SERVER['REQUEST_METHOD'] == 'GET') {
		$rid = clean_runner_id($rid);
		list($name, $email, $twitter) = get_runner_details($rid);
		# print out a new form with this rid and player details
		echo form_results($rid, $name, $email, $twitter, false);
	} else {
		$rid = clean_runner_id($rid);
		$name = $_POST['name'];
		$email = $_POST['email'];
		$twitter = $_POST['twitter'];
		$form = form_results($rid, $name, $email, $twitter, true);
		if (!$form) {
			# passed validation
			update_or_create_new_runner($rid,$name,$email,$twitter,$rid);
			redirect_to('/runners/' . $rid);			
		} else {
			# had errors; redisplay form
			echo $form;
		}
	}	
}

?>