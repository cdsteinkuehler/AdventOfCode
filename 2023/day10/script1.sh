#!/bin/bash

#set -x

function max () {
	if [ "$1" -gt "$2" ] ; then
		echo $1
	else
		echo $2
	fi
}

function min () {
	if [ "$1" -lt "$2" ] ; then
		echo $1
	else
		echo $2
	fi
}

function getchar () {
	local X Y
	if [ $3 = N ] ; then
		X=$1
		let Y=$2-1
		if [ $Y -lt 0 ] ; then
			echo .
		else
			echo ${MAP[$Y]:$X:1}
		fi
	elif [ $3 = S ] ; then
		X=$1
		let Y=$2+1
		if [ $Y -gt ${#MAP[$2]} ] ; then
			echo .
		else
			echo ${MAP[$Y]:$X:1}
		fi
	elif [ $3 = E ] ; then
		let X=$1+1
		Y=$2
		if [ $X -gt ${#MAP[$Y]} ] ; then
			echo .
		else
			echo ${MAP[$Y]:$X:1}
		fi
	elif [ $3 = W ] ; then
		let X=$1-1
		Y=$2
		if [ $X -lt 0 ] ; then
			echo .
		else
			echo ${MAP[$Y]:$X:1}
		fi
	else
		echo .
	fi
}

function follow () {
	local X=$1
	local Y=$2
	local D=${3:-x}
	local C=${MAP[$Y]:$X:1}

	local N="${DIR[$C]}"
	N="${N//$D/}"


	if [ -n "${N//[^N]/}" ] ; then
		C=$( getchar $X $Y N )
		if [ -z "${C//[|7FS]/}" ] ; then
			let Y-=1
			echo $X $Y S
			return
		fi
	fi
	if [ -n "${N//[^S]/}" ] ; then
		C=$( getchar $X $Y S )
		if [ -z "${C//[|LJS]/}" ] ; then
			let Y+=1
			echo $X $Y N
			return
		fi
	fi
	if [ -n "${N//[^E]/}" ] ; then
		C=$( getchar $X $Y E )
		if [ -z "${C//[-J7S]/}" ] ; then
			let X+=1
			echo $X $Y W
			return
		fi
	fi
	if [ -n "${N//[^W]/}" ] ; then
		C=$( getchar $X $Y W )
		if [ -z "${C//[-FLS]/}" ] ; then
			let X-=1
			echo $X $Y E
			return
		fi
	fi

	echo "Stuck!"
	echo $X $Y $D
	exit 1
}

LN=0

declare -A DIR

DIR[|]=NS
DIR[-]=EW
DIR[L]=NE
DIR[J]=NW
DIR[7]=SW
DIR[F]=SE
DIR[S]=NSEW

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		X=$SX
		Y=$SY
		C=.
		NEXT="$X $Y ."
		TOTAL=0
		echo "$TOTAL: $NEXT $C"
		while [ $C != S ] ; do
			NEXT=$( follow $X $Y $D )
			set $NEXT
			X=$1
			Y=$2
			D=$3
			C="${MAP[$Y]:$X:1}"
			let TOTAL+=1
			echo "$TOTAL: $NEXT $C"
		done
		echo "Total: $(( $TOTAL / 2 ))"
		exit
	fi

	MAP[$LN]=$LINE

	if [ -n "${LINE//[^S]/}" ] ; then
		SY=$LN
		LINE="${LINE%%S*}"
		SX=${#LINE}
		echo "Start: $SX,$SY"
	fi

	let LN+=1

done

