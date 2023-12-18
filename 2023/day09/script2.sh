#!/bin/bash

function predict () {
#	echo "Predict: $*" >&2
	local -a D
	local X Y L
	local i=0 Z=Y

	while [ $# -gt 1 ] ; do
		let X=$2-$1
		D[$i]=$X
		if [ $X -ne 0 ] ; then
			Z=N
		fi
		let i+=1
		shift
	done

	L=$1

	if [ $Z = Y ] ; then
		echo $L
	else
		Y=$( predict ${D[*]} )
		let X+=Y
		let L+=Y
		echo $L
	fi
}

function reverse () {
	local R=""
	while [ $# -gt 0 ] ; do
		R="$1 $R"
		shift
	done
	echo $R
}

LN=0
TOTAL=0

{ cat ${1:-input} ; echo ; } |
while read -a DATA ; do
	let LN+=1

	if [ -z "${DATA[0]}" ] ; then
		exit
	fi

	R=`reverse ${DATA[*]}`
	P=`predict $R`
	let TOTAL+=P
	echo "$P : $TOTAL"


done

