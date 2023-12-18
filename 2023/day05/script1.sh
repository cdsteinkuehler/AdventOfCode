#!/bin/bash

#set -x
function MLUT () {
	local i L R X
	i=0
	X=$1
	while [ $i -lt $MAPLEN ] ; do
		set ${MAP[$i]}
		let L=$2
		let R=$2+$3
		if [ $X -ge $L -a $X -lt $R ] ; then
			let X-=$2
			let X+=$1
			break
		fi
		let i+=1
		shift
	done
	echo $X
}

function LUT () {
	local OUT
	local i
	while [ $# -ge 1 ] ; do
		OUT="$OUT $( MLUT $1 )"
		shift
	done
	echo $OUT
}

declare -a MAP
EOL='
'

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	case $LINE
	in
		seeds:*)
			set $LINE
			shift
			SEEDS="$*"
			MAPLEN=0
			;;
		"")
			if [ $MAPLEN -gt 0 ] ; then
				SEEDS="$( LUT $SEEDS )"
				echo $SEEDS
				echo -n "Lowest: "
				echo "${SEEDS// /$EOL}" | sort -n | head -n 1
			fi
			;;
		*map:)
			MAPLEN=0
			echo $LINE
			;;
		[0-9]*)
			MAP[$MAPLEN]="$LINE"
			let MAPLEN+=1
			;;
		*)
			echo "Unexpected: $LINE"
			exit
			;;
	esac

done

