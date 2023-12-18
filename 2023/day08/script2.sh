#!/bin/bash

function follow () {
	echo follow...
	echo "POS : ${POS[*]}"
	echo "POSN: $POSN"
	echo "Determine period each start position, factor, and find the least-common-multiple"

	local Z=012345
	while [ -n "$Z" ] ; do
		D=${DIR:$DIRP:1}
		let DIRP+=1
		if [ $DIRP -ge ${#DIR} ] ; then
			DIRP=0
		fi

		let TOTAL+=1
		echo -n "$TOTAL: ${POS[*]} $D"
		printf " %03i:" $DIRP
		local i=0
		local ZS=""
		local PN=""
		while [ $i -lt $POSN ] ; do
			if [ $D = L ] ; then
				P=${MAPL[${POS[$i]}]}
			else
				P=${MAPR[${POS[$i]}]}
			fi

			if [ "${P:2:1}" != Z ] ; then
				ZS="${ZS}-"
			else
				ZS="${ZS}Z"
				Z="${Z//$i/}"
				if [ "${PERIOD[$i]}" -eq 0 ] ; then
					PERIOD[$i]=$TOTAL
					PN=$TOTAL
				fi
			fi

			echo -n " $P"
			POS[$i]=$P

			let i+=1
		done
		echo " $ZS $Z $PN"

		if [ -z "$Z" ] ; then
			echo "Total: $TOTAL"
			echo ${PERIOD[*]}
			echo 
			X=1
			factor ${PERIOD[*]} | sed 's/[0-9]*: //;s/ /\n/' | sort -un |
				while read V ; do
					let X*=V
					echo $V:$X
				done
		fi
	done
}

declare -A MAPL MAPR
declare -a POS PERIOD

LN=0
TOTAL=0
DIRP=0
POSN=0

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
	set ${LINE//[^A-Z0-9 ]/}
	MAPL[$1]=$2
	MAPR[$1]=$3

	if [ ${1:2:1} = A ] ; then
		POS[$POSN]=$1
		PERIOD[$POSN]=0
		let POSN+=1
	fi

done

