#!/bin/bash

n=1
RECORDNUMBER=`cat runneridtable | wc -l`

echo "Number of Runner IDs:" $RECORDNUMBER

for i in $(cat runneridtable)
do
	echo "Generating "$n" of "$RECORDNUMBER": " $i
	QUOTE=`shuf -n 1 quotes.txt`
	qrencode -o temp/$i-qr-l.png -s 73 -m 0 "http://jl.vc/$i"
	qrencode -o temp/$i-qr-s.png -s 33 -m 0 "http://jl.vc/$i"
	convert -limit memory 0 -limit map 0 \
	journey-manifest.png \
	temp/$i-qr-l.png -geometry +176+3130 -composite \
	temp/$i-qr-s.png -geometry +3470+4140 -composite \
	temp/$i-qr-s.png -geometry +5628+150 -composite \
	-fill black -font OCRA-Medium -pointsize 160 -annotate +240+3060 "RUNNERID: $i" \
	-fill black -font OCRA-Medium -pointsize 75 -annotate +3472+4100 "RUNNERID: $i" \
	-fill black -font OCRA-Medium -pointsize 75 -annotate +5630+1090 "RUNNERID: $i" \
	-fill black -font Courier -pointsize 56 -annotate 90x90+2200+250 "$QUOTE" \
	-depth 8 completed/$i-man.pdf
	rm temp/$i-qr-l.png temp/$i-qr-s.png
	n=$((n+1))
done
echo "Done!"
