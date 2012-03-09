<?php
require_once('functions.php');

$target_id = $command[1];
# NOTE: $chaser_id may be empty
$chaser_id = $command[2];

if (is_chaser($target_id)) {
	echo "<p>Runner $target_id has been marked as tagged.</p>";
} else {
	tag($target_id, $chaser_id);
	echo "<p>Runner $target_id has been tagged.</p>";
}

?>