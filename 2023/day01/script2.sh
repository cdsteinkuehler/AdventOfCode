#!/bin/bash

#set -x

TOTAL=0

while read LINE ; do
	SUB=$( echo $LINE | sed -f numbers.sed )
	VAL=${SUB//[^0-9]/}
	LAST=$(( ${#VAL} - 1 ))
	CAL=${VAL:0:1}${VAL:$LAST:1}
	echo "$CAL $VAL $SUB $LINE"
	TOTAL=$(( $TOTAL + $CAL ))
	echo Total: $TOTAL
done < ${1:-input}

