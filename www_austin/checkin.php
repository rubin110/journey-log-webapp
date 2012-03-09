<?php
require_once('functions.php');

$cid = $command[1];
list($checkpoint_name, $checked_in_so_far) = get_checkpoint_name_and_status($cid);
$cookie_rid = $_COOKIE["jlog-rid"];

# echo "got cid ", $cid, " with runner id in cookie ", $cookie_rid, " and name ", $checkpoint_name, " and checked in so far ", $checked_in_so_far, "<br />\n";

if (!$cookie_rid) {
	echo "<p>You need to log in first!  Scan your QR code.</p>";
} elseif (!$checkpoint_name) {
	# TODO: this should never happen, unless someone tries entering a bad checkpoint code, so a confusing redirect/not mentioning the error is probably okay...but printing errors is usually better
	redirect_to('/instructions');
} else {
	if (is_chaser($cookie_rid)) {
		echo "<p>Sorry...you're a chaser.  We're glad you made it to this checkpoint, but your goal is now to tag runners.</p>";
		echo "<p><a href='/runners/$cookie_rid'>Check your stats</a></p>";
	} else {
		if (checkin($cookie_rid, $cid, $checked_in_so_far)) {
			echo "<p>You successfully checked in at " , $checkpoint_name , ". Only " , $checked_in_so_far , " runners checked in here before you did.</p>";		
			$seconds_since_start = time() - $game_start_time;
			$m = (int)($seconds_since_start / 60); $s = $seconds_since_start % 60;
			$h = (int)($m / 60); $m = $m % 60;
			$timestring = str_pad($h,2,'0',STR_PAD_LEFT) . ":" . str_pad($m,2,'0',STR_PAD_LEFT) . ":" . str_pad($s,2,'0',STR_PAD_LEFT);
			$twitterString="I survived to $checkpoint_name! Made it in $timestring, with only $checked_in_so_far runners ahead of me. #sxsw #jtteotn";
			echo "<p><a href='http://twitter.com/intent/tweet?text=" . clean_tweet($twitterString) . "'>Tweet it!</a> $twitterString</p>";
			echo "<p><a href='/runners/$cookie_rid'>Check your stats</a></p>";
		} else {
			echo "<p>You FAILED to check in at " , $checkpoint_name , "!</p>";				
		}		
	}
}

?>