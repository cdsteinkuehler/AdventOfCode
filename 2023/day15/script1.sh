#!/bin/bash

function hash () {
	local A
	A=`printf %i \"$1`
	let HASH+=A
	let HASH*=17
	let HASH%=256
}

HASH=0
STEP=""
TOTAL=0

{ cat ${1:-input} ; echo "," ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		echo "Total: $TOTAL"
		exit
	fi

	while [ ${#LINE} -gt 0 ] ; do
		C=${LINE:0:1}
		LINE=${LINE:1}
		if [ $C = "," ] ; then
			echo "$STEP = $HASH"
			let TOTAL+=HASH
			HASH=0
			STEP=""
			continue
		fi

		hash $C
		STEP=$STEP$C

		#let TOTAL+=${#O}*M
	done
done

