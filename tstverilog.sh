#!/bin/bash

filename=$1

iverilog -o build/${filename}.v.out ${filename}.v ${filename}_tb.v \
&& vvp build/${filename}.v.out