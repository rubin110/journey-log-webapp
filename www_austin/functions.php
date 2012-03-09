<?
//functions.php
include("settings.php");

$tz = 'US/Central';
# this is 8PM Central -- I'm assuming this is the correct time to start; if not, we can change it
$game_start_time = 1331431200;

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

#####################################################################
## display functions -- in particular, runner create/edit form
##I'm sure there are nice libraries to do this, and we should be using one
#####################################################################

function email_or_twitter_taken($email, $twitter) {
	$mysqli = connectdb();

	$query = "SELECT runner_id, player_email, player_twitter_handle FROM ".RUNNERS_TBL." WHERE player_email = ? OR player_twitter_handle = ? LIMIT 1";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('ss', $email, $twitter);
	$stmt->execute();
	$stmt->bind_result($rid, $returned_email, $returned_twitter);
	$stmt->fetch();
	$stmt->close();
	
	return(array($rid, $email && ($returned_email == $email), $twitter && ($returned_twitter == $twitter)));	
}

function form_results($rid, $name, $email, $twitter, $submitted) {
	$is_edit = is_valid_runner($rid);
	
	$name_error = false;
	$email_error = false;
	$twtter_error = false;

	# do 'validation' if it's being submitted
	if ($submitted) {
		if (!$rid) {
			return("<p>...how are you even here?  I have no idea who you are.  Scan your QR code.</p>");
		}
		if (!$name) {
			$name_error = "*required";
		}
		if (!$email) {
			$email_error = "*required";
		}
		if ($email || $twitter) {
			list($rid_taken, $email_taken, $twitter_taken) = email_or_twitter_taken($email, $twitter);
			if ($email_taken && ($rid_taken != $rid)) {
				$email_error = "already registered";
			}
			if ($twitter_taken && ($rid_taken != $rid)) {
				$twitter_error = "already registered";
			}
		}
		if (!$name_error && !$email_error && !$twitter_error) {
			return(false);
		} else {
			return <<<RUNNER_FORM_WITH_ERRORS
			<form method="POST">
			<input type="hidden" name="rid" value="$rid" />
			<table>
			<tr><td>Public Player Name:</td><td><input type="text" name="name" value="$name" /></td><td class="error">$name_error</td></tr>
			<tr><td>Email address:</td><td><input type="text" name="email" value="$email" /></td><td class="error">$email_error</td></tr>
			<tr><td>Twitter handle (optional)</td><td><input type="text" name="twitter" value="$twitter" /></td><td class="error">$twitter_error</td></tr>
			</table><br />
			<input type="submit" value="Submit" />
			</form>
RUNNER_FORM_WITH_ERRORS;
		}
	} else {
		if ($is_edit) {
			return <<<EDIT_RUNNER_FORM
			<form method="POST">
			<input type="hidden" name="rid" value="$rid" />
			<table>
			<tr><td>Public Player Name:</td><td><input type="text" name="name" value="$name" /></td></tr>
			<tr><td>Email address:</td><td><input type="text" name="email" value="$email" /></td></tr>
			<tr><td>Twitter handle (optional)</td><td><input type="text" name="twitter" value="$twitter" /></td></tr>
			</table><br />
			<input type="submit" value="Submit" />
			</form>
EDIT_RUNNER_FORM;
		} else {
			return <<<NEW_RUNNER_FORM
			<form method="POST">
			<input type="hidden" name="rid" value="$rid" />
			<table>
			<tr><td>Public Player Name:</td><td><input type="text" name="name" /></td></tr>
			<tr><td>Email address:</td><td><input type="text" name="email" /></td></tr>
			<tr><td>Twitter handle (optional)</td><td><input type="text" name="twitter" /></td></tr>
			</table><br />
			<input type="submit" value="Submit" />
			</form>
NEW_RUNNER_FORM;
		}
	}
}

#####################################################################
## action functions -- log in, log out, redirect, etc.
#####################################################################

function login($rid) {
	# TODO: actually generate some cryptographic validation to store in the cookie
	setcookie("jlog-rid", $rid, time()+60*60*24*60, "/", $_SERVER['SERVER_NAME']);
}

function logout($rid) {
	setcookie("jlog-rid", $rid, time()-86400, "/", $_SERVER['SERVER_NAME']);
}

function redirect_to($location) {
	echo "<p>would be redirecting you to <a href='",$location,"'>",$location,"</a></p>";
	#echo "<script type='text/javascript'>window.location = '" . $location . "';</script>";
}

