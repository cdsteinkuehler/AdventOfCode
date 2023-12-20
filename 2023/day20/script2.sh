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

	if [[ $1 = $RX_1 ]] ; then
		if (( $2 > 0 )) ; then
			local X
			eval X="0x$RXST"
			let FOUND+=X
			printf "%i.%i: %04x:%04x\n" $PUSHES $STEPS $X $FOUND
			PERIOD[$3]=$PUSHES
		fi
	fi
}

function push () {
	CUR[0]="broadcaster 0"
	CURN=1
	LO_N=0
	HI_N=0
	STEPS=0

	while (( $CURN > 0 )) ; do
		#PCUR
		local i=0
		let STEPS+=1

		while (( $i < $CURN )) ; do
			process ${CUR[i]}
			let i+=1
		done

		NXT2CUR
	done
#	echo "Pulses: $LO_N:$HI_N"
}

function find_rx () {
	echo "rx <- ${INS[rx]}"
	RX_1="${INS[rx]}"
	RX_1="${RX_1// /}"
	RXST=""
	for I in ${INS[rx]} ; do
		echo "$I <- ${INS[$I]}"
		for J in ${INS[$I]} ; do
			RXST="$RXST\${STATE[$I $J]}"
		done
	done

	local i=0
	eval FIN="$RXST"
	FIN="0x${FIN//?/1}"
	echo "Goal = $FIN"
	PUSHES=0
	FOUND=0
	while (( FOUND < $FIN )) ; do
		let PUSHES+=1
		push
	done

	X=1
	echo "Periods: ${PERIOD[*]}"
	factor ${PERIOD[*]} | sed 's/[0-9]*: //;s/ /\n/' | sort -un |
		while read V ; do
			let X*=V
			echo $V:$X
		done
}


declare -A MAP IN INS OUT STATE PERIOD

LN=0

{ cat ${1:-input} ; echo ; } |
while read NODE A DEST ; do
	let LN+=1
	if [ -z "$NODE" ] ; then

		init
		find_rx

		exit
	fi

	# Build map array
	if [[ $NODE = broadcaster ]] ; then
		MAP[$NODE]=b
	else
		T="${NODE:0:1}"
		NODE="${NODE:1}"
		MAP[$NODE]=$T
	fi
	OUT[$NODE]="${DEST//,/}"
	for D in ${DEST//,/} ; do
		INS[$D]="${INS[$D]} $NODE"
	done

done

