#!/bin/bash
cat longquotes.txt | while read line ; do
		cc=`echo $line | wc -m` 
		if [ "$cc" -lt "140" ]
			then
			echo $line
		fi
	done
	
#	for i in $(cat longquotes.txt)
#		do
#			cc=`echo $i | wc -m` 
#			if [ "$cc" -lt "140" ]
#				then
#				echo $i
#			fi
#		done