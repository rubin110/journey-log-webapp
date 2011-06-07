<?
include('mobile-friendly.html');

setcookie("jlog-cid", $cid, time()-86400, "/", $_SERVER['SERVER_NAME']);
setcookie("jlog-rid", $cid, time()-86400, "/", $_SERVER['SERVER_NAME']);
print "Cleared all cookies";

?>