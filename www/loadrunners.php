<?
include('functions.php');
/* Shouldn't need this now since they're all in the .sql file
function insert_runner_id($runner_id) {
	$mysqli = connectdb();
	$query = "INSERT INTO ".RUNNERS_TBL." (runner_id) VALUES (?)";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $runner_id);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		return true;
	} else {
		$stmt->close();
		return false;
	}
}

if ($fh = fopen('runneridtable',r)) {
	while (!feof($fh)) {
		$runner_id = trim(fgets($fh));
		print $runner_id;
		if (!empty)
		if (insert_runner_id($runner_id)) {
			print " added<br />\n";
		}
	}
	
	fclose($fh);
}
*/

?>
