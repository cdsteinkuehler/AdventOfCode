#!/bin/bash

function insert () {
	if [ $2 -eq 0 ] ; then
		HOT[$3]=$1${HOT[$3]:1}
	elif [ $2 -eq ${#HOT[$3]} ] ; then
		local L
		let L=$2-1
		HOT[$3]=${HOT[$3]:0:$L}$1
	else
		local L R
		let L=$2
		let R=$2+1
		HOT[$3]=${HOT[$3]:0:$L}$1${HOT[$3]:$R}
	fi
}

function clearhot () {
	local i=0
	while [ $i -lt ${#HOT[*]} ] ; do
		HOT[i]="${MAP[i]//[^.]/.}"
		let i+=1
	done
}

function printhot () {
	local i=0
	local H N T=0
	echo "Hot:"
	while [ $i -lt ${#HOT[*]} ] ; do
		H="${HOT[i]//[^#]/}"
		N="${#H}"
		let T+=N
		echo "${HOT[i]} $N"
		let i+=1
	done
	echo "Total: $T"
}

function numhot () {
	local i=0
	local H
	TOTAL=0
	while [ $i -lt ${#HOT[*]} ] ; do
		H="${HOT[i]//[^#]/}"
		let TOTAL+="${#H}"
		let i+=1
	done
	if [ $TOTAL -gt $TMAX ] ; then
		TMAX=$TOTAL
	fi
	if [ $STATES -gt $MAXSTATES ] ; then
		MAXSTATES=$STATES
	fi
	echo "States: $STATES MaxStates: $MAXSTATES Total: $TOTAL TMax: $TMAX"
}

function NXT2CUR () {
	CUR=()
	local X=0
	for STATE in "${!NXT[@]}" ; do
		CUR[$STATE]=${NXT[$STATE]}
#		echo "$STATE = ${NXT[$STATE]}"
		X+=1
	done
	NXT=()
}

function meander () {
#	local R B
#	R=${#MAP[0]}
#	B=${#MAP[*]}
	declare -A CUR SEEN
	MIN=$1
	MAX=$2
	# State is Value XPos YPos Dir
	CUR[0 0 0 E]=1
#	CUR[144 12 10 E]=1
	CUR[0 0 0 S]=1
	SMAX=0
	while STATES=${#CUR[*]} && [ $STATES -gt 0 ] ; do
		if [ $STATES -gt $SMAX ] ; then
			SMAX=$STATES
		fi
#		echo ${!CUR[*]}
#		echo ${CUR[*]}
#		printhot
		IFS=$'\n' sorted=($(sort -n <<<"${!CUR[*]}"))
		unset IFS
		for STATE in "$sorted" ; do
			local X Y C D
			set -- $STATE
#			echo "State: $STATE $n"
			V=$1
			X=$2
			Y=$3
			D=$4

			unset CUR["$STATE"]

			if [ $X -lt 0 -o $Y -lt 0 -o $X -gt $R -o $Y -gt $B ] ; then
				# We fell off the map, just carry on with the other states
				continue
			fi
			if [ $X -eq $R -a $Y -eq $B ] ; then
				# Finished, return result
				TOTAL="$TOTAL $V"
				return
			fi

			if [ -n "${SEEN[$X $Y $D]}" ] ; then
				# We've been here before...
#				if [ "${SEEN[$X $Y $D]}" -le $V ] ; then
					# ...and the path value was the same or less
					continue
#				fi
			fi

			SEEN["$X $Y $D"]=$V

			case $D in
				[NS]) DIRS="E W" ;;
				[EW]) DIRS="N S" ;;
				*)    DIRS="." ;;
			esac

			for D in $DIRS ; do
				local XI YI
				local VL=$V
				local XL=$X
				local YL=$Y
				case $D in
					N) XI=0 ; YI=-1 ;;
					S) XI=0 ; YI=1 ;;
					E) XI=1 ; YI=0 ;;
					W) XI=-1 ; YI=0 ;;
					*) XI=0 ; YI=0 ;;
				esac

				# Advance MIN elements
				local i=0
				while [ $i -lt $MIN ] ; do
					let XL+=XI
					let YL+=YI
					if [ $XL -lt 0 -o $YL -lt 0 -o $XL -gt $R -o $YL -gt $B ] ; then
						break
					fi
					let VL+=${MAP[$YL]:$XL:1}
					let i+=1
				done
				# Walk MIN to MAX elements
				while [ $i -lt $MAX ] ; do
					let XL+=XI
					let YL+=YI
					if [ $XL -lt 0 -o $YL -lt 0 -o $XL -gt $R -o $YL -gt $B ] ; then
						break
					fi
					let VL+=${MAP[$YL]:$XL:1}
#					echo CUR["$VL $XL $YL $D"]=1
					CUR["$VL $XL $YL $D"]=1
					let i+=1
				done
			done
		done
	done

	STATES=$SMAX
}

LN=0

declare -a MAP

TMAX=0
TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then
		let R=${#MAP[0]}-1
		let B=${#MAP[*]}-1
		i=0
		meander 0 3
		echo "Min: $TOTAL"

		exit
	fi

	echo "$LINE"
	MAP[LN]="$LINE"
	let LN+=1

done

