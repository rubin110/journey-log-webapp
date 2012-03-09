<?php
require_once('functions.php');

$cookie_rid = $_COOKIE["jlog-rid"];

resurrect($cookie_rid);

echo "<p>You have been resurrected.</p>";

$twitterString="I'm resurrected and back in the running! #sxsw #jtteotn";
echo "<p><a href='http://twitter.com/intent/tweet?text=$twitterString'>Tweet it!</a> $twitterString</p>";


?>