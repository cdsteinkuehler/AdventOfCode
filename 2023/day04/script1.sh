#!/bin/bash

#set -x

function check () {
	IN=$1
	set $2
	while [ $# -ge 1 ] ; do
		if [ "$IN" -eq "$1" ] ; then
			echo "$IN "
			break
		fi
		shift
	done
}

OIFS="$IFS"
TOTAL=0

IFS=":|"
while read CARD WIN HAVE ; do
	IFS="${OIFS}"
	set $WIN
	POINTS=0
	while [ $# -ge 1 ] ; do
		WIN=`check $1 "$HAVE"`
		if [ -n "$WIN" ] ; then
			if [ $POINTS -eq 0 ] ; then
				POINTS=1
			else
				let POINTS*=2
			fi
		fi
		shift
	done
	TOTAL=$(( $TOTAL + $POINTS ))
	echo Points: $POINTS Total: $TOTAL
IFS=":|"
done < ${1:-input}

