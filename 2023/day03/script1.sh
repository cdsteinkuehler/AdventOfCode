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

LN=0

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
		if [ -n "${CHAR/[!0-9]/}" ] ; then
			let L=i-1
			L=$(max $L 0)
			R=0
			while [ $R -eq 0 ] ; do
				let i=i+1
				if [ $i -ge $LLEN ] ; then
					let R=LLEN-1
				else
					CHAR=${THIS:$i:1}
					if [ -n "${CHAR/[0-9]/}" ] ; then
						let R=i
					fi
				fi
			done
			let NLEN=R-L+1
			NRAW=${THIS:L:$NLEN}
			N=${NRAW//[^0-9]/}
			# Now check LAST/THIS/NEXT for symbols
			PART=N
			let X=L
			while [ $X -le $R ] ; do
				for C in ${LAST:$X:1} ${THIS:$X:1} ${NEXT:$X:1} ; do
					if [ -n "${C/[.0-9]/}" ] ; then
						PART=Y
						break 2
					fi
				done
				let X=X+1
			done
			echo -n "$L:$R:$N:$PART "
			if [ $PART = Y ] ; then
				let TOTAL+=N
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

