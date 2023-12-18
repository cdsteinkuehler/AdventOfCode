#!/bin/bash

#set -x

function insert () {
	if [ $2 -eq 0 ] ; then
		PAT[$3]=$1${PAT[$3]:1}
	elif [ $2 -eq ${#PAT[$3]} ] ; then
		local L
		let L=$2-1
		PAT[$3]=${PAT[$3]:0:$L}$1
	else
		local L R
		let L=$2
		let R=$2+1
		PAT[$3]=${PAT[$3]:0:$L}$1${PAT[$3]:$R}
	fi
}

function tiltN () {
	local i j
	local BASE C
	i=0
	while [ $i -lt ${#PAT[0]} ] ; do
		BASE=-1
		j=0
		while [ $j -lt $PATN ] ; do
			C=${PAT[$j]:$i:1}
			if [ $C = "#" ] ; then
				let BASE=$j+1
			elif [ $C = "O" -a $BASE -ge 0 ] ; then
				if [ $BASE -ne $j ] ; then
					insert "O" $i $BASE
					insert "." $i $j
				fi
				let BASE+=1
			elif [ $C = "." -a $BASE -lt 0 ] ; then
				BASE=$j
			fi
			let j+=1
		done
		let i+=1
	done
}

function tiltW () {
	local i j
	local BASE C
	i=0
	while [ $i -lt $PATN ] ; do
		BASE=-1
		j=0
		while [ $j -lt ${#PAT[0]} ] ; do
			C=${PAT[$i]:$j:1}
			if [ $C = "#" ] ; then
				let BASE=$j+1
			elif [ $C = "O" -a $BASE -ge 0 ] ; then
				if [ $BASE -ne $j ] ; then
					insert "O" $BASE $i
					insert "." $j $i
				fi
				let BASE+=1
			elif [ "$C" = "." -a $BASE -lt 0 ] ; then
				BASE=$j
			fi
			let j+=1
		done
		let i+=1
	done
}

function tiltS () {
	local i j
	local BASE C
	i=0
	while [ $i -lt ${#PAT[0]} ] ; do
		BASE=-1
		let j=PATN-1
		while [ $j -ge 0 ] ; do
			C=${PAT[$j]:$i:1}
			if [ $C = "#" ] ; then
				let BASE=$j-1
			elif [ $C = "O" -a $BASE -ge 0 ] ; then
				if [ $BASE -ne $j ] ; then
					insert "O" $i $BASE
					insert "." $i $j
				fi
				let BASE-=1
			elif [ $C = "." -a $BASE -lt 0 ] ; then
				BASE=$j
			fi
			let j-=1
		done
		let i+=1
	done
}

function tiltE () {
	local i j
	local BASE C
	i=0
	while [ $i -lt $PATN ] ; do
		BASE=-1
		let j=PATN-1
		while [ $j -ge 0 ] ; do
			C=${PAT[$i]:$j:1}
			if [ $C = "#" ] ; then
				let BASE=$j-1
			elif [ $C = "O" -a $BASE -ge 0 ] ; then
				if [ $BASE -ne $j ] ; then
					insert "O" $BASE $i
					insert "." $j $i
				fi
				let BASE-=1
			elif [ "$C" = "." -a $BASE -lt 0 ] ; then
				BASE=$j
			fi
			let j-=1
		done
		let i+=1
	done
}

function patprint () {
	local i O M T
	echo "$1"
	i=0
	T=0
	while [ $i -lt $PATN ] ; do
		O="${PAT[$i]//[^O]/}"
		let M=PATN-i
		echo "${PAT[$i]} ${#O} * $M"
		let T+=${#O}*M
		let i+=1
	done
	echo "Total: $T"
}

function doTotal () {
	local i O M T
	i=0
	T=0
	while [ $i -lt $PATN ] ; do
		O="${PAT[$i]//[^O]/}"
		let M=PATN-i
		let T+=${#O}*M
		let i+=1
	done
	TOTAL=$T
}

function tprint () {
	local i O M T
	echo "$1"
	i=0
	T=0
	while [ $i -lt $PATN ] ; do
		O="${PAT[$i]//[^O]/}"
		let M=PATN-i
		echo -n "${#O} "
		let T+=${#O}*M
		let i+=1
	done
	echo "T: $T"
}

function spin () {
	tiltN
#	patprint "Tilt North:"
	tiltW
#	patprint "Tilt West:"
	tiltS
#	patprint "Tilt South:"
	tiltE
#	patprint "Tilt East:"
}

LN=0

declare -a PAT TX
declare -A SEEN

PATN=0
TOTAL=0
PERIOD=0
DONE=0

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		echo "$PATN Rows"
		i=0
		#while [ $i -lt 40 ] ; do
		while [ $DONE -ge 0 ] ; do
			spin
			tprint "Spin #$i: Period=$PERIOD Done=$DONE"
			PREV=$TOTAL
			doTotal
#			set -x
			echo KEY="$PREV.$TOTAL"
			KEY="$PREV.$TOTAL"
			if [ -z "${SEEN[$KEY]}" ] ; then
				PERIOD=0
				DONE=0
			else
				let DIFF=i-${SEEN[$KEY]}
				if [ $DIFF -eq $PERIOD ] ; then
					let DONE-=1
				else
					PERIOD=$DIFF
					DONE=$DIFF
				fi

			fi
			SEEN[$KEY]=$i
			let i+=1
			set +x
		done

		echo "Period: $PERIOD"
		echo "Current index: $i"

		let SKIP=1000000000-i-1
		let SKIPK=SKIP/PERIOD
		let SKIPN=SKIPK*PERIOD
		let i+=SKIPN
		while [ $i -lt 1000000000 ] ; do
			spin
			tprint "Spin #$i:"

			let i+=1
		done
#		i=0
#		: > out
#		while [ $i -lt $PATN ] ; do
#			echo "${PAT[$i]}" >> out
#			O="${PAT[$i]//[^O]/}"
#			let M=PATN-i
#			echo "${PAT[$i]} ${#O} * $M"
#			let TOTAL+=${#O}*M
#			let i+=1
#		done
#		echo "Total: $TOTAL"
		exit
	fi

	PAT[$PATN]=$LINE
	echo $LINE

	let PATN+=1
	let LN+=1

done

