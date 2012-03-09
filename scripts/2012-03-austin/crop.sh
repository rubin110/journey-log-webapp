#!/bin/bash
export TMPDIR=/home/rubin110/temp/tmp/

n=1
RECORDNUMBER=$(ls -1 completed/*.png | wc -l)

echo "Number of Runner IDs:" $RECORDNUMBER

for i in $(ls -1 completed/*.png)
do
	echo "Generating "$n" of "$RECORDNUMBER": " $i
	convert -gravity Center -crop 12200x9400+0+0 -depth 4 $i print/$i
	n=$((n+1))
done
echo "Done!"
