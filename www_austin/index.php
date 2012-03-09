<?php
include('mobile-friendly.html');
require_once('functions.php');

$jlogCID = $_COOKIE["jlog-cid"];
$jlogRID = $_COOKIE["jlog-rid"];

$request_str = $_SERVER['REQUEST_URI'];
$param_pos = strpos($request_str, '?');
if ($param_pos > 0)
  $request_str = substr($request_str, 0, $param_pos);
$command = explode('/', substr($request_str,1));

#echo 'got request ' , $_SERVER['REQUEST_URI'] , '<br />';
#echo 'switching on command ' , $command[0] , '<br />';

switch($command[0]) {
  # Instructions page
  case 'instructions' :
    include('instructions.php');
    break;

  # Checkpoint Redirect page
  case 'c' :
	include('checkin.php');
    break;

  # Player Profile page
  case 'runners' :
    include('player_profile.php');
    break;

  # Runner Generate New Runner Id -- in case we don't print unique QR codes on manifests or need a backup
  case 'rid' :
	include('new_runner_id.php');
    break;

  # Runner Create form page
  case 'create_runner' :
	include('create_runner.php');
    break;

  # Runner Edit page
  case 'edit' :
	include('edit.php');
    break;

  # Tagged page: note that it is /tagged/<target>/<tagger>
  case 'tagged' :
	include('tagged.php');
    break;

  # Resurrected page
  case 'resurrected' :
	include('resurrected.php');
    break;

  # Logout page
  case 'logout' :
    include('logout.php');
    break;

  # Global info page
  case 'info' :
	include('info.php');
    break;
	
  # Runner Redirect page
  default:
	include('runner_redirect.php');
    break;
}

?>