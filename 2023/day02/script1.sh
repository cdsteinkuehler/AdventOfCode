#!/bin/bash

OIFS="$IFS"
TOTAL=0

while read GAME NUM DATA ; do
	IFS="${OIFS},;"
	set $DATA
	POSSIBLE=Y
	while [ $# -ge 2 ] ; do
		case "$2"
		in
			red)	if [ $1 -gt 12 ] ; then POSSIBLE=N ; fi ;;
			green)	if [ $1 -gt 13 ] ; then POSSIBLE=N ; fi ;;
			blue)	if [ $1 -gt 14 ] ; then POSSIBLE=N ; fi ;;
		esac
		shift 2
	done
	if [ $POSSIBLE = Y ] ; then TOTAL=$(( $TOTAL + ${NUM/:/} )) ; fi
	echo "$GAME ${NUM/:/} $POSSIBLE $TOTAL"
done < ${1:-input}

