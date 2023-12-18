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

function tilt () {
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

LN=0

declare -a PAT TX

PATN=0
TOTAL=0

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		echo "$PATN Rows"
		tilt

		i=0
		while [ $i -lt $PATN ] ; do
			O="${PAT[$i]//[^O]/}"
			let M=PATN-i
			echo "${PAT[$i]} ${#O} * $M"
			let TOTAL+=${#O}*M
			let i+=1
		done
		echo "Total: $TOTAL"
		exit
	fi

	PAT[$PATN]=$LINE
	echo $LINE

	let PATN+=1
	let LN+=1

done

