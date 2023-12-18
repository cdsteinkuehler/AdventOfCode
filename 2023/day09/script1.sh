#!/bin/bash

function predict () {
	local -a D
	local X Y L
	local i=0

	while [ $# -gt 1 ] ; do
		let X=$2-$1
		D[$i]=$X
		let i+=1
		shift
	done

	L=$1

	if [ $X -eq 0 ] ; then
		echo $L
	else
		Y=$( predict ${D[*]} )
		let X+=Y
		let L+=Y
		echo $L
	fi
}

LN=0
TOTAL=0

{ cat ${1:-input} ; echo ; } |
while read -a DATA ; do
	let LN+=1

	if [ -z "${DATA[0]}" ] ; then
		exit
	fi

	P=`predict ${DATA[*]}`
	let TOTAL+=P
	echo "$P : $TOTAL"


done

