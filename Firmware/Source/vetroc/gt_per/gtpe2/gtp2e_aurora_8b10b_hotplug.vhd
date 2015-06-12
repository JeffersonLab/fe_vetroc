------------------------------------------------------------------------------
-- (c) Copyright 2010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
--
------------------------------------------------------------------------------
-- Hot-plug logic
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_MISC.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity gtp2e_aurora_8b10b_HOTPLUG is
generic
(
  ENABLE_HOTPLUG          : integer :=   1;
  EXAMPLE_SIMULATION       : integer :=  0     
);
port
(

  ---------------------- Sym Dec Interface -------------------------------
  RX_CC               : in    std_logic;
  RX_SP               : in    std_logic;
  RX_SPA              : in    std_logic;

  ----------------------  GT Wrapper Interface ----------------------------
  LINK_RESET_OUT      : out   std_logic := '0';
  HPCNT_RESET         : in    std_logic;

  ----------------------  System Interface ----------------------------
  INIT_CLK            : in    std_logic;
  USER_CLK            : in    std_logic;
  RESET               : in    std_logic

);

end gtp2e_aurora_8b10b_HOTPLUG;

architecture BEHAVIORAL of gtp2e_aurora_8b10b_HOTPLUG is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of BEHAVIORAL : architecture is "yes";
  attribute core_generation_info               : string;
attribute core_generation_info of BEHAVIORAL : architecture is "gtp2e_aurora_8b10b,aurora_8b10b_v10_3,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=2,c_column_used=None,c_gt_clock_1=GTPQ3,c_gt_clock_2=None,c_gt_loc_1=X,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=1,c_gt_loc_16=2,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=2,c_line_rate=25000,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}";

  component  gtp2e_aurora_8b10b_cdc_sync is
    generic (
        C_CDC_TYPE                  : integer range 0 to 2 := 1                 ;
                                    -- 0 is pulse synch
                                    -- 1 is level synch
                                    -- 2 is ack based level sync
        C_RESET_STATE               : integer range 0 to 1 := 0                 ;
                                    -- 0 is reset not needed 
                                    -- 1 is reset needed 
        C_SINGLE_BIT                : integer range 0 to 1 := 1                 ; 
                                    -- 0 is bus input
                                    -- 1 is single bit input
        C_FLOP_INPUT                : integer range 0 to 1 := 0                 ;
        C_VECTOR_WIDTH              : integer range 0 to 32 := 32                             ;
        C_MTBF_STAGES               : integer range 0 to 6 := 2                 
            -- Vector Data witdth
    );

    port (
        prmry_aclk                  : in  std_logic                             ;               --
        prmry_resetn                : in  std_logic                             ;               --
        prmry_in                    : in  std_logic                             ;               --
        prmry_vect_in               : in  std_logic_vector                                      --
                                        (C_VECTOR_WIDTH - 1 downto 0)           ;               --
        prmry_ack                   : out std_logic                             ;
                                                                                                --
        scndry_aclk                 : in  std_logic                             ;               --
        scndry_resetn               : in  std_logic                             ;               --
                                                                                                --
        -- Primary to Secondary Clock Crossing                                                  --
        scndry_out                  : out std_logic                             ;               --
                                                                                                --
        scndry_vect_out             : out std_logic_vector                                      --
                                        (C_VECTOR_WIDTH - 1 downto 0)                           --

    );

   end component;

--***********************************Parameter Declarations***************************

    constant DLY             : time      := 1 ns;

    signal   link_reset_0                   : std_logic;
    signal   link_reset_r                   : std_logic;
    signal   count_for_reset_r              : std_logic_vector(21 downto 0) := "0000000000000000000000";
    signal   rx_cc_extend_r                 : std_logic_vector(7 downto 0) := "00000000";
    signal   rx_cc_extend_r2                : std_logic;
    signal   cc_sync                        : std_logic;

begin

--*********************************Main Body of Code**********************************

