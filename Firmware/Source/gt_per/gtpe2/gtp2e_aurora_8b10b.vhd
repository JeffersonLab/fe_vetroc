------------------------------------------------------------------------------/
-- (c) Copyright 1995-2013 Xilinx, Inc. All rights reserved.
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
------------------------------------------------------------------------------/
 library ieee;
     use ieee.std_logic_1164.all;
     use ieee.std_logic_misc.all;
     use IEEE.numeric_std.all;
     use ieee.std_logic_arith.all;
     use ieee.std_logic_unsigned.all;

entity  gtp2e_aurora_8b10b is
 port (
 
    s_axi_tx_tdata         : in  std_logic_vector(0 to 31);
    s_axi_tx_tvalid        : in  std_logic;
    s_axi_tx_tready        : out std_logic;


 
    m_axi_rx_tdata         : out std_logic_vector(0 to 31);
    m_axi_rx_tvalid        : out std_logic;



 
    -- GT Serial I/O
    rxp                    : in std_logic_vector(0 to 1);
    rxn                    : in std_logic_vector(0 to 1);

    txp                    : out std_logic_vector(0 to 1);
    txn                    : out std_logic_vector(0 to 1);

    -- GT Reference Clock Interface
    gt_refclk1             : in  std_logic;

    -- Error Detection Interface
    hard_err               : out std_logic;
    soft_err               : out std_logic;
    channel_up             : out std_logic;
    lane_up                : out std_logic_vector(0 to 1);



    -- Clock Compensation Control Interface
    warn_cc                : in std_logic;
    do_cc                  : in std_logic;

    -- System Interface
    user_clk               : in  std_logic;
    sync_clk               : in  std_logic;
    reset                  : in  std_logic;

    power_down             : in  std_logic;
    loopback               : in  std_logic_vector(2 downto 0);
    gt_reset               : in  std_logic;
    tx_lock                : out std_logic;
    sys_reset_out          : out std_logic;
    init_clk_in            : in  std_logic;
    tx_resetdone_out       : out std_logic;
    rx_resetdone_out       : out std_logic;
    link_reset_out         : out std_logic;

    --DRP Ports
    drpclk_in                            : in   std_logic;
    drpaddr_in             : in   std_logic_vector(8 downto 0);
    drpdi_in               : in   std_logic_vector(15 downto 0);
    drpdo_out              : out  std_logic_vector(15 downto 0);
    drpen_in               : in   std_logic;
    drprdy_out             : out  std_logic;
    drpwe_in               : in   std_logic;
    drpaddr_in_lane1             : in   std_logic_vector(8 downto 0);
    drpdi_in_lane1               : in   std_logic_vector(15 downto 0);
    drpdo_out_lane1              : out  std_logic_vector(15 downto 0);
    drpen_in_lane1               : in   std_logic;
    drprdy_out_lane1             : out  std_logic;
    drpwe_in_lane1               : in   std_logic;


    ------------------------ TX Configurable Driver Ports ----------------------
    gt0_txpostcursor_in                         : in   std_logic_vector(4 downto 0);
    gt0_txprecursor_in                          : in   std_logic_vector(4 downto 0);
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt0_txchardispmode_in                       : in   std_logic_vector(1 downto 0);
    gt0_txchardispval_in                        : in   std_logic_vector(1 downto 0);
    gt0_txdiffctrl_in                           : in   std_logic_vector(3 downto 0);
    gt0_txmaincursor_in                         : in   std_logic_vector(6 downto 0);
    ----------------- Transmit Ports - TX Polarity Control Ports ---------------
    gt0_txpolarity_in                           : in   std_logic;
    gt0_tx_buf_err_out                          : out  std_logic;
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt0_txprbsforceerr_in                       : in   std_logic;
    gt0_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt0_txpcsreset_in                           : in   std_logic;
    gt0_txpmareset_in                           : in   std_logic;
    gt0_txresetdone_out                         : out std_logic;
    gt0_txbufstatus_out                         : out  std_logic_vector(1 downto 0);

    gt0_rxlpmhfhold_in                          : in   std_logic;
    gt0_rxlpmlfhold_in                          : in   std_logic;
    gt0_rxlpmhfovrden_in                        : in   std_logic;
    gt0_rxlpmreset_in                           : in   std_logic;
    gt0_rxcdrhold_in                            : in   std_logic;
    gt0_eyescanreset_in                         : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                    : out  std_logic;
    gt0_eyescantrigger_in                       : in   std_logic;
    gt0_rxbyteisaligned_out                     : out  std_logic;
    gt0_rxcommadet_out                          : out  std_logic;
        ------------------- Receive Ports - Pattern Checker Ports ------------------
    gt0_rxprbserr_out                           : out  std_logic;
    gt0_rxprbssel_in                            : in   std_logic_vector(2 downto 0);
        ------------------- Receive Ports - Pattern Checker ports ------------------
    gt0_rxprbscntreset_in                       : in   std_logic;
        ------------------- Receive Ports - RX Data Path interface -----------------
    gt0_rxpcsreset_in                           : in   std_logic;
    gt0_rxpmareset_in                           : in   std_logic;
    gt0_rxpmaresetdone_out                      : out    std_logic;
    gt0_dmonitorout_out                         : out  std_logic_vector(14 downto 0);
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    gt0_rxbufreset_in                           : in   std_logic;
    gt0_rx_disp_err_out                         : out  std_logic_vector(1 downto 0);
    gt0_rx_not_in_table_out                     : out  std_logic_vector(1 downto 0);
    gt0_rx_realign_out                          : out  std_logic;
    gt0_rx_buf_err_out                          : out  std_logic;
    gt0_rxresetdone_out                         : out std_logic;
    gt0_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);


    ------------------------ TX Configurable Driver Ports ----------------------
    gt1_txpostcursor_in                         : in   std_logic_vector(4 downto 0);
    gt1_txprecursor_in                          : in   std_logic_vector(4 downto 0);
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt1_txchardispmode_in                       : in   std_logic_vector(1 downto 0);
    gt1_txchardispval_in                        : in   std_logic_vector(1 downto 0);
    gt1_txdiffctrl_in                           : in   std_logic_vector(3 downto 0);
    gt1_txmaincursor_in                         : in   std_logic_vector(6 downto 0);
    ----------------- Transmit Ports - TX Polarity Control Ports ---------------
    gt1_txpolarity_in                           : in   std_logic;
    gt1_tx_buf_err_out                          : out  std_logic;
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt1_txprbsforceerr_in                       : in   std_logic;
    gt1_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt1_txpcsreset_in                           : in   std_logic;
    gt1_txpmareset_in                           : in   std_logic;
    gt1_txresetdone_out                         : out std_logic;
    gt1_txbufstatus_out                         : out  std_logic_vector(1 downto 0);

    gt1_rxlpmhfhold_in                          : in   std_logic;
    gt1_rxlpmlfhold_in                          : in   std_logic;
    gt1_rxlpmhfovrden_in                        : in   std_logic;
    gt1_rxlpmreset_in                           : in   std_logic;
    gt1_rxcdrhold_in                            : in   std_logic;
    gt1_eyescanreset_in                         : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt1_eyescandataerror_out                    : out  std_logic;
    gt1_eyescantrigger_in                       : in   std_logic;
    gt1_rxbyteisaligned_out                     : out  std_logic;
    gt1_rxcommadet_out                          : out  std_logic;
        ------------------- Receive Ports - Pattern Checker Ports ------------------
    gt1_rxprbserr_out                           : out  std_logic;
    gt1_rxprbssel_in                            : in   std_logic_vector(2 downto 0);
        ------------------- Receive Ports - Pattern Checker ports ------------------
    gt1_rxprbscntreset_in                       : in   std_logic;
        ------------------- Receive Ports - RX Data Path interface -----------------
    gt1_rxpcsreset_in                           : in   std_logic;
    gt1_rxpmareset_in                           : in   std_logic;
    gt1_rxpmaresetdone_out                      : out    std_logic;
    gt1_dmonitorout_out                         : out  std_logic_vector(14 downto 0);
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    gt1_rxbufreset_in                           : in   std_logic;
    gt1_rx_disp_err_out                         : out  std_logic_vector(1 downto 0);
    gt1_rx_not_in_table_out                     : out  std_logic_vector(1 downto 0);
    gt1_rx_realign_out                          : out  std_logic;
    gt1_rx_buf_err_out                          : out  std_logic;
    gt1_rxresetdone_out                         : out std_logic;
    gt1_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);

  gt_common_reset_out     : out std_logic;
