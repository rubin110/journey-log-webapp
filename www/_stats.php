<?
/*
Oh man is this quick and dirty. This makes way too many database calls and could be made
more efficient but we're assuming not many people are going to be using this. A quick
fix would be to cronjob this shit and pipe it to a static html file every 5 min or so.
*/

include('functions.php');

$checkpoints = get_all_checkpoint_ids();

function total_runners() {
	$mysql = connectdb(true);
	$query = "SELECT COUNT(*) from ".RUNNERS_TBL;
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];	
}

function total_runners_registered($registered_status) {
	$mysql = connectdb(true);
	$query = "SELECT COUNT(*) from ".RUNNERS_TBL." WHERE is_registered = ".$registered_status;
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];
}

function total_runners_tagged() {
	$mysql = connectdb(true);
	$query = "SELECT COUNT(*) from ".RUNNERS_TBL." WHERE is_tagged = 1";
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];
}

function total_runners_registered_untagged($registered_status) {
	$mysql = connectdb(true);
	$query = "SELECT COUNT(*) from ".RUNNERS_TBL." WHERE is_registered=".$registered_status." AND is_tagged = 0";
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];
}

function total_checkpoint_checkins($checkpoint_id) {
	$mysql = connectdb(true);
	$query = "SELECT COUNT(*) from ".CHECKINS_TBL." WHERE checkpoint_id=".$checkpoint_id;
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];
}

function most_recent_checkin($checkpoint_id) {
	$mysql = connectdb(true);
	$query = "SELECT * from ".CHECKINS_TBL." WHERE checkpoint_id=".$checkpoint_id." ORDER BY checkin_time DESC LIMIT 1";
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result, MYSQL_BOTH);
	return $row;
}

function active_chasers($time = "") {
	$mysql = connectdb(true);
	//Query that pulls all the unique chasers that have reistered at least one tag
	if ($time!="") {
		$query = "SELECT COUNT(DISTINCT tagger_id) from ".TAGS_TBL." WHERE tag_time > (now() - interval ".$time." minute)";
	} else {
		$query = "SELECT COUNT(DISTINCT tagger_id) from ".TAGS_TBL;
	}
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];
}

print "Total Runners in Database: ".total_runners()."<br />";
print "Registered Runners: ".total_runners_registered(1)."<br />";
print "Unregistered Runners: ".total_runners_registered(0)."<br />";
print "<br />";
print "Runners that have been tagged: ".total_runners_tagged()."<br />";
print "Registered Runners remaining: ".total_runners_registered_untagged(1)."<br />";
print "Unregistered runners remaining: ".total_runners_registered_untagged(0)."<br />";
print "<br />";
print "<b>Tag Stats</b><br />";
print "Active Taggers: ".active_chasers()."<br />";
print "Active Taggers in last 30min: ".active_chasers(30)."<br />";
print "<br />";
print "<b>Checkpoint Stats:</b><br />";
foreach ($checkpoints as $checkpoint_id) {
	print get_checkpoint_name($checkpoint_id).":<br />";
	print "&nbsp;&nbsp&nbsp;Checkins: ".total_checkpoint_checkins($checkpoint_id)."<br />";
	$most_recent = most_recent_checkin($checkpoint_id);
	if (!empty($most_recent)) {
		print "&nbsp;&nbsp&nbsp;Most recent checkin: ".get_runner_name($most_recent['runner_id'])." (".$most_recent['runner_id'].") at ".$most_recent['checkin_time']."<br />";
	}
	print "<br />";
}

print "<ost recent"
?>
