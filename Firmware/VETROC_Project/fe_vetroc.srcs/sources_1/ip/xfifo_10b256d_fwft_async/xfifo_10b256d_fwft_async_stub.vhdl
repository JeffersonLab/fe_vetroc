-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
-- Date        : Fri Jun 19 17:14:14 2015
-- Host        : braydopc2 running 64-bit Red Hat Enterprise Linux Workstation release 6.6 (Santiago)
-- Command     : write_vhdl -force -mode synth_stub
--               /home/braydo/Projects/fe_vetroc/Firmware/VETROC_Project/fe_vetroc.srcs/sources_1/ip/xfifo_10b256d_fwft_async/xfifo_10b256d_fwft_async_stub.vhdl
-- Design      : xfifo_10b256d_fwft_async
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tffg1156-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xfifo_10b256d_fwft_async is
  Port ( 
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 9 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    prog_full_thresh : in STD_LOGIC_VECTOR ( 7 downto 0 );
    dout : out STD_LOGIC_VECTOR ( 9 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    prog_full : out STD_LOGIC
  );

end xfifo_10b256d_fwft_async;

architecture stub of xfifo_10b256d_fwft_async is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,wr_clk,rd_clk,din[9:0],wr_en,rd_en,prog_full_thresh[7:0],dout[9:0],full,empty,prog_full";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v12_0,Vivado 2014.4";
begin
end;
