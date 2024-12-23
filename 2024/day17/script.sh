#!/bin/bash

printstate () {
	echo "Reg A: $A"
	echo "Reg B: $B"
	echo "Reg C: $C"
	echo "PC: $PC"
	echo -n "MEM:"
	local I=0
	while [ $I -le $END ] ; do
		echo -n " ${MEM[$I]}"
		let I+=1
	done
	echo ""
	echo ""
}

program2mem () {
	PGM="$1"
	local I=0
	while [ -n "$PGM" ] ; do
		MEM[$I]=${PGM%%,*}
		PGM=${PGM#${MEM[$I]}}
		PGM=${PGM#,}
		let I+=1
	done
	let END=$I-1
}

combo () {
	case $1 in
		[0-3]) echo $1 ;;
		4) echo $A ;;
		5) echo $B ;;
		6) echo $C ;;
		*) echo "Unknown operand!"; exit 1 ;;
	esac
}

execute () {
	echo "Let's go!"
	while [ $PC -lt $END ] ; do
		OP=${MEM[$PC]}
		let PC+=1
		ARG=${MEM[$PC]}
		let PC+=1

		case $OP in
			0)	# adv: A / 2 ** combo -> A
				ARG=$(combo $ARG)
				let "A=A/(1 << $ARG)"
				;;
			1)	# bxl: B xor literal -> B
				let "B=B^ARG"
				;;
			2)	# bst: combo mod 8 -> B
				ARG=$(combo $ARG)
				let "B=ARG%8"
				;;
			3)	# jnz: if A != 0, literal -> PC
				if [ "$A" -ne 0 ] ; then
					PC=$ARG
				fi
				;;
			4)	# bxc: B xor C -> B
				let "B=B^C"
				;;
			5)	# out: combo mod 8 -> output
				ARG=$(combo $ARG)
				let "ARG=ARG%8"
				echo -n "$OUT$ARG"
				OUT=","
				;;
			6)	# bdv: A / 2 ** combo -> B
				ARG=$(combo $ARG)
				let "B=A/(1 << $ARG)"
				;;
			7)	# cdv: A / 2 ** combo -> C
				ARG=$(combo $ARG)
				let "C=A/(1 << $ARG)"
				;;
			*)	# Illegal instructions
				echo "Unknown opcode!"; exit 1
				;;
		esac
	done
	echo ""
}

findvals () {
	local AX BX CX PCX VAL N
	let AX=$1*8
	PCX=$2
	VAL=${MEM[$PCX]}

	for N in 0 1 2 3 4 5 6 7 ; do
		let "BX=(AX%8)^5"
		let "CX=(AX/(1 << $BX))%8"
		let "BX=BX^6^CX"
		#echo "$PCX:$N: $BX == $VAL"
		if [ "$BX" -eq "$VAL" ] ; then
			if [ $PCX -eq 0 ] ; then
				# Done, print the answer!
				echo "Initial value: $AX"
				exit 0
			else
				# Find the next value
				let PCX-=1
				findvals $AX $PCX
				# If findvals returns, we need to test other options
				let "AX+=1"
				let PCX+=1
			fi
		else
			let "AX+=1"
		fi
	done
	#echo "No valid value found!"
}

replicate () {
	# Does not return, answer printed by the last recursive stage
	findvals 0 $END
}

LN=0

declare -a MEM

# CPU State
A=X
B=X
C=X
PC=0

# Last valid instruction location
END=0

INIT="$2"
OUT=""

TOTAL=0
STATES=0
MAXSTATES=0

{ cat ${1:-input} ; echo ; } |
while read -r LINE ; do
	echo "$LINE"
	set -- $LINE
	case "$1" in
		Register)
			case "$2" in
				A:) A="$3";;
				B:) B="$3";;
				C:) C="$3";;
				*) ;;
			esac
			;;
		Program:)
			A=${INIT:-$A}
			program2mem "$2"
			printstate
			execute
			replicate
			;;
		*) ;;
	esac
	let LN+=1

done

