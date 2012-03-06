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

echo 'got request ' , $_SERVER['REQUEST_URI'] , '<br />';
echo 'switching on command ' , $command[0] , '<br />';

switch($command[0]) {
  # Instructions page
  case 'instructions' :
    echo 'Sending you instructions';
    break;

  # Checkpoint Redirect page
  case 'c' :
    echo 'checkpoint redirect for ' + $command[1];
    break;

  # Checkpoint Checkin page	
  case 'checkins' :
    echo 'you are checking in';
    break;

  # Player Profile page
  case 'runners' :
    echo 'player profile for ' + $command[1];
    break;

  # Runner Generate New Runner Id -- in case we don't print unique QR codes on manifests
  case 'rid' :
  	echo 'you are trying to generate a new runner id';
	include('new_runner_id.php');
    break;

  # Runner Create form page
  case 'create_runner' :
    echo 'you are making a new runner (and should be passing params)';
	include('create_runner.php');
    break;

  # Runner Edit page
  case 'edit_runner' :
    echo 'you are editing a runner';
    break;

  # Tagged page
  case 'tagged' :
    echo 'you are logging a tag';
    break;

  # Logout page
  case 'logout' :
    echo 'you are logging out';
    break;

  # Global info page
  case 'info' :
    echo 'secret global info page';
    break;
	
  # Runner Redirect page
  default:
    echo 'a runner redirect for ' , $command[1];
    break;
}

?>