<?php
include('mobile-friendly.html');
include('functions.php');

$jlogCID = $_COOKIE["jlog-cid"];
$jlogRID = $_COOKIE["jlog-rid"];

$command = explode('/', substr($_SERVER['REQUEST_URI'],1));

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

  # Runner Create form page
  case 'new_runner' :
    echo 'you are making a new runner (and should be passing params)';
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