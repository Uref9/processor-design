#!/bin/bash

filename=$1

iverilog -o build/${filename}.v.out \
  module/${filename}.v \
  module/test_${filename}.v \
&& vvp build/${filename}.v.out