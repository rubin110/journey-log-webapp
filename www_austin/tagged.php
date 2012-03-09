<?php
require_once('functions.php');

$target_id = $command[1];
# NOTE: $chaser_id may be empty
$chaser_id = $command[2];
$cookie_rid = $_COOKIE["jlog-rid"];

if (is_chaser($target_id)) {
	echo "<p>Runner $target_id has been marked as tagged.</p>";
} else {
	tag($target_id, $chaser_id);
	$num_tagged = '';
	if ($chaser_id) {
		$num_tagged = get_num_tagged_by($chaser_id);
		$chaser_name = get_runner_name($chaser_id);
	}
	echo "<p>Runner $target_id has been tagged.</p>";
	if ($num_tagged) {
		echo "<p>$chaser_name has claimed victim number $num_tagged.</p>";
	}
	if ($cookie_rid == $chaser_id) {
		$tagged_name = get_runner_name($target_id);
		if ($tagged_name) {
			$twitterString="I just tagged $tagged_name -- victim number $num_tagged! #sxsw #jtteotn";						
		} else {
			$twitterString="I just tagged victim number $num_tagged! #sxsw #jtteotn";			
		}		
		echo "<p><a href='http://twitter.com/intent/tweet?text=" . clean_tweet($twitterString) . "'>Tweet it!</a> $twitterString</p>";				
	} elseif ($cookie_rid == $target_id) {
		$twitterString="I've been tagged -- now /I/ am a chaser, ready to stalk the runners through the night. #sxsw #jtteotn";
		echo "<p><a href='http://twitter.com/intent/tweet?text=" . clean_tweet($twitterString) . "'>Tweet it!</a> $twitterString</p>";		
	}
}

?>