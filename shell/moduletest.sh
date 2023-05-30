#!/bin/bash

filename=$1

iverilog -o build/${filename}.v.out \
  module/${filename}.v \
  module/test/${filename}_test.sv \
&& vvp build/${filename}.v.out