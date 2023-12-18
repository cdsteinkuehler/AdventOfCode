#!/bin/bash

function insert () {
	local T
	T="${BOX[$1]/ $2 ?/}"

	if [ ${#BOX[$1]} -eq ${#T} ] ; then
		BOX[$1]="${BOX[$1]} $2 $3"
	else
		BOX[$1]="${BOX[$1]/ $2 ?/ $2 $3}"
	fi
}

function boxprint () {
	local i=0
	while [ $i -lt 256 ] ; do
		if [ -n "${BOX[i]}" ] ; then
			echo "$i : ${BOX[i]}"
		fi
		let i+=1
	done
}

function boxtotal () {
	local i=0
	local B S F T
	while [ $i -lt 256 ] ; do
		let B=i+1
		let S=1
		let T=0
		set -- ${BOX[i]}
		while [ $# -gt 1 ] ; do
			let T+=B*S*$2

			let S+=1
			shift 2
		done
		let TOTAL+=T
		let i+=1
	done
}

function hash () {
	local A
	A=`printf %i \"$1`
	let HASH+=A
	let HASH*=17
	let HASH%=256
}

declare -a BOX=()

HASH=0
LABEL=""
TOTAL=0

{ cat ${1:-input} ; echo "," ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		boxprint
		boxtotal
		echo "Total: $TOTAL"
		exit
	fi

	while [ ${#LINE} -gt 0 ] ; do
		C=${LINE:0:1}
		LINE=${LINE:1}
		if [ $C = "-" ] ; then
			BOX[HASH]="${BOX[HASH]/ $LABEL ?/}"
			LINE=${LINE:1}
			#boxprint
			HASH=0
			LABEL=""
			continue
		elif [ $C = "=" ] ; then
			F=${LINE:0:1}
			insert $HASH $LABEL $F
			LINE=${LINE:2}
			#boxprint
			HASH=0
			LABEL=""
			continue
		fi

		hash $C
		LABEL=$LABEL$C

		#let TOTAL+=${#O}*M
	done
done

