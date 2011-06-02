<?
include('functions.php');

$all = get_all_checkpoint_ids();
foreach ($all as $check) {
	print $check."<br />";
}

?>