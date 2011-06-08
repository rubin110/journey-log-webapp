<?
//user has a jlog-rid cookie set, so this means they scanned the qr code of someone they tagged
include('mobile-friendly.html');
include('functions.php');
print '<h2>Journey Log</h2>';
$tagger_id = clean_chaser_id($_GET['tid']);
$runner_id = clean_runner_id($_GET['rid']);

if ($_SERVER['REQUEST_METHOD'] == 'POST'){
	$tagger_id = clean_chaser_id($_POST['tagger_id']);
	$runner_id = clean_chaser_id($_POST['runner_id']);
	$loc_lat = $_POST['latitude'];
	$loc_long = $_POST['longitude'];
	$loc_addr = $_POST['address'];
	if (empty($loc_lat)) {
		$loc_lat = 0;
	}
	if (empty($loc_long)) {
		$loc_long = 0;
	}
	print '<h3>Registering Tag</h3>
	<p><span style="color:red;">Chaser '.$tagger_id.'</span> tagged <span style="color:blue;">Runner '.$runner_id.'</span> at '.$loc_lat.','.$loc_long.'.<br />';
	if (is_valid_runner($tagger_id) && is_valid_runner($runner_id)) {
		if (register_tag($tagger_id, $runner_id, $loc_lat, $loc_long)) {
			print '<h3>Your tag is checked in!</h3><div style="font-size:14em;color:green;text-align: center;">&#10003;</div>';
		} else {
			if (tag_exists($tagger_id, $runner_id)) {
				print '<h3>You\'ve already tagged this runner!</h3><div style="font-size:14em;color:red;text-align: center;">X</div>';
			} else {
				print '<h3>Oops, something is broken</h3><div style="font-size:14em;color:red;text-align: center;">X</div>';
			}
		}
	} else {
		if (DEBUG) print '<h3>Invalid tagger or runner</h3><div style="font-size:14em;color:red;text-align: center;">X</div>';
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
<h3>Checkin your Tag</h3>
<p>Note: Be sure the <span style="color:red;">Chaser</span> is scanning the <span style="color:blue;">Runner's</span> Runner ID on the <span style="color:red;">Chaser's</span> phone!
<form name="tag_runner" action="<?= $_SERVER['PHP_SELF']; ?>" method="post">
<?php if (is_valid_runner($tagger_id)){
	print '<p><div style="color:red;">Pursuing Chaser: </div><input id="tagger_id" name="tagger_id" value="'.$tagger_id.'" readonly>';
}
else {
	print '<p><div style="color:red;">Pursuing Chaser: </div><input id="tagger_id" name="tagger_id" value="">';
};
if (is_valid_runner($runner_id)){
	print '<p><div style="color:blue;">Tagged Runner: </div><input id="runner_id" name="runner_id" value="'.$runner_id.'" readonly>';
}
else {
	print '<p><div style="color:blue;">Tagged Runner: </div><input id="runner_id" name="runner_id" value="">';
};
?>
<p>Lat:<br><input id="latitude" type="text" name="latitude" value="" readonly>
<p>Log:<br><input id="longitude" type="text" name="longitude" value="" readonly>
<p><input type="submit" value="I tagged them!"></p>


<?
}
?>
