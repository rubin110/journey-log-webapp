#!/bin/bash

touch runneridtable

for i in {1..2000}
do
NEWID=`</dev/urandom tr -dc A-NP-Z1-9 | head -c5`
CHECKID=`/bin/grep $NEWID runneridtable`
if [ "$CHECKID" = "" ]
	then
	echo $NEWID >> runneridtable
fi
echo "Found duplicate"
done
