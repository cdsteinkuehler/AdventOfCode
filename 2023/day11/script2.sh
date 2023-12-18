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

function flagCol () {
	local i=0

	echo -n "Flagging columns:"
	COLN=0
	while [ $i -lt ${#CG} ] ; do
		if [ ${CG:$i:1} = "." ] ; then
			COL[$COLN]=$i
			let COLN+=1
			echo -n " $i"
		fi
		let i+=1
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

function xcol () {
	local C i=0
	local X=0
	while [ $i -lt $COLN ] ; do
		C=${COL[$i]}
		if [ $C -gt $2 ] ; then
			break
		elif [ $C -gt $1 -a $C -lt $2 ] ; then
			let X+=EXPAND
			#echo "XCOL" >&2
		fi
		let i+=1
	done
	echo $X
}

function xrow () {
	local R i=0
	local X=0
	while [ $i -lt $ROWN ] ; do
		R=${ROW[$i]}
		if [ $R -gt $2 ] ; then
			break
		elif [ $R -gt $1 -a $R -lt $2 ] ; then
			let X+=EXPAND
			#echo "XROW" >&2
		fi
		let i+=1
	done
	echo $X
}

function dist () {
	local XA XB YA YB X Y D X
	set ${G[$1]} ${G[$2]}
	if [ $3 -gt $1 ] ; then
		XA=$1
		XB=$3
	else
		XA=$3
		XB=$1
	fi
	if [ $4 -gt $2 ] ; then
		YA=$2
		YB=$4
	else
		YA=$4
		YB=$2
	fi
	let X=XB-XA
	let Y=YB-YA
	
	let D=X+Y
	X=`xrow $YA $YB`
	let D+=X
	X=`xcol $XA $XB`
	let D+=X
	echo $D
}

function paths () {
	local i=0
	TOTAL=0
	while [ $i -lt $GN ] ; do
		local j
		let j=i+1
		while [ $j -lt $GN ] ; do
			#echo "dist $i $j : ${G[$i]} ${G[$j]}"
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

declare -a MAP ROW COL

ROWN=0
COLN=0

if [ -z "$1" ] ; then
	echo "Must provided an expansion value!"
	exit 1
fi
if [ $1 -lt 1 ] ; then
	echo "Expansion value must be 1 or more!"
	exit 1
fi

let EXPAND=$1-1

{ cat ${2:-input} ; echo ; } |
while read LINE ; do
	if [ -z "$LINE" ] ; then
		echo "$COL Columns"
		flagCol
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
		CG=$LINE
	fi

	if [ -z "${LINE//[.]/}" ] ; then
		# Empty row, flag
		ROW[$ROWN]=$LN
		let ROWN+=1
	else
		i=0
		CGN=""
		while [ $i -lt ${#LINE} ] ; do
			C="${LINE:$i:1}"
			if [ $C = "#" ] ; then
				CGN="${CGN}#"
			else
				CGN="${CGN}${CG:$i:1}"
			fi
			let i+=1
		done
		CG=$CGN
		echo "$CG C"
	fi

	let LN+=1

done

