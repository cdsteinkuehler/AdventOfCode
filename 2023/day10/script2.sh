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

function insert () {
	if [ $2 -eq 0 ] ; then
		echo $1${3:1}
	elif [ $2 -eq ${#3} ] ; then
		local L
		let L=$2-1
		echo ${3:0:$L}$1
	else
		local L R
		let L=$2
		let R=$2+1
		echo ${3:0:$L}$1${3:$R}
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
			if [ -n "${D//[^EW]}" ] ; then
				LOOP[$Y]=$( insert X $X ${LOOP[$Y]} )
			else
				LOOP[$Y]=$( insert N $X ${LOOP[$Y]} )
			fi
			let Y-=1
			NEXT="$X $Y S"
			return
		fi
	fi
	if [ -n "${N//[^S]/}" ] ; then
		C=$( getchar $X $Y S )
		if [ -z "${C//[|LJS]/}" ] ; then
			LOOP[$Y]=$( insert S $X ${LOOP[$Y]} )
			let Y+=1
			NEXT="$X $Y N"
			return
		fi
	fi
	if [ -n "${N//[^E]/}" ] ; then
		C=$( getchar $X $Y E )
		if [ -z "${C//[-J7S]/}" ] ; then
			if [ -n "${D//[^S]}" ] ; then
				LOOP[$Y]=$( insert N $X ${LOOP[$Y]} )
			else
				LOOP[$Y]=$( insert X $X ${LOOP[$Y]} )
			fi
			let X+=1
			NEXT="$X $Y W"
			return
		fi
	fi
	if [ -n "${N//[^W]/}" ] ; then
		C=$( getchar $X $Y W )
		if [ -z "${C//[-FLS]/}" ] ; then
			if [ -n "${D//[^S]}" ] ; then
				LOOP[$Y]=$( insert N $X ${LOOP[$Y]} )
			else
				LOOP[$Y]=$( insert X $X ${LOOP[$Y]} )
			fi
			let X-=1
			NEXT="$X $Y E"
			return
		fi
	fi

	echo "Stuck!"
	NEXT="$X $Y $D"
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

declare -a MAP LOOP LOOPI

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
			follow $X $Y $D
			set $NEXT
			X=$1
			Y=$2
			D=$3
			C="${MAP[$Y]:$X:1}"
			let TOTAL+=1
			echo "$TOTAL: $NEXT $C"
		done
		echo "Total: $(( $TOTAL / 2 ))"

		echo Loop:
		i=0
		while [ $i -lt $LN ] ; do
			echo ${LOOP[$i]}
			let i+=1
		done

		i=0
		TOTAL=0
		while [ $i -lt $LN ] ; do
			j=0
			k=${#LOOP[$i]}
			NZ=0
			IL=""
			while [ $j -lt $k ] ; do
				C=${LOOP[$i]:$j:1}
				if [ $C = N ] ; then
					let NZ+=1
				elif [ $C = S ] ; then
					let NZ-=1
				elif [ $C = . ] ; then
					if [ $NZ -ne 0 ] ; then
						C=I
					fi
				fi
				IL="$IL$C"
				let j+=1
			done
			LOOPI[$i]=$IL

			IL="${IL//[^I]/}"
			NUMI=${#IL}
			let TOTAL+=NUMI
			echo Line $i : $NUMI : $TOTAL

			let i+=1
		done

		i=0
		while [ $i -lt $LN ] ; do
			echo ${LOOPI[$i]}
			let i+=1
		done
		echo "Total: $TOTAL"
	fi

	MAP[$LN]=$LINE
	LOOP[$LN]=${LINE//?/.}

	if [ -n "${LINE//[^S]/}" ] ; then
		SY=$LN
		LINE="${LINE%%S*}"
		SX=${#LINE}
		echo "Start: $SX,$SY"
	fi

	let LN+=1

done

