<?
//functions.php
include("settings.php");

#####################################################################
## function connectdb()
## connects us to our database (DB_NAME) on server (DB_SERVER) with the defined (DB_LOGIN) 
## and (DB_PASSWORD)
#####################################################################
function connectdb($reg_mysql=false) {
    // Connecting, selecting database
    if ($reg_mysql) {
    	$link = mysql_connect(DB_SERVER, DB_LOGIN, DB_PASSWD);
    	mysql_select_db(DB_NAME, $link);
    	return $link;
    } else {
    	$mysqli = new mysqli(DB_SERVER,DB_LOGIN,DB_PASSWD, DB_NAME)
    		or die("Could not connect");
		return $mysqli;
	}
}

function _logger($type,$result,$message) {
	/* $type should be TAG, CHECKIN, REGISTER, anything else?
		We should also never log line breaks in $message
		$result is FAIL or SUCCESS
	*/
	$timestamp = date('d/M/Y:H:i:s O');
	$ip_address = $_SERVER['REMOTE_ADDR'];
	$logfile = "journeylog.log";
	$fh = fopen($logfile, 'a');
	fwrite($fh, "[".$timestamp."] ".$ip_address." -- ".$type." -- ".$result." -- ".$message."\n");
	fclose($fh);
}

function get_start_time() {
	$mysqli = connectdb();
	$query = "SELECT time FROM ".OTHER_TBL." WHERE event='start'";
	$stmt = $mysqli->prepare($query);
	$stmt->execute();
	$stmt->bind_result($starttime);
	$stmt->fetch();
	return $starttime;
}

function get_end_time() {
	$mysqli = connectdb();
	$query = "SELECT time FROM ".OTHER_TBL." WHERE event='end'";
	$stmt = $mysqli->prepare($query);
	$stmt->execute();
	$stmt->bind_result($endtime);
	$stmt->fetch();
	return $endtime;

}

#Return true if this checkpoint exists in the database
function is_valid_checkpoint($id) {
	$mysqli = connectdb();
	$result = $mysqli->query("SELECT checkpoint_id from ".CHECKPOINTS_TBL." WHERE checkpoint_id = ".$id);
	$row_cnt = $result->num_rows;
	if ($row_cnt > 0) {
		return true;
	} else {
		return false;
	}
}

#Return true if this runner id exists in the database
function is_valid_runner($id) {
	$mysqli = connectdb();
	$query = "SELECT runner_id FROM ".RUNNERS_TBL." WHERE runner_id = '".$id."'";
	$result = $mysqli->query($query);
	$row_cnt = $result->num_rows;
	if ($row_cnt > 0) {
		return true;
	} else {
		return false;
	}
}

function get_runner_name($rid) {
	$rid = clean_runner_id($rid);
	$mysql = connectdb(true);
	$query = "SELECT player_name FROM ".RUNNERS_TBL." WHERE runner_id = '".$rid."'";
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	if (!empty($row[0])) {
		return $row[0];
	} else {
		return $rid;
	}
}

function get_runner_email($rid) {
	$rid = clean_runner_id($rid);
	$mysql = connectdb(true);
	$query = "SELECT player_email FROM ".RUNNERS_TBL." WHERE runner_id = '".$rid."'";
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	return $row[0];
}

#Return runner_id with only alphanumeric characters and all uppercase
function clean_runner_id($rid) {
	return strtoupper(preg_replace("/[^a-zA-Z0-9\s]/", "", $rid));
}

#Return chaser_id with only alphanumeric characters and all uppercase
function clean_chaser_id($chaser_id) {
	return strtoupper(preg_replace("/[^a-zA-Z0-9\s]/", "", $chaser_id));
}

function clean_checkpoint_id($cid) {
	return preg_replace("/[^a-zA-Z0-9\s]/", "", $cid);
}


#Return an array of all checkpoint ids
function get_all_checkpoint_ids() {
	$mysqli = connectdb();
	$result = $mysqli->query("SELECT checkpoint_id from ".CHECKPOINTS_TBL." WHERE 1 ORDER BY checkpoint_name");
	while ($row = $result->fetch_object()) {
		$return_array[] = $row->checkpoint_id;
	}
	return $return_array;
}

function get_checkpoint_name($cid) {
	$cid = clean_checkpoint_id($cid);
	$mysql = connectdb(true);
	$query = "SELECT checkpoint_name FROM ".CHECKPOINTS_TBL." WHERE checkpoint_id = ".$cid;
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	return $row[0];
}

