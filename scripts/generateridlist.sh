#!/bin/bash

echo "Making sure the runneridtable exists"
touch runneridtable
echo "Start generation"
for i in {1..$1}
do
NEWID=`</dev/urandom tr -dc A-NP-Z1-9 | head -c5`
CHECKID=`/bin/grep $NEWID runneridtable`
if [ "$CHECKID" = "" ]
	then
	echo $NEWID >> runneridtable
else
echo "Found duplicate"
fi
echo "Generation complete"
echo "Double checking for duplicates"
sort runneridtable | uniq -d
done
