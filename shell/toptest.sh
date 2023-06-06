#!/bin/bash

name='top'
type=$1

iverilog -o ${type}/test/log/${type}_${name}.v.out \
  ${type}/${name}.v \
  ${type}/test/${name}_test.sv \
&& vvp ${type}/test/log/${type}_${name}.v.out | tee log