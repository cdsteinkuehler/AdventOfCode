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
declare -a MULT=( 1 1 1 1 1 1 1 1 1 1 1 )

IFS=":|"
while read CARD WIN HAVE ; do
	IFS="${OIFS}"
	set $WIN
	WINS=0
	while [ $# -ge 1 ] ; do
		WIN=`check $1 "$HAVE"`
		if [ -n "$WIN" ] ; then
			let WINS+=1
		fi
		shift
	done
	
	i=1
	while [ $i -le $WINS ] ; do
		let MULT[$i]+=MULT[0]
		let i+=1
	done

	TOTAL=$(( $TOTAL + ${MULT[0]} ))
	echo Wins: $WINS Total: $TOTAL

	i=0
	while [ $i -le 9 ] ; do
		let MULT[$i]=MULT[$i+1]
		let i+=1
	done
	MULT[10]=1

IFS=":|"
done < ${1:-input}

