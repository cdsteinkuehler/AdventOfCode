#!/bin/bash

function ParseRules () {
	echo $*
	local R N M x m a s
	R=$1
	N=$2
	x=$3
	m=$4
	a=$5
	s=$6
	while : ; do
		local C V LO HI
		C="${RULE_COND[$R $N]}"
		V="${C:0:1}"
		let M=N+1
		if [[ "$V" = 0 ]] ; then
			# Rule always matches
			case ${RULE_DEST[$R $N]} in
				R)	echo " Rejected"
					;;
				A)	echo " Accepted"
					let x=1+${x/:/-}
					let m=1+${m/:/-}
					let a=1+${a/:/-}
					let s=1+${s/:/-}
					let TOTAL+=x*m*a*s
					echo "Total: $TOTAL"
					;;
				*)	ParseRules ${RULE_DEST[$R $N]} 0 $x $m $a $s
					;;
			esac
			return
		fi
		eval LO=\${$V#*:}
		eval HI=\${$V%:*}
		if [[ "${C:1:1}" = "<" ]] ; then
			C=${C:2}
			if (( $LO < $C )) ; then
				# Rule matches, process
				eval $V=$HI:$C
				ParseRules $R $M $x $m $a $s
				let C-=1
				eval $V=$C:$LO
				case ${RULE_DEST[$R $N]} in
					R)	echo " Rejected"
						;;
					A)	echo " Accepted"
						let x=1+${x/:/-}
						let m=1+${m/:/-}
						let a=1+${a/:/-}
						let s=1+${s/:/-}
						let TOTAL+=x*m*a*s
						echo "Total: $TOTAL"
						;;
					*)	ParseRules ${RULE_DEST[$R $N]} 0 $x $m $a $s
						;;
				esac
				return
			fi
		else
			C=${C:2}
			if (( $HI > $C )) ; then
				# Rule matches, process
				eval $V=$C:$LO
				ParseRules $R $M $x $m $a $s
				let C+=1
				eval $V=$HI:$C
				case ${RULE_DEST[$R $N]} in
					R)	echo " Rejected"
						;;
					A)	echo " Accepted"
						let x=1+${x/:/-}
						let m=1+${m/:/-}
						let a=1+${a/:/-}
						let s=1+${s/:/-}
						let TOTAL+=x*m*a*s
						echo "Total: $TOTAL"
						;;
					*)	ParseRules ${RULE_DEST[$R $N]} 0 $x $m $a $s
						;;
				esac
				return
			fi
		fi
		N=$M
	done
}

LN=0

declare -A RULE_COND RULE_DEST

TOTAL=0
RULES=1

cat ${1:-input} |
while read -r LINE ; do
	if [[ -z "$LINE" ]] ; then
		ParseRules "in" 0 4000:1 4000:1 4000:1 4000:1
		echo "Total: $TOTAL"
		exit
	fi

	if (( RULES==1 )) ; then
		RULE=${LINE%%\{*}
		LINE="${LINE#$RULE\{}"
		LINE="${LINE%\}}"
		i=0
		echo -n "Rule $RULE :"
		while [[ -n "$LINE" ]] ; do
			C="${LINE%%:*}"
			if [[ "$C" = "$LINE" ]] ; then
				C="0==0"
			fi
			LINE="${LINE#$C:}"
			D="${LINE%%,*}"
			LINE="${LINE#$D}"
			LINE="${LINE#,}"
			echo -n " $C -> $D"
			RULE_COND["$RULE $i"]="$C"
			RULE_DEST["$RULE $i"]="$D"
			let i+=1
		done
		echo
	fi

	let LN+=1
done

