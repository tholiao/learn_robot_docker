#!/bin/bash

example_exp="5 5 5 50 100 1 --contextual"
exp="example_exp"

tmux new "cd vrep_files/V-REP_PRO_EDU_V3_5_0_Linux && ./vrep.sh -h; bash -i" ';' \
     split "bash -i" ';' \
     select-layout even-horizontal
