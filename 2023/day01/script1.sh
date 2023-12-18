#!/bin/bash

TOTAL=0

sed s/[^0-9]//g ${1:-input} |
while read VAL ; do
	LAST=$(( ${#VAL} - 1 ))
	CAL=${VAL:0:1}${VAL:$LAST:1}
	echo $CAL
	TOTAL=$(( $TOTAL + $CAL ))
echo Total: $TOTAL
done

