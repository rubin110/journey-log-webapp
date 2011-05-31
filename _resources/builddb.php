<?php
// create database jlog;
// GRANT ALL ON jlog.* TO jloguser@localhost IDENTIFIED BY "y6kaYsHjW48ZRD";
// Make a MySQL Connection
mysql_connect("localhost","jloguser","y6kaYsHjW48ZRD") or die(mysql_error());
mysql_select_db("jlog") or die(mysql_error());

// Create a MySQL table in the selected database
mysql_query("CREATE TABLE jlog_data
(
uid int unsigned not null auto_increment primary key,
rid varchar(5),
name varchar(256),
email varchar(256),
CP0 int,
CP1A int,
CP1B int,
CP2A int,
CP2B int,
CP3 int,
CP4 int,
CP5 int,
CP6 int,
CP7 int,
BA int,
BB int,
tag int,
tagloc varchar(256))")
 or die(mysql_error());  

echo "jlog_data Table Created!";

mysql_query("CREATE TABLE jlog_event
(
eid int unsigned not null auto_increment primary key,
rid varchar(5),
type varchar(4),
time int,
tagloc varchar(256))")
 or die(mysql_error());  

echo "jlog_event Table Created!";



/* $con = mysql_pconnect("localhost","jloguser","y6kaYsHjW48ZRD") or die(mysql_error());
mysql_select_db("jlog") or die(mysql_error()); */
/* if (!$con)
  {
  die('Could not connect: ' . mysql_error());
  } */
// Create table
/* mysql_select_db("jlog", $con);
$sql = "
	CREATE TABLE jlog_data
	(
	uid int unsigned not null auto_increment primary key,
	rid varchar(5),
	name varchar(256),
	email varchar(256),
	CP0 int,
	CP1A int,
	CP1B int,
	CP2A int,
	CP2B int,
	CP3 int,
	CP4 int,
	CP5 int,
	CP6 int,
	CP7 int,
	BA int,
	BB int,
	tag int,
	tagloc varchar(256),
	);
";

// Execute query
mysql_query($sql,$con);

mysql_close($con);
 */ ?>