# check in
function checkin($rid, $cid, $checked_in_earlier) {
	$mysqli = connectdb();
	$stmt = $mysqli->prepare("INSERT INTO ".CHECKINS_TBL." (runner_id, checkpoint_id, checked_in_earlier, checkin_time) VALUES (?,?,?,NOW())");	
	$stmt->bind_param('ssi', $rid, $cid, $checked_in_earlier);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		_logger(LOG_CHECKIN, LOG_SUCCESS, $rid." checked in to ".get_checkpoint_name($cid));
		# update the number of people checked in to this checkpoint so far
		$stmt = $mysqli->prepare("UPDATE ".CHECKPOINTS_TBL." SET checked_in_so_far = checked_in_so_far+1 WHERE checkpoint_id = ?");	
		$stmt->bind_param('s', $cid);
		$stmt->execute();
		$stmt->close();
		# update the first checkin time
		$stmt = $mysqli->prepare("UPDATE ".CHECKPOINTS_TBL." SET first_checkin_at = NOW(), first_runner=? WHERE first_checkin_at IS NULL AND checkpoint_id = ?");	
		$stmt->bind_param('ss', $rid, $cid);
		$stmt->execute();
		$stmt->close();
		# update the most recent checkin time
		$stmt = $mysqli->prepare("UPDATE ".CHECKPOINTS_TBL." SET most_recent_checkin_at = NOW(), most_recent_runner=? WHERE checkpoint_id = ?");	
		$stmt->bind_param('ss', $rid, $cid);
		$stmt->execute();
		$stmt->close();
		return true;
	} else {
		if (is_already_checked_in($cid, $rid)) {
			_logger(LOG_CHECKIN, "", $rid." is already checked in to ".get_checkpoint_name($cid));
			$stmt->close();
			return true;
		} else {
			_logger(LOG_CHECKIN, LOG_FAILED, $rid." failed to check in to ".get_checkpoint_name($cid).": ".$stmt->error);
			$stmt->close();
			return false;
		}
	}	
}


#####################################################################
## generator functions -- helper functions for creating new ids and inserting new runners in the DB
#####################################################################

function new_runner_id() {
	$new_id = random_runner_id();
	while (is_valid_runner($new_id)) {
		$new_id = random_runner_id();
	}
	return $new_id;
}

function random_runner_id() {
	$length = 5;
	$chars = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";	

	$size = strlen( $chars );
	for( $i = 0; $i < $length; $i++ ) {
		$str .= $chars[ rand( 0, $size - 1 ) ];
	}

	return $str;
}

# generate a password hash
define('SALT_LENGTH', 8);
function generate_password_hash($password, $salt = null) {
    if ($salt === null) {
        $salt = substr(md5(uniqid(rand(), true)), 0, SALT_LENGTH);
    } else {
        $salt = substr($salt, 0, SALT_LENGTH);
    }
    return $salt . sha1($salt . $password);
}

# verify the password
function password_matches($password, $hash) {
	$salt = substr($hash,0,SALT_LENGTH);
	if ($hash == $salt . sha1($salt . $password)) {
		return true;
	} else {
		return false;
	}
}

function update_or_create_new_runner($rid, $name, $email, $twitter, $password) {
	$mysqli = connectdb();
	
	$hash = generate_password_hash($password);
	$query = "INSERT INTO ".RUNNERS_TBL." (runner_id, player_name, player_email, player_twitter_handle, hashed_password, created_at) VALUES (?,?,?,?,?,NOW()) ON DUPLICATE KEY UPDATE player_name=?, player_email=?, player_twitter_handle=?, hashed_password=?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('sssssssss',$rid, $name, $email, $twitter, $hash, $name, $email, $twitter, $hash);
	$stmt->execute();
	if ($stmt->affected_rows > 0) {
		$stmt->close();
		_logger(LOG_USERREGISTER, LOG_SUCCESS, $rid." updated or created their info. player_name='".$name."' player_email=".$email);
		return true;
	} else {
		$stmt->close();
		_logger(LOG_USERREGISTER, LOG_SUCCESS, $rid." failed to update or create their info. player_name='".$name."' player_email=".$email);
		return false;
	}
}

#####################################################################
## db access helper functions -- get data on users and checkpoints
#####################################################################

function get_checkpoint_name($cid) {
	$cid = clean_checkpoint_id($cid);
	$mysqli = connectdb();

	$query = "SELECT checkpoint_name FROM ".CHECKPOINTS_TBL." WHERE checkpoint_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $cid);
	$stmt->execute();
	$stmt->bind_result($checkpoint_name);
	$stmt->fetch();
	$stmt->close();
	
	return($checkpoint_name);
}

function get_checkpoint_name_and_status($cid) {
	$cid = clean_checkpoint_id($cid);
	$mysqli = connectdb();

	$query = "SELECT checkpoint_name, checked_in_so_far FROM ".CHECKPOINTS_TBL." WHERE checkpoint_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $cid);
	$stmt->execute();
	$stmt->bind_result($checkpoint_name, $checked_in_so_far);
	$stmt->fetch();
	$stmt->close();
	
	return(array($checkpoint_name, $checked_in_so_far));
}

