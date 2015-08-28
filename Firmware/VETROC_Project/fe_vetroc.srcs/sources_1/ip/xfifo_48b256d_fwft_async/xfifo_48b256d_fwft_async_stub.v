// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
// Date        : Fri Jun 19 17:19:36 2015
// Host        : braydopc2 running 64-bit Red Hat Enterprise Linux Workstation release 6.6 (Santiago)
// Command     : write_verilog -force -mode synth_stub
//               /home/braydo/Projects/fe_vetroc/Firmware/VETROC_Project/fe_vetroc.srcs/sources_1/ip/xfifo_48b256d_fwft_async/xfifo_48b256d_fwft_async_stub.v
// Design      : xfifo_48b256d_fwft_async
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tffg1156-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v12_0,Vivado 2014.4" *)
module xfifo_48b256d_fwft_async(rst, wr_clk, rd_clk, din, wr_en, rd_en, prog_full_thresh, dout, full, empty, prog_full)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[47:0],wr_en,rd_en,prog_full_thresh[7:0],dout[47:0],full,empty,prog_full" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [47:0]din;
  input wr_en;
  input rd_en;
  input [7:0]prog_full_thresh;
  output [47:0]dout;
  output full;
  output empty;
  output prog_full;
endmodule
