<?php
require_once('functions.php');

$cookie_rid = $_COOKIE["jlog-rid"];
$url_rid = $command[0];

if ($cookie_rid && $cookie_rid == $url_rid) {
	# rid cookie already assigned; redirect to runner profile
	redirect_to('/runners/' . $url_rid);
} elseif (!$cookie_rid && $url_rid) {
	# no cookie; if the runner is already created, log in and redirect to runner profile; if not, create
	if (is_valid_runner($url_rid)) {
		login($url_rid);
		redirect_to('/runners/' . $url_rid);
	} else {		
		redirect_to('/create_runner/' . $url_rid);
	}
} elseif ($cookie_rid && !$url_rid) {
	# logged in, going to base page (no runner id in url) -- redirect to runner info
	redirect_to('/runners/' . $cookie_rid);
} elseif ($cookie_rid && $url_rid && ($cookie_id != $url_rid)) {
	# scanning a different rid than the one you're logged in as; if you're a chaser, then probably a tag; otherwise...TODO: notify somehow
	if (is_chaser($cookie_rid)) {
		redirect_to('/tagged/' . $url_rid . '/' . $cookie_rid);
	} else {
		# TODO: notify somehow instead of just redirecting to your info page
		redirect_to('/runners/' . $cookie_rid);
	}
} else {
	# no cookie and no url id -- probably direct url access by bot or player? redirect to instructions
	redirect_to('/instructions');
}
?>