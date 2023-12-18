#!/bin/bash

# Crafty math (Green's theorem) makes this simple!
# Intermediate results can include 0.5, so we track 2x area instead
# and divide the result by 2 at the end
function step () {
	# XInc YInc Dist
	local X Y N A
	X=$1
	Y=$2
	N=$3

	let POS+=X*N
	let A=Y*N*POS*2
	let TOTAL+=A+N
}

LN=0

declare -A DIRS

DIRS[U]="0 -1"
DIRS[D]="0 1"
DIRS[L]="-1 0"
DIRS[R]="1 0"

POS=0
TOTAL=2

{ cat ${1:-input} ; echo ; } |
while read -r DIR LEN COLOR ; do
	if [ -z "$COLOR" ] ; then
		let AREA=TOTAL/2
		echo "Area: $AREA"

		exit
	fi

	echo "step ${DIRS[$DIR]} $LEN"
	step ${DIRS[$DIR]} $LEN
	echo "Pos: $POS Area2: $TOTAL"

	let LN+=1
done

