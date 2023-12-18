#!/bin/bash

#set -x


# Part 2 can be trivially solved with a quadratic equation, but I was
# busy so I just let the computer chew on the brute force solution.
# Takes about 10 minutes on my machine
function check () {
	local T=$1
	local D=$2
	local i=1
	local R X
	local W=0
	while (( $i < $T )) ; do
		let R=T-i
		let X=R*i
		if (( $X > $D )) ; then
			let W+=1
#			echo -n "$i:$X "
		fi
		let i+=1
	done
#	echo
	echo $W
}

LN=0

{ cat ${1:-input} ; } |
while read LINE ; do
	let LN+=1
	if [ $LN -eq 1 ] ; then
		LINE="${LINE#*:}"
		TIME[0]="${LINE// /}"
		continue
	elif [ $LN -eq 2 ] ; then
		LINE="${LINE#*:}"
		DIST[0]="${LINE// /}"
		let N=1
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

