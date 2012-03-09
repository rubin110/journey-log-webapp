#!/bin/bash
export TMPDIR=/home/rubin110/temp/tmp/

for i in $(ls -1 completed | /bin/grep zzz)
do
	echo "Starting on dir " $i
	convert -limit memory 0 -limit map 0 -adjoin -quality 100 completed/$i/*.png completed/pdf/$i.pdf 
	echo "Done!"

done
