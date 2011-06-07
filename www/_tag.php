<?
//user has a jlog-rid cookie set, so this means they scanned the qr code of someone they tagged
include('mobile-friendly.html');
include('functions.php');

$tagger_id = clean_chaser_id($_GET['tid']);
$runner_id = clean_runner_id($_GET['rid']);

if ($_SERVER['REQUEST_METHOD'] == 'POST'){
	if ((empty($_POST['tagger_id'])) || (empty($_POST['runner_id']))) {
		print "Missing data to register tag. Please rescan runner's QR code<br />";
		die();
	}
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
			if (is_player_tagge($runner_id)) {
				print "This runner has already been tagged!<br />";
				die();
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
<input id="tagger_id" type="hidden" name="tagger_id" value="<?= $tagger_id ?>">
<input id="runner_id" type="hidden" name="runner_id" value="<?= $runner_id ?>">
<input id="latitude" type="hidden" name="latitude" value="">
<input id="longitude" type="hidden" name="longitude" value="">
<p><input type="submit" value="I tagged them!"></p>


<?
}
?>