#Register runner
function register_runner_app($rid) {
	$mysqli = connectdb();
	$query = "UPDATE ".RUNNERS_TBL." SET is_mugshot=1 WHERE runner_id=?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s',$rid);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		_logger(LOG_REGISTER, LOG_SUCCESS, $rid." registered.");
		return true;
	} else {
		$stmt->close();
		_logger(LOG_REGISTER, LOG_FAIL, $rid." failed to register.");
		return false;
	}
}


#Check a runner ($rid) into a checkpoint ($cid)
function check_runner_in($cid, $rid, $device_id="", $lat="", $long="", $timestamp="") {
	$device_id = "some device";
	$user_agent = $_SERVER['HTTP_USER_AGENT'];
	$ip_address = $_SERVER['REMOTE_ADDR'];
	$mysqli = connectdb();
	$stmt = $mysqli->prepare("INSERT INTO ".CHECKINS_TBL." (runner_id, checkpoint_id, device_id, user_agent, ip_address, lat, lng, checkin_time) VALUES (?,?,?,?,?,?,?,?)");	
	//print "INSERT INTO ".CHECKINS_TBL." (runner_id, checkpoint_id, device_id, user_agent, ip_address, lat, lng, checkin_time) VALUES ($rid,$cid,$device_id,$user_agent,$ip_address,$lat,$long,$timestamp)";
	$stmt->bind_param('sissssss', $rid, $cid, $device_id, $user_agent, $ip_address, $lat, $long, $timestamp);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		_logger(LOG_CHECKIN, LOG_SUCCESS, $rid." checked in to ".get_checkpoint_name($cid)." ".$lat.",".$long."  ts=".$timestamp);
		return true;
	} else {
		$stmt->close();
		if (is_already_checked_in($cid, $rid)) {
			_logger(LOG_CHECKIN, "", $rid." is already checked in to ".get_checkpoint_name($cid));
		} else {
			_logger(LOG_CHECKIN, LOG_FAILED, $rid." failed to check in to ".get_checkpoint_name($cid)." ".$lat.",".$long);
		}
		return false;
	}
	
}

function is_already_checked_in($cid, $rid) {
	$rid = clean_runner_id($rid);
	$mysqli = connectdb();
	$query = "SELECT COUNT(*) FROM ".CHECKINS_TBL." WHERE checkpoint_id = ? and runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('ss', $cid, $rid);
	$stmt->execute();
	$stmt->bind_result($is_checkedin_already);
	$stmt->fetch();
	if ($is_checkedin_already) {
		return true;
	} else {
		return false;
	}
}

function register_tag($tagger_id, $runner_id, $loc_lat, $loc_long, $loc_addr) {
	$user_agent = $_SERVER['HTTP_USER_AGENT'];
	$ip_address = $_SERVER['REMOTE_ADDR'];
	$tag_time = date('Y-m-d H:i:s');
	$mysqli = connectdb();
	$query = "INSERT INTO ".TAGS_TBL." (runner_id, tagger_id, tag_time, loc_lat, loc_long, loc_addr, user_agent, ip_address) VALUES (?,?,?,?,?,?,?,?)";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('sssddsss', $runner_id, $tagger_id, $tag_time, $loc_lat, $loc_long, $loc_addr, $user_agent, $ip_address);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		//don't forget to set the "is_tagged" field in the runner table for $runner_id
		set_user_tagged($runner_id);
		_logger(LOG_TAG, LOG_SUCCESS, $tagger_id." tagged ".$runner_id." at ".$loc_lat.",".$loc_long." (".$loc_addr.") UserAgent='".$user_agent."' IpAddress=".$ip_address);
		return true;
	} else {
		$stmt->close();
		_logger(LOG_TAG, LOG_FAIL, $tagger_id." failed to tag ".$runner_id." at ".$loc_lat.",".$loc_long." (".$loc_addr.") UserAgent='".$user_agent."' IpAddress=".$ip_address);
		return false;
	}
}

