// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Fri Jun  7 11:26:27 2019
// Host        : daedalus running 64-bit Ubuntu 18.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/dmonk/Firmware/DTC-firmware/top/top.srcs/sources_1/ip/blockram_512x36/blockram_512x36_stub.v
// Design      : blockram_512x36
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module blockram_512x36(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[8:0],dina[35:0],clkb,addrb[8:0],doutb[35:0]" */;
  input clka;
  input [0:0]wea;
  input [8:0]addra;
  input [35:0]dina;
  input clkb;
  input [8:0]addrb;
  output [35:0]doutb;
endmodule
