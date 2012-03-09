#!/bin/bash
export TMPDIR=/home/rubin110/temp/tmp/
cd completed/
n=1
RECORDNUMBER=$(ls -1 *.png | wc -l)

echo "Number of Runner IDs:" $RECORDNUMBER

for i in $(ls -1 *.png)
do
	echo "Printing "$n" of "$RECORDNUMBER": " $i
	echo "Print sent"
	lpr -P Canon-iR105 -o landscape $i
	sleep 20
	n=$((n+1))
done
echo "Done!"

