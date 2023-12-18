#!/bin/bash

function insert () {
	if [ $2 -eq 0 ] ; then
		HOT[$3]=$1${HOT[$3]:1}
	elif [ $2 -eq ${#HOT[$3]} ] ; then
		local L
		let L=$2-1
		HOT[$3]=${HOT[$3]:0:$L}$1
	else
		local L R
		let L=$2
		let R=$2+1
		HOT[$3]=${HOT[$3]:0:$L}$1${HOT[$3]:$R}
	fi
}

function heapcp () {
	HEAP_V[$2]="${HEAP_V[$1]}"
	HEAP_X[$2]="${HEAP_X[$1]}"
}

function heapswap () {
	local V X
	V="${HEAP_V[$2]}"
	X="${HEAP_X[$2]}"
	HEAP_V[$2]="${HEAP_V[$1]}"
	HEAP_X[$2]="${HEAP_X[$1]}"
	HEAP_V[$1]="$V"
	HEAP_X[$1]="$X"
}

function sanitycheck () {
	local i=1
	local A
	while [ $i -lt $HEAPN ] ; do
		let A=i-1
		let A=A/2
		if [ ! ${HEAP_V[$i]} -ge ${HEAP_V[$A]} ] ; then
			echo "Heap error!"
			exit
		fi
		let i+=1
	done

}

function heappush () {
#	echo heappush $*
	# State is Value XPos YPos Dir
	local A=$HEAPN B
	let HEAPN+=1
	let B=A-1
	let B=B/2

	while (( $A != 0 && $1 < ${HEAP_V[$B]:-0} )) ; do
		#heapcp $B $A
		HEAP_V[$A]="${HEAP_V[$B]}"
		HEAP_X[$A]="${HEAP_X[$B]}"
		A=$B
		let B=A-1
		let B=B/2
	done

	HEAP_V[$A]=$1
	HEAP_X[$A]="$2 $3 $4"
}

function heappop () {
#	echo heappop
	if [ $HEAPN -eq 1 ] ; then
		let HEAPN-=1
		STATE="${HEAP_V[0]} ${HEAP_X[0]}"
		return
	fi

	STATE="${HEAP_V[0]} ${HEAP_X[0]}"
	let HEAPN-=1
	heapcp $HEAPN 0

	local A DONE S L R
	A=0
	DONE=0
	while [ $DONE -eq 0 ] ; do
		S=$A
		let L=A*2+1
		let R=L+1
		if (( $L < $HEAPN && ${HEAP_V[$L]:-0} < ${HEAP_V[$S]:-0} )) ; then
			S=$L
		fi
		if (( $R < $HEAPN && ${HEAP_V[$R]:-0} < ${HEAP_V[$S]:-0} )) ; then
			S=$R
		fi
		if (( $S != $A )) ; then
			#heapcp $A $HEAPN
			#heapcp $S $A
			#heapcp $HEAPN $S
			#heapswap $S $A
			local V X
			V="${HEAP_V[$A]}"
			X="${HEAP_X[$A]}"
			HEAP_V[$A]="${HEAP_V[$S]}"
			HEAP_X[$A]="${HEAP_X[$S]}"
			HEAP_V[$S]="$V"
			HEAP_X[$S]="$X"

			A=$S
		else
			DONE=1
		fi
	done

}

function meander () {
#	local R B
#	R=${#MAP[0]}
#	B=${#MAP[*]}
	declare -A CUR SEEN
	MIN=$1
	MAX=$2
	# State is Value XPos YPos Dir
	heappush 0 0 0 E
	heappush 0 0 0 S
	SMAX=0
	TRIES=0
	while [ $HEAPN -gt 0 ] ; do
		if [ $HEAPN -gt $SMAX ] ; then
			SMAX=$HEAPN
		fi

		heappop
#		for STATE in "$sorted" ; do
			local X Y C D
			set -- $STATE
#			echo "State: $STATE $n"
			V=$1
			X=$2
			Y=$3
			D=$4

			let TRIES+=1
			echo "$TRIES: $STATE"

			if [ $X -eq $R -a $Y -eq $B ] ; then
				# Finished, return result
				TOTAL="$TOTAL $V"
				return
			fi

			if [ -n "${SEEN[$X $Y $D]}" ] ; then
				# We've been here before...
#				if [ "${SEEN[$X $Y $D]}" -le $V ] ; then
					# ...and the path value was the same or less
					continue
#				fi
			fi

			SEEN["$X $Y $D"]=$V

			case $D in
				[NS]) DIRS="E W" ;;
				[EW]) DIRS="N S" ;;
				*)    DIRS="." ;;
			esac

			for D in $DIRS ; do
				local XI YI
				local VL=$V
				local XL=$X
				local YL=$Y
				local CX CY
				case $D in
					N) XI=0  ; YI=-1 ; CX="= a"    ; CY="-lt 0" ;;
					S) XI=0  ; YI=1  ; CX="= a"    ; CY="-gt $B";;
					E) XI=1  ; YI=0  ; CX="-gt $R" ; CY="= a" ;;
					W) XI=-1 ; YI=0  ; CX="-lt 0"  ; CY="= a" ;;
					*) echo "Error: $STATE" ; exit ;;
				esac

				# Advance MIN elements
				local i=0
				while (( $i < $MIN )) ; do
					let XL+=XI
					let YL+=YI
					if [ $XL $CX -o $YL $CY ] ; then
						break
					fi
					let VL+=${MAP[$YL]:$XL:1}
					let i+=1
				done
				# Walk MIN to MAX elements
				while (( $i < $MAX )) ; do
					let XL+=XI
					let YL+=YI
					if [ $XL $CX -o $YL $CY ] ; then
						break
					fi
					let VL+=${MAP[$YL]:$XL:1}
					heappush $VL $XL $YL $D
					let i+=1
				done
			done
			#sanitycheck
#		done
	done

	STATES=$SMAX
}

LN=0

declare -a MAP

declare -a HEAP_V HEAP_X
HEAPN=0

TMAX=0
TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	if [ -z "$LINE" ] ; then
		let R=${#MAP[0]}-1
		let B=${#MAP[*]}-1
		i=0
		meander 0 3
		echo "Min: $TOTAL"

		exit
	fi

	echo "$LINE"
	MAP[LN]="$LINE"
	let LN+=1

done

