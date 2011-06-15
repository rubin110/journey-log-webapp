#!/bin/bash
COUNT="$1"
echo "Making sure the runneridtable exists"
touch runneridtable
CURRENTNUMBER=0
echo "Start generation"
while  [ $COUNT -le $CURRENTNUMBER ]
do
NEWID=`</dev/urandom tr -dc A-NP-Z1-9 | head -c5`
CHECKID=`/bin/grep $NEWID runneridtable`
if [ "$CHECKID" = "" ]
	then
	echo $NEWID >> runneridtable
else
echo "Found duplicate"
fi
CURRENTNUMBER=`cat runnertable | wc -l`
done
echo "Generation complete"
echo "Double checking for duplicates"
sort runneridtable | uniq -d
echo "Done!"