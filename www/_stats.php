<?
/*
Oh man is this quick and dirty. This makes way too many database calls and could be made
more efficient but we're assuming not many people are going to be using this. A quick
fix would be to cronjob this shit and pipe it to a static html file every 5 min or so.
*/

include('functions.php');

$checkpoints = get_all_checkpoint_ids();


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
	print "<h2>".get_checkpoint_name($checkpoint_id).":</h2>";
	print "&nbsp;&nbsp&nbsp;Checkins: ".total_checkpoint_checkins($checkpoint_id)."<br />";
	$most_recent = most_recent_checkin($checkpoint_id);
	if (!empty($most_recent)) {
		print "&nbsp;&nbsp&nbsp;Most recent checkin: ".get_runner_name($most_recent['runner_id'])." (".$most_recent['runner_id'].") at ".$most_recent['checkin_time']."<br />";
		print "<img src=\"/photos/".$most_recent['runner_id'].".jpg\" style=\"margin-left: 25px;\"><br />";
	}
	print "<br />";
}

print "<ost recent"
?>
