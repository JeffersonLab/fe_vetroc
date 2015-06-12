-------------------------------------------------------------------------------
-- (c) Copyright 2008 Xilinx, Inc. All rights reserved.
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
--------------------------------------------------------------------------------
-- Module gtp2e_aurora_8b10b_GT_WRAPPER
--------------------------------------------------------------------------------
library IEEE;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.Vcomponents.ALL;

--***************************** Entity Declaration ****************************

entity gtp2e_aurora_8b10b_multi_gt is
generic
(
    -- Simulation attributes
    WRAPPER_SIM_GTRESET_SPEEDUP    : string   := "FALSE" -- Set to "TRUE" to speed up sim reset
);
port
(
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT0
    --____________________________CHANNEL PORTS________________________________
    GT0_DRP_BUSY_OUT                        : out  std_logic;
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT0_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT0_DRPCLK_IN                           : in   std_logic;
    GT0_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT0_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT0_DRPEN_IN                            : in   std_logic;
    GT0_DRPRDY_OUT                          : out  std_logic;
    GT0_DRPWE_IN                            : in   std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT0_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT0_RXPD_IN                             : in   std_logic_vector(1 downto 0);
    GT0_TXPD_IN                             : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    GT0_eyescanreset_in                     : in   std_logic;
    GT0_RXUSERRDY_IN                        : in   std_logic;
    ------------------- Receive Ports - Pattern Checker Ports ------------------
    GT0_rxprbserr_out                       : out  std_logic;
    GT0_rxprbssel_in                        : in   std_logic_vector(2 downto 0);
    ------------------- Receive Ports - Pattern Checker ports ------------------
    GT0_rxprbscntreset_in                   : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    GT0_eyescandataerror_out                : out  std_logic;
    GT0_eyescantrigger_in                   : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT0_RXCHARISCOMMA_OUT                   : out  std_logic_vector(1 downto 0);
    GT0_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------------- Receive Ports - AFE Ports ------------------------
    GT0_GTPRXN_IN                           : in   std_logic;
    GT0_GTPRXP_IN                           : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT0_RXCHANBONDSEQ_OUT                   : out  std_logic;
    GT0_RXCHBONDEN_IN                       : in   std_logic;
    GT0_RXCHBONDI_IN                        : in   std_logic_vector(3 downto 0);
    GT0_RXCHBONDLEVEL_IN                    : in   std_logic_vector(2 downto 0);
    GT0_RXCHBONDMASTER_IN                   : in   std_logic;
    GT0_RXCHBONDO_OUT                       : out  std_logic_vector(3 downto 0);
    GT0_RXCHBONDSLAVE_IN                    : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT0_RXCHANISALIGNED_OUT                 : out  std_logic;
    GT0_RXCHANREALIGN_OUT                   : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT0_RXCLKCORCNT_OUT                     : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT0_rxbyteisaligned_out                 : out  std_logic;
    GT0_RXBYTEREALIGN_OUT                   : out  std_logic;
    GT0_rxcommadet_out                      : out  std_logic;
    GT0_RXMCOMMAALIGNEN_IN                  : in   std_logic;
    GT0_RXPCOMMAALIGNEN_IN                  : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT0_GTRXRESET_IN                        : in   std_logic;
    GT0_rxpcsreset_in                       : in   std_logic;
    GT0_rxpmareset_in                       : in   std_logic;
    GT0_rxlpmreset_in                       : in   std_logic;
    GT0_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT0_RXOUTCLK_OUT                        : out  std_logic;
    GT0_RXUSRCLK_IN                         : in   std_logic;
    GT0_RXUSRCLK2_IN                        : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT0_RXCDRLOCK_OUT                       : out  std_logic;
    GT0_RXLPMHFHOLD_IN                      : in   std_logic;
    GT0_RXLPMLFHOLD_IN                      : in   std_logic;
    GT0_rxlpmhfovrden_in                    : in   std_logic;
    GT0_rxcdrhold_in                        : in   std_logic;
    GT0_dmonitorout_out                     : out  std_logic_vector(14 downto 0);
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT0_rxbufreset_in                       : in   std_logic;
    GT0_RXBUFSTATUS_OUT                     : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT0_RXRESETDONE_OUT                     : out  std_logic;
    GT0_RXPMARESETDONE_OUT                  : out  std_logic;
    ------------------------ TX Configurable Driver Ports ----------------------
    GT0_txpostcursor_in                     : in   std_logic_vector(4 downto 0);
    GT0_txprecursor_in                      : in   std_logic_vector(4 downto 0);
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    GT0_RXPOLARITY_IN                       : in   std_logic;
    ------------------------------- Transmit Ports -----------------------------
    GT0_TXUSERRDY_IN                        : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT0_txchardispmode_in                   : in   std_logic_vector(1 downto 0);
    GT0_txchardispval_in                    : in   std_logic_vector(1 downto 0);
    GT0_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT0_TXBUFSTATUS_OUT                     : out  std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT0_GTTXRESET_IN                        : in   std_logic;
    GT0_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT0_TXOUTCLK_OUT                        : out  std_logic;
    GT0_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT0_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT0_TXUSRCLK_IN                         : in   std_logic;
    GT0_TXUSRCLK2_IN                        : in   std_logic;
    --------------------- Transmit Ports - PCI Express Ports -------------------
    GT0_txelecidle_in                       : in   std_logic;
    ------------------ Transmit Ports - Pattern Generator Ports ----------------
    GT0_txprbsforceerr_in                   : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT0_GTPTXN_OUT                          : out  std_logic;
    GT0_GTPTXP_OUT                          : out  std_logic;
    GT0_txdiffctrl_in                       : in   std_logic_vector(3 downto 0);
    GT0_txmaincursor_in                     : in   std_logic_vector(6 downto 0);
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT0_txpcsreset_in                       : in   std_logic;
    GT0_txpmareset_in                       : in   std_logic;
    GT0_TXRESETDONE_OUT                     : out  std_logic;
    ------------------ Transmit Ports - pattern Generator Ports ----------------
    GT0_txprbssel_in                        : in   std_logic_vector(2 downto 0);
    ----------------- Transmit Ports - TX Polarity Control Ports ---------------
    GT0_txpolarity_in                       : in   std_logic;

    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT1
    --____________________________CHANNEL PORTS________________________________
    GT1_DRP_BUSY_OUT                        : out  std_logic;
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    GT1_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT1_DRPCLK_IN                           : in   std_logic;
    GT1_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT1_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT1_DRPEN_IN                            : in   std_logic;
    GT1_DRPRDY_OUT                          : out  std_logic;
    GT1_DRPWE_IN                            : in   std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT1_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT1_RXPD_IN                             : in   std_logic_vector(1 downto 0);
    GT1_TXPD_IN                             : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    GT1_eyescanreset_in                     : in   std_logic;
    GT1_RXUSERRDY_IN                        : in   std_logic;
    ------------------- Receive Ports - Pattern Checker Ports ------------------
    GT1_rxprbserr_out                       : out  std_logic;
    GT1_rxprbssel_in                        : in   std_logic_vector(2 downto 0);
    ------------------- Receive Ports - Pattern Checker ports ------------------
    GT1_rxprbscntreset_in                   : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    GT1_eyescandataerror_out                : out  std_logic;
    GT1_eyescantrigger_in                   : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GT1_RXCHARISCOMMA_OUT                   : out  std_logic_vector(1 downto 0);
    GT1_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT1_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT1_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------------- Receive Ports - AFE Ports ------------------------
    GT1_GTPRXN_IN                           : in   std_logic;
    GT1_GTPRXP_IN                           : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT1_RXCHANBONDSEQ_OUT                   : out  std_logic;
    GT1_RXCHBONDEN_IN                       : in   std_logic;
    GT1_RXCHBONDI_IN                        : in   std_logic_vector(3 downto 0);
    GT1_RXCHBONDLEVEL_IN                    : in   std_logic_vector(2 downto 0);
    GT1_RXCHBONDMASTER_IN                   : in   std_logic;
    GT1_RXCHBONDO_OUT                       : out  std_logic_vector(3 downto 0);
    GT1_RXCHBONDSLAVE_IN                    : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    GT1_RXCHANISALIGNED_OUT                 : out  std_logic;
    GT1_RXCHANREALIGN_OUT                   : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT1_RXCLKCORCNT_OUT                     : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT1_rxbyteisaligned_out                 : out  std_logic;
    GT1_RXBYTEREALIGN_OUT                   : out  std_logic;
    GT1_rxcommadet_out                      : out  std_logic;
    GT1_RXMCOMMAALIGNEN_IN                  : in   std_logic;
    GT1_RXPCOMMAALIGNEN_IN                  : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT1_GTRXRESET_IN                        : in   std_logic;
    GT1_rxpcsreset_in                       : in   std_logic;
    GT1_rxpmareset_in                       : in   std_logic;
    GT1_rxlpmreset_in                       : in   std_logic;
    GT1_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT1_RXOUTCLK_OUT                        : out  std_logic;
    GT1_RXUSRCLK_IN                         : in   std_logic;
    GT1_RXUSRCLK2_IN                        : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT1_RXCDRLOCK_OUT                       : out  std_logic;
    GT1_RXLPMHFHOLD_IN                      : in   std_logic;
    GT1_RXLPMLFHOLD_IN                      : in   std_logic;
    GT1_rxlpmhfovrden_in                    : in   std_logic;
    GT1_rxcdrhold_in                        : in   std_logic;
    GT1_dmonitorout_out                     : out  std_logic_vector(14 downto 0);
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GT1_rxbufreset_in                       : in   std_logic;
    GT1_RXBUFSTATUS_OUT                     : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT1_RXRESETDONE_OUT                     : out  std_logic;
    GT1_RXPMARESETDONE_OUT                  : out  std_logic;
    ------------------------ TX Configurable Driver Ports ----------------------
    GT1_txpostcursor_in                     : in   std_logic_vector(4 downto 0);
    GT1_txprecursor_in                      : in   std_logic_vector(4 downto 0);
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    GT1_RXPOLARITY_IN                       : in   std_logic;
    ------------------------------- Transmit Ports -----------------------------
    GT1_TXUSERRDY_IN                        : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GT1_txchardispmode_in                   : in   std_logic_vector(1 downto 0);
    GT1_txchardispval_in                    : in   std_logic_vector(1 downto 0);
    GT1_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    GT1_TXBUFSTATUS_OUT                     : out  std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT1_GTTXRESET_IN                        : in   std_logic;
    GT1_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT1_TXOUTCLK_OUT                        : out  std_logic;
    GT1_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT1_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT1_TXUSRCLK_IN                         : in   std_logic;
    GT1_TXUSRCLK2_IN                        : in   std_logic;
    --------------------- Transmit Ports - PCI Express Ports -------------------
    GT1_txelecidle_in                       : in   std_logic;
    ------------------ Transmit Ports - Pattern Generator Ports ----------------
    GT1_txprbsforceerr_in                   : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT1_GTPTXN_OUT                          : out  std_logic;
    GT1_GTPTXP_OUT                          : out  std_logic;
    GT1_txdiffctrl_in                       : in   std_logic_vector(3 downto 0);
    GT1_txmaincursor_in                     : in   std_logic_vector(6 downto 0);
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT1_txpcsreset_in                       : in   std_logic;
    GT1_txpmareset_in                       : in   std_logic;
    GT1_TXRESETDONE_OUT                     : out  std_logic;
    ------------------ Transmit Ports - pattern Generator Ports ----------------
    GT1_txprbssel_in                        : in   std_logic_vector(2 downto 0);
    ----------------- Transmit Ports - TX Polarity Control Ports ---------------
    GT1_txpolarity_in                       : in   std_logic;



    --____________________________COMMON PORTS________________________________
    GT0_PLL0OUTCLK_IN                       : in   std_logic;
    GT0_PLL1OUTCLK_IN                       : in   std_logic;
    GT0_PLL0OUTREFCLK_IN                    : in   std_logic;
    GT0_PLL1OUTREFCLK_IN                    : in   std_logic;
    GT0_PLL0RESET_IN                        : in   std_logic


);


