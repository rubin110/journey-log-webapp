<?php
require_once('functions.php');

$cookie_rid = $_COOKIE["jlog-rid"];

resurrect($cookie_rid);

echo "<p>Runner $cookie_rid has been resurrected.</p>";

?>