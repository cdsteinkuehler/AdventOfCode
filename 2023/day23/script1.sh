#!/bin/bash

function NXT2CUR () {
	local i
	CUR=()
	for i in "${NXT[@]}" ; do
		CUR["$i"]="${NXT[$i]}"
	done
	NXT=()
}

function step () {
	local STEPS=$2
	local PX PY PD NX NY C D V
	local -a N
	set -- ${1//,/ }
	PX=$1
	PY=$2
	PD=$3
	while [[ "$PX $PY" != $END ]] ; do
		let STEPS+=1
		echo -n "$STEPS Pos: $PX $PY $PD : ${DIRS[$PD]} :"
		V=0
		N=()
		for D in ${DIRS[$PD]} ; do
			NX=$PX
			NY=$PY
			eval let ${MOVE[$D]}
			C="${MAP[$NY]}"
			C="${C:$NX:1}"
			echo -n " $D:$C"
			if [[ "$C" = "." ]] ; then
				N[$V]="$NX $NY $D"
				let V+=1
				echo -n " Nxt: $NX $NY"
			elif [[ "$C" == "^" && "$D" == "N" ]] ; then
				N[$V]="$NX $NY $D"
				let V+=1
				echo -n " Nxt: $NX $NY"
			elif [[ "$C" == ">" && "$D" == "E" ]] ; then
				N[$V]="$NX $NY $D"
				let V+=1
				echo -n " Nxt: $NX $NY"
			elif [[ "$C" == "v" && "$D" == "S" ]] ; then
				N[$V]="$NX $NY $D"
				let V+=1
				echo -n " Nxt: $NX $NY"
			elif [[ "$C" == "<" && "$D" == "W" ]] ; then
				N[$V]="$NX $NY $D"
				let V+=1
				echo -n " Nxt: $NX $NY"
			fi
		done
		echo
		if (( $V == 0 )) ; then
			return
		elif (( $V > 1 )) ; then
			for (( i=1 ; i<V ; i++ )) ; do
				step ${N[i]// /,} $STEPS
			done
		fi
		set -- ${N[0]}
		PX=$1
		PY=$2
		PD=$3
	done
	PATHS="$PATHS $STEPS"
}

function walk () {
	CUR["$START"]="$START"
	NXT=()

	local i=0
	while (( $i < $1 )) ; do
		step
		let i+=1
		echo "$i States: ${#CUR[*]}"
	done

}

LN=0

declare -A CUR NXT DIRS MOVE

DIRS[N]="N E W"
DIRS[S]="S E W"
DIRS[E]="N S E"
DIRS[W]="N S W"

MOVE[N]="NY=PY-1"
MOVE[S]="NY=PY+1"
MOVE[E]="NX=PX+1"
MOVE[W]="NX=PX-1"

TMAX=0
TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then
		let R=${#MAP[0]}-1
		let B=${#MAP[*]}-1

		LINE="${MAP[$B]%.*}"
		END="${#LINE} $B"

		echo "Tiles: $R x $B"
		echo "Start: $START"
		echo "End  : $END"

		step $START 0

		echo "Paths: $PATHS"

		exit
	fi

	MAP[LN]="$LINE"

	if (( LN == 0 )) ; then
		LINE="${LINE%.*}"
		START="${#LINE},$LN,S"
	fi

	echo "${MAP[LN]}"

	let LN+=1

done