--____________________________COMMON PORTS_______________________________{
  gt0_pll0refclklost_in   : in  std_logic;
  quad1_common_lock_in    : in  std_logic;
------------------------- Channel - Ref Clock Ports ------------------------
    GT0_PLL0OUTCLK_IN                       : in   std_logic;
    GT0_PLL1OUTCLK_IN                       : in   std_logic;
    GT0_PLL0OUTREFCLK_IN                    : in   std_logic;
    GT0_PLL1OUTREFCLK_IN                    : in   std_logic;
--____________________________COMMON PORTS_______________________________}
    tx_out_clk             : out std_logic;
    pll_not_locked         : in  std_logic

 );

end gtp2e_aurora_8b10b;


architecture STRUCTURE of gtp2e_aurora_8b10b is
  attribute core_generation_info           : string;
  attribute core_generation_info of STRUCTURE : architecture is "gtp2e_aurora_8b10b,aurora_8b10b_v10_3,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=2,c_column_used=None,c_gt_clock_1=GTPQ3,c_gt_clock_2=None,c_gt_loc_1=X,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=1,c_gt_loc_16=2,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=2,c_line_rate=25000,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}";

    component gtp2e_aurora_8b10b_core
        port   (
         -- AXI TX Interface
         S_AXI_TX_TDATA         : in  std_logic_vector(0 to 31);
         S_AXI_TX_TVALID        : in  std_logic;
         S_AXI_TX_TREADY        : out std_logic;

         -- AXI RX Interface
         M_AXI_RX_TDATA         : out std_logic_vector(0 to 31);
         M_AXI_RX_TVALID        : out std_logic;

         -- GTX Serial I/O
         RXP                    : in  std_logic_vector(0 to 1);
         RXN                    : in  std_logic_vector(0 to 1); 
         TXP                    : out std_logic_vector(0 to 1); 
         TXN                    : out std_logic_vector(0 to 1);

         -- GT Reference Clock Interface

         GT_REFCLK1             : in std_logic;

         -- Error Detection Interface
         HARD_ERR               : out std_logic;
         SOFT_ERR               : out std_logic;

         -- Status
         CHANNEL_UP             : out std_logic;
         LANE_UP                : out std_logic_vector(0 to 1);




         -- Clock Compensation Control Interface

         WARN_CC          : in std_logic;
         DO_CC            : in std_logic;

         -- System Interface

         USER_CLK         : in std_logic;
         SYNC_CLK         : in std_logic;
         GT_RESET         : in std_logic;
         RESET            : in std_logic;
         sys_reset_out    : out std_logic;
         POWER_DOWN       : in std_logic;
         LOOPBACK         : in std_logic_vector(2 downto 0);
         TX_OUT_CLK       : out std_logic;
         INIT_CLK_IN         : in  std_logic; 
         PLL_NOT_LOCKED      : in  std_logic;
         TX_RESETDONE_OUT    : out std_logic;
         RX_RESETDONE_OUT    : out std_logic;
         LINK_RESET_OUT      : out std_logic;



    ------------------------ TX Configurable Driver Ports ----------------------
    gt0_txpostcursor_in                         : in   std_logic_vector(4 downto 0);
    gt0_txprecursor_in                          : in   std_logic_vector(4 downto 0);
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt0_txchardispmode_in                       : in   std_logic_vector(1 downto 0);
    gt0_txchardispval_in                        : in   std_logic_vector(1 downto 0);
    gt0_txdiffctrl_in                           : in   std_logic_vector(3 downto 0);
    gt0_txmaincursor_in                         : in   std_logic_vector(6 downto 0);
    ----------------- Transmit Ports - TX Polarity Control Ports ---------------
    gt0_txpolarity_in                           : in   std_logic;
    gt0_tx_buf_err_out                          : out  std_logic;
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt0_txprbsforceerr_in                       : in   std_logic;
    gt0_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt0_txpcsreset_in                           : in   std_logic;
    gt0_txpmareset_in                           : in   std_logic;
    gt0_txresetdone_out                         : out std_logic;
    gt0_txbufstatus_out                         : out  std_logic_vector(1 downto 0);

    gt0_rxlpmhfhold_in                          : in   std_logic;
    gt0_rxlpmlfhold_in                          : in   std_logic;
    gt0_rxlpmhfovrden_in                        : in   std_logic;
    gt0_rxlpmreset_in                           : in   std_logic;
    gt0_rxcdrhold_in                            : in   std_logic;
    gt0_eyescanreset_in                         : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                    : out  std_logic;
    gt0_eyescantrigger_in                       : in   std_logic;
    gt0_rxbyteisaligned_out                     : out  std_logic;
    gt0_rxcommadet_out                          : out  std_logic;
        ------------------- Receive Ports - Pattern Checker Ports ------------------
    gt0_rxprbserr_out                           : out  std_logic;
    gt0_rxprbssel_in                            : in   std_logic_vector(2 downto 0);
        ------------------- Receive Ports - Pattern Checker ports ------------------
    gt0_rxprbscntreset_in                       : in   std_logic;
        ------------------- Receive Ports - RX Data Path interface -----------------
    gt0_rxpcsreset_in                           : in   std_logic;
    gt0_rxpmareset_in                           : in   std_logic;
    gt0_rxpmaresetdone_out                      : out    std_logic;
    gt0_dmonitorout_out                         : out  std_logic_vector(14 downto 0);
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    gt0_rxbufreset_in                           : in   std_logic;
    gt0_rx_disp_err_out                         : out  std_logic_vector(1 downto 0);
    gt0_rx_not_in_table_out                     : out  std_logic_vector(1 downto 0);
    gt0_rx_realign_out                          : out  std_logic;
    gt0_rx_buf_err_out                          : out  std_logic;
    gt0_rxresetdone_out                         : out std_logic;
    gt0_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);


    ------------------------ TX Configurable Driver Ports ----------------------
    gt1_txpostcursor_in                         : in   std_logic_vector(4 downto 0);
    gt1_txprecursor_in                          : in   std_logic_vector(4 downto 0);
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt1_txchardispmode_in                       : in   std_logic_vector(1 downto 0);
    gt1_txchardispval_in                        : in   std_logic_vector(1 downto 0);
    gt1_txdiffctrl_in                           : in   std_logic_vector(3 downto 0);
    gt1_txmaincursor_in                         : in   std_logic_vector(6 downto 0);
    ----------------- Transmit Ports - TX Polarity Control Ports ---------------
    gt1_txpolarity_in                           : in   std_logic;
    gt1_tx_buf_err_out                          : out  std_logic;
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt1_txprbsforceerr_in                       : in   std_logic;
    gt1_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt1_txpcsreset_in                           : in   std_logic;
    gt1_txpmareset_in                           : in   std_logic;
    gt1_txresetdone_out                         : out std_logic;
    gt1_txbufstatus_out                         : out  std_logic_vector(1 downto 0);

    gt1_rxlpmhfhold_in                          : in   std_logic;
    gt1_rxlpmlfhold_in                          : in   std_logic;
    gt1_rxlpmhfovrden_in                        : in   std_logic;
    gt1_rxlpmreset_in                           : in   std_logic;
    gt1_rxcdrhold_in                            : in   std_logic;
    gt1_eyescanreset_in                         : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt1_eyescandataerror_out                    : out  std_logic;
    gt1_eyescantrigger_in                       : in   std_logic;
    gt1_rxbyteisaligned_out                     : out  std_logic;
    gt1_rxcommadet_out                          : out  std_logic;
        ------------------- Receive Ports - Pattern Checker Ports ------------------
    gt1_rxprbserr_out                           : out  std_logic;
    gt1_rxprbssel_in                            : in   std_logic_vector(2 downto 0);
        ------------------- Receive Ports - Pattern Checker ports ------------------
    gt1_rxprbscntreset_in                       : in   std_logic;
        ------------------- Receive Ports - RX Data Path interface -----------------
    gt1_rxpcsreset_in                           : in   std_logic;
    gt1_rxpmareset_in                           : in   std_logic;
    gt1_rxpmaresetdone_out                      : out    std_logic;
    gt1_dmonitorout_out                         : out  std_logic_vector(14 downto 0);
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    gt1_rxbufreset_in                           : in   std_logic;
    gt1_rx_disp_err_out                         : out  std_logic_vector(1 downto 0);
    gt1_rx_not_in_table_out                     : out  std_logic_vector(1 downto 0);
    gt1_rx_realign_out                          : out  std_logic;
    gt1_rx_buf_err_out                          : out  std_logic;
    gt1_rxresetdone_out                         : out std_logic;
    gt1_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);

         drpclk_in                                    : in   std_logic;
         DRPADDR_IN                              : in   std_logic_vector(8 downto 0);
         DRPDI_IN                                : in   std_logic_vector(15 downto 0);
         DRPDO_OUT                               : out  std_logic_vector(15 downto 0);
         DRPEN_IN                                : in   std_logic;
         DRPRDY_OUT                              : out  std_logic;
         DRPWE_IN                                : in   std_logic;
         DRPADDR_IN_LANE1                              : in   std_logic_vector(8 downto 0);
         DRPDI_IN_LANE1                                : in   std_logic_vector(15 downto 0);
         DRPDO_OUT_LANE1                               : out  std_logic_vector(15 downto 0);
         DRPEN_IN_LANE1                                : in   std_logic;
         DRPRDY_OUT_LANE1                              : out  std_logic;
         DRPWE_IN_LANE1                                : in   std_logic;
   	
   	
  gt_common_reset_out     : out std_logic;