--Extend the RX_CC pulse for 8 clock cycles
--This RX_CC extension is required when INIT_CLK is slower than USER_CLK

    process(USER_CLK)
    begin
        if(USER_CLK'event and USER_CLK = '1') then
          if(RESET = '1') then
            rx_cc_extend_r   <=   (others => '0') after DLY;
          else
            rx_cc_extend_r   <=   RX_CC & rx_cc_extend_r(7 downto 1) after DLY;
          end if;
        end if;
    end process;

    process(USER_CLK)
    begin
        if(USER_CLK'event and USER_CLK = '1') then
          rx_cc_extend_r2  <=  OR_REDUCE(rx_cc_extend_r) after DLY;
      end if;
    end process;
   
   -- Clock domain crossing from USER_CLK to INIT_CLK
      rx_cc_cdc_sync : gtp2e_aurora_8b10b_cdc_sync
      generic map
         (
           c_cdc_type      => 1             ,   
           c_flop_input    => 0             ,  
           c_reset_state   => 0             ,  
           c_single_bit    => 1             ,  
           c_vector_width  => 2             ,  
           c_mtbf_stages   => 3
         )
      port map   
         (
           prmry_aclk      => USER_CLK           ,
           prmry_resetn    => '1'                ,
           prmry_in        => rx_cc_extend_r2    ,
           prmry_vect_in   => "00"               ,
           scndry_aclk     => INIT_CLK           ,
           scndry_resetn   => '1'                ,
           prmry_ack       => open               ,
           scndry_out      => cc_sync            ,
           scndry_vect_out => open                     
          );

    -- Incoming control characters are decoded to detmine CC reception
    -- Reset the link if CC is not detected for longer time
    -- Wait for sufficient time to allow the link recovery and CC consumption
    -- link_reset_0 is used to reset the GT & Aurora core

    -- RX_CC is used as the reset for the count_for_reset_r
hotplug_count_synth : if EXAMPLE_SIMULATION = 0 generate
  process(INIT_CLK,HPCNT_RESET)
  begin
    if(HPCNT_RESET = '1') then 
      count_for_reset_r  <=  (others => '0') after DLY;
    elsif(INIT_CLK'event and INIT_CLK = '1') then
      if(cc_sync = '1') then
        count_for_reset_r  <=  (others => '0') after DLY;
      else
        count_for_reset_r  <=  count_for_reset_r + 1 after DLY;
      end if;
    end if;
  end process;
end generate hotplug_count_synth;

hotplug_count_sim : if EXAMPLE_SIMULATION = 1 generate
process(INIT_CLK,HPCNT_RESET)
begin
  if(HPCNT_RESET = '1') then 
    count_for_reset_r  <=  (others => '0') after DLY;
  elsif(INIT_CLK'event and INIT_CLK = '1') then
    if(cc_sync = '1') then
      count_for_reset_r  <=  (others => '0') after DLY;
    else
      if (count_for_reset_r = X"FFFFF") then
        count_for_reset_r  <= (others => '0') after DLY;
      else 
        count_for_reset_r  <=  count_for_reset_r + 1 after DLY;
      end if;
    end if;
  end if;
end process;
end generate hotplug_count_sim;

link_reset_synth : if EXAMPLE_SIMULATION = 0 generate
      link_reset_0 <= '1' when ((count_for_reset_r > X"3FFFEB") AND (count_for_reset_r < X"3FFFFF")) else
                      '0'; -- 4194283 to 4194303
end generate link_reset_synth;

link_reset_sim : if EXAMPLE_SIMULATION = 1 generate
      -- Wait for sufficient time : 2^20 = 1048576 for simulation
      link_reset_0 <= '1' when ((count_for_reset_r > X"FF447") AND (count_for_reset_r < X"FFFFA")) else
                      '0'; -- 1045575 to 1048570
end generate link_reset_sim;

    process(INIT_CLK)
    begin
      if(INIT_CLK'event and INIT_CLK = '1') then
        link_reset_r <= link_reset_0 after DLY;
      end if;
    end process;

hotplug_enable : if ENABLE_HOTPLUG = 1 generate

    process(INIT_CLK)
    begin
      if(INIT_CLK'event and INIT_CLK = '1') then
        LINK_RESET_OUT <= link_reset_r after DLY;
      end if;
    end process;

end generate hotplug_enable;


hotplug_disable : if ENABLE_HOTPLUG = 0 generate

      LINK_RESET_OUT <= '0';

end generate hotplug_disable;

end BEHAVIORAL;
