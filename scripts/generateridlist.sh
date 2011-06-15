#!/bin/bash
COUNT=$1
echo "Making sure the runneridtable exists"
touch runneridtable
CURRENTNUMBER=0
echo "Start generation"
while  [ "$CURRENTNUMBER" -lt "$COUNT"  ]
do
NEWID=`</dev/urandom tr -dc A-NP-Z1-9 | head -c5`	# Linux
# NEWID=`echo $RANDOM`								# Mac
# CHECKID=`/usr/bin/grep $NEWID runneridtable` 		# Mac fuck
CHECKID=`/bin/grep $NEWID runneridtable` 			# Linux
if [ "$CHECKID" = "" ]
	then
	echo $NEWID >> runneridtable
else
echo "Found duplicate, killed"
fi
CURRENTNUMBER=`cat runneridtable | wc -l`
done
echo "Generation complete"
echo "Double checking for duplicates"
sort runneridtable | uniq -d
echo "Done!"