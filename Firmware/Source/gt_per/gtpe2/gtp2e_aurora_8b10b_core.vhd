
------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
--
--  gtp2e_aurora_8b10b
--
--
--  Description: This is the top level module for a 2 2-byte lane Aurora
--               reference design module. This module supports the following features:
--
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_MISC.all;
-- synthesis translate_off
library UNISIM;
use UNISIM.all;
-- synthesis translate_on


entity gtp2e_aurora_8b10b_core is
generic(
          SIM_GTRESET_SPEEDUP : string  :=   "FALSE";
          EXAMPLE_SIMULATION  : integer :=  0      
       );
port
       (
    -- TX Stream Interface
S_AXI_TX_TDATA             : in  std_logic_vector(0 to 31);
    S_AXI_TX_TVALID            : in  std_logic;
    S_AXI_TX_TREADY            : out std_logic;

    -- RX Stream Interface
M_AXI_RX_TDATA             : out std_logic_vector(0 to 31);
    M_AXI_RX_TVALID            : out std_logic;

    -- Clock Correction Interface
DO_CC               : in  std_logic;
WARN_CC             : in  std_logic;    
   
    -- GT Serial I/O
RXP                 : in std_logic_vector(0 to 1);
RXN                 : in std_logic_vector(0 to 1);
TXP                 : out std_logic_vector(0 to 1);
TXN                 : out std_logic_vector(0 to 1);

    --GT Reference Clock Interface
    GT_REFCLK1       : in std_logic;

    -- Error Detection Interface
    HARD_ERR          : out std_logic;
    SOFT_ERR          : out std_logic;

    -- Status
    CHANNEL_UP          : out std_logic;
LANE_UP             : out std_logic_vector(0 to 1);

    -- System Interface
    user_clk            : in  std_logic;
    sync_clk            : in  std_logic;
    RESET               : in  std_logic;
    POWER_DOWN          : in  std_logic;
    LOOPBACK            : in  std_logic_vector(2 downto 0);
    GT_RESET            : in  std_logic;
    init_clk_in   : in  std_logic;
    PLL_NOT_LOCKED      : in  std_logic;
    TX_RESETDONE_OUT    : out std_logic;
    RX_RESETDONE_OUT    : out std_logic;
    LINK_RESET_OUT      : out std_logic; 
drpclk_in                                            : in   std_logic;
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
  
    TX_OUT_CLK          : out std_logic;
  gt_common_reset_out     : out std_logic;
--____________________________COMMON PORTS_______________________________{
  gt0_pll0refclklost_in  : in  std_logic;
  quad1_common_lock_in        : in  std_logic;
------------------------- Channel - Ref Clock Ports ------------------------
    GT0_PLL0OUTCLK_IN                       : in   std_logic;
    GT0_PLL1OUTCLK_IN                       : in   std_logic;
    GT0_PLL0OUTREFCLK_IN                    : in   std_logic;
    GT0_PLL1OUTREFCLK_IN                    : in   std_logic;
--____________________________COMMON PORTS_______________________________}

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
    gt0_rxresetdone_out                         : out  std_logic;
    gt0_txresetdone_out                         : out  std_logic;
    gt0_txbufstatus_out                         : out  std_logic_vector(1 downto 0);
    gt0_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt0_txprbsforceerr_in                       : in   std_logic;
    gt0_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt0_txpcsreset_in                           : in   std_logic;
    gt0_txpmareset_in                           : in   std_logic;
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
    gt0_rx_disp_err_out                         : out  std_logic_vector(1 downto 0);
    gt0_rx_not_in_table_out                     : out  std_logic_vector(1 downto 0);
    gt0_rx_realign_out                          : out  std_logic;
    gt0_rx_buf_err_out                          : out  std_logic;
    gt0_tx_buf_err_out                          : out  std_logic;

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
    gt1_rxresetdone_out                         : out  std_logic;
    gt1_txresetdone_out                         : out  std_logic;
    gt1_txbufstatus_out                         : out  std_logic_vector(1 downto 0);
    gt1_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt1_txprbsforceerr_in                       : in   std_logic;
    gt1_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt1_txpcsreset_in                           : in   std_logic;
    gt1_txpmareset_in                           : in   std_logic;
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
    gt1_rx_disp_err_out                         : out  std_logic_vector(1 downto 0);
    gt1_rx_not_in_table_out                     : out  std_logic_vector(1 downto 0);
    gt1_rx_realign_out                          : out  std_logic;
    gt1_rx_buf_err_out                          : out  std_logic;
    gt1_tx_buf_err_out                          : out  std_logic;

    sys_reset_out       : out std_logic;
    TX_LOCK             : out std_logic
    );

end gtp2e_aurora_8b10b_core;


architecture MAPPED of gtp2e_aurora_8b10b_core is
  attribute core_generation_info           : string;
attribute core_generation_info of MAPPED : architecture is "gtp2e_aurora_8b10b,aurora_8b10b_v10_3,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=2,c_column_used=None,c_gt_clock_1=GTPQ3,c_gt_clock_2=None,c_gt_loc_1=X,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=1,c_gt_loc_16=2,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=2,c_line_rate=25000,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}";

    -- Parameter Declarations --
    constant DLY : time := 1 ns;

