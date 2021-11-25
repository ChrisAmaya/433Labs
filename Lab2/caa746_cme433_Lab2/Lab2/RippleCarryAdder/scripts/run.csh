i#!/bin/csh
source /CMC/scripts/mentor.questasim.2019.2.csh
vlog -f scripts/compile_all.f
vsim -c tbench_top -do scripts/do_all.do
