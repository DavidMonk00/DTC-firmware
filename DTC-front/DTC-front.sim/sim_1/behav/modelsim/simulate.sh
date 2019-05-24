#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2018.3 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Mentor Graphics ModelSim Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Fri May 24 12:14:13 BST 2019
# SW Build 2405991 on Thu Dec  6 23:36:41 MST 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
bin_path="/opt/MentorGraphics/modeltech/bin"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $bin_path/vsim -64  -do "do {top_simulate.do}" -l simulate.log
