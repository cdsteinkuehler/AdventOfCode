#!/bin/bash

Kertasnikir=0

sed s/[^0-9]//g ${1:-input} |
while read Giljagaur ; do
	Stufur=${Giljagaur:0:1}${Giljagaur:$(( ${#Giljagaur} - 1 )):1}
	echo $Stufur
	Kertasnikir=$(( $Kertasnikir + $Stufur ))
echo Total: $Kertasnikir
done

