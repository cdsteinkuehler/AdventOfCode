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
#	echo "step $@"
	local SEEN="$3"
	local STEPS=$2
	local PX PY PD NX NY C D V
	set -- ${1//,/ }
	PX=$1
	PY=$2
	PD=$3
	if (( 1 == 1 )) ; then
	if [[ -n "${NODE[$PX $PY $PD]}" ]] ; then
#		echo "  N: ${NODE[$PX $PY $PD]}"
		set -- ${NODE[$PX $PY $PD]}
#		echo "FF: $*"
		if (( $2 < 0 )) ; then
			return
		fi
		let STEPS+=$2
		set -- ${1//,/ }
		PX=$1
		PY=$2
		PD=$3
#		if [[ "${SEEN//$PX,$PY/}" != "$SEEN" ]] ; then
#			echo "SeenN: $PX $PY"
#			return
#		fi
	fi
	fi
	local SX SY SD SS
	SX=$PX
	SY=$PY
	SD=$PD
	SS=0
#	echo let ${PREV[$SD]}
#	eval let ${PREV[$SD]}
	local -a N
	while [[ "$PX $PY" != $END ]] ; do
		let STEPS+=1
#		echo -n "$STEPS Pos: $PX $PY $PD : ${DIRS[$PD]} :"
		V=0
		N=()
		for D in ${DIRS[$PD]} ; do
			NX=$PX
			NY=$PY
			eval let ${MOVE[$D]}
			C="${MAP[$NY]}"
			C="${C:$NX:1}"
#			echo -n " $D:$C"
			if [[ "$C" = "." ]] ; then
				N[$V]="$NX $NY $D"
				let V+=1
#				echo -n " Nxt: $NX $NY"
			fi
		done
#		echo
		if (( $V == 0 )) ; then
			if [[ -z "${NODE[$SX $SY $SD]}" ]] ; then
				NODE["$SX $SY $SD"]="$PX,$PY,$PD -1"
				echo NODE["$SX $SY $SD"]="$PX,$PY,$PD $SS"
			fi
			return
		elif (( $V > 1 )) ; then
			if [[ "${SEEN//$PX,$PY/}" != "$SEEN" ]] ; then
#				echo "Seen: $PX $PY"
				return
			fi
			SEEN="$SEEN $PX,$PY"
#			echo "Seen: $SEEN"
			if [[ -z "${NODE[$SX $SY $SD]}" ]] ; then
				NODE["$SX $SY $SD"]="$PX,$PY,$PD $SS"
				echo NODE["$SX $SY $SD"]="$PX,$PY,$PD $SS"
#				echo "N:$V ${N[@]}"
			fi
			local i
			for (( i=0 ; i<V ; i++ )) ; do
				step ${N[i]// /,} $STEPS "$SEEN"
			done
			return
		fi
		set -- ${N[0]}
		PX=$1
		PY=$2
		PD=$3
		let SS+=1
	done

	if [[ -z "${NODE[$SX $SY $SD]}" ]] ; then
		NODE["$SX $SY $SD"]="$PX,$PY,$PD $SS"
		echo NODE["$SX $SY $SD"]="$PX,$PY,$PD $SS"
	fi

	let "PATHS+=1"
	let "LONG=(STEPS>LONG)?STEPS:LONG"
	echo "Paths: $PATHS This: $STEPS Long: $LONG"
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

declare -A CUR NXT DIRS PREV MOVE NODE

DIRS[N]="N E W"
DIRS[S]="S E W"
DIRS[E]="N S E"
DIRS[W]="N S W"

MOVE[N]="NY=PY-1"
MOVE[S]="NY=PY+1"
MOVE[E]="NX=PX+1"
MOVE[W]="NX=PX-1"

PATHS=0
LONG=0

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
		echo "Long: $LONG"

		exit
	fi

	MAP[LN]="${LINE//[^#]/.}"

	if (( LN == 0 )) ; then
		LINE="${LINE%.*}"
		START="${#LINE},$LN,S"
	fi

	echo "${MAP[LN]}"

	let LN+=1

done

