// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
// Date        : Tue Jan 23 12:06:17 2018
// Host        : heppc94 running 64-bit CentOS release 6.9 (Final)
// Command     : write_verilog -force -mode synth_stub -rename_top zs_fifo_8k_x_36b -prefix
//               zs_fifo_8k_x_36b_ zs_fifo_8k_x_36b_stub.v
// Design      : zs_fifo_8k_x_36b
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_3,Vivado 2016.4" *)
module zs_fifo_8k_x_36b(clk, rst, din, wr_en, rd_en, dout, full, empty, valid)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,din[35:0],wr_en,rd_en,dout[35:0],full,empty,valid" */;
  input clk;
  input rst;
  input [35:0]din;
  input wr_en;
  input rd_en;
  output [35:0]dout;
  output full;
  output empty;
  output valid;
endmodule
