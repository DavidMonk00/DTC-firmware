######################################################################
#
# File name : top_compile.do
# Created on: Mon Jun 10 12:05:28 BST 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib  \
"../../../../DTC-front.srcs/sources_1/new/utilities.vhd" \
"../../../../DTC-front.srcs/sources_1/new/FunkyMiniBus.vhd" \
"../../../../DTC-front.srcs/sources_1/new/DataTypes.vhd" \
"../../../../DTC-front.srcs/sources_1/new/CoordinateCorrector.vhd" \
"../../../../DTC-front.srcs/sources_1/new/GenPromClocked.vhd" \
"../../../../DTC-front.srcs/sources_1/new/GetCorrectionMatrix.vhd" \
"../../../../DTC-front.srcs/sources_1/new/LinkFormatter.vhd" \
"../../../../DTC-front.srcs/sources_1/new/LinkGenerator.vhd" \
"../../../../DTC-front.srcs/sources_1/new/RouterInputReformatting.vhd" \
"../../../../DTC-front.srcs/sources_1/new/StubFormatter.vhd" \
"../../../../DTC-front.srcs/sources_1/new/top.vhd" \


