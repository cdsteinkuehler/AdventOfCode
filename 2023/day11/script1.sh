#!/bin/bash

#set -x

function max () {
	if [ "$1" -gt "$2" ] ; then
		echo $1
	else
		echo $2
	fi
}

function min () {
	if [ "$1" -lt "$2" ] ; then
		echo $1
	else
		echo $2
	fi
}

function insert () {
	if [ $2 -eq 0 ] ; then
		echo $1$3
	elif [ $2 -eq ${#3} ] ; then
		echo $3$1
	else
		echo ${3:0:$2}$1${3:$2}
	fi
}

function insertCol () {
	local i=0
	while [ $i -lt $LN ] ; do
		MAP[$i]=`insert $1 $2 ${MAP[$i]}`
		let i+=1
	done
}

function expandCol () {
	local i

	echo -n "Inserting columns:"
	let i=${#COL}-1
	while [ $i -ge 0 ] ; do
		if [ ${COL:$i:1} = "." ] ; then
			echo -n " $i"
			insertCol . $i
		fi
		let i-=1
	done
	echo " done"
}

function mapRow () {
	local i=0
	while [ $i -lt ${#MAP[$1]} ] ; do
		if [ "${MAP[$1]:$i:1}" = "#" ] ; then
			G[$GN]="$i $1"
			echo "$GN $i $1"
			let GN+=1
		fi

		let i+=1
	done
}

function mapGal () {
	echo "Mapping galaxies"
	local i=0
	GN=0
	while [ $i -lt $LN ] ; do
		mapRow $i
		let i+=1
	done
}

function dist () {
	local XA XB YA YB X Y D
	set ${G[$1]} ${G[$2]}
	XA=$1
	YA=$2
	XB=$3
	YB=$4
	let X=XA-XB
	let Y=YA-YB
	if [ $X -lt 0 ] ; then
		let X=0-X
	fi
	if [ $Y -lt 0 ] ; then
		let Y=0-Y
	fi
	
	let D=X+Y
	echo $D
}

function paths () {
	local i=0
	TOTAL=0
	while [ $i -lt $GN ] ; do
		local j
		let j=i+1
		while [ $j -lt $GN ] ; do
			echo "dist $i $j : ${G[$i]} ${G[$j]}"
			D=`dist $i $j`
			let TOTAL+=D
			echo "$D : $TOTAL"
			let j+=1
		done
		let i+=1
	done
	echo $TOTAL
}

LN=0

declare -a MAP

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		echo "$COL Columns"
		expandCol
		i=0
		while [ $i -lt $LN ] ; do
			echo ${MAP[$i]}
			let i+=1
		done
		mapGal
		paths
		exit
	fi

	MAP[$LN]=$LINE
	echo $LINE

	if [ $LN -eq 0 ] ; then
		COL=$LINE
	fi

	if [ -z "${LINE//[.]/}" ] ; then
		# Empty row, expand
		let LN+=1
		MAP[$LN]=$LINE
		echo "$LINE ++"
	else
		i=0
		COLN=""
		while [ $i -lt ${#LINE} ] ; do
			C="${LINE:$i:1}"
			if [ $C = "#" ] ; then
				COLN="${COLN}#"
			else
				COLN="${COLN}${COL:$i:1}"
			fi
			let i+=1
		done
		COL=$COLN
		echo "$COL C"
	fi

	let LN+=1

done

