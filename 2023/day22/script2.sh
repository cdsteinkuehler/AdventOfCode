#!/bin/bash

function NXT2CUR () {
	local i=0
	CUR=()
	while (( $i < $NXTN )) ; do
		CUR[i]=${NXT[i]}
		let i+=1
	done
	CURN=$NXTN
	NXT=()
	NXTN=0
}

function PCUR () {
	local i=0
	echo "Current States:"
	while (( $i < $CURN )) ; do
		echo ${CUR[i]}
		let i+=1
	done
}

function init () {
	for NODE in "${!MAP[@]}" ; do
		#echo $NODE
		if [[ "${MAP[$NODE]}" = "%" ]] ; then
			STATE[$NODE]=0
		elif [[ "${MAP[$NODE]}" = "&" ]] ; then
			for I in ${INS[$NODE]} ; do
				STATE["$NODE $I"]=0
			done
		fi
	done
}

function process () {
	local D I
	let LO_N+=1-$2
	let HI_N+=$2
	case ${MAP[$1]} in
		"b")	for D in ${OUT[$1]} ; do
				NXT[NXTN]="$D $2 $1"
				let NXTN+=1
			done
			;;
		"%")	if (( $2 == 0 )) ; then
				let STATE[$1]=${STATE[$1]}==0?1:0
				for D in ${OUT[$1]} ; do
					NXT[NXTN]="$D ${STATE[$1]} $1"
					let NXTN+=1
				done
			fi
			;;
		"&")	STATE[$1 $3]=$2
			local X=0
			for I in ${INS[$1]} ; do
				if (( STATE[$1 $I] == 0 )) ; then
					X=1
					break
				fi
			done
			for D in ${OUT[$1]} ; do
				NXT[NXTN]="$D $X $1"
				let NXTN+=1
			done
			;;
		*)	;;
	esac

}

function printmap () {
	local x y
	for (( y=0 ; y<$1 ; y++ )) ; do
		echo -n "$y:"
		for (( x=0 ; x<$1 ; x++ )) ; do
			#echo -n " ${MAP[$x $y]:-0}"
			printf " %3i" ${MAP[$x $y]:-0}
		done
		echo
	done
}

function stack () {
	local a x y z=0
	set -- ${1//,/ } ${2//,/ }
	for (( x=$1 ; x<=$4 ; x++ )) ; do
		for (( y=$2 ; y<=$5 ; y++ )) ; do
			a="${MAP[$x $y]:-0}"
			let "z=(a>z)?a:z"
		done
	done
	let a=z+1
	let a+=$6-$3
	for (( x=$1 ; x<=$4 ; x++ )) ; do
		for (( y=$2 ; y<=$5 ; y++ )) ; do
			if (( ${MAP[$x $y]:-0} == z )) ; then
				B=${BLK[$x $y]:-0}
				BASE[$LN]="${BASE[$LN]// $B /}"
				BASE[$LN]="${BASE[$LN]} $B "
				HOLD[$B]="${HOLD[$B]// $LN /}"
				HOLD[$B]="${HOLD[$B]} $LN "
			fi
			MAP["$x $y"]=$a
			BLK["$x $y"]=$LN
		done
	done
#	printmap 3
#	printmap 10

}

function fall () {
	FALLEN=0
	CUR=" $1 "
	GONE="$CUR"
	while [[ -n "$CUR" ]] ; do
		#echo "F: $FALLEN Cur: $CUR Gone: $GONE"
		NXT=""
		for N in $CUR ; do
			for H in ${HOLD[$N]} ; do
				SAFE=0
				for B in ${BASE[$H]} ; do
					if [[ "${GONE/ $B /}" == "$GONE" ]] ; then
						SAFE=1
						break
					fi
				done
				if (( SAFE == 0 )) ; then
					NXT="${NXT/ $H /}"
					NXT="$NXT $H "
				fi
			done
		done
		set -- $NXT
		for N in $NXT ; do
			GONE="$GONE $N "
		done
		let FALLEN+=$#
		CUR="$NXT"
	done
	set -- $GONE
	shift
	(( FALLEN != $# )) && echo "Error! $FALLEN != $# : $GONE"
	FALLEN=$#
}

function delete () {
	TOTAL=0
	for (( i=1 ; i<$LN ; i++ )) ; do
		fall $i
		let TOTAL+=FALLEN
		#echo "Fallen: $FALLEN Total: $TOTAL"
		(( i%50 == 0 )) && echo -n "."
	done
	echo ""
	echo "Total: $TOTAL"
}

declare -A MAP BLK
declare -a BASE HOLD

LN=0

( sed 'h;s/.*,\([0-9]*\)~.*$/\1/;G;s/\n/ /' ${1:-input} | sort -n ; echo ) |
while read Z B ; do
	let LN+=1
	if [ -z "$Z" ] ; then
		echo "Done reading input, processing..."

		delete

		exit
	fi

	# Stack bricks
	stack ${B/\~/ }

done

