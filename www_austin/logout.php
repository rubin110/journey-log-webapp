<?php
require_once('functions.php');

$rid = $command[1];

logout($rid);
redirect_to('/instructions');

?>