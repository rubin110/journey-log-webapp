<?
#Register players via staff app
#Accessed via agent/app/autoreg
//include('functions.php');
$destination_folder = "/photos/";

//Receives post data and insert into database
/*
$key = $_POST['key'];

if ($key !== "doorhenge") {
	die();
}
*/


$runner_id = clean_runner_id($_POST['runner_id']);
$photo_name = $runner_id.".jpg";

print "<h2>Journey Log<br>Autoregistering runner ".$runner_id."</h2>";


if ($_FILES["player_photo"]["error"] > 0)
{
	echo "Error Code: " . $_FILES["player_photo"]["error"] . "<br />";
} else {
	if (move_uploaded_file($_FILES["player_photo"]["tmp_name"],"photos/" . $photo_name)) {
		print "Successfully processed image<br />";
	} else {
		print "Error processing image<br />";
		die();
	}
}

if (is_runner_registered($runner_id)) {
	print "Runner is already registered<br />";
} else {
	#Register runner	
	if (register_runner_app($runner_id)) {
		print "Runner successfully registered<br />";
	} else {
		print "Failed to register runner<br />";
	}
}
/*
    $_FILES["file"]["name"] - the name of the uploaded file
    $_FILES["file"]["type"] - the type of the uploaded file
    $_FILES["file"]["size"] - the size in bytes of the uploaded file
    $_FILES["file"]["tmp_name"] - the name of the temporary copy of the file stored on the server
    $_FILES["file"]["error"] - the error code resulting from the file upload
*/

?>