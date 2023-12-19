#!/bin/bash

function FollowRules () {
	while : ; do
		echo -n " $RULE $N ->"
		if (( ${RULE_COND[$RULE $N]} )) ; then
			case ${RULE_DEST[$RULE $N]} in
				R)	echo " Rejected"
					break
					;;
				A)	echo " Accepted"
					let TOTAL+=x+m+a+s
					break
					;;
				*)	RULE=${RULE_DEST[$RULE $N]}
					N=0
					;;
			esac
		else
			let N+=1
		fi
	done
}

LN=0

declare -A RULE_COND RULE_DEST

TOTAL=0
RULES=1

cat ${1:-input} |
while read -r LINE ; do
	if [[ -z "$LINE" ]] ; then
		RULES=0
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
	else
		LINE="${LINE#\{}"
		LINE="${LINE%\}}"
		LINE="${LINE//,/ ; }"
		eval $LINE

		RULE=in
		N=0

		echo -n "$x $m $a $s"
		FollowRules

		echo "Total: $TOTAL"
	fi

	let LN+=1
done

