#!/bin/bash

function follow () {
	echo follow...
	P=AAA
	while [ $P != ZZZ ] ; do
		D=${DIR:$DIRP:1}
		let DIRP+=1
		if [ $DIRP -ge ${#DIR} ] ; then
			DIRP=0
		fi

		echo -n "$P $D $DIRP:"
		if [ $D = L ] ; then
			P=${MAPL[$P]}
		else
			P=${MAPR[$P]}
		fi

		echo $P

		let TOTAL+=1
		if [ $P = ZZZ ] ; then
			echo "Total: $TOTAL"
			return
		fi
	done
}

declare -A MAPL MAPR

LN=0
TOTAL=0
DIRP=0

{ cat ${1:-input} ; echo ; } |
while read LINE ; do
	let LN+=1
	if [ $LN -eq 1 ] ; then
		DIR=$LINE
		continue
	fi

	if [ $LN -eq 2 ] ; then
		continue
	fi

	if [ -z "$LINE" ] ; then
		echo "Dir: $DIR"
		echo "    :  ${!MAPL[*]}"
		echo "MAPL:  ${MAPL[*]}"
		echo "MAPR:  ${MAPR[*]}"

		follow
		exit
	fi

	# Build map array
	set ${LINE//[^A-Z ]/}
	MAPL[$1]=$2
	MAPR[$1]=$3

done

