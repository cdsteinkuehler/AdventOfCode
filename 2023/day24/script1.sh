#!/bin/bash

function intersect () {
#	echo "intersect: $*"
	let TRIES+=1
#	echo "A: ${L[$1]}"
#	echo "B: ${L[$2]}"
	let D=VX[$1]*VY[$2]-VX[$2]*VY[$1]
	if (( D == 0 )) ; then
#		echo "No collision: D=0"
		return
	fi
	let "DP=(D>0)?1:0"

	let DX=${PX[$1]}-${PX[$2]}
	let DY=${PY[$1]}-${PY[$2]}

	let N1=VX[$1]*DY-VY[$1]*DX
	let "N1N=(N1<0)?1:0"
	let N2=VX[$2]*DY-VY[$2]*DX
	let "N2N=(N2<0)?1:0"

	# AoC values overflow 64-bit ints if we delay the divide...
	# ...use bc for maximum precision:
	#NX=`echo "${PX[$1]} + ( ${VX[$1]}*$N2 / $D )" | bc `
	#NY=`echo "${PY[$1]} + ( ${VY[$1]}*$N2 / $D )" | bc `

	# ...or do the divide early, loose VX/VY * Remainder, and
	# what do you know, we're close enough (no points fall close
	# to the bounding box edge)
	# Bash built-in math, MUCH faster!
	let X=N2/D
	let X*=VX[$1]
	let X+=PX[$1]
	let Y=N2/D
	let Y*=VY[$1]
	let Y+=PY[$1]
	NX=$X
	NY=$Y
	
#	echo "Cross at: $NX $NY"
	let CROSS+=1

	if (( N1N == DP )) ; then
#		echo "No collision: N1"
		return
	fi
	if (( N2N == DP )) ; then
#		echo "No collision: N2"
		return
	fi

	if (( NX == AMIN || NX == AMAX || NY == AMIN || NY == AMAX )) ; then
		echo "Dangerous edge case!"
	fi

	if (( NX < AMIN || NX > AMAX )) ; then
#		echo "X out of bounds"
		return
	fi

	if (( NY < AMIN || NY > AMAX )) ; then
#		echo "Y out of bounds"
		return
	fi

	let TOTAL+=1
}

function storm () {
	for (( i=0 ; i<$LN ; i++ )) ; do
		for (( j=i+1 ; j<LN ; j++ )) ; do
			intersect $i $j
		done
	done
}

declare -a PX PY PZ VX VY VZ

LN=0
TOTAL=0
TRIES=0
CROSS=0

AMIN=${2:-200000000000000}
AMAX=${3:-400000000000000}

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then

		storm
		echo "Total: $TOTAL of $CROSS intersections of $TRIES combinations"

		exit
	fi

	L[LN]="$LINE"
	set -- ${LINE//[@,]/ }
	PX[LN]=$1
	PY[LN]=$2
	PZ[LN]=$3
	VX[LN]=$4
	VY[LN]=$5
	VZ[LN]=$6

	echo "${PX[LN]} ${PY[LN]} ${PZ[LN]} ${VX[LN]} ${VY[LN]} ${VZ[LN]}"

	let LN+=1

done