-- ******************************Component Declarations************************************** --

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
        C_VECTOR_WIDTH              : integer range 0 to 32 := 32               ;
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


    component FD
    -- synthesis translate_off
    generic
    (
        INIT : bit := '0'
    );
    -- synthesis translate_on
    port
    (
        Q : out std_ulogic;
        C : in  std_ulogic;
        D : in  std_ulogic
    );
    end component;

    component gtp2e_aurora_8b10b_AURORA_LANE
    generic (
        EXAMPLE_SIMULATION  : integer :=  0      
   
        );
    port (
       -- GT Interface
  
        RX_DATA           : in std_logic_vector(15 downto 0);  -- 2-byte data bus from the GT.
        RX_NOT_IN_TABLE   : in std_logic_vector(1 downto 0);   -- Invalid 10-bit code was recieved.
        RX_DISP_ERR       : in std_logic_vector(1 downto 0);   -- Disparity error detected on RX interface.
        RX_CHAR_IS_K      : in std_logic_vector(1 downto 0);   -- Indicates which bytes of RX_DATA are control.
        RX_CHAR_IS_COMMA  : in std_logic_vector(1 downto 0);   -- Comma received on given byte.
        RX_STATUS         : in std_logic_vector(5 downto 0);   -- Part of GT status and error bus.
        RX_BUF_ERR        : in std_logic;                      -- Overflow/Underflow of RX buffer detected.
        TX_BUF_ERR        : in std_logic;                      -- Overflow/Underflow of TX buffer detected.
        RX_REALIGN        : in std_logic;                      -- SERDES was realigned because of a new comma.
        RX_POLARITY       : out std_logic;                     -- Controls interpreted polarity of serial data inputs.
        RX_RESET          : out std_logic;                     -- Reset RX side of GT logic.
        TX_CHAR_IS_K      : out std_logic_vector(1 downto 0);  -- TX_DATA byte is a control character.
        TX_DATA           : out std_logic_vector(15 downto 0); -- 2-byte data bus to the GT.
        TX_RESET          : out std_logic;                     -- Reset TX side of GT logic.
                LINK_RESET_OUT    : out std_logic;                     -- Link reset for hotplug scenerio.
                HPCNT_RESET       : in  std_logic;                     -- Hotplug count reset input.
                INIT_CLK          : in  std_logic;         
  
        -- Comma Detect Phase Align Interface
     
        ENA_COMMA_ALIGN   : out std_logic;                     -- Request comma alignment.
     
        -- TX_LL Interface
     
        GEN_SCP           : in std_logic;                      -- SCP generation request from TX_LL.
        GEN_ECP           : in std_logic;                      -- ECP generation request from TX_LL.
        GEN_PAD           : in std_logic;                      -- PAD generation request from TX_LL.
        TX_PE_DATA        : in std_logic_vector(0 to 15);      -- Data from TX_LL to send over lane.
        TX_PE_DATA_V      : in std_logic;                      -- Indicates TX_PE_DATA is Valid.
        GEN_CC            : in std_logic;                      -- CC generation request from TX_LL.
     
        -- RX_LL Interface
     
        RX_PAD            : out std_logic;                     -- Indicates lane received PAD.
        RX_PE_DATA        : out std_logic_vector(0 to 15);     -- RX data from lane to RX_LL.
        RX_PE_DATA_V      : out std_logic;                     -- RX_PE_DATA is data, not control symbol.
        RX_SCP            : out std_logic;                     -- Indicates lane received SCP.
        RX_ECP            : out std_logic;                     -- Indicates lane received ECP.
  
       -- Global Logic Interface
  
        GEN_A             : in std_logic;                      -- 'A character' generation request from Global Logic.
        GEN_K             : in std_logic_vector(0 to 1);       -- 'K character' generation request from Global Logic.
        GEN_R             : in std_logic_vector(0 to 1);       -- 'R character' generation request from Global Logic.
        GEN_V             : in std_logic_vector(0 to 1);       -- Verification data generation request.
        LANE_UP           : out std_logic;                     -- Lane is ready for bonding and verification.
        SOFT_ERR        : out std_logic;                     -- Soft error detected.
        HARD_ERR        : out std_logic;                     -- Hard error detected.
        CHANNEL_BOND_LOAD : out std_logic;                     -- Channel Bonding done code received.
        GOT_A             : out std_logic_vector(0 to 1);      -- Indicates lane recieved 'A character' bytes.
        GOT_V             : out std_logic;                     -- Verification symbols received.
        CHANNEL_UP        : in  std_logic;
  
        -- System Interface
     
        USER_CLK          : in std_logic;                      -- System clock for all non-GT Aurora Logic.
        RESET_SYMGEN      : in std_logic;                      -- Reset the SYM_GEN module.
        RESET             : in std_logic                       -- Reset the lane.
     );
   end component;
  
    component gtp2e_aurora_8b10b_GT_WRAPPER
       generic(
                  SIM_GTRESET_SPEEDUP : string :=   "FALSE";     -- Set to "true" to speed up sim reset
                  EXAMPLE_SIMULATION  : integer :=  0      
              );
        port  (
RXFSM_DATA_VALID                        : in    std_logic;
  gt_common_reset_out     : out std_logic;
--____________________________COMMON PORTS_______________________________{
  gt0_pll0refclklost_in  : in  std_logic;
  quad1_common_lock_in        : in  std_logic;
------------------------- Channel - Ref Clock Ports ------------------------
    GT0_PLL0OUTCLK_IN                       : in   std_logic;
    GT0_PLL1OUTCLK_IN                       : in   std_logic;
    GT0_PLL0OUTREFCLK_IN                    : in   std_logic;
    GT0_PLL1OUTREFCLK_IN                    : in   std_logic;
--____________________________COMMON PORTS_______________________________}
    gt0_txresetdone_out         : out    std_logic;
    gt0_rxresetdone_out         : out    std_logic;
    gt0_rxpmaresetdone_out      : out    std_logic;
    gt0_txbufstatus_out                         : out  std_logic_vector(1 downto 0);
    gt0_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);
    gt1_txresetdone_out         : out    std_logic;
    gt1_rxresetdone_out         : out    std_logic;
    gt1_rxpmaresetdone_out      : out    std_logic;
    gt1_txbufstatus_out                         : out  std_logic_vector(1 downto 0);
    gt1_rxbufstatus_out                         : out  std_logic_vector(2 downto 0);


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
    gt0_dmonitorout_out                         : out  std_logic_vector(14 downto 0);
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    gt0_rxbufreset_in                           : in   std_logic;
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt0_txprbsforceerr_in                       : in   std_logic;
    gt0_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt0_txpcsreset_in                           : in   std_logic;
    gt0_txpmareset_in                           : in   std_logic;
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
    gt1_dmonitorout_out                         : out  std_logic_vector(14 downto 0);
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    gt1_rxbufreset_in                           : in   std_logic;
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
    gt1_txprbsforceerr_in                       : in   std_logic;
    gt1_txprbssel_in                            : in   std_logic_vector(2 downto 0); 
        ------------------- Transmit Ports - TX Data Path interface -----------------
    gt1_txpcsreset_in                           : in   std_logic;
    gt1_txpmareset_in                           : in   std_logic;
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
                -- DRP I/F
DRPADDR_IN                              : in   std_logic_vector(8 downto 0);
DRPCLK_IN                               : in   std_logic;
DRPDI_IN                                : in   std_logic_vector(15 downto 0);
DRPDO_OUT                               : out  std_logic_vector(15 downto 0);
DRPEN_IN                                : in   std_logic;
DRPRDY_OUT                              : out  std_logic;
DRPWE_IN                                : in   std_logic;
DRPADDR_IN_LANE1                              : in   std_logic_vector(8 downto 0);
DRPCLK_IN_LANE1                               : in   std_logic;
DRPDI_IN_LANE1                                : in   std_logic_vector(15 downto 0);
DRPDO_OUT_LANE1                               : out  std_logic_vector(15 downto 0);
DRPEN_IN_LANE1                                : in   std_logic;
DRPRDY_OUT_LANE1                              : out  std_logic;
DRPWE_IN_LANE1                                : in   std_logic;

                INIT_CLK_IN        : in    std_logic;
        	PLL_NOT_LOCKED           : in    std_logic;
        	TX_RESETDONE_OUT         : out   std_logic;
        	RX_RESETDONE_OUT         : out   std_logic;

ENCHANSYNC_IN           : in    std_logic;
ENCHANSYNC_IN_LANE1           : in    std_logic;
ENMCOMMAALIGN_IN        : in    std_logic;
ENMCOMMAALIGN_IN_LANE1        : in    std_logic;
ENPCOMMAALIGN_IN        : in    std_logic;
ENPCOMMAALIGN_IN_LANE1        : in    std_logic;
                REFCLK                  : in    std_logic;
                LOOPBACK_IN             : in    std_logic_vector (2 downto 0);
