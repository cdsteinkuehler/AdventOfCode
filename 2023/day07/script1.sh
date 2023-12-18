#!/bin/bash

#set -x

# True if $1 is greater than $2
function cmphand () {
	local L R C i
	for i in 0 1 2 3 4 ; do
		L=${1:$i:1}
		R=${2:$i:1}
		if [ $L = $R ] ; then
			continue
		fi

		for C in A K Q J T 9 8 7 6 5 4 3 2 ; do
			if [ $L = $C ] ; then
				return 0
			elif [ $R = $C ] ; then
				return 1
			fi
		done
	done
}

function check () {
	local MATCH=0
#	echo -n "$1:"
	for C in A K Q J T 9 8 7 6 5 4 3 2 ; do
		X=${1//$C/}
		case ${#X} in
			0)	echo Five
				return
				;;
			1)	echo Four
				return
				;;
			2)	if [ $MATCH -eq 2 ] ; then
					echo Full
					return
				else
					MATCH=3
				fi
				;;
			3)	if [ $MATCH -eq 3 ] ; then
					echo Full
					return
				elif [ $MATCH -eq 2 ] ; then
					echo Pair2
					return
				else
					MATCH=2
				fi
				;;
			*)	;;
		esac
	done
	if [ $MATCH -eq 3 ] ; then
		echo Three
	elif [ $MATCH -eq 2 ] ; then
		echo Pair1
	elif [ $MATCH -eq 0 ] ; then
		echo High
	else
		echo UNKNOWN!
	fi
}

function insertHand () { # Index Hand Bet
	echo insertHand $*
	local R i j
	let R=${HANDL[High]}+${HANDL[Pair1]}+${HANDL[Pair2]}+${HANDL[Three]}+${HANDL[Full]}+${HANDL[Four]}+${HANDL[Five]}
	let i=R
	while [ $i -gt $1 ] ; do
		let j=i-1
		HAND[$i]=${HAND[$j]}
		BET[$i]=${BET[$j]}
		let i-=1
	done
	HAND[$1]=$2
	BET[$1]=$3
}

function insertType () { # Type Hand Bet
	echo insertType $*
	local PREV

	case $1 in
		High)	let HANDB[Pair1]+=1 ;&
		Pair1)	let HANDB[Pair2]+=1 ;&
		Pair2)	let HANDB[Three]+=1 ;&
		Three)	let HANDB[Full]+=1 ;&
		Full)	let HANDB[Four]+=1 ;&
		Four)	let HANDB[Five]+=1 ;&
		Five)	;;
		*)	;;
	esac

	if [ ${HANDL[$1]} -eq 0 ] ; then
		case $1 in
			High)	PREV=High
				;;
			Five)	PREV=Four
				;;
			Four)	PREV=Full
				;;
			Full)	PREV=Three
				;;
			Three)	PREV=Pair2
				;;
			Pair2)	PREV=Pair1
				;;
			Pair1)	PREV=High
				;;
			*)	PREV=High
				;;
		esac
		let HANDB[$1]=${HANDB[$PREV]}+${HANDL[$PREV]}

		insertHand ${HANDB[$1]} $2 $3
		let HANDL[$1]+=1
		return
	fi

	local R i
	let R=${HANDB[$1]}+${HANDL[$1]}
	let i=${HANDB[$1]}
	while [ $i -lt $R ] ; do
		if cmphand $2 ${HAND[$i]} ; then
			let i+=1
			continue
		else
			insertHand $i $2 $3
			let HANDL[$1]+=1
			return
		fi
	done

	insertHand $R $2 $3
	let HANDL[$1]+=1
}

LN=0

declare -a HAND BET
declare -A HANDB=( [Five]=0 [Four]=0 [Full]=0 [Three]=0 [Pair2]=0 [Pair1]=0 [High]=0 )
declare -A HANDL=( [Five]=0 [Four]=0 [Full]=0 [Three]=0 [Pair2]=0 [Pair1]=0 [High]=0 )

LAST=23456
TOTAL=0

{ cat ${1:-input} ; echo ; } |
while read H B ; do
	let LN+=1
	if [ -z "$H" ] ; then
		let R=${HANDL[High]}+${HANDL[Pair1]}+${HANDL[Pair2]}+${HANDL[Three]}+${HANDL[Full]}+${HANDL[Four]}+${HANDL[Five]}
		i=0
		while [ $i -lt $R ] ; do
			let RANK=i+1
			let BIDX=${BET[$i]}*RANK
			let TOTAL+=BIDX
			let i+=1
		done
		echo "Total: $TOTAL"
		exit
	fi

	T=`check $H`

	insertType $T $H $B
	echo "HAND :${HAND[*]}"
	echo "BET  :${BET[*]}"
	echo "HANDL:${!HANDL[*]}"
	echo "HANDL:${HANDL[*]}"
	echo "HANDB:${HANDB[*]}"

#	echo -n "Compare $H $LAST : "
#	if cmphand $H $LAST ; then
#		echo $H
#	else
#		echo $LAST
#	fi

	LAST=$H

done

