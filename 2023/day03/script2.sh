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

function gearpn () {
	local RATIO=1
	local L=$1
	local R=$2
	local SCH=$3

	C=${SCH:$L:1}
	if [ -n "${C/[^0-9]/}" ] ; then
		# Left-hand char is a number, look for the start
		while : ; do
			C=${SCH:$L:1}
			if [ -n "${C/[^0-9]/}" ] ; then
				let L-=1
				if [ $L -lt 0 ] ; then
					L=0
					break
				fi
			else
				let L+=1
				break
			fi
		done

		R=$1
		while : ; do
			C=${SCH:$R:1}
			if [ -n "${C/[^0-9]/}" ] ; then
				let R+=1
				if [ $R -ge ${#SCH} ] ; then
					let R=SCH-1
					break
				fi
			else
				let R-=1
				break
			fi
		done

		let N=R-L+1
		#echo $L:$R:${SCH:$L:$N} >&2
		echo -n "${SCH:$L:$N} " >&2

		RATIO=$(( $RATIO * ${SCH:$L:$N} ))

		# Check for possible second number
		let L=R+1
		R=$2
	fi

	# Find left-most number
	NUM=N
	while : ; do
		C=${SCH:$L:1}
		if [ -n "${C/[^0-9]/}" ] ; then
			NUM=Y
			break
		fi
		if [ $L -ge $2 ] ; then
			break
		fi
		let L+=1
	done

	if [ $NUM = Y ] ; then
		let R=L+1
		while : ; do
			C=${SCH:$R:1}
			if [ -n "${C/[^0-9]/}" ] ; then
				let R+=1
				if [ $R -ge ${#SCH} ] ; then
					let R=${#SCH}-1
					break
				fi
			else
				let R-=1
				break
			fi
		done
		let N=R-L+1
		#echo $L:$R:${SCH:$L:$N} >&2
		echo -n "${SCH:$L:$N} " >&2

		RATIO=$(( $RATIO * ${SCH:$L:$N} ))
	fi
	echo $RATIO
}

LN=0
TOTAL=0

while read NEXT ; do
	if [ $LN -eq 0 ] ; then
		LAST=$NEXT
		THIS=$NEXT
		LN=$(( $LN + 1 ))
		continue
	fi

	i=0
	LLEN=${#THIS}
	echo -n "$LN: "
	while [ $i -lt $LLEN ] ; do
		CHAR=${THIS:$i:1}
		if [ -n "${CHAR/[!*]/}" ] ; then
			let L=i-1
			L=$(max $L 0)
			R=0
			#while [ $R -eq 0 ] ; do
				let i=i+1
				if [ $i -ge $LLEN ] ; then
					let R=LLEN-1
				else
					let R=i
				fi
			#done
			let NLEN=R-L+1

			last=${LAST:L:$NLEN}
			this=${THIS:L:$NLEN}
			next=${NEXT:L:$NLEN}
			last="${last//[^0-9]/ }"
			this="${this//[^0-9]/ }"
			next="${next//[^0-9]/ }"
			set $last $this $next
			GEARS=$#

			if [ $GEARS -ge 2 ] ; then
				RATIO=$(( `gearpn $L $R $LAST` ))
				RATIO=$(( `gearpn $L $R $THIS` * RATIO ))
				RATIO=$(( `gearpn $L $R $NEXT` * RATIO ))
				let TOTAL+=RATIO
				echo -n "- "
			fi
		fi
		i=$(( $i + 1 ))
	done

	echo "Total: $TOTAL"
	LAST=$THIS
	THIS=$NEXT
	LN=$(( $LN + 1 ))

#	if [ $POSSIBLE = Y ] ; then TOTAL=$(( $TOTAL + ${NUM/:/} )) ; fi
#	echo "$GAME ${NUM/:/} $POSSIBLE $TOTAL"
done < ${1:-input}

