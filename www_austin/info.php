<?php
require_once('functions.php');

$checkpoint_info = get_all_checkpoint_info();

echo "<table><tr><th>Checkpoint name</th><th>Num checked in</th><th>First Checkin</th></tr>\n";
foreach ($checkpoint_info as &$row) {
	echo "<tr><td>",$row[0],"</td><td>",$row[1],"</td><td>",$row[2],"</td></tr>\n";
}
echo "</table>\n"
?>