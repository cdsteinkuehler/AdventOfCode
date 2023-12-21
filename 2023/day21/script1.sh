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
			if (( $NX < 0 || $NY < 0 )) ; then
				continue
			fi
			C="${MAP[$NY]}"
			C="${C:$NX:1}"
			#echo -n "$C "
			if [[ "$C" = "." ]] ; then
				#echo "Nxt[$NX $NY]: $NX $NY"
				NXT["$NX $NY"]="$NX $NY"
			fi
		done
	done
	NXT2CUR
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

declare -A CUR NXT
declare -a MAP DIRS

DIRS[0]="NX=PX+1"
DIRS[1]="NX=PX-1"
DIRS[2]="NY=PY+1"
DIRS[3]="NY=PY-1"

TMAX=0
TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then
		echo "Start: $START"

		walk ${2:-64}

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