end gtp2e_aurora_8b10b_multi_gt;
  
architecture MAPPED of gtp2e_aurora_8b10b_multi_gt is
  attribute core_generation_info               : string;
attribute core_generation_info of MAPPED : architecture is "gtp2e_aurora_8b10b,aurora_8b10b_v10_3,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=2,c_column_used=None,c_gt_clock_1=GTPQ3,c_gt_clock_2=None,c_gt_loc_1=X,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=1,c_gt_loc_16=2,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=2,c_line_rate=25000,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}";

--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;

--***************************** Signal Declarations *****************************

    -- ground and tied_to_vcc_i signals
    signal  tied_to_ground_i                :   std_logic;
    signal  tied_to_ground_vec_i            :   std_logic_vector(63 downto 0);
    signal  tied_to_vcc_i                   :   std_logic;

    signal   gt0_pll0clk_i       :   std_logic;
    signal   gt0_pll0refclk_i    :   std_logic;
    signal   gt0_pll1clk_i       :   std_logic;
    signal   gt0_pll1refclk_i    :   std_logic;
    signal   gt0_rst_i           :   std_logic;
    signal   gt1_pll0clk_i       :   std_logic;
    signal   gt1_pll0refclk_i    :   std_logic;
    signal   gt1_pll1clk_i       :   std_logic;
    signal   gt1_pll1refclk_i    :   std_logic;
    signal   gt1_rst_i           :   std_logic;

