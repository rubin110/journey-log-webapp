<?php
require_once('functions.php');

$cookie_rid = $_COOKIE["jlog-rid"];

if ($cookie_rid) {
	echo "<p>You are logged in with runner id " , $cookie_rid , "</p>\n";
} else {
	echo "<p>Scan your QR code to log in.</p>\n";
}

echo "<p>Your instructions: After scanning your QR code to log in, scan the QR codes of the checkpoints in order to log your time at each one.  If you are tagged, the chaser may scan your QR code to register that you are tagged.  If you tag someone, you can scan their QR code to record that you tagged them.  You can always scan your own QR code again to get your stats.</p>";

if ($cookie_rid) {
	if (get_runner_twitter($cookie_rid)) {
		$seconds_until_start = $game_start_time - time();
		if ($seconds_until_start > 0) {
			$m = (int)($seconds_until_start / 60); $s = $seconds_until_start % 60;
			$h = (int)($m / 60); $m = $m % 60;
			$timestring = str_pad($h,2,'0') . ":" . str_pad($m,2,'0') . ":" . str_pad($s,2,'0');
			$twitterString="t-$timestring until Journey starts! Hurry to Spiral Hill in Butler Park! #sxsw #jtteotn";
			echo "<p>$twitterString</p>";
			echo "<p>(link to tweet this: )</p>";
		}
	}
	echo "<p><a href='/runners/" , $cookie_rid , "'>View your stats</a></p>\n";
} else {
	echo "<p>Scan your QR code to log in.</p>\n";
}

?>