function set_user_tagged($runner_id) {
	$mysqli = connectdb();
	$query = "UPDATE ".RUNNERS_TBL." SET is_tagged=1 WHERE runner_id=?";
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


function register_runner($runner_id, $runner_name, $email_address) {
	if (!is_valid_runner($runner_id)) {
		print "Not a valid runner<br />";
		return false;
	}
	$mysqli = connectdb();
	$query = "UPDATE ".RUNNERS_TBL." SET player_name=?, player_email=?, is_registered=1 WHERE runner_id=?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('sss',$runner_name, $email_address, $runner_id);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		_logger(LOG_USERREGISTER, LOG_SUCCESS, $runner_id." registered themselves. player_name='".$runner_name."' player_email=".$email_address);
		return true;
	} else {
		$stmt->close();
		_logger(LOG_USERREGISTER, LOG_FAIL, $rid." failed to register themselves. player_name='".$runner_name."' player_email=".$email_address);
		return false;
	}
}

function update_runner($runner_id, $runner_name, $email_address) {
	if (!is_valid_runner($runner_id)) {
		print "Not a valid runner<br />";
		return false;
	}
	$mysqli = connectdb();
	$query = "UPDATE ".RUNNERS_TBL." SET player_name=?, player_email=?, is_registered=1 WHERE runner_id=?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('sss',$runner_name, $email_address, $runner_id);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		_logger(LOG_USERREGISTER, LOG_SUCCESS, $runner_id." updated their info. player_name='".$runner_name."' player_email=".$email_address);
		return true;
	} else {
		$stmt->close();
		_logger(LOG_USERREGISTER, LOG_SUCCESS, $runner_id." failed to update their info. player_name='".$runner_name."' player_email=".$email_address);
		return false;
	}
}

function is_runner_registered($runner_id) {
	$mysqli = connectdb();
	$query = "SELECT is_registered FROM ".RUNNERS_TBL." WHERE runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $runner_id);
	$stmt->execute();
	$stmt->bind_result($is_registered);
	$stmt->fetch();
	if ($is_registered) {
		return true;
	} else {
		return false;
	}
}

function tag_exists($tagger_id, $runner_id) {
	$runner_id = clean_runner_id($runner_id);
	$tagger_id = clean_chaser_id($tagger_id);
	if (!is_valid_runner($tagger_id) || !is_valid_runner($runner_id)) {
		print "Invalid runner or tagger id<br/ >";
		return false;
	}
	
	$mysql = connectdb(true);
	$query = "SELECT tag_id FROM ".TAGS_TBL." WHERE tagger_id = '".$tagger_id."' AND runner_id = '".$runner_id."'";
	$result = mysql_query($query, $mysql);
	if (mysql_num_rows($result) > 0) {
		return true;
	} else {
		return false;
	}
}


/* STATS STUFF */
function time_between($from,$to) {
  $to = (($to === null) ? (time()) : ($to));
  $to = ((is_int($to)) ? ($to) : (strtotime($to)));
  $from = ((is_int($from)) ? ($from) : (strtotime($from)));

  $units = array
  (
   "year"   => 29030400, // seconds in a year   (12 months)
   "month"  => 2419200,  // seconds in a month  (4 weeks)
   "week"   => 604800,   // seconds in a week   (7 days)
   "day"    => 86400,    // seconds in a day    (24 hours)
   "hour"   => 3600,     // seconds in an hour  (60 minutes)
   "minute" => 60,       // seconds in a minute (60 seconds)
   "second" => 1         // 1 second
  );

  $diff = abs($from - $to);
//  $suffix = (($from > $to) ? ("from now") : ("ago"));

  foreach($units as $unit => $mult)
   if($diff >= $mult)
   {
    $and = (($mult != 1) ? ("") : ("and "));
    $output .= ", ".$and.intval($diff / $mult)." ".$unit.((intval($diff / $mult) == 1) ? ("") : ("s"));
    $diff -= intval($diff / $mult) * $mult;
   }
  $output .= " ".$suffix;
  $output = substr($output, strlen(", "));

  return $output;
}

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
	$checkpoint_id = clean_checkpoint_id($checkpoint_id);
	$mysql = connectdb(true);
	$query = "SELECT COUNT(*) from ".CHECKINS_TBL." WHERE checkpoint_id=".$checkpoint_id;
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];
}

function most_recent_checkin($checkpoint_id) {
	$checkpoint_id = clean_checkpoint_id($checkpoint_id);
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


// Converts PHP time format to SQL Time Format
function time_php2sql($unixtime){
    return gmstrftime("%G-%m-%d %H:%M:%S", $unixtime);
}

