#!/bin/bash

OIFS="$IFS"
TOTAL=0

while read GAME NUM DATA ; do
	IFS="${OIFS},;"
	set $DATA
	RED=0; GRN=0; BLU=0
	while [ $# -ge 2 ] ; do
		case "$2"
		in
			red)	if [ $1 -gt $RED ] ; then RED=$1 ; fi ;;
			green)	if [ $1 -gt $GRN ] ; then GRN=$1 ; fi ;;
			blue)	if [ $1 -gt $BLU ] ; then BLU=$1 ; fi ;;
		esac
		shift 2
	done
	POWER=$(( $RED * $GRN * $BLU ))
	TOTAL=$(( $TOTAL + $POWER ))
	echo "$GAME ${NUM/:/} $TOTAL $POWER $RED $GRN $BLU"
done < ${1:-input}

