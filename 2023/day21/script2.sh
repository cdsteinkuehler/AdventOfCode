#!/bin/bash

function step () {
	local i=0
	for i in "${CUR[@]}" ; do
		POS="${CUR[$i]}"
		PX=${POS% *}
		PY=${POS#* }
		#echo "Pos: $POS - $PX $PY"
		for D in "${DIRS[@]}" ; do
			NX=$PX
			NY=$PY
			eval let $D
			let "MX=NX%W"
			let "MY=NY%H"
			let "MX+=(MX<0)?W:0"
			let "MY+=(MY<0)?H:0"
#			echo "$NX $NY $MX $MY"
			C="${MAP[$MY]}"
			C="${C:$MX:1}"
			#echo -n "$C "
			if [[ "$C" = "." ]] ; then
				#echo "Nxt[$NX $NY]: $NX $NY"
				NXT["$NX $NY"]="$NX $NY"
#			elif [[ "$C" != "#" ]] ; then
#				echo "Huh? $NX $NY $MX $MY \"$C\""
			fi
		done
	done
	#NXT2CUR
	CUR=()
}

function stepN () {
	local i=0
	for i in "${NXT[@]}" ; do
		POS="${NXT[$i]}"
		PX=${POS% *}
		PY=${POS#* }
		#echo "Pos: $POS - $PX $PY"
		for D in "${DIRS[@]}" ; do
			NX=$PX
			NY=$PY
			eval let $D
			let "MX=NX%W"
			let "MY=NY%H"
			let "MX+=(MX<0)?W:0"
			let "MY+=(MY<0)?H:0"
			C="${MAP[$MY]}"
			C="${C:$MX:1}"
			#echo -n "$C "
			if [[ "$C" = "." ]] ; then
				#echo "Nxt[$NX $NY]: $NX $NY"
				CUR["$NX $NY"]="$NX $NY"
			fi
		done
	done
	NXT=()
}

function walk () {
	CUR["$START"]="$START"
	NXT=()
	FNXT=0

	W=${#MAP[0]}
	H=${#MAP[*]}
	echo "Size: $W x $H"
	let TEST=W/2
	echo "Test: $TEST"

	local i=0
	while (( $i < $1 )) ; do
		step
		let i+=1
		echo "$i States: ${#NXT[*]}"

		if (( $i == $TEST )) ; then
			FACT[FNXT]=${#NXT[*]}
			echo "FACT: ${FACT[*]}"
			let FNXT+=1
			let TEST+=W

		fi

		stepN
		let i+=1
		echo "$i States: ${#CUR[*]}"

		if (( $i == $TEST )) ; then
			FACT[FNXT]=${#CUR[*]}
			echo "FACT: ${FACT[*]}"
			let FNXT+=1
			let TEST+=W

		fi
		if (( $FNXT == 3 )) ; then
			echo "FACT: ${FACT[*]}"
			DELTA[0]=${FACT[0]}
			let DELTA[1]=${FACT[1]}-${FACT[0]}
			let DELTA[2]=${FACT[2]}-${FACT[1]}-${FACT[1]}+${FACT[0]}
			echo "Delta: ${DELTA[*]}"
			let GOAL_H=GOAL/H
			TOTAL=${DELTA[0]}
			let TOTAL+=${DELTA[1]}*GOAL_H
			let GOAL_H_1=GOAL_H-1
			let GOAL_3=GOAL_H*GOAL_H_1/2
			echo "Goal: $GOAL $GOAL_H $GOAL_2_1 $GOAL_3"
			let TOTAL+=${DELTA[2]}*GOAL_3
			echo "Total : $TOTAL"
			exit
		fi
	done

}

LN=0

declare -A CUR NXT
declare -a MAP DIRS FACT

DIRS[0]="NX+=1"
DIRS[1]="NX-=1"
DIRS[2]="NY+=1"
DIRS[3]="NY-=1"

TMAX=0
TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then
		echo "Start: $START"

		GOAL=26501365

		walk ${2:-1000}

		exit

		let R=${#MAP[0]}-1
		let B=${#MAP[*]}-1
		i=0
		meander 0 3
		echo "Min: $TOTAL"

		exit
	fi

	MAP[LN]="$LINE"
	if [[ "${LINE%S*}" != "$LINE" ]] ; then
		MAP[LN]="${LINE//S/.}"
		LINE="${LINE%S*}"
		START="${#LINE} $LN"
	fi

	echo "${MAP[LN]}"

	let LN+=1

done

