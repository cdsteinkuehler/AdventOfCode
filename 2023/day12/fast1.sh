#!/bin/bash

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

function permute () {
	MAP="$1"
	shift
	set -- ${1//,/ }
	local i=0
	declare -a BAD
	while [ $# -gt 0 ] ; do
		BAD[i]=$1
		let i+=1
		shift
	done

	echo "Permute: $MAP ${BAD[*]}"

	declare -A CUR NXT
	CUR[0 0 0 0]=1
	MATCH=0
	MAX=0
	while STATES=${#CUR[*]} && [ $STATES -gt 0 ] ; do
		if [ $STATES -gt $MAX ] ; then
			MAX=$STATES
		fi
		local i=0
		for STATE in "${!CUR[@]}" ; do
			local n=${CUR[$STATE]}
			set -- $STATE
#			echo "State: $STATE $n"
			si=$1
			ci=$2
			cc=$3
			nxtdot=$4
			let sn=si+1
			if [ $si -eq ${#MAP} ] ; then
				if [ $ci -eq ${#BAD[*]} ] ; then
					let MATCH+=n
			       	fi
				continue
			fi
			C=${MAP:$si:1}
			if [ $C = "#" -o $C = "?" ] && [ $ci -lt ${#BAD[*]} -a $nxtdot -eq 0 ] ; then
				# We are still looking for broken springs
				if [ $C = "?" -a $cc -eq 0 ] ; then
					# Not in a run of broken springs, ? can be "."
					let NXT["$sn $ci $cc $nxtdot"]=${NXT["$sn $ci $cc $nxtdot"]:-0}+$n
				fi
				let cc+=1
				if [ $cc -eq ${BAD[$ci]} ] ; then
					# Found the full next contiguous section of broken springs
					let ci+=1
					cc=0
					# Next spring needs to be working (.)
					nxtdot=1
				fi
				let NXT["$sn $ci $cc $nxtdot"]=${NXT["$sn $ci $cc $nxtdot"]:-0}+$n
			elif [ $C = "." -o $C = "?" ] ; then
				if [ $cc -eq 0 ] ; then
					# Not in a run of broken springs
					nxtdot=0
					let sn=si+1
					let NXT["$sn $ci $cc $nxtdot"]=${NXT["$sn $ci $cc $nxtdot"]:-0}+$n
				fi
			fi

		done

		NXT2CUR
	done

	STATES=$MAX
}

LN=0

TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read SPRINGS BAD ; do
	if [ -z "$SPRINGS" ] ; then
#		echo ${!ONES[*]}
#		echo ${ONES[*]}
#		echo ${BINARY[*]}
		exit
	fi

	echo "$SPRINGS" "$BAD"

	MATCH=0
	permute "$SPRINGS" "$BAD"

	let TOTAL+=MATCH
	if [ $STATES -gt $MAXSTATES ] ; then
		MAXSTATES=$STATES
	fi
	echo "States: $STATES MaxStates: $MAXSTATES Match: $MATCH Total: $TOTAL"

	let LN+=1
done