#Return true if this runner id is marked as a chaser
function is_chaser($rid) {
	$rid = clean_runner_id($rid);
	$mysqli = connectdb();

	$query = "SELECT runner_id FROM ".RUNNERS_TBL." WHERE is_tagged=1 AND runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $rid);
	$stmt->execute();
	$stmt->store_result();
	$row_cnt = $stmt->num_rows;
	$stmt->close();
	if ($row_cnt > 0) {
		return true;
	} else {
		return false;
	}
}

#Return true if this runner id is in the db
function is_valid_runner($rid) {
	$rid = clean_runner_id($rid);
	$mysqli = connectdb();

	$query = "SELECT runner_id FROM ".RUNNERS_TBL." WHERE runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $rid);
	$stmt->execute();
	$stmt->store_result();
	$row_cnt = $stmt->num_rows;
	$stmt->close();
	if ($row_cnt > 0) {
		return true;
	} else {
		return false;
	}
}

function get_runner_name($rid) {
	$rid = clean_runner_id($rid);	
	$mysqli = connectdb();
	
	$query = "SELECT player_name FROM ".RUNNERS_TBL." WHERE runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $rid);
	$stmt->execute();
	$stmt->bind_result($runner_name);
	$stmt->fetch();
	$stmt->close();
	
	return($runner_name);
}

function get_runner_twitter($rid) {
	$rid = clean_runner_id($rid);	
	$mysqli = connectdb();
	
	$query = "SELECT player_twitter_handle FROM ".RUNNERS_TBL." WHERE runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $rid);
	$stmt->execute();
	$stmt->bind_result($player_twitter_handle);
	$stmt->fetch();
	$stmt->close();
	
	return($player_twitter_handle);
}

function get_runner_details($rid) {
	$rid = clean_runner_id($rid);	
	$mysqli = connectdb();
	
	$query = "SELECT player_name, player_email, player_twitter_handle FROM ".RUNNERS_TBL." WHERE runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('s', $rid);
	$stmt->execute();
	$stmt->bind_result($runner_name, $email, $twitter);
	$stmt->fetch();
	$stmt->close();
	
	return(array($runner_name, $email, $twitter));
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

#Return runner_id with only alphanumeric characters and all uppercase
function clean_runner_id($rid) {
	return strtoupper(preg_replace("/[^a-zA-Z0-9\s]/", "", $rid));
}

function clean_checkpoint_id($cid) {
	return strtoupper(preg_replace("/[^a-zA-Z0-9\s]/", "", $cid));
}

#Return an array of all checkpoint info
function get_all_checkpoint_info() {
	$mysqli = connectdb();
	$result = $mysqli->query("SELECT checkpoint_name, checked_in_so_far, first_checkin_at from ".CHECKPOINTS_TBL." ORDER BY checkpoint_order, checkpoint_name");
    $return_array = array();
    while($row = $result->fetch_row()) {
      $return_array[] = $row;
    }
	$result->close();
	return $return_array;
}

#Return an array of all runner checkin
function get_runner_checkin_info($rid) {
	$rid = clean_runner_id($rid);
	$mysqli = connectdb();
	$result = $mysqli->query("SELECT cp.checkpoint_name, c.checked_in_earlier, c.checkin_time FROM ".CHECKPOINTS_TBL." as cp JOIN ".CHECKINS_TBL." as c ON c.checkpoint_id=cp.checkpoint_id WHERE runner_id = '$rid' ORDER BY c.checkin_time");
    $return_array = array();

    while($row = $result->fetch_row()) {
      $return_array[] = $row;
    }
	$result->close();
	return $return_array;
}

function is_already_checked_in($cid, $rid) {
	$cid = clean_checkpoint_id($cid);
	$rid = clean_runner_id($rid);
	$mysqli = connectdb();
	
	$query = "SELECT COUNT(*) FROM ".CHECKINS_TBL." WHERE checkpoint_id = ? and runner_id = ?";
	$stmt = $mysqli->prepare($query);
	$stmt->bind_param('ss', $cid, $rid);
	$stmt->execute();
	$stmt->bind_result($is_checkedin_already);
	$stmt->fetch();
	$stmt->close();
	if ($is_checkedin_already) {
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


function total_runners_tagged() {
	$mysql = connectdb(true);
	$query = "SELECT COUNT(*) from ".RUNNERS_TBL." WHERE is_tagged = 1";
	$result = mysql_query($query, $mysql);
	$row = mysql_fetch_array($result);
	return $row[0];
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

