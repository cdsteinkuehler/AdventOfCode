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

function push () {
	CUR[0]="broadcaster 0"
	CURN=1
	LO_N=0
	HI_N=0

	while (( $CURN > 0 )) ; do
		#PCUR
		local i=0

		while (( $i < $CURN )) ; do
			process ${CUR[i]}
			let i+=1
		done

		NXT2CUR
	done
#	echo "Pulses: $LO_N:$HI_N"
}

declare -A MAP IN INS OUT STATE

LN=0

{ cat ${1:-input} ; echo ; } |
while read NODE A DEST ; do
	let LN+=1
	if [ -z "$NODE" ] ; then

		init
		i=0
		while (( $i < 1000 )) ; do
			push
			let LO_T+=LO_N
			let HI_T+=HI_N
			let i+=1
		done

		let TOTAL=LO_T*HI_T
		echo "Total: $LO_T * $HI_T = $TOTAL"

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

