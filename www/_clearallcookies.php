<?
include('mobile-friendly.html');
print '<h2>Journey Log</h2>';

setcookie("jlog-cid", $cid, time()-86400, "/", $_SERVER['SERVER_NAME']);
setcookie("jlog-rid", $cid, time()-86400, "/", $_SERVER['SERVER_NAME']);
print '<h3>Your phone is no longer bound to anything!</h3>
<div style="font-size:14em;color:red;text-align: center;">X</div>';

?>