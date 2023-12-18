#!/bin/bash

function smudge () {
	local i=0
	while [ $i -lt ${#1} ] ; do
		if [ ${1:$i:1} != ${2:$i:1} ] ; then
			let SMUDGE+=1
		fi
		let i+=1
	done
}

function findaxis () {
	AXIS=0
	local i=0
	local j R
	local Z=Y
	let R=$PATN-1
	while [ $i -lt $R ] ; do
		SMUDGE=0
		let j=i+1
		smudge ${PAT[$i]} ${PAT[$j]}
		if [ $SMUDGE -le 1 ] ; then
			local X Y
			let X=i-1
			let Y=j+1
			while [ $X -ge 0 -a $Y -lt $PATN ] ; do
				if [ ${PAT[$X]} != ${PAT[$Y]} ] ; then
					smudge ${PAT[$X]} ${PAT[$Y]}
					if [ $SMUDGE -gt 1 ] ; then
						echo -n "!"
						Z=N
						break
					else
						echo -n "s"
					fi
				else
					echo -n "."
				fi
				let X-=1
				let Y+=1
			done
			echo " $i:$Z"
			if [ $Z = Y -a $SMUDGE -eq 1 ] ; then
				let AXIS=$i+1
				return
			fi
			Z=Y
		fi
		i=$j
	done
}

function transpose () {
	echo "Transpose:"
	TX=()
	TXN=${#PAT[0]}
	local i=0
	while [ $i -lt $PATN ] ; do
		local j=0
		while [ $j -lt $TXN ] ; do
			TX[$j]="${TX[$j]}${PAT[$i]:$j:1}"
			let j+=1
		done
		let i+=1
	done
	PAT=()
	i=0
	while [ $i -lt $TXN ] ; do
		PAT[$i]=${TX[$i]}
		echo ${PAT[$i]}
		let i+=1
	done
	PATN=$TXN

}

LN=0

declare -a PAT TX

PATN=0
TOTAL=0

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		echo "$PATN Rows"
		findaxis

		if [ $AXIS -gt 0 ] ; then
			let INC=AXIS*100
			echo "Axis=$AXIS += $INC"
			let TOTAL+=INC
			echo "Total: $TOTAL"
		else
			transpose
			findaxis
			echo "Axis=$AXIS += $AXIS"
			let TOTAL+=AXIS
			echo "Total: $TOTAL"
		fi

		PATN=0
		continue

	fi

	PAT[$PATN]=$LINE
	echo $LINE

	let PATN+=1
	let LN+=1

done

