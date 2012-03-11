<?php
$starttime = strftime('%s');
$starttime_file = "starttime";
$fh = fopen($starttime_file, 'a');
fwrite($fh, $starttime);
fclose($fh);
print $starttime
?>