RXPOLARITY_IN           : in    std_logic;
RXPOLARITY_IN_LANE1           : in    std_logic;
RXRESET_IN              : in    std_logic;
RXRESET_IN_LANE1              : in    std_logic;
                RXUSRCLK_IN             : in    std_logic;
                RXUSRCLK2_IN            : in    std_logic;
RX1N_IN                 : in    std_logic;
RX1N_IN_LANE1                 : in    std_logic;
RX1P_IN                 : in    std_logic;
RX1P_IN_LANE1                 : in    std_logic;
TXCHARISK_IN            : in    std_logic_vector (1 downto 0);
TXCHARISK_IN_LANE1            : in    std_logic_vector (1 downto 0);
TXDATA_IN               : in    std_logic_vector (15 downto 0);
TXDATA_IN_LANE1               : in    std_logic_vector (15 downto 0);
                GTRESET_IN                                     : in    std_logic;
TXRESET_IN              : in    std_logic;
TXRESET_IN_LANE1              : in    std_logic;
                TXUSRCLK_IN             : in    std_logic;
                TXUSRCLK2_IN            : in    std_logic;
RXBUFERR_OUT            : out   std_logic;
RXBUFERR_OUT_LANE1            : out   std_logic;
RXCHARISCOMMA_OUT       : out   std_logic_vector (1 downto 0);
RXCHARISCOMMA_OUT_LANE1       : out   std_logic_vector (1 downto 0);
RXCHARISK_OUT           : out   std_logic_vector (1 downto 0);
RXCHARISK_OUT_LANE1           : out   std_logic_vector (1 downto 0);
RXDATA_OUT              : out   std_logic_vector (15 downto 0);
RXDATA_OUT_LANE1              : out   std_logic_vector (15 downto 0);
RXDISPERR_OUT           : out   std_logic_vector (1 downto 0);
RXDISPERR_OUT_LANE1           : out   std_logic_vector (1 downto 0);
RXNOTINTABLE_OUT        : out   std_logic_vector (1 downto 0);
RXNOTINTABLE_OUT_LANE1        : out   std_logic_vector (1 downto 0);
RXREALIGN_OUT           : out   std_logic;
RXREALIGN_OUT_LANE1           : out   std_logic;
CHBONDDONE_OUT          : out   std_logic;
CHBONDDONE_OUT_LANE1          : out   std_logic;
TXBUFERR_OUT            : out   std_logic;
TXBUFERR_OUT_LANE1            : out   std_logic;
               GTRXRESET_IN            :  in std_logic;
                LINK_RESET_IN          : in std_logic;                     -- Link reset for hotplug scenerio.
PLLLKDET_OUT            : out   std_logic;
PLLLKDET_OUT_LANE1            : out   std_logic;
TXOUTCLK1_OUT           : out   std_logic;
TXOUTCLK1_OUT_LANE1           : out   std_logic;
TX1N_OUT                : out   std_logic;
TX1N_OUT_LANE1                : out   std_logic;
TX1P_OUT                : out   std_logic;
TX1P_OUT_LANE1                : out   std_logic;
                POWERDOWN_IN            : in    std_logic

             );

    end component;


    component BUFG
    port
    (
        O : out STD_ULOGIC;
        I : in STD_ULOGIC
    );
    end component;

    component gtp2e_aurora_8b10b_RESET_LOGIC
    port (
           RESET                  : in std_logic;
           USER_CLK               : in std_logic;
           INIT_CLK_IN            : in std_logic;
           TX_LOCK_IN             : in std_logic;
           PLL_NOT_LOCKED         : in std_logic;
           LINK_RESET_IN          : in std_logic;
           TX_RESETDONE_IN        : in std_logic;
           RX_RESETDONE_IN        : in std_logic;
           SYSTEM_RESET           : out std_logic
         );
     end component;


    component gtp2e_aurora_8b10b_GLOBAL_LOGIC
    port
    (
        -- GT Interface
CH_BOND_DONE       : in std_logic_vector(0 to 1);
        EN_CHAN_SYNC       : out std_logic;


        -- Aurora Lane Interface
LANE_UP            : in std_logic_vector(0 to 1);
SOFT_ERR         : in std_logic_vector(0 to 1);
HARD_ERR         : in std_logic_vector(0 to 1);
CHANNEL_BOND_LOAD  : in std_logic_vector(0 to 1);
GOT_A              : in std_logic_vector(0 to 3);
GOT_V              : in std_logic_vector(0 to 1);
GEN_A              : out std_logic_vector(0 to 1);
GEN_K              : out std_logic_vector(0 to 3);
GEN_R              : out std_logic_vector(0 to 3);
GEN_V              : out std_logic_vector(0 to 3);
RESET_LANES        : out std_logic_vector(0 to 1);
            GTRXRESET_OUT         : out std_logic;

        -- System Interface
        USER_CLK           : in std_logic;
        RESET              : in std_logic;
        POWER_DOWN         : in std_logic;
        CHANNEL_UP         : out std_logic;
        START_RX           : out std_logic;
        CHANNEL_SOFT_ERR : out std_logic;
        CHANNEL_HARD_ERR : out std_logic
    );
    end component;


    component gtp2e_aurora_8b10b_TX_STREAM
    port
    (
        -- Data interface
TX_D                : in  std_logic_vector(0 to 31);
TX_SRC_RDY_N        : in  std_logic;
TX_DST_RDY_N        : out std_logic;


        -- Global Logic Interface
CHANNEL_UP      : in  std_logic;


        -- Clock Correction Interface
DO_CC           : in  std_logic;
WARN_CC         : in  std_logic;
   
   
        -- Aurora Lane Interface
GEN_SCP         : out std_logic;
GEN_ECP         : out std_logic;
TX_PE_DATA_V    : out std_logic_vector(0 to 1);
GEN_PAD         : out std_logic_vector(0 to 1);
TX_PE_DATA      : out std_logic_vector(0 to 31);
GEN_CC          : out std_logic;


        -- System Interface
USER_CLK        : in  std_logic


    );
    end component;


    component gtp2e_aurora_8b10b_RX_STREAM
    port
    (
        -- LocalLink PDU Interface
RX_D                : out std_logic_vector(0 to 31);
RX_SRC_RDY_N        : out std_logic;


        -- Global Logic Interface
START_RX        : in  std_logic;


        -- Aurora Lane Interface
RX_PAD          : in  std_logic_vector(0 to 1);
RX_PE_DATA      : in  std_logic_vector(0 to 31);
RX_PE_DATA_V    : in  std_logic_vector(0 to 1);
RX_SCP          : in  std_logic_vector(0 to 1);
RX_ECP          : in  std_logic_vector(0 to 1);
        -- System Interface
USER_CLK        : in  std_logic
    );
    end component;

   -- AXI Shim modules
   component gtp2e_aurora_8b10b_LL_TO_AXI is
   generic
   (
    DATA_WIDTH : integer :=   16;      -- DATA bus width
    STRB_WIDTH : integer :=   2;       -- STROBE bus width
    REM_WIDTH  : integer :=   1        -- REM bus width
   );  

   port
   (

    ----------------------  AXI4-S Interface -------------------------------
    AXI4_S_OP_TDATA                 : out   std_logic_vector (0 to DATA_WIDTH-1);
    AXI4_S_OP_TKEEP                 : out   std_logic_vector (0 to STRB_WIDTH-1);
    AXI4_S_OP_TVALID                : out   std_logic;
    AXI4_S_OP_TLAST                 : out   std_logic;
    AXI4_S_IP_TREADY                : in    std_logic;

    ----------------------  LocalLink Interface ----------------------------
    LL_IP_DATA                      : in    std_logic_vector (0 to DATA_WIDTH-1);
    LL_IP_REM                       : in    std_logic_vector (0 to REM_WIDTH-1);
    LL_IP_SRC_RDY_N                 : in    std_logic;
    LL_IP_SOF_N                     : in    std_logic;
    LL_IP_EOF_N                     : in    std_logic;
    LL_OP_DST_RDY_N                 : out   std_logic

   );
   end component;

   component gtp2e_aurora_8b10b_AXI_TO_LL is
   generic
   (
    DATA_WIDTH  : integer :=   16;      -- DATA bus width
    STRB_WIDTH  : integer :=   2;       -- STROBE bus width
    REM_WIDTH   : integer :=   1;       -- REM bus width
    USE_4_NFC   : integer :=   0;       --  0 => PDU, 1 => NFC, 2 => UFC
    USE_UFC_REM : integer :=   0        -- UFC REM bus width identifier
   );  

   port
   (

     ----------------------  AXI4-S Interface -------------------------------
     AXI4_S_IP_TX_TDATA              : in    std_logic_vector (0 to DATA_WIDTH-1);
     AXI4_S_IP_TX_TKEEP              : in    std_logic_vector (0 to STRB_WIDTH-1);
     AXI4_S_IP_TX_TVALID             : in    std_logic;
     AXI4_S_IP_TX_TLAST              : in    std_logic;
     AXI4_S_OP_TX_TREADY             : out   std_logic;

     ----------------------  LocalLink Interface ----------------------------
     LL_OP_DATA                      : out   std_logic_vector (0 to DATA_WIDTH-1);
     LL_OP_REM                       : out   std_logic_vector (0 to REM_WIDTH -1);
     LL_OP_SRC_RDY_N                 : out   std_logic;
     LL_OP_SOF_N                     : out   std_logic;
     LL_OP_EOF_N                     : out   std_logic;
     LL_IP_DST_RDY_N                 : in    std_logic;

     ----------------------  System Interface ----------------------------
     USER_CLK                        : in    std_logic;
     RESET                           : in    std_logic;
     CHANNEL_UP                      : in    std_logic

   );
   end component;
   

