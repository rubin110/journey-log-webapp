#!/bin/bash
export TMPDIR=/home/rubin110/temp/tmp/
cd completed/
n=1
RECORDNUMBER=$(ls -1 *.png | wc -l)

echo "Number of Runner IDs:" $RECORDNUMBER

for i in $(ls -1 *.png)
do
	echo "Printing "$n" of "$RECORDNUMBER": " $i
	convert -scale 50% -depth 1 $i $i_t.png
	lp -d Canon-iR105 $i.png
	echo "Print sent"
	sleep 10
	n=$((n+1))
done
echo "Done!"

