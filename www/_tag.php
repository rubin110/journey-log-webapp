<?
//user has a jlog-rid cookie set, so this means they scanned the qr code of someone they tagged
include('mobile-friendly.html');
include('functions.php');

$tagger_id = clean_chaser_id($_GET['tid']);
$runner_id = clean_runner_id($_GET['rid']);

if ($_SERVER['REQUEST_METHOD'] == 'POST'){
	$tagger_id = clean_chaser_id($_POST['tagger_id']);
	$runner_id = clean_chaser_id($_POST['runner_id']);
	$loc_lat = $_POST['latitude'];
	$loc_long = $_POST['longitude'];
	if (empty($loc_lat)) {
		$loc_lat = 0;
	}
	if (empty($loc_long)) {
		$loc_long = 0;
	}
	print "Registering tag: Tagger ".$tagger_id." tagged Runner ".$runner_id." at ".$loc_lat.",".$loc_long."<br />";
	if (is_valid_runner($tagger_id) && is_valid_runner($runner_id)) {
		if (register_tag($tagger_id, $runner_id, $loc_lat, $loc_long)) {
			print "Oh shit, you tagged someone! Good job<br />";
			print "Tag registered!<br />";
		} else {
			if (tag_exists($tagger_id, $runner_id)) {
				print "You've already tagged this runner.<br />";
			} else {
				print "Oops, something is broken<br />";
			}
		}
	} else {
		print "Invalid data<br />";
		if (DEBUG) print "Invalid tagger or runner<br />";
	}

} else {
?>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>
<script>
	navigator.geolocation.getCurrentPosition(foundLocation, noLocation);

	function foundLocation(position)
	{

	  $('#latitude').val(position.coords.latitude);
	  $('#longitude').val(position.coords.longitude);
	  
	}
	function noLocation()
	{
	  alert('Could not find location');
	}
</script>

<form name="tag_runner" action="<?= $_SERVER['PHP_SELF']; ?>" method="post">
<?php if (is_valid_runner($tagger_id)){
print '<p><span style="color=red;">Pursuing Chaser: </span><br><input id="tagger_id" name="tagger_id" value="'.$tagger_id.'" readonly>';
}
else {
	print '<p><span style="color=red;">Pursuing Chaser: </span><br><input id="tagger_id" name="tagger_id" value="">';
};
?>
<p><span style="color=blue;">Tagged Runner: </span><br><input id="runner_id" name="runner_id" value="<?= $runner_id ?>">
<p>Lat:<br><input id="latitude" type="text" name="latitude" value="" readonly>
<p>Log:<br><input id="longitude" type="text" name="longitude" value="" readonly>
<p><input type="submit" value="I tagged them!"></p>


<?
}
?>