--*********************************Wire Declarations**********************************

signal TX1N_OUT_unused                 : std_logic_vector(0 to 1);
signal TX1P_OUT_unused                 : std_logic_vector(0 to 1);
signal RX1N_IN_unused                  : std_logic_vector(0 to 1);
signal RX1P_IN_unused                  : std_logic_vector(0 to 1);
signal rx_char_is_comma_i_unused       : std_logic_vector(3 downto 0);    
signal rx_char_is_k_i_unused           : std_logic_vector(3 downto 0);    
signal rx_data_i_unused                : std_logic_vector(31 downto 0);    
signal rx_disp_err_i_unused            : std_logic_vector(3 downto 0);    
signal rx_not_in_table_i_unused        : std_logic_vector(3 downto 0);    
signal rx_realign_i_unused             : std_logic_vector(1 downto 0);    
signal ch_bond_done_i_unused           : std_logic_vector(1 downto 0);


signal ch_bond_done_i           :   std_logic_vector(1 downto 0);
signal ch_bond_done_r1          :   std_logic_vector(1 downto 0);
signal ch_bond_done_r2          :   std_logic_vector(1 downto 0);
signal ch_bond_load_not_used_i  :   std_logic_vector(0 to 1);
    signal channel_up_i             :   std_logic;
signal chbondi_not_used_i       :   std_logic_vector(4 downto 0);         
signal chbondo_not_used_i       :   std_logic_vector(9 downto 0);          
signal combus_in_not_used_i     :   std_logic_vector(15 downto 0);            
signal combusout_out_not_used_i :   std_logic_vector(15 downto 0);            
    signal en_chan_sync_i               :   std_logic;
signal ena_comma_align_i            :   std_logic_vector(1 downto 0);
signal gen_a_i                      :   std_logic_vector(0 to 1);
signal gen_cc_i                     :   std_logic;
    signal gen_ecp_i                    :   std_logic;
signal gen_k_i                      :   std_logic_vector(0 to 3);
signal gen_pad_i                    :   std_logic_vector(0 to 1);
signal gen_r_i                      :   std_logic_vector(0 to 3);
    signal gen_scp_i                    :   std_logic;
signal gen_v_i                      :   std_logic_vector(0 to 3);
signal got_a_i                      :   std_logic_vector(0 to 3);
signal got_v_i                      :   std_logic_vector(0 to 1);
signal hard_err_i                 :   std_logic_vector(0 to 1);
signal lane_up_i                    :   std_logic_vector(0 to 1);
signal raw_tx_out_clk_i             :   std_logic_vector(0 to 1);
signal reset_lanes_i                :   std_logic_vector(0 to 1);
signal rx_buf_err_i                 :   std_logic_vector(1 downto 0);
signal rx_char_is_comma_i           :   std_logic_vector(3 downto 0);
signal rx_char_is_k_i               :   std_logic_vector(3 downto 0);
signal rx_clk_cor_cnt_i             :   std_logic_vector(5 downto 0);
signal rx_data_i                    :   std_logic_vector(31 downto 0);
signal rx_disp_err_i                :   std_logic_vector(3 downto 0);
signal rx_ecp_i                     :   std_logic_vector(0 to 1);
signal rx_not_in_table_i            :   std_logic_vector(3 downto 0);
signal rx_pad_i                     :   std_logic_vector(0 to 1);
signal rx_pe_data_i                 :   std_logic_vector(0 to 31);
signal rx_pe_data_v_i               :   std_logic_vector(0 to 1);
signal rx_polarity_i                :   std_logic_vector(1 downto 0);
signal rx_realign_i                 :   std_logic_vector(1 downto 0);
signal rx_reset_i                   :   std_logic_vector(1 downto 0);
signal rx_scp_i                     :   std_logic_vector(0 to 1);
signal rxmclk_out_not_used_i        :   std_logic_vector(0 to 1);            
signal rxpcshclkout_not_used_i      :   std_logic_vector(0 to 1);            
signal soft_err_i                 :   std_logic_vector(0 to 1);
    signal start_rx_i                   :   std_logic;
    signal tied_to_ground_i             :   std_logic;
    signal tied_to_ground_vec_i         :   std_logic_vector(47 downto 0);
    signal tied_to_vcc_i                :   std_logic;
