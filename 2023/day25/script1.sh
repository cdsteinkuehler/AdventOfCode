#!/bin/bash

function count () {
	R=""
	RX=0
	RL=0
	RN=""
	C=0
	for N in ${A} ; do
		X=${AC[$N]:-0}
		# Track the node with the most external connections..
		if (( X > RX )) ; then
			R=$N
			RX=$X
			RL=${#G[$N]}
		# ...and the most neighbors
		elif (( X == RX && RL < ${#G[$N]} )) ; then
			R=$N
			RX=$X
			RL=${#G[$N]}
		fi

		# We can move any node with 2 or more external links
		if (( X > 1 )) ; then
			RN="$RN $N"
		fi
		let C+=$X
	done
	let i+=1
}

function remove () {
	for N in ${G[$1]} ; do
		let AC[$N]=${AC[$N]:-0}+1
	done
}

function separate () {
	A="${!G[@]}"
	B=""
	C=0
	i=0

	count
	echo "R: $R, C: $C Remove: ${RN:-$R}"

	while (( $C != 3 )) ; do
		# Move nodes from A to B
		for N in ${RN:-$R} ; do
			A="${A//$N/}"
			B="$B $N"
			remove $N
		done
		count
		echo "$i C: $C Remove: ${RN:-$R}"
	done
}

declare -A G AC

LN=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then

		for N in "${!G[@]}" ; do
			echo "Node $N :${G[$N]}"
		done

		separate
		echo "A: $A"
		echo "B: $B"
		set -- $A
		AN=$#
		set -- $B
		BN=$#
		echo "AN: $AN BN: $BN"
		let T=AN*BN
		echo "Answer: $T"

		exit
	fi

	L[LN]="$LINE"
	set -- $LINE
	N=${1/:/}
	shift
	while (( $# > 0 )) ; do
		G[$N]="${G[$N]} $1"
		G[$1]="${G[$1]} $N"
		shift
	done

	let LN+=1

done

