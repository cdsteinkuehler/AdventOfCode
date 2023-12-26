#!/bin/bash

function storm () {
	for (( i=0 ; i<4 ; i++ )) ; do
		echo "${PX[i]}"
		echo "${PY[i]}"
		echo "${PZ[i]}"
		echo "${VX[i]}"
		echo "${VY[i]}"
		echo "${VZ[i]}"
	done | bc -q math.bc
}

declare -a PX PY PZ VX VY VZ

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
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

	if (( LN >= 4 )) ; then
		storm
		exit
	fi

done