signal tx_buf_err_i                 :   std_logic_vector(1 downto 0);
signal tx_char_is_k_i               :   std_logic_vector(3 downto 0);
signal tx_data_i                    :   std_logic_vector(31 downto 0);
signal tx_lock_i                    :   std_logic_vector(0 to 1);
signal tx_pe_data_i                 :   std_logic_vector(0 to 31);
signal tx_pe_data_v_i               :   std_logic_vector(0 to 1);
signal tx_reset_i                   :   std_logic_vector(1 downto 0);
signal   txoutclk2_out_not_used_i   :   std_logic_vector(0 to 1);            
signal   txpcshclkout_not_used_i    :   std_logic_vector(0 to 1);            
signal ch_bond_load_pulse_i         :   std_logic_vector(0 to 1);
signal ch_bond_done_dly_i           :   std_logic_vector(0 to 1);


    -- TX AXI PDU I/F wires
signal tx_data                      :   std_logic_vector(0 to 31);
    signal tx_src_rdy                   :   std_logic;
    signal tx_dst_rdy                   :   std_logic;

    -- RX AXI PDU I/F wires
signal rx_data                      :   std_logic_vector(0 to 31);
    signal rx_src_rdy                   :   std_logic;
    signal link_reset_lane0_i       : std_logic;
    signal link_reset_lane1_i       : std_logic;
