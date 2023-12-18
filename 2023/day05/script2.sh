#!/bin/bash

#set -x
function MLUT () {
	local i L R X
	i=0
	X=$1
	while [ $i -lt $MAPN ] ; do
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

function MAPRANGE () {
	local RL RR ML MR i=0
	local MAPPED=N
	local LEN
	let RL=$1
	let RR=$1+$2-1
	while [ $i -lt $MAPN ] ; do
		ML=${MAPI[$i]}
		let MR=ML+${MAPL[$i]}-1
		if [ $MR -lt $RL -a $ML -gt $RR ] ; then
			# Ranges do not overlap
			let i+=1
			continue
		elif [ $ML -le $RL -a $MR -ge $RR ] ; then
			# Map fully covers range, directly convert
			let NEXTB[$NEXTN]=RL-ML+${MAPO[$i]}
			let NEXTL[$NEXTN]=$2
			#echo A:${NEXTB[$NEXTN]}:${NEXTL[$NEXTN]}
			let NEXTN+=1
			MAPPED=Y
			break
		elif [ $ML -le $RL -a $MR -gt $RL ] ; then
			# Map covers start of range
			let LEN=${MAPL[$i]}-RL+ML
			let NEXTB[$NEXTN]=RL-ML+${MAPO[$i]}
			let NEXTL[$NEXTN]=$LEN
			#echo L:${NEXTB[$NEXTN]}:${NEXTL[$NEXTN]}
			let NEXTN+=1
			# Now map the rest of the range
			let RL+=LEN
			let RR=$2-LEN
			MAPRANGE $RL $RR
			MAPPED=Y
			break
		elif [ $ML -le $RR -a $MR -gt $RR ] ; then
			# Map covers end of range
			let LEN=${MAPL[$i]}-MR+RR
			let NEXTB[$NEXTN]=${MAPO[$i]}
			let NEXTL[$NEXTN]=$LEN
			#echo R:${NEXTB[$NEXTN]}:${NEXTL[$NEXTN]}
			let NEXTN+=1
			# Now map the rest of the range
			let RR=$2-LEN
			MAPRANGE $RL $RR
			MAPPED=Y
			break
		elif [ $ML -gt $RL -a $MR -lt $RR ] ; then
			# Entire map is contained by range
			let NEXTB[$NEXTN]=${MAPO[$i]}
			let NEXTL[$NEXTN]=${MAPL[$i]}
			#echo C:${NEXTB[$NEXTN]}:${NEXTL[$NEXTN]}
			# Left side of range
			let LEN=ML-RL
			MAPRANGE $RL $LEN
			# Right side of range
			let LEN=RR-MR
			MAPRANGE $MR LEN
			MAPPED=Y
			break
		fi
		let i+=1
	done
	if [ $MAPPED = N ] ; then
		let NEXTB[$NEXTN]=RL
		let NEXTL[$NEXTN]=$2
		#echo N:${NEXTB[$NEXTN]}:${NEXTL[$NEXTN]}
		let NEXTN+=1
	fi
}

function THIS2NEXT () {
	NEXTN=0

	local OUT
	local i=0
	while [ $i -lt $THISN ] ; do
		MAPRANGE ${THISB[$i]} ${THISL[$i]}
		#OUT="$OUT $( MLUT $1 )"
		let i+=1
		shift
	done
	echo Ranges:$NEXTN
}

function NEXT2THIS () {
	local i=0
	while [ $i -lt $NEXTN ] ; do
		THISB[$i]="${NEXTB[$i]}"
		THISL[$i]="${NEXTL[$i]}"
		let i+=1
	done
	THISN=$NEXTN
}

function PRINTTHIS () {
	local i=0
	while [ $i -lt $THISN ] ; do
		echo ${THISB[$i]}:${THISL[$i]}
		let i+=1
	done | sort -n
}

function PRINTONE () {
	echo -n "Lowest range: "
	PRINTTHIS | head -n 1
}

declare -a MAPO MAPI MAPL
declare -a THISB THISL
declare -a NEXTB NEXTL
THISN=0
NEXTN=0

EOL='
'

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	case $LINE
	in
		seeds:*)
			set $LINE
			shift
			i=0
			echo -n "Seeds ranges:"
			while [ $# -ge 2 ] ; do
				THISB[$i]=$1
				THISL[$i]=$2
				echo -n " ${THISB[$i]}:${THISL[$i]}"
				shift 2
				let i+=1
			done
			echo
			THISN=$i
			MAPN=0
			;;
		"")
			if [ $MAPN -gt 0 ] ; then
				THIS2NEXT
				NEXT2THIS
				PRINTONE
			fi
			;;
		*map:)
			MAPN=0
			echo $LINE
			;;
		[0-9]*)
			set $LINE
			MAPO[$MAPN]=$1
			MAPI[$MAPN]=$2
			MAPL[$MAPN]=$3
			let MAPN+=1
			;;
		*)
			echo "Unexpected: $LINE"
			exit
			;;
	esac

done