--____________________________COMMON PORTS_______________________________{
  gt0_pll0refclklost_in   : in  std_logic;
  quad1_common_lock_in    : in  std_logic;
------------------------- Channel - Ref Clock Ports ------------------------
    GT0_PLL0OUTCLK_IN                       : in   std_logic;
    GT0_PLL1OUTCLK_IN                       : in   std_logic;
    GT0_PLL0OUTREFCLK_IN                    : in   std_logic;
    GT0_PLL1OUTREFCLK_IN                    : in   std_logic;
--____________________________COMMON PORTS_______________________________}
         TX_LOCK          : out std_logic
    );

    end component;

begin

 --*********************************Main Body of Code**********************************

     U0 : gtp2e_aurora_8b10b_core
     port map (
        -- AXI TX Interface
        s_axi_tx_tdata               => s_axi_tx_tdata,
        s_axi_tx_tvalid              => s_axi_tx_tvalid,
        s_axi_tx_tready              => s_axi_tx_tready,

        -- AXI RX Interface
        m_axi_rx_tdata               => m_axi_rx_tdata,
        m_axi_rx_tvalid              => m_axi_rx_tvalid,


        -- GT Serial I/O
        rxp                          => rxp,
        rxn                          => rxn,
        txp                          => txp,
        txn                          => txn,

        -- GT Reference Clock Interface
        gt_refclk1                   => gt_refclk1,
        -- Error Detection Interface

        -- Error Detection Interface
        hard_err                     => hard_err,
        soft_err                     => soft_err,

        -- Status
        channel_up                   => channel_up,
        lane_up                      => lane_up,



        -- Clock Compensation Control Interface
        warn_cc                      => warn_cc,
        do_cc                        => do_cc,

        -- System Interface
        user_clk                     => user_clk,
        sync_clk                     => sync_clk,
        reset                        => reset,
        sys_reset_out                => sys_reset_out,
        power_down                   => power_down,
        loopback                     => loopback,
        gt_reset                     => gt_reset,
        tx_lock                      => tx_lock,
        init_clk_in                  => init_clk_in,
        pll_not_locked               => pll_not_locked,
	tx_resetdone_out             => tx_resetdone_out,
	rx_resetdone_out             => rx_resetdone_out,
        link_reset_out               => link_reset_out,


        ------------------------ TX Configurable Driver Ports ----------------------
         gt0_txpostcursor_in                => gt0_txpostcursor_in,
         gt0_txprecursor_in                 => gt0_txprecursor_in,
        ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
         gt0_txchardispmode_in              => gt0_txchardispmode_in,
         gt0_txchardispval_in               => gt0_txchardispval_in,
         gt0_txdiffctrl_in                  => gt0_txdiffctrl_in,
         gt0_txmaincursor_in                => gt0_txmaincursor_in,
        ----------------- Transmit Ports - TX Polarity Control Ports ---------------
         gt0_txpolarity_in                  => gt0_txpolarity_in,
         gt0_tx_buf_err_out                 => gt0_tx_buf_err_out,
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        gt0_txprbsforceerr_in           => gt0_txprbsforceerr_in,
        gt0_txprbssel_in                => gt0_txprbssel_in,
        ------------------- Transmit Ports - TX Data Path interface -----------------
        gt0_txpcsreset_in               => gt0_txpcsreset_in,
        gt0_txpmareset_in               => gt0_txpmareset_in,
        gt0_txresetdone_out             => gt0_txresetdone_out,
        gt0_txbufstatus_out             => gt0_txbufstatus_out,


        -------------------------- RX Margin Analysis Ports ------------------------
         gt0_eyescanreset_in                => gt0_eyescanreset_in,
         gt0_eyescandataerror_out           => gt0_eyescandataerror_out,
         gt0_eyescantrigger_in              => gt0_eyescantrigger_in,

         gt0_rxlpmhfhold_in                 => gt0_rxlpmhfhold_in,
         gt0_rxlpmlfhold_in                 => gt0_rxlpmlfhold_in,
         gt0_rxlpmreset_in                  => gt0_rxlpmreset_in,
         gt0_rxlpmhfovrden_in               => gt0_rxlpmhfovrden_in,
         gt0_rxcdrhold_in                   => gt0_rxcdrhold_in,
         gt0_rxbyteisaligned_out            => gt0_rxbyteisaligned_out,
         gt0_rxcommadet_out                 => gt0_rxcommadet_out,
         gt0_rx_disp_err_out                => gt0_rx_disp_err_out,
         gt0_rx_not_in_table_out            => gt0_rx_not_in_table_out,
         gt0_rx_realign_out                 => gt0_rx_realign_out,
         gt0_rx_buf_err_out                 => gt0_rx_buf_err_out,
        ------------------- Receive Ports - Pattern Checker Ports ------------------
        gt0_rxprbserr_out               => gt0_rxprbserr_out,
        gt0_rxprbssel_in                => gt0_rxprbssel_in,
        ------------------- Receive Ports - Pattern Checker ports ------------------
        gt0_rxprbscntreset_in           => gt0_rxprbscntreset_in,
        ------------------- Receive Ports - RX Data Path interface -----------------
        gt0_rxpcsreset_in               => gt0_rxpcsreset_in,
        gt0_rxpmareset_in               => gt0_rxpmareset_in,
        gt0_dmonitorout_out             => gt0_dmonitorout_out,
        gt0_rxpmaresetdone_out          => gt0_rxpmaresetdone_out,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        gt0_rxbufreset_in               => gt0_rxbufreset_in,
        gt0_rxresetdone_out             => gt0_rxresetdone_out,
        gt0_rxbufstatus_out             => gt0_rxbufstatus_out,


        ------------------------ TX Configurable Driver Ports ----------------------
         gt1_txpostcursor_in                => gt1_txpostcursor_in,
         gt1_txprecursor_in                 => gt1_txprecursor_in,
        ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
         gt1_txchardispmode_in              => gt1_txchardispmode_in,
         gt1_txchardispval_in               => gt1_txchardispval_in,
         gt1_txdiffctrl_in                  => gt1_txdiffctrl_in,
         gt1_txmaincursor_in                => gt1_txmaincursor_in,
        ----------------- Transmit Ports - TX Polarity Control Ports ---------------
         gt1_txpolarity_in                  => gt1_txpolarity_in,
         gt1_tx_buf_err_out                 => gt1_tx_buf_err_out,
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        gt1_txprbsforceerr_in           => gt1_txprbsforceerr_in,
        gt1_txprbssel_in                => gt1_txprbssel_in,
        ------------------- Transmit Ports - TX Data Path interface -----------------
        gt1_txpcsreset_in               => gt1_txpcsreset_in,
        gt1_txpmareset_in               => gt1_txpmareset_in,
        gt1_txresetdone_out             => gt1_txresetdone_out,
        gt1_txbufstatus_out             => gt1_txbufstatus_out,


        -------------------------- RX Margin Analysis Ports ------------------------
         gt1_eyescanreset_in                => gt1_eyescanreset_in,
         gt1_eyescandataerror_out           => gt1_eyescandataerror_out,
         gt1_eyescantrigger_in              => gt1_eyescantrigger_in,

         gt1_rxlpmhfhold_in                 => gt1_rxlpmhfhold_in,
         gt1_rxlpmlfhold_in                 => gt1_rxlpmlfhold_in,
         gt1_rxlpmreset_in                  => gt1_rxlpmreset_in,
         gt1_rxlpmhfovrden_in               => gt1_rxlpmhfovrden_in,
         gt1_rxcdrhold_in                   => gt1_rxcdrhold_in,
         gt1_rxbyteisaligned_out            => gt1_rxbyteisaligned_out,
         gt1_rxcommadet_out                 => gt1_rxcommadet_out,
         gt1_rx_disp_err_out                => gt1_rx_disp_err_out,
         gt1_rx_not_in_table_out            => gt1_rx_not_in_table_out,
         gt1_rx_realign_out                 => gt1_rx_realign_out,
         gt1_rx_buf_err_out                 => gt1_rx_buf_err_out,
        ------------------- Receive Ports - Pattern Checker Ports ------------------
        gt1_rxprbserr_out               => gt1_rxprbserr_out,
        gt1_rxprbssel_in                => gt1_rxprbssel_in,
        ------------------- Receive Ports - Pattern Checker ports ------------------
        gt1_rxprbscntreset_in           => gt1_rxprbscntreset_in,
        ------------------- Receive Ports - RX Data Path interface -----------------
        gt1_rxpcsreset_in               => gt1_rxpcsreset_in,
        gt1_rxpmareset_in               => gt1_rxpmareset_in,
        gt1_dmonitorout_out             => gt1_dmonitorout_out,
        gt1_rxpmaresetdone_out          => gt1_rxpmaresetdone_out,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        gt1_rxbufreset_in               => gt1_rxbufreset_in,
        gt1_rxresetdone_out             => gt1_rxresetdone_out,
        gt1_rxbufstatus_out             => gt1_rxbufstatus_out,
        drpclk_in                    => drpclk_in,
        drpaddr_in                   => drpaddr_in,
        drpen_in                     => drpen_in,
        drpdi_in                     => drpdi_in,
        drprdy_out                   => drprdy_out, 
        drpdo_out                    => drpdo_out,
        drpwe_in                     => drpwe_in,
        drpaddr_in_lane1                   => drpaddr_in_lane1,
        drpen_in_lane1                     => drpen_in_lane1,
        drpdi_in_lane1                     => drpdi_in_lane1,
        drprdy_out_lane1                   => drprdy_out_lane1, 
        drpdo_out_lane1                    => drpdo_out_lane1,
        drpwe_in_lane1                     => drpwe_in_lane1,
--------------------{
  gt_common_reset_out          =>  gt_common_reset_out,
--____________________________COMMON PORTS_______________________________{
  gt0_pll0refclklost_in       =>  gt0_pll0refclklost_in, 
  quad1_common_lock_in     =>  quad1_common_lock_in,
------------------------- Channel - Ref Clock Ports ------------------------
    GT0_PLL0OUTCLK_IN        =>  GT0_PLL0OUTCLK_IN,
    GT0_PLL1OUTCLK_IN        =>  GT0_PLL1OUTCLK_IN,
    GT0_PLL0OUTREFCLK_IN     =>  GT0_PLL0OUTREFCLK_IN,
    GT0_PLL1OUTREFCLK_IN     =>  GT0_PLL1OUTREFCLK_IN,
--____________________________COMMON PORTS_______________________________}
--------------------}
        tx_out_clk                   => tx_out_clk

     );

 end STRUCTURE;