signal link_reset_i             : std_logic;
signal   gtrxreset_i              : std_logic;
signal   system_reset_i           : std_logic;
signal   tx_lock_comb_i           : std_logic;
signal   tx_resetdone_i           : std_logic;
signal   rx_resetdone_i           : std_logic;
signal   rxfsm_data_valid_r       : std_logic;
signal   hpcnt_reset_i            : std_logic;
signal   reset_sync               : std_logic;
begin
--*********************************Main Body of Code**********************************


    --Tie off top level constants
    tied_to_ground_vec_i    <=  (others => '0');
    tied_to_ground_i        <=  '0';
    tied_to_vcc_i           <=  '1';

    --Connect top level logic
    CHANNEL_UP          <=  channel_up_i;
    tx_lock              <=  tx_lock_comb_i;
    tx_resetdone_out     <=  tx_resetdone_i;
    rx_resetdone_out     <=  rx_resetdone_i;
    sys_reset_out        <=  system_reset_i;


    --GT0
    gt0_rx_disp_err_out        <=  rx_disp_err_i(1 downto 0);
    gt0_rx_not_in_table_out    <=  rx_not_in_table_i(1 downto 0);
    gt0_rx_realign_out         <=  rx_realign_i (0);
    gt0_rx_buf_err_out         <=  rx_buf_err_i (0);
    gt0_tx_buf_err_out         <=  tx_buf_err_i (0);

    --GT1
    gt1_rx_disp_err_out        <=  rx_disp_err_i(3 downto 2);
    gt1_rx_not_in_table_out    <=  rx_not_in_table_i(3 downto 2);
    gt1_rx_realign_out         <=  rx_realign_i (1);
    gt1_rx_buf_err_out         <=  rx_buf_err_i (1);
    gt1_tx_buf_err_out         <=  tx_buf_err_i (1);

    link_reset_i    <=   link_reset_lane0_i or link_reset_lane1_i ;

    process(user_clk)
    begin
      if(user_clk'event and user_clk='1') then
        rxfsm_data_valid_r   <= AND_REDUCE(lane_up_i) after DLY;
      end if;
    end process;

    LINK_RESET_OUT  <=  link_reset_i;

    --Connect the TXOUTCLK of lane 0 to TX_OUT_CLK
TX_OUT_CLK  <=   raw_tx_out_clk_i (0);
   
   
    --Connect TX_LOCK to tx_lock_i from lane 0
    tx_lock_comb_i    <=   AND_REDUCE(tx_lock_i);

    -- RESET_LOGIC instance
    core_reset_logic_i  :  gtp2e_aurora_8b10b_RESET_LOGIC 
    port map
    (
        RESET                    =>   reset,
        USER_CLK                 =>   user_clk,
        INIT_CLK_IN              =>   init_clk_in,
        TX_LOCK_IN               =>   tx_lock_comb_i,
        PLL_NOT_LOCKED           =>   pll_not_locked,
        TX_RESETDONE_IN          =>   tx_resetdone_i,
     	  RX_RESETDONE_IN          =>   rx_resetdone_i,
        LINK_RESET_IN            =>   link_reset_i,
        SYSTEM_RESET             =>   system_reset_i
    );

 hpcnt_reset_cdc_sync : gtp2e_aurora_8b10b_cdc_sync
   generic map
     (
       c_cdc_type        => 1,   
       c_flop_input      => 0,  
       c_reset_state     => 0,  
       c_single_bit      => 1,  
       c_vector_width    => 2,  
       c_mtbf_stages     => 3 
     )
  port map
     (
       prmry_aclk        => user_clk     ,
       prmry_resetn      => '1'          ,
       prmry_in          => RESET        ,
       prmry_vect_in     => "00"         ,
       scndry_aclk       => init_clk_in  ,
       scndry_resetn     => '1'          ,
       prmry_ack         => open         ,
       scndry_out        => reset_sync   ,
       scndry_vect_out   => open           
     );

hpcnt_reset_i <= GT_RESET or reset_sync;

    --_________________________Instantiate Lane 0______________________________

LANE_UP (0) <=   lane_up_i (0);

    aurora_lane_0_i : gtp2e_aurora_8b10b_AURORA_LANE
    generic map
    (
       EXAMPLE_SIMULATION   => EXAMPLE_SIMULATION
    )   
    port map
    (
       
        --GT Interface
        RX_DATA             => rx_data_i(15 downto 0),
        RX_NOT_IN_TABLE     => rx_not_in_table_i(1 downto 0),
        RX_DISP_ERR         => rx_disp_err_i(1 downto 0),
        RX_CHAR_IS_K        => rx_char_is_k_i(1 downto 0),
        RX_CHAR_IS_COMMA    => rx_char_is_comma_i(1 downto 0),
        RX_STATUS           => tied_to_ground_vec_i(5 downto 0),
        TX_BUF_ERR          => tx_buf_err_i (0),
        RX_BUF_ERR          => rx_buf_err_i (0),
        RX_REALIGN          => rx_realign_i (0),
        RX_POLARITY         => rx_polarity_i (0),
        RX_RESET            => rx_reset_i (0),
        TX_CHAR_IS_K        => tx_char_is_k_i(1 downto 0),
        TX_DATA             => tx_data_i(15 downto 0),
TX_RESET            => tx_reset_i (0),
        INIT_CLK            => init_clk_in,  
        LINK_RESET_OUT      => link_reset_lane0_i,
        HPCNT_RESET         => hpcnt_reset_i,

       
        --Comma Detect Phase Align Interface
ENA_COMMA_ALIGN     => ena_comma_align_i (0),


        --TX_LL Interface
        GEN_SCP             => gen_scp_i,
        GEN_ECP             => tied_to_ground_i,
GEN_PAD             => gen_pad_i (0),
        TX_PE_DATA          => tx_pe_data_i(0 to 15),
TX_PE_DATA_V        => tx_pe_data_v_i (0),
        GEN_CC              => gen_cc_i,


        --RX_LL Interface
RX_PAD              => rx_pad_i (0),
        RX_PE_DATA          => rx_pe_data_i(0 to 15),
RX_PE_DATA_V        => rx_pe_data_v_i (0),
RX_SCP              => rx_scp_i (0),
RX_ECP              => rx_ecp_i (0),

        --Global Logic Interface
GEN_A               => gen_a_i (0),
        GEN_K               => gen_k_i(0 to 1),
        GEN_R               => gen_r_i(0 to 1),
        GEN_V               => gen_v_i(0 to 1),
LANE_UP             => lane_up_i (0),
SOFT_ERR          => soft_err_i (0),
HARD_ERR          => hard_err_i (0),
CHANNEL_BOND_LOAD   => ch_bond_load_not_used_i (0),
        GOT_A               => got_a_i(0 to 1),
GOT_V               => got_v_i (0),
        CHANNEL_UP          => channel_up_i,

        --System Interface
        USER_CLK            => user_clk,
        RESET_SYMGEN        => system_reset_i,
RESET               => reset_lanes_i (0)
    );
    --_________________________Instantiate Lane 1______________________________

LANE_UP (1) <=   lane_up_i (1);

    aurora_lane_1_i : gtp2e_aurora_8b10b_AURORA_LANE
    generic map
    (
       EXAMPLE_SIMULATION   => EXAMPLE_SIMULATION
    )   
    port map
    (
       
        --GT Interface
        RX_DATA             => rx_data_i(31 downto 16),
        RX_NOT_IN_TABLE     => rx_not_in_table_i(3 downto 2),
        RX_DISP_ERR         => rx_disp_err_i(3 downto 2),
        RX_CHAR_IS_K        => rx_char_is_k_i(3 downto 2),
        RX_CHAR_IS_COMMA    => rx_char_is_comma_i(3 downto 2),
        RX_STATUS           => tied_to_ground_vec_i(5 downto 0),
        TX_BUF_ERR          => tx_buf_err_i (1),
        RX_BUF_ERR          => rx_buf_err_i (1),
        RX_REALIGN          => rx_realign_i (1),
        RX_POLARITY         => rx_polarity_i (1),
        RX_RESET            => rx_reset_i (1),
        TX_CHAR_IS_K        => tx_char_is_k_i(3 downto 2),
        TX_DATA             => tx_data_i(31 downto 16),
TX_RESET            => tx_reset_i (1),
        INIT_CLK            => init_clk_in,  
        LINK_RESET_OUT      => link_reset_lane1_i,
        HPCNT_RESET         => hpcnt_reset_i,

       
        --Comma Detect Phase Align Interface
ENA_COMMA_ALIGN     => ena_comma_align_i (1),


        --TX_LL Interface
        GEN_SCP             => tied_to_ground_i,
       
        GEN_ECP             => gen_ecp_i,
GEN_PAD             => gen_pad_i (1),
        TX_PE_DATA          => tx_pe_data_i(16 to 31),
TX_PE_DATA_V        => tx_pe_data_v_i (1),
        GEN_CC              => gen_cc_i,


        --RX_LL Interface
RX_PAD              => rx_pad_i (1),
        RX_PE_DATA          => rx_pe_data_i(16 to 31),
RX_PE_DATA_V        => rx_pe_data_v_i (1),
RX_SCP              => rx_scp_i (1),
RX_ECP              => rx_ecp_i (1),

        --Global Logic Interface
GEN_A               => gen_a_i (1),
        GEN_K               => gen_k_i(2 to 3),
        GEN_R               => gen_r_i(2 to 3),
        GEN_V               => gen_v_i(2 to 3),
LANE_UP             => lane_up_i (1),
SOFT_ERR          => soft_err_i (1),
HARD_ERR          => hard_err_i (1),
CHANNEL_BOND_LOAD   => ch_bond_load_not_used_i (1),
        GOT_A               => got_a_i(2 to 3),
GOT_V               => got_v_i (1),
        CHANNEL_UP          => channel_up_i,

        --System Interface
        USER_CLK            => user_clk,
        RESET_SYMGEN        => system_reset_i,
RESET               => reset_lanes_i (1)
    );

    --_________________________Instantiate GT Wrapper ______________________________

    gt_wrapper_i : gtp2e_aurora_8b10b_GT_WRAPPER 
    generic map(
                     SIM_GTRESET_SPEEDUP  => SIM_GTRESET_SPEEDUP,
                     EXAMPLE_SIMULATION          => EXAMPLE_SIMULATION
               )
    port map   (  
RXFSM_DATA_VALID                              => rxfsm_data_valid_r,

  gt_common_reset_out     =>  gt_common_reset_out,
--____________________________COMMON PORTS_______________________________{
  gt0_pll0refclklost_in  =>  gt0_pll0refclklost_in, 
  quad1_common_lock_in     =>  quad1_common_lock_in,
------------------------- Channel - Ref Clock Ports ------------------------
    GT0_PLL0OUTCLK_IN        =>  GT0_PLL0OUTCLK_IN,
    GT0_PLL1OUTCLK_IN        =>  GT0_PLL1OUTCLK_IN,
    GT0_PLL0OUTREFCLK_IN     =>  GT0_PLL0OUTREFCLK_IN,
    GT0_PLL1OUTREFCLK_IN     =>  GT0_PLL1OUTREFCLK_IN,
--____________________________COMMON PORTS_______________________________}


         gt0_rxlpmhfhold_in                 => gt0_rxlpmhfhold_in,
         gt0_rxlpmlfhold_in                 => gt0_rxlpmlfhold_in,
         gt0_rxlpmreset_in                  => gt0_rxlpmreset_in,
         gt0_rxlpmhfovrden_in               => gt0_rxlpmhfovrden_in,
         gt0_rxcdrhold_in                   => gt0_rxcdrhold_in,

         gt0_eyescanreset_in                => gt0_eyescanreset_in,
        -------------------------- RX Margin Analysis Ports ------------------------
         gt0_eyescandataerror_out           => gt0_eyescandataerror_out,
         gt0_eyescantrigger_in              => gt0_eyescantrigger_in,
         gt0_rxbyteisaligned_out            => gt0_rxbyteisaligned_out,
         gt0_rxcommadet_out                 => gt0_rxcommadet_out,
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
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        gt0_txprbsforceerr_in           => gt0_txprbsforceerr_in,
        gt0_txprbssel_in                => gt0_txprbssel_in,
        ------------------- Transmit Ports - TX Data Path interface -----------------
        gt0_txpcsreset_in               => gt0_txpcsreset_in,
        gt0_txpmareset_in               => gt0_txpmareset_in,
        gt0_txresetdone_out             => gt0_txresetdone_out,
        gt0_rxresetdone_out             => gt0_rxresetdone_out,
        gt0_txbufstatus_out             => gt0_txbufstatus_out,
        gt0_rxbufstatus_out             => gt0_rxbufstatus_out,

         gt1_rxlpmhfhold_in                 => gt1_rxlpmhfhold_in,
         gt1_rxlpmlfhold_in                 => gt1_rxlpmlfhold_in,
         gt1_rxlpmreset_in                  => gt1_rxlpmreset_in,
         gt1_rxlpmhfovrden_in               => gt1_rxlpmhfovrden_in,
         gt1_rxcdrhold_in                   => gt1_rxcdrhold_in,

         gt1_eyescanreset_in                => gt1_eyescanreset_in,
        -------------------------- RX Margin Analysis Ports ------------------------
         gt1_eyescandataerror_out           => gt1_eyescandataerror_out,
         gt1_eyescantrigger_in              => gt1_eyescantrigger_in,
         gt1_rxbyteisaligned_out            => gt1_rxbyteisaligned_out,
         gt1_rxcommadet_out                 => gt1_rxcommadet_out,
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
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        gt1_txprbsforceerr_in           => gt1_txprbsforceerr_in,
        gt1_txprbssel_in                => gt1_txprbssel_in,
        ------------------- Transmit Ports - TX Data Path interface -----------------
        gt1_txpcsreset_in               => gt1_txpcsreset_in,
        gt1_txpmareset_in               => gt1_txpmareset_in,
        gt1_txresetdone_out             => gt1_txresetdone_out,
        gt1_rxresetdone_out             => gt1_rxresetdone_out,
        gt1_txbufstatus_out             => gt1_txbufstatus_out,
        gt1_rxbufstatus_out             => gt1_rxbufstatus_out,

        -- DRP I/F
DRPADDR_IN                     => DRPADDR_IN,
DRPCLK_IN                      => drpclk_in,
DRPDI_IN                       => DRPDI_IN,
DRPDO_OUT                      => DRPDO_OUT,
DRPEN_IN                       => DRPEN_IN,
DRPRDY_OUT                     => DRPRDY_OUT,
DRPWE_IN                       => DRPWE_IN,
DRPADDR_IN_LANE1                     => DRPADDR_IN_LANE1,
DRPCLK_IN_LANE1                      => drpclk_in,
DRPDI_IN_LANE1                       => DRPDI_IN_LANE1,
DRPDO_OUT_LANE1                      => DRPDO_OUT_LANE1,
DRPEN_IN_LANE1                       => DRPEN_IN_LANE1,
DRPRDY_OUT_LANE1                     => DRPRDY_OUT_LANE1,
DRPWE_IN_LANE1                       => DRPWE_IN_LANE1,

        INIT_CLK_IN                => init_clk_in,   
	PLL_NOT_LOCKED                   => PLL_NOT_LOCKED,
	TX_RESETDONE_OUT                 => tx_resetdone_i,
	RX_RESETDONE_OUT                 => rx_resetdone_i,   
        --Aurora Lane Interface
RXPOLARITY_IN           => rx_polarity_i (0),
RXPOLARITY_IN_LANE1           => rx_polarity_i (1),
RXRESET_IN              => rx_reset_i (0),
RXRESET_IN_LANE1              => rx_reset_i (1),
TXCHARISK_IN            => tx_char_is_k_i(1 downto 0),
TXCHARISK_IN_LANE1            => tx_char_is_k_i(3 downto 2),
TXDATA_IN               => tx_data_i(15 downto 0),
TXDATA_IN_LANE1               => tx_data_i(31 downto 16),
TXRESET_IN              => tx_reset_i (0),
TXRESET_IN_LANE1              => tx_reset_i (1),
RXDATA_OUT              => rx_data_i(15 downto 0),
RXDATA_OUT_LANE1              => rx_data_i(31 downto 16),
RXNOTINTABLE_OUT        => rx_not_in_table_i(1 downto 0),
RXNOTINTABLE_OUT_LANE1        => rx_not_in_table_i(3 downto 2),
RXDISPERR_OUT           => rx_disp_err_i(1 downto 0),
RXDISPERR_OUT_LANE1           => rx_disp_err_i(3 downto 2),
RXCHARISK_OUT           => rx_char_is_k_i(1 downto 0),
RXCHARISK_OUT_LANE1           => rx_char_is_k_i(3 downto 2),
RXCHARISCOMMA_OUT       => rx_char_is_comma_i(1 downto 0),
RXCHARISCOMMA_OUT_LANE1       => rx_char_is_comma_i(3 downto 2),
TXBUFERR_OUT            => tx_buf_err_i (0),
TXBUFERR_OUT_LANE1            => tx_buf_err_i (1),
RXBUFERR_OUT            => rx_buf_err_i (0),
RXBUFERR_OUT_LANE1            => rx_buf_err_i (1),
RXREALIGN_OUT           => rx_realign_i (0),
RXREALIGN_OUT_LANE1           => rx_realign_i (1),
        -- Reset due to channel initialization watchdog timer expiry  
                    GTRXRESET_IN                =>  gtrxreset_i,

                    -- reset for hot plug
                    LINK_RESET_IN                => link_reset_i,

        -- Phase Align Interface
ENMCOMMAALIGN_IN        => ena_comma_align_i (0),
ENMCOMMAALIGN_IN_LANE1        => ena_comma_align_i (1),
ENPCOMMAALIGN_IN        => ena_comma_align_i (0),
ENPCOMMAALIGN_IN_LANE1        => ena_comma_align_i (1),
        --Global Logic Interface
ENCHANSYNC_IN           => en_chan_sync_i,
ENCHANSYNC_IN_LANE1           => tied_to_vcc_i,
CHBONDDONE_OUT          => ch_bond_done_i (0),
CHBONDDONE_OUT_LANE1          => ch_bond_done_i (1),

        --Serial IO
RX1N_IN        => RXN (0),
RX1N_IN_LANE1        => RXN (1),
RX1P_IN        => RXP (0),
RX1P_IN_LANE1        => RXP (1),
TX1N_OUT       => TXN (0),
TX1N_OUT_LANE1       => TXN (1),
TX1P_OUT       => TXP (0),
TX1P_OUT_LANE1       => TXP (1),

       --Reference Clocks and User Clock
        RXUSRCLK_IN             => sync_clk,
        RXUSRCLK2_IN            => user_clk,
        TXUSRCLK_IN             => sync_clk,
        TXUSRCLK2_IN            => user_clk,
        REFCLK                  =>  GT_REFCLK1,
TXOUTCLK1_OUT           => raw_tx_out_clk_i (0),
TXOUTCLK1_OUT_LANE1           => raw_tx_out_clk_i (1),
PLLLKDET_OUT            => tx_lock_i (0),       
PLLLKDET_OUT_LANE1            => tx_lock_i (1),       
        --System Interface
        GTRESET_IN                                 => GT_RESET,
        LOOPBACK_IN                                     => LOOPBACK,

        POWERDOWN_IN                                    => POWER_DOWN
    );

    --__________Instantiate Global Logic to combine Lanes into a Channel______

-- FF stages added for timing closure
process (user_clk)
begin
  if (user_clk 'event and user_clk = '1') then
    ch_bond_done_r1 <= ch_bond_done_i;
  end if;
end process;

process (user_clk)
begin
  if (user_clk 'event and user_clk = '1') then
    ch_bond_done_r2 <= ch_bond_done_r1;
  end if;
end process;

process(user_clk)
begin
  if(user_clk='1' and user_clk'event)then
    if(system_reset_i='1')then
      ch_bond_done_dly_i  <=  (others => '0');
    elsif(en_chan_sync_i='1')then
      ch_bond_done_dly_i  <=  ch_bond_done_r2;
    else
      ch_bond_done_dly_i  <=  (others => '0');
    end if;
  end if;
end process;

process(user_clk)
begin
  if(user_clk='1' and user_clk'event)then
    if(system_reset_i='1')then
      ch_bond_load_pulse_i  <=  (others => '0');
    elsif(en_chan_sync_i='1')then
      ch_bond_load_pulse_i  <=  ch_bond_done_r2 and not ch_bond_done_dly_i;
    else
      ch_bond_load_pulse_i  <=  (others => '0');
    end if;
  end if;
end process;

    global_logic_i : gtp2e_aurora_8b10b_GLOBAL_LOGIC
    port map
    (
        -- GT Interface
        CH_BOND_DONE            => ch_bond_done_i,
        EN_CHAN_SYNC            => en_chan_sync_i,

        -- Aurora Lane Interface
        LANE_UP                 => lane_up_i,
        SOFT_ERR              => soft_err_i,
        HARD_ERR              => hard_err_i,
        CHANNEL_BOND_LOAD       => ch_bond_load_pulse_i,
        GOT_A                   => got_a_i,
        GOT_V                   => got_v_i,
        GEN_A                   => gen_a_i,
        GEN_K                   => gen_k_i,
        GEN_R                   => gen_r_i,
        GEN_V                   => gen_v_i,
        RESET_LANES             => reset_lanes_i,
                    GTRXRESET_OUT           => gtrxreset_i,
       
        -- System Interface
        USER_CLK                => user_clk,
        RESET                   => system_reset_i,
        POWER_DOWN              => POWER_DOWN,
        CHANNEL_UP              => channel_up_i,
        START_RX                => start_rx_i,
        CHANNEL_SOFT_ERR      => SOFT_ERR,
        CHANNEL_HARD_ERR      => HARD_ERR
    );

    --_____________________________ TX AXI SHIM _______________________________
    axi_to_ll_pdu_i : gtp2e_aurora_8b10b_AXI_TO_LL
    generic map
    (
       DATA_WIDTH           => 32,
       STRB_WIDTH           => 4,
       REM_WIDTH            => 2,
       USE_4_NFC            => 0,
       USE_UFC_REM          => 0
    )

    port map
    (
      AXI4_S_IP_TX_TVALID   => S_AXI_TX_TVALID,
      AXI4_S_IP_TX_TDATA    => S_AXI_TX_TDATA,
AXI4_S_IP_TX_TKEEP    => "0000",
      AXI4_S_IP_TX_TLAST    => tied_to_ground_i,
      AXI4_S_OP_TX_TREADY   => S_AXI_TX_TREADY,

      LL_OP_DATA            => tx_data,
      LL_OP_SOF_N           => OPEN,
      LL_OP_EOF_N           => OPEN,
      LL_OP_REM             => OPEN,
      LL_OP_SRC_RDY_N       => tx_src_rdy,
      LL_IP_DST_RDY_N       => tx_dst_rdy,

      -- System Interface
      USER_CLK              => user_clk,
      RESET                 => system_reset_i, 
      CHANNEL_UP            => channel_up_i
    );

    --_____________________________Instantiate TX_STREAM___________________________
    tx_stream_i : gtp2e_aurora_8b10b_TX_STREAM
    port map
    (
        -- Data interface
        TX_D            =>  tx_data,
        TX_SRC_RDY_N    =>  tx_src_rdy,
        TX_DST_RDY_N    =>  tx_dst_rdy,

        -- Global Logic Interface
        CHANNEL_UP      =>  channel_up_i,

        -- Clock Correction Interface
        DO_CC           =>  DO_CC,
        WARN_CC         =>  WARN_CC,

        -- Aurora Lane Interface
        GEN_SCP         =>  gen_scp_i,
        GEN_ECP         =>  gen_ecp_i,
        TX_PE_DATA_V    =>  tx_pe_data_v_i,
        GEN_PAD         =>  gen_pad_i,
        TX_PE_DATA      =>  tx_pe_data_i,
        GEN_CC          =>  gen_cc_i,

        -- System Interface
        USER_CLK        =>  user_clk
    );

    --_____________________________ RX AXI SHIM _______________________________
    ll_to_axi_pdu_i : gtp2e_aurora_8b10b_LL_TO_AXI
    generic map
    (
       DATA_WIDTH           => 32,
       STRB_WIDTH           => 4,
       REM_WIDTH            => 2
    )

    port map
    (
      LL_IP_DATA            => rx_data,
      LL_IP_SOF_N           => tied_to_ground_i,
      LL_IP_EOF_N           => tied_to_ground_i,
LL_IP_REM             => "00",
      LL_IP_SRC_RDY_N       => rx_src_rdy,
      LL_OP_DST_RDY_N       => OPEN,

      AXI4_S_OP_TVALID      => M_AXI_RX_TVALID,
      AXI4_S_OP_TDATA       => M_AXI_RX_TDATA,
      AXI4_S_OP_TKEEP       => OPEN,
      AXI4_S_OP_TLAST       => OPEN,
      AXI4_S_IP_TREADY      => tied_to_ground_i

    );


    --______________________________________Instantiate RX_STREAM__________________________________
    rx_stream_i : gtp2e_aurora_8b10b_RX_STREAM
    port map
    (
        -- AXI PDU Interface
        RX_D                =>  rx_data,
        RX_SRC_RDY_N        =>  rx_src_rdy,

        -- Global Logic Interface
        START_RX        =>  start_rx_i,

        -- Aurora Lane Interface
        RX_PAD          =>  rx_pad_i,
        RX_PE_DATA      =>  rx_pe_data_i,
        RX_PE_DATA_V    =>  rx_pe_data_v_i,
        RX_SCP          =>  rx_scp_i,
        RX_ECP          =>  rx_ecp_i,
        -- System Interface
        USER_CLK        =>  user_clk
    );

end MAPPED; 
