#!/bin/bash

type=$1

rm ${1}/test/mem/Imem.dat ${1}/test/mem/Dmem.dat
cp ../c/hello/Imem.dat ../c/hello/Dmem.dat ${1}/test/mem/ \
&& echo copied hello Imem and Dmem.dat