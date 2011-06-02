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
	$result = $mysqli->query("SELECT runner_id from ".RUNNERS_TBL." WHERE runner_id = ".$id);
	$row_cnt = $result->num_rows;
	if ($row_cnt > 0) {
		return true;
	} else {
		return false;
	}
}

#Return runner_id with only alphanumeric characters and all uppercase
function clean_runner_id($rid) {
	return strtoupper(preg_replace("/[^a-zA-Z0-9\s]/", "", $rid));
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
	$mysql = connectdb(true);
	$query = "SELECT checkpoint_name FROM ".CHECKPOINTS_TBL." WHERE checkpoint_id = ".$cid;
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	return $row[0];
}







