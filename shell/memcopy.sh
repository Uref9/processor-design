#!/bin/bash

type=$1
path=$2

rm ${1}/test/mem/Imem.dat ${1}/test/mem/Dmem.dat
cp ../${2}/Imem.dat ../${2}/Dmem.dat ${1}/test/mem/ \
&& echo copied ${2} Imem and Dmem.dat