// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
// Date        : Mon Jul 11 10:41:10 2016
// Host        : braydopc2.jlab.org running 64-bit Red Hat Enterprise Linux Workstation release 7.2 (Maipo)
// Command     : write_verilog -force -mode synth_stub
//               /home/braydo/Projects/fe_vetroc/Firmware/VETROC_Project/fe_vetroc.srcs/sources_1/ip/readout_fifo/readout_fifo_stub.v
// Design      : readout_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tffg1156-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_0_1,Vivado 2015.4" *)
module readout_fifo(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[35:0],wr_en,rd_en,dout[71:0],full,empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [35:0]din;
  input wr_en;
  input rd_en;
  output [71:0]dout;
  output full;
  output empty;
endmodule
