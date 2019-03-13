// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
// Date        : Tue Jan 23 12:06:16 2018
// Host        : heppc94 running 64-bit CentOS release 6.9 (Final)
// Command     : write_verilog -force -mode synth_stub -rename_top amc13_link_gth -prefix
//               amc13_link_gth_ amc13_link_gth_stub.v
// Design      : amc13_link_gth
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "amc13_link_gth,gtwizard_v3_6_5,{protocol_file=Start_from_scratch}" *)
module amc13_link_gth(SYSCLK_IN, SOFT_RESET_TX_IN, 
  SOFT_RESET_RX_IN, DONT_RESET_ON_DATA_ERROR_IN, GT0_TX_FSM_RESET_DONE_OUT, 
  GT0_RX_FSM_RESET_DONE_OUT, GT0_DATA_VALID_IN, gt0_cpllfbclklost_out, gt0_cplllock_out, 
  gt0_cplllockdetclk_in, gt0_cpllreset_in, gt0_gtrefclk0_in, gt0_gtrefclk1_in, 
  gt0_drpclk_in, gt0_eyescanreset_in, gt0_rxuserrdy_in, gt0_eyescandataerror_out, 
  gt0_eyescantrigger_in, gt0_rxclkcorcnt_out, gt0_dmonitorout_out, gt0_rxusrclk_in, 
  gt0_rxusrclk2_in, gt0_rxdata_out, gt0_rxdisperr_out, gt0_rxnotintable_out, gt0_gthrxn_in, 
  gt0_rxmonitorout_out, gt0_rxmonitorsel_in, gt0_rxoutclkfabric_out, gt0_gtrxreset_in, 
  gt0_rxchariscomma_out, gt0_rxcharisk_out, gt0_gthrxp_in, gt0_rxresetdone_out, 
  gt0_gttxreset_in, gt0_txuserrdy_in, gt0_txusrclk_in, gt0_txusrclk2_in, gt0_txdata_in, 
  gt0_gthtxn_out, gt0_gthtxp_out, gt0_txoutclk_out, gt0_txoutclkfabric_out, 
  gt0_txoutclkpcs_out, gt0_txresetdone_out, gt0_txcharisk_in, GT0_QPLLOUTCLK_IN, 
  GT0_QPLLOUTREFCLK_IN)
/* synthesis syn_black_box black_box_pad_pin="SYSCLK_IN,SOFT_RESET_TX_IN,SOFT_RESET_RX_IN,DONT_RESET_ON_DATA_ERROR_IN,GT0_TX_FSM_RESET_DONE_OUT,GT0_RX_FSM_RESET_DONE_OUT,GT0_DATA_VALID_IN,gt0_cpllfbclklost_out,gt0_cplllock_out,gt0_cplllockdetclk_in,gt0_cpllreset_in,gt0_gtrefclk0_in,gt0_gtrefclk1_in,gt0_drpclk_in,gt0_eyescanreset_in,gt0_rxuserrdy_in,gt0_eyescandataerror_out,gt0_eyescantrigger_in,gt0_rxclkcorcnt_out[1:0],gt0_dmonitorout_out[14:0],gt0_rxusrclk_in,gt0_rxusrclk2_in,gt0_rxdata_out[15:0],gt0_rxdisperr_out[1:0],gt0_rxnotintable_out[1:0],gt0_gthrxn_in,gt0_rxmonitorout_out[6:0],gt0_rxmonitorsel_in[1:0],gt0_rxoutclkfabric_out,gt0_gtrxreset_in,gt0_rxchariscomma_out[1:0],gt0_rxcharisk_out[1:0],gt0_gthrxp_in,gt0_rxresetdone_out,gt0_gttxreset_in,gt0_txuserrdy_in,gt0_txusrclk_in,gt0_txusrclk2_in,gt0_txdata_in[15:0],gt0_gthtxn_out,gt0_gthtxp_out,gt0_txoutclk_out,gt0_txoutclkfabric_out,gt0_txoutclkpcs_out,gt0_txresetdone_out,gt0_txcharisk_in[1:0],GT0_QPLLOUTCLK_IN,GT0_QPLLOUTREFCLK_IN" */;
  input SYSCLK_IN;
  input SOFT_RESET_TX_IN;
  input SOFT_RESET_RX_IN;
  input DONT_RESET_ON_DATA_ERROR_IN;
  output GT0_TX_FSM_RESET_DONE_OUT;
  output GT0_RX_FSM_RESET_DONE_OUT;
  input GT0_DATA_VALID_IN;
  output gt0_cpllfbclklost_out;
  output gt0_cplllock_out;
  input gt0_cplllockdetclk_in;
  input gt0_cpllreset_in;
  input gt0_gtrefclk0_in;
  input gt0_gtrefclk1_in;
  input gt0_drpclk_in;
  input gt0_eyescanreset_in;
  input gt0_rxuserrdy_in;
  output gt0_eyescandataerror_out;
  input gt0_eyescantrigger_in;
  output [1:0]gt0_rxclkcorcnt_out;
  output [14:0]gt0_dmonitorout_out;
  input gt0_rxusrclk_in;
  input gt0_rxusrclk2_in;
  output [15:0]gt0_rxdata_out;
  output [1:0]gt0_rxdisperr_out;
  output [1:0]gt0_rxnotintable_out;
  input gt0_gthrxn_in;
  output [6:0]gt0_rxmonitorout_out;
  input [1:0]gt0_rxmonitorsel_in;
  output gt0_rxoutclkfabric_out;
  input gt0_gtrxreset_in;
  output [1:0]gt0_rxchariscomma_out;
  output [1:0]gt0_rxcharisk_out;
  input gt0_gthrxp_in;
  output gt0_rxresetdone_out;
  input gt0_gttxreset_in;
  input gt0_txuserrdy_in;
  input gt0_txusrclk_in;
  input gt0_txusrclk2_in;
  input [15:0]gt0_txdata_in;
  output gt0_gthtxn_out;
  output gt0_gthtxp_out;
  output gt0_txoutclk_out;
  output gt0_txoutclkfabric_out;
  output gt0_txoutclkpcs_out;
  output gt0_txresetdone_out;
  input [1:0]gt0_txcharisk_in;
  input GT0_QPLLOUTCLK_IN;
  input GT0_QPLLOUTREFCLK_IN;
endmodule
