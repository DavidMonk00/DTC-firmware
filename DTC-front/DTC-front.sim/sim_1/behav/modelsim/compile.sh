#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2018.3 (64-bit)
#
# Filename    : compile.sh
# Simulator   : Mentor Graphics ModelSim Simulator
# Description : Script for compiling the simulation design source files
#
# Generated by Vivado on Fri May 24 11:46:31 BST 2019
# SW Build 2405991 on Thu Dec  6 23:36:41 MST 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
#
# usage: compile.sh
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
ExecStep source top_compile.do 2>&1 | tee -a compile.log
