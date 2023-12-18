#!/bin/bash

#set -x

function check () {
	local T=$1
	local D=$2
	local i=1
	local R X
	local W=0
	while [ $i -lt $T ] ; do
		let R=T-i
		let X=R*i
		if [ $X -gt $D ] ; then
			let W+=1
#			echo -n "$i:$X "
		fi
		let i+=1
	done
#	echo
	echo $W
}

LN=0

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	let LN+=1
	if [ $LN -eq 1 ] ; then
		set $LINE
		shift
		i=0
		while [ $# -gt 0 ] ; do
			echo TIME[$i]=$1
			TIME[$i]=$1
			shift
			let i+=1
		done
		continue
	elif [ $LN -eq 2 ] ; then
		set $LINE
		shift
		i=0
		while [ $# -gt 0 ] ; do
			echo DIST[$i]=$1
			DIST[$i]=$1
			shift
			let i+=1
		done
		let N=i
		echo "$N races"
	fi

	i=0
	T=1
	while [ $i -lt $N ] ; do
		echo -n "check ${TIME[$i]} ${DIST[$i]} : "
		D=$(check ${TIME[$i]} ${DIST[$i]})
		echo $D
		let T*=D
		echo "Total: $T"
		let i+=1
	done

done