--*************************** Component Declarations **************************
component gtp2e_aurora_8b10b_gt
generic
(
    -- Simulation attributes
    GT_SIM_GTRESET_SPEEDUP    : string := "FALSE";
    TXSYNC_OVRD_IN            : bit    := '0';
    TXSYNC_MULTILANE_IN       : bit    := '0'   
);
port
(
    RST_IN                                  : in   std_logic; -- Connect to System Reset
    DRP_BUSY_OUT                            : out  std_logic; -- Indicates that the DRP bus is not accessible to the User
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    DRPADDR_IN                              : in   std_logic_vector(8 downto 0);
    DRPCLK_IN                               : in   std_logic;
    DRPDI_IN                                : in   std_logic_vector(15 downto 0);
    DRPDO_OUT                               : out  std_logic_vector(15 downto 0);
    DRPEN_IN                                : in   std_logic;
    DRPRDY_OUT                              : out  std_logic;
    DRPWE_IN                                : in   std_logic;
    ------------------------------- Clocking Ports -----------------------------
    PLL0CLK_IN                              : in   std_logic;
    PLL0REFCLK_IN                           : in   std_logic;
    PLL1CLK_IN                              : in   std_logic;
    PLL1REFCLK_IN                           : in   std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    LOOPBACK_IN                             : in   std_logic_vector(2 downto 0);
    RXPD_IN                                 : in   std_logic_vector(1 downto 0);
    TXPD_IN                                 : in   std_logic_vector(1 downto 0);
    ------------------------------- Receive Ports ------------------------------
    eyescanreset_in                         : in   std_logic;
    RXUSERRDY_IN                            : in   std_logic;
    ------------------- Receive Ports - Pattern Checker Ports ------------------
    rxprbserr_out                           : out  std_logic;
    rxprbssel_in                            : in   std_logic_vector(2 downto 0);
    ------------------- Receive Ports - Pattern Checker ports ------------------
    rxprbscntreset_in                       : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    eyescandataerror_out                    : out  std_logic;
    eyescantrigger_in                       : in   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISCOMMA_OUT                       : out  std_logic_vector(1 downto 0);
    RXCHARISK_OUT                           : out  std_logic_vector(1 downto 0);
    RXDISPERR_OUT                           : out  std_logic_vector(1 downto 0);
    RXNOTINTABLE_OUT                        : out  std_logic_vector(1 downto 0);
    ------------------------- Receive Ports - AFE Ports ------------------------
    GTPRXN_IN                               : in   std_logic;
    GTPRXP_IN                               : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    RXCHANBONDSEQ_OUT                       : out  std_logic;
    RXCHBONDEN_IN                           : in   std_logic;
    RXCHBONDI_IN                            : in   std_logic_vector(3 downto 0);
    RXCHBONDLEVEL_IN                        : in   std_logic_vector(2 downto 0);
    RXCHBONDMASTER_IN                       : in   std_logic;
    RXCHBONDO_OUT                           : out  std_logic_vector(3 downto 0);
    RXCHBONDSLAVE_IN                        : in   std_logic;
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
    RXCHANISALIGNED_OUT                     : out  std_logic;
    RXCHANREALIGN_OUT                       : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT_OUT                         : out  std_logic_vector(1 downto 0);
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    rxbyteisaligned_out                     : out  std_logic;
    RXBYTEREALIGN_OUT                       : out  std_logic;
    rxcommadet_out                          : out  std_logic;
    RXMCOMMAALIGNEN_IN                      : in   std_logic;
    RXPCOMMAALIGNEN_IN                      : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GTRXRESET_IN                            : in   std_logic;
    rxpcsreset_in                           : in   std_logic;
    rxpmareset_in                           : in   std_logic;
    rxlpmreset_in                           : in   std_logic;
    RXDATA_OUT                              : out  std_logic_vector(15 downto 0);
    RXOUTCLK_OUT                            : out  std_logic;
    RXUSRCLK_IN                             : in   std_logic;
    RXUSRCLK2_IN                            : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    RXCDRLOCK_OUT                           : out  std_logic;
    RXLPMHFHOLD_IN                          : in   std_logic;
    RXLPMLFHOLD_IN                          : in   std_logic;
    rxlpmhfovrden_in                        : in   std_logic;
    rxcdrhold_in                            : in   std_logic;
    dmonitorout_out                         : out  std_logic_vector(14 downto 0);
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    rxbufreset_in                           : in   std_logic;
    RXBUFSTATUS_OUT                         : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    RXRESETDONE_OUT                         : out  std_logic;
    RXPMARESETDONE_OUT                      : out  std_logic;
    ------------------------ TX Configurable Driver Ports ----------------------
    txpostcursor_in                         : in   std_logic_vector(4 downto 0);
    txprecursor_in                          : in   std_logic_vector(4 downto 0);
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    RXPOLARITY_IN                           : in   std_logic;
    ------------------------------- Transmit Ports -----------------------------
    TXUSERRDY_IN                            : in   std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    txchardispmode_in                       : in   std_logic_vector(1 downto 0);
    txchardispval_in                        : in   std_logic_vector(1 downto 0);
    TXCHARISK_IN                            : in   std_logic_vector(1 downto 0);
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
    TXBUFSTATUS_OUT                         : out  std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GTTXRESET_IN                            : in   std_logic;
    TXDATA_IN                               : in   std_logic_vector(15 downto 0);
    TXOUTCLK_OUT                            : out  std_logic;
    TXOUTCLKFABRIC_OUT                      : out  std_logic;
    TXOUTCLKPCS_OUT                         : out  std_logic;
    TXUSRCLK_IN                             : in   std_logic;
    TXUSRCLK2_IN                            : in   std_logic;
    --------------------- Transmit Ports - PCI Express Ports -------------------
    txelecidle_in                           : in   std_logic;
    ------------------ Transmit Ports - Pattern Generator Ports ----------------
    txprbsforceerr_in                       : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GTPTXN_OUT                              : out  std_logic;
    GTPTXP_OUT                              : out  std_logic;
    txdiffctrl_in                           : in   std_logic_vector(3 downto 0);
    txmaincursor_in                         : in   std_logic_vector(6 downto 0);
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    txpcsreset_in                           : in   std_logic;
    txpmareset_in                           : in   std_logic;
    TXRESETDONE_OUT                         : out  std_logic;
    ------------------ Transmit Ports - pattern Generator Ports ----------------
    txprbssel_in                            : in   std_logic_vector(2 downto 0);
    ----------------- Transmit Ports - TX Polarity Control Ports ---------------
    txpolarity_in                           : in   std_logic

);
end component;

