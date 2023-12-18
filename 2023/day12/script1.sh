#!/bin/bash

function populate () {
	local X=0
	local B="" C
	X=`printf '%x' $1`
	local i
	let i=${#X}-1
	# Build binary image LSB first!
	while [ $i -ge 0 ] ; do
		C=${X:$i:1}
		B="$B${X2B[$C]}"
		let i-=1
	done
	X=${B//[^#]/}
	ONES[$1]=${#X}
	BINARY[$1]=$B
}

function pattern () {
	local P=""
	local K="$1"
	set -- ${1//,/ }
	while [ $# -gt 0 ] ; do
		local i=$1
		while [ $i -gt 0 ] ; do
			P="$P#"
			let i-=1
		done
		shift
		if [ $# -gt 0 ] ; then
			P="$P."
		fi
	done
	PAT[$K]="$P"
}

function try () {
	if [ -z "${PAT[$2]}" ] ; then
		pattern $2
	fi
#	echo Try $B : $2
	if [ "$1" = "${PAT[$2]}" ] ; then
#		echo "MATCH!!"
		let MATCH+=1
	fi
}

function test () {
	local i=0 j=0 n=${#1}
	local C X=""
	while [ $i -lt $n ] ; do
		C="${1:$i:1}"
		if [ "$C" = "?" ] ; then
			C="${3:$j:1}"
			if [ -z "$C" ] ; then
				C=.
			fi
			let j+=1
		fi
		X="$X$C"
		let i+=1
	done
	local Y
	while Y="${X//../.}" ; [ "$X" != "$Y" ] ; do
		X="$Y"
	done
	X="${X%.}"
	X="${X#.}"
#	echo "try $X $2"
	try $X $2
}

function permute () {
	# Number of unknown springs
	X="${1//[^?]/}"
	UN=${#X}
	# Number of bad springs
	X="${1//[^#]/}"
	BN=${#X}
	# Total number of springs
	eval let N="${2//,/+}"
	echo "Permute: $N $BN $UN"
	if [ $BN -lt $N ] ; then
		i=1
		let R=2**UN
		let NEED=N-BN
		while [ $i -lt $R ] ; do
			if [ -z "${ONES[$i]}" ] ; then
				populate $i
			fi
			if [ ${ONES[$i]} -ne $NEED ] ; then
				let i+=1
				continue
			else
				test "$1" "$2" "${BINARY[$i]}"
			fi
			let i+=1
		done


		echo "Arrangements $LN: $MATCH"
	else
		echo "Arrangements $LN! 1"
		MATCH=1
	fi
}

LN=0

declare -a ONES BINARY
declare -A X2B PAT

# Build binary image LSB first!
X2B[0]="...."
X2B[1]="#..."
X2B[2]=".#.."
X2B[3]="##.."
X2B[4]="..#."
X2B[5]="#.#."
X2B[6]=".##."
X2B[7]="###."
X2B[8]="...#"
X2B[9]="#..#"
X2B[a]=".#.#"
X2B[b]="##.#"
X2B[c]="..##"
X2B[d]="#.##"
X2B[e]=".###"
X2B[f]="####"

TOTAL=0

{ cat ${1:-input} ; echo ; } |
while read SPRINGS BAD ; do
	if [ -z "$SPRINGS" ] ; then
#		echo ${!ONES[*]}
#		echo ${ONES[*]}
#		echo ${BINARY[*]}
		exit
	fi

	echo "$SPRINGS" "$BAD"

	MATCH=0
	permute "$SPRINGS" "$BAD"

	let TOTAL+=MATCH
	echo "Total: $TOTAL"

	let LN+=1
done

