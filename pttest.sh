#!/bin/bash

name='top'
type='pipeline'

iverilog -o ${type}/test/log/${type}_${name}.v.out \
  ${type}/${name}.v \
  ${type}/test/${name}_test.sv \
&& vvp ${type}/test/log/${type}_${name}.v.out