--********************************* Main Body of Code**************************

begin

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(63 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';

    gt0_pll0clk_i    <= GT0_PLL0OUTCLK_IN;
    gt0_pll0refclk_i <= GT0_PLL0OUTREFCLK_IN;
    gt0_pll1clk_i    <= GT0_PLL1OUTCLK_IN;
    gt0_pll1refclk_i <= GT0_PLL1OUTREFCLK_IN;
    gt0_rst_i        <= GT0_PLL0RESET_IN;
    gt1_pll0clk_i    <= GT0_PLL0OUTCLK_IN;
    gt1_pll0refclk_i <= GT0_PLL0OUTREFCLK_IN;
    gt1_pll1clk_i    <= GT0_PLL1OUTCLK_IN;
    gt1_pll1refclk_i <= GT0_PLL1OUTREFCLK_IN;
    gt1_rst_i        <= GT0_PLL0RESET_IN;

    --------------------------- GT Instances  ------------------------------- 
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT0
    gt0_gtp2e_aurora_8b10b_i : gtp2e_aurora_8b10b_gt
    generic map
    (
        -- Simulation attributes
        GT_SIM_GTRESET_SPEEDUP => WRAPPER_SIM_GTRESET_SPEEDUP,
        TXSYNC_OVRD_IN         => ('0'),
        TXSYNC_MULTILANE_IN    => ('0')
    )
    port map
    (
        RST_IN                         =>       gt0_rst_i,
        DRP_BUSY_OUT                   =>       GT0_DRP_BUSY_OUT,	    
      
        ---------------------------- Channel - DRP Ports  --------------------------
        DRPADDR_IN                      =>      GT0_DRPADDR_IN,
        DRPCLK_IN                       =>      GT0_DRPCLK_IN,
        DRPDI_IN                        =>      GT0_DRPDI_IN,
        DRPDO_OUT                       =>      GT0_DRPDO_OUT,
        DRPEN_IN                        =>      GT0_DRPEN_IN,
        DRPRDY_OUT                      =>      GT0_DRPRDY_OUT,
        DRPWE_IN                        =>      GT0_DRPWE_IN,
        ------------------------------- Clocking Ports -----------------------------
        PLL0CLK_IN                      =>      gt0_pll0clk_i,
        PLL0REFCLK_IN                   =>      gt0_pll0refclk_i,
        PLL1CLK_IN                      =>      gt0_pll1clk_i,
        PLL1REFCLK_IN                   =>      gt0_pll1refclk_i,
        ------------------------ Loopback and Powerdown Ports ----------------------
        LOOPBACK_IN                     =>      GT0_LOOPBACK_IN,
        RXPD_IN                         =>      GT0_RXPD_IN,
        TXPD_IN                         =>      GT0_TXPD_IN,
        ------------------------------- Receive Ports ------------------------------
        eyescanreset_in                 =>      gt0_eyescanreset_in,
        RXUSERRDY_IN                    =>      GT0_RXUSERRDY_IN,
        ------------------- Receive Ports - Pattern Checker Ports ------------------
        rxprbserr_out                   =>      gt0_rxprbserr_out,
        rxprbssel_in                    =>      gt0_rxprbssel_in,
        ------------------- Receive Ports - Pattern Checker ports ------------------
        rxprbscntreset_in               =>      gt0_rxprbscntreset_in,
        -------------------------- RX Margin Analysis Ports ------------------------
        eyescandataerror_out            =>      gt0_eyescandataerror_out,
        eyescantrigger_in               =>      gt0_eyescantrigger_in,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA_OUT               =>      GT0_RXCHARISCOMMA_OUT,
        RXCHARISK_OUT                   =>      GT0_RXCHARISK_OUT,
        RXDISPERR_OUT                   =>      GT0_RXDISPERR_OUT,
        RXNOTINTABLE_OUT                =>      GT0_RXNOTINTABLE_OUT,
        ------------------------- Receive Ports - AFE Ports ------------------------
        GTPRXN_IN                       =>      GT0_GTPRXN_IN,
        GTPRXP_IN                       =>      GT0_GTPRXP_IN,
        ------------------- Receive Ports - Channel Bonding Ports ------------------
        RXCHANBONDSEQ_OUT               =>      GT0_RXCHANBONDSEQ_OUT,
        RXCHBONDEN_IN                   =>      GT0_RXCHBONDEN_IN,
        RXCHBONDI_IN                    =>      GT0_RXCHBONDI_IN,
        RXCHBONDLEVEL_IN                =>      GT0_RXCHBONDLEVEL_IN,
        RXCHBONDMASTER_IN               =>      GT0_RXCHBONDMASTER_IN,
        RXCHBONDO_OUT                   =>      GT0_RXCHBONDO_OUT,
        RXCHBONDSLAVE_IN                =>      GT0_RXCHBONDSLAVE_IN,
        ------------------- Receive Ports - Channel Bonding Ports  -----------------
        RXCHANISALIGNED_OUT             =>      GT0_RXCHANISALIGNED_OUT,
        RXCHANREALIGN_OUT               =>      GT0_RXCHANREALIGN_OUT,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        RXCLKCORCNT_OUT                 =>      GT0_RXCLKCORCNT_OUT,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        rxbyteisaligned_out             =>      gt0_rxbyteisaligned_out,
        RXBYTEREALIGN_OUT               =>      GT0_RXBYTEREALIGN_OUT,
        rxcommadet_out                  =>      gt0_rxcommadet_out,
        RXMCOMMAALIGNEN_IN              =>      GT0_RXMCOMMAALIGNEN_IN,
        RXPCOMMAALIGNEN_IN              =>      GT0_RXPCOMMAALIGNEN_IN,
        ------------------- Receive Ports - RX Data Path interface -----------------
        GTRXRESET_IN                    =>      GT0_GTRXRESET_IN,
        rxpcsreset_in                   =>      gt0_rxpcsreset_in,
        rxpmareset_in                   =>      gt0_rxpmareset_in,
        rxlpmreset_in                   =>      gt0_rxlpmreset_in,
        RXDATA_OUT                      =>      GT0_RXDATA_OUT,
        RXOUTCLK_OUT                    =>      GT0_RXOUTCLK_OUT,
        RXUSRCLK_IN                     =>      GT0_RXUSRCLK_IN,
        RXUSRCLK2_IN                    =>      GT0_RXUSRCLK2_IN,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXCDRLOCK_OUT                   =>      GT0_RXCDRLOCK_OUT,
        RXLPMHFHOLD_IN                  =>      GT0_RXLPMHFHOLD_IN,
        RXLPMLFHOLD_IN                  =>      GT0_RXLPMLFHOLD_IN,
        rxlpmhfovrden_in                =>      gt0_rxlpmhfovrden_in,
        rxcdrhold_in                    =>      gt0_rxcdrhold_in,
        dmonitorout_out                 =>      gt0_dmonitorout_out,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        rxbufreset_in                   =>      gt0_rxbufreset_in,
        RXBUFSTATUS_OUT                 =>      GT0_RXBUFSTATUS_OUT,
        ------------------------ Receive Ports - RX PLL Ports ----------------------
        RXRESETDONE_OUT                 =>      GT0_RXRESETDONE_OUT,
        RXPMARESETDONE_OUT              =>      GT0_RXPMARESETDONE_OUT,
        ------------------------ TX Configurable Driver Ports ----------------------
        txpostcursor_in                 =>       gt0_txpostcursor_in,
        txprecursor_in                  =>       gt0_txprecursor_in,
        ----------------- Receive Ports - RX Polarity Control Ports ----------------
        RXPOLARITY_IN                   =>      GT0_RXPOLARITY_IN,
        ------------------------------- Transmit Ports -----------------------------
        TXUSERRDY_IN                    =>      GT0_TXUSERRDY_IN,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        txchardispmode_in               =>      gt0_txchardispmode_in,
        txchardispval_in                =>      gt0_txchardispval_in,
        TXCHARISK_IN                    =>      GT0_TXCHARISK_IN,
        ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
        TXBUFSTATUS_OUT                 =>      GT0_TXBUFSTATUS_OUT,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        GTTXRESET_IN                    =>      GT0_GTTXRESET_IN,
        TXDATA_IN                       =>      GT0_TXDATA_IN,
        TXOUTCLK_OUT                    =>      GT0_TXOUTCLK_OUT,
        TXOUTCLKFABRIC_OUT              =>      GT0_TXOUTCLKFABRIC_OUT,
        TXOUTCLKPCS_OUT                 =>      GT0_TXOUTCLKPCS_OUT,
        TXUSRCLK_IN                     =>      GT0_TXUSRCLK_IN,
        TXUSRCLK2_IN                    =>      GT0_TXUSRCLK2_IN,
        --------------------- Transmit Ports - PCI Express Ports -------------------
        txelecidle_in                   =>      gt0_txelecidle_in,
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        txprbsforceerr_in               =>      gt0_txprbsforceerr_in,
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        GTPTXN_OUT                      =>      GT0_GTPTXN_OUT,
        GTPTXP_OUT                      =>      GT0_GTPTXP_OUT,
        txdiffctrl_in                   =>      gt0_txdiffctrl_in,
        txmaincursor_in                 =>      gt0_txmaincursor_in,
        ----------------------- Transmit Ports - TX PLL Ports ----------------------
        txpcsreset_in                   =>      gt0_txpcsreset_in,
        txpmareset_in                   =>      gt0_txpmareset_in,
        TXRESETDONE_OUT                 =>      GT0_TXRESETDONE_OUT,
        ------------------ Transmit Ports - pattern Generator Ports ----------------
        txprbssel_in                    =>      gt0_txprbssel_in,
        ----------------- Transmit Ports - TX Polarity Control Ports ---------------
        txpolarity_in                   =>      gt0_txpolarity_in


    );

    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT1
    gt1_gtp2e_aurora_8b10b_i : gtp2e_aurora_8b10b_gt
    generic map
    (
        -- Simulation attributes
        GT_SIM_GTRESET_SPEEDUP => WRAPPER_SIM_GTRESET_SPEEDUP,
        TXSYNC_OVRD_IN         => ('0'),
        TXSYNC_MULTILANE_IN    => ('0')
    )
    port map
    (
        RST_IN                         =>       gt1_rst_i,
        DRP_BUSY_OUT                   =>       GT1_DRP_BUSY_OUT,	    
      
        ---------------------------- Channel - DRP Ports  --------------------------
        DRPADDR_IN                      =>      GT1_DRPADDR_IN,
        DRPCLK_IN                       =>      GT1_DRPCLK_IN,
        DRPDI_IN                        =>      GT1_DRPDI_IN,
        DRPDO_OUT                       =>      GT1_DRPDO_OUT,
        DRPEN_IN                        =>      GT1_DRPEN_IN,
        DRPRDY_OUT                      =>      GT1_DRPRDY_OUT,
        DRPWE_IN                        =>      GT1_DRPWE_IN,
        ------------------------------- Clocking Ports -----------------------------
        PLL0CLK_IN                      =>      gt1_pll0clk_i,
        PLL0REFCLK_IN                   =>      gt1_pll0refclk_i,
        PLL1CLK_IN                      =>      gt1_pll1clk_i,
        PLL1REFCLK_IN                   =>      gt1_pll1refclk_i,
        ------------------------ Loopback and Powerdown Ports ----------------------
        LOOPBACK_IN                     =>      GT1_LOOPBACK_IN,
        RXPD_IN                         =>      GT1_RXPD_IN,
        TXPD_IN                         =>      GT1_TXPD_IN,
        ------------------------------- Receive Ports ------------------------------
        eyescanreset_in                 =>      gt1_eyescanreset_in,
        RXUSERRDY_IN                    =>      GT1_RXUSERRDY_IN,
        ------------------- Receive Ports - Pattern Checker Ports ------------------
        rxprbserr_out                   =>      gt1_rxprbserr_out,
        rxprbssel_in                    =>      gt1_rxprbssel_in,
        ------------------- Receive Ports - Pattern Checker ports ------------------
        rxprbscntreset_in               =>      gt1_rxprbscntreset_in,
        -------------------------- RX Margin Analysis Ports ------------------------
        eyescandataerror_out            =>      gt1_eyescandataerror_out,
        eyescantrigger_in               =>      gt1_eyescantrigger_in,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA_OUT               =>      GT1_RXCHARISCOMMA_OUT,
        RXCHARISK_OUT                   =>      GT1_RXCHARISK_OUT,
        RXDISPERR_OUT                   =>      GT1_RXDISPERR_OUT,
        RXNOTINTABLE_OUT                =>      GT1_RXNOTINTABLE_OUT,
        ------------------------- Receive Ports - AFE Ports ------------------------
        GTPRXN_IN                       =>      GT1_GTPRXN_IN,
        GTPRXP_IN                       =>      GT1_GTPRXP_IN,
        ------------------- Receive Ports - Channel Bonding Ports ------------------
        RXCHANBONDSEQ_OUT               =>      GT1_RXCHANBONDSEQ_OUT,
        RXCHBONDEN_IN                   =>      GT1_RXCHBONDEN_IN,
        RXCHBONDI_IN                    =>      GT1_RXCHBONDI_IN,
        RXCHBONDLEVEL_IN                =>      GT1_RXCHBONDLEVEL_IN,
        RXCHBONDMASTER_IN               =>      GT1_RXCHBONDMASTER_IN,
        RXCHBONDO_OUT                   =>      GT1_RXCHBONDO_OUT,
        RXCHBONDSLAVE_IN                =>      GT1_RXCHBONDSLAVE_IN,
        ------------------- Receive Ports - Channel Bonding Ports  -----------------
        RXCHANISALIGNED_OUT             =>      GT1_RXCHANISALIGNED_OUT,
        RXCHANREALIGN_OUT               =>      GT1_RXCHANREALIGN_OUT,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        RXCLKCORCNT_OUT                 =>      GT1_RXCLKCORCNT_OUT,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        rxbyteisaligned_out             =>      gt1_rxbyteisaligned_out,
        RXBYTEREALIGN_OUT               =>      GT1_RXBYTEREALIGN_OUT,
        rxcommadet_out                  =>      gt1_rxcommadet_out,
        RXMCOMMAALIGNEN_IN              =>      GT1_RXMCOMMAALIGNEN_IN,
        RXPCOMMAALIGNEN_IN              =>      GT1_RXPCOMMAALIGNEN_IN,
        ------------------- Receive Ports - RX Data Path interface -----------------
        GTRXRESET_IN                    =>      GT1_GTRXRESET_IN,
        rxpcsreset_in                   =>      gt1_rxpcsreset_in,
        rxpmareset_in                   =>      gt1_rxpmareset_in,
        rxlpmreset_in                   =>      gt1_rxlpmreset_in,
        RXDATA_OUT                      =>      GT1_RXDATA_OUT,
        RXOUTCLK_OUT                    =>      GT1_RXOUTCLK_OUT,
        RXUSRCLK_IN                     =>      GT1_RXUSRCLK_IN,
        RXUSRCLK2_IN                    =>      GT1_RXUSRCLK2_IN,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXCDRLOCK_OUT                   =>      GT1_RXCDRLOCK_OUT,
        RXLPMHFHOLD_IN                  =>      GT1_RXLPMHFHOLD_IN,
        RXLPMLFHOLD_IN                  =>      GT1_RXLPMLFHOLD_IN,
        rxlpmhfovrden_in                =>      gt1_rxlpmhfovrden_in,
        rxcdrhold_in                    =>      gt1_rxcdrhold_in,
        dmonitorout_out                 =>      gt1_dmonitorout_out,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        rxbufreset_in                   =>      gt1_rxbufreset_in,
        RXBUFSTATUS_OUT                 =>      GT1_RXBUFSTATUS_OUT,
        ------------------------ Receive Ports - RX PLL Ports ----------------------
        RXRESETDONE_OUT                 =>      GT1_RXRESETDONE_OUT,
        RXPMARESETDONE_OUT              =>      GT1_RXPMARESETDONE_OUT,
        ------------------------ TX Configurable Driver Ports ----------------------
        txpostcursor_in                 =>       gt1_txpostcursor_in,
        txprecursor_in                  =>       gt1_txprecursor_in,
        ----------------- Receive Ports - RX Polarity Control Ports ----------------
        RXPOLARITY_IN                   =>      GT1_RXPOLARITY_IN,
        ------------------------------- Transmit Ports -----------------------------
        TXUSERRDY_IN                    =>      GT1_TXUSERRDY_IN,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        txchardispmode_in               =>      gt1_txchardispmode_in,
        txchardispval_in                =>      gt1_txchardispval_in,
        TXCHARISK_IN                    =>      GT1_TXCHARISK_IN,
        ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
        TXBUFSTATUS_OUT                 =>      GT1_TXBUFSTATUS_OUT,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        GTTXRESET_IN                    =>      GT1_GTTXRESET_IN,
        TXDATA_IN                       =>      GT1_TXDATA_IN,
        TXOUTCLK_OUT                    =>      GT1_TXOUTCLK_OUT,
        TXOUTCLKFABRIC_OUT              =>      GT1_TXOUTCLKFABRIC_OUT,
        TXOUTCLKPCS_OUT                 =>      GT1_TXOUTCLKPCS_OUT,
        TXUSRCLK_IN                     =>      GT1_TXUSRCLK_IN,
        TXUSRCLK2_IN                    =>      GT1_TXUSRCLK2_IN,
        --------------------- Transmit Ports - PCI Express Ports -------------------
        txelecidle_in                   =>      gt1_txelecidle_in,
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        txprbsforceerr_in               =>      gt1_txprbsforceerr_in,
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        GTPTXN_OUT                      =>      GT1_GTPTXN_OUT,
        GTPTXP_OUT                      =>      GT1_GTPTXP_OUT,
        txdiffctrl_in                   =>      gt1_txdiffctrl_in,
        txmaincursor_in                 =>      gt1_txmaincursor_in,
        ----------------------- Transmit Ports - TX PLL Ports ----------------------
        txpcsreset_in                   =>      gt1_txpcsreset_in,
        txpmareset_in                   =>      gt1_txpmareset_in,
        TXRESETDONE_OUT                 =>      GT1_TXRESETDONE_OUT,
        ------------------ Transmit Ports - pattern Generator Ports ----------------
        txprbssel_in                    =>      gt1_txprbssel_in,
        ----------------- Transmit Ports - TX Polarity Control Ports ---------------
        txpolarity_in                   =>      gt1_txpolarity_in


    );


end MAPPED;
