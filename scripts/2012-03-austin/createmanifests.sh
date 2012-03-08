#!/bin/bash
export TMPDIR=/home/rubin110/temp/tmp/

n=1
RECORDNUMBER=$(cat runneridtable | wc -l)

echo "Number of Runner IDs:" $RECORDNUMBER

for i in $(cat runneridtable)
do
	echo "Generating "$n" of "$RECORDNUMBER": " $i
	qrencode -o temp/$i-qr-l.png -s 80 -m 0 "http://jl.vc/$i"
	convert -limit map 0 \
	journey-manifest.png \
	temp/$i-qr-l.png -geometry +10410+5840 -composite \
	-fill black -font OCRA-Medium -pointsize 185 -annotate +10410+8070 "RUNNERID: $i" \
	-depth 8 completed/$i-man.png
	rm temp/$i-qr-l.png
	n=$((n+1))
done
echo "Done!"
