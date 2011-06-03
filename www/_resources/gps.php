<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Journey Log</title>
</head>
<body>
	<script>
	navigator.geolocation.getCurrentPosition(foundLocation, noLocation);

	function foundLocation(position)
	{
	  var lat = position.coords.latitude;
	  var long = position.coords.longitude;
	  alert('Found location: ' + lat + ', ' + long);
	}
	function noLocation()
	{
	  alert('Could not find location');
	}
	</script>
</body>
</html>
