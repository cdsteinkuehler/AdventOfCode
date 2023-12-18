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
	R=${#MAP[0]}
	B=${#MAP[*]}
	declare -A CUR NXT SEEN
	CUR[0 0]=E
	MAX=0
	while STATES=${#CUR[*]} && [ $STATES -gt 0 ] ; do
		if [ $STATES -gt $MAX ] ; then
			MAX=$STATES
		fi
#		echo ${!CUR[*]}
#		echo ${CUR[*]}
#		printhot
		for STATE in "${!CUR[@]}" ; do
			local D=${CUR[$STATE]}
			local X Y C D
			set -- $STATE
#			echo "State: $STATE $n"
			X=$1
			Y=$2

			if [ $X -lt 0 -o $Y -lt 0 -o $X -ge $R -o $Y -ge $B ] ; then
				# We fell off the map, just carry on with the other states
				continue
			fi

			C=${MAP[Y]:$X:1}

			if [ -n "${SEEN[$X $Y $D]}" -a $C = "." ] ; then
				# We've been here before...
				continue
			fi

			SEEN["$X $Y $D"]=1
			insert "#" $X $Y

			if [ $C = '.' ] ; then
				# Continue on in the current direction
				case $D in
					N) let Y-=1 ;;
					S) let Y+=1 ;;
					E) let X+=1 ;;
					W) let X-=1 ;;
					*) ;;
				esac
				NXT["$X $Y $D"]=$D
			elif [ $C = '\' ] ; then
				# Reflect 90 deg
				case $D in
					N) D=W ; let X-=1 ;;
					S) D=E ; let X+=1 ;;
					E) D=S ; let Y+=1 ;;
					W) D=N ; let Y-=1 ;;
					*) ;;
				esac
				NXT["$X $Y $D"]=$D
			elif [ $C = '/' ] ; then
				# Reflect 90 deg
				case $D in
					N) D=E ; let X+=1 ;;
					S) D=W ; let X-=1 ;;
					E) D=N ; let Y-=1 ;;
					W) D=S ; let Y+=1 ;;
					*) ;;
				esac
				NXT["$X $Y $D"]=$D
			elif [ $C = '-' ] ; then
				# Horizontal splitter
				case $D in
					[NS])	let X+=1 ; NXT["$X $Y E"]=E
						let X-=2 ; NXT["$X $Y W"]=W ;;
					E)	let X+=1 ; NXT["$X $Y E"]=E ;;
					W)	let X-=1 ; NXT["$X $Y W"]=W ;;
					*)	;;
				esac
			elif [ $C = '|' ] ; then
				# Vertical splitter
				case $D in
					N)	let Y-=1 ; NXT["$X $Y N"]=N ;;
					S)	let Y+=1 ; NXT["$X $Y S"]=S ;;
					[EW])	let Y-=1 ; NXT["$X $Y N"]=N
						let Y+=2 ; NXT["$X $Y S"]=S ;;
					*)	;;
				esac
			else
				# Huh?!?
				echo "Unknown space!"
				exit
			fi
		done

		NXT2CUR
	done

	STATES=$MAX
}

LN=0

declare -a MAP HOT

TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then
		meander

		printhot

		numhot

		if [ $STATES -gt $MAXSTATES ] ; then
			MAXSTATES=$STATES
		fi
		echo "States: $STATES MaxStates: $MAXSTATES Total: $TOTAL"
		exit
	fi

	echo "$LINE"
	MAP[LN]="$LINE"
	HOT[LN]="${LINE//[^.]/.}"
	let LN+=1

done

