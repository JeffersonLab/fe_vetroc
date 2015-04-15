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

entity gtp2e_aurora_8b10b_GT_WRAPPER is
generic
(
    QPLL_FBDIV_TOP                 : integer  := 40;
    -- Channel bond MASTER/SLAVE connection
    CHAN_BOND_MASTER : std_logic := '1';
    CHAN_BOND_SLAVE  : std_logic := '0';
    CHAN_BOND_LEVEL  : std_logic_vector := "001";
    CHAN_BOND_MASTER_LANE1 : std_logic := '0';
    CHAN_BOND_SLAVE_LANE1  : std_logic := '1';
    CHAN_BOND_LEVEL_LANE1  : std_logic_vector := "000";
    -- Simulation attribute
    EXAMPLE_SIMULATION  : integer :=  0;     
    SIM_GTRESET_SPEEDUP : string  :=   "FALSE"      -- Set to "TRUE" to speed up sim reset
);

port
(

---------------------- Loopback and Powerdown Ports ----------------------
LOOPBACK_IN                               : in    std_logic_vector (2 downto 0);
--------------------- Receive Ports - 8b10b Decoder ----------------------
RXCHARISCOMMA_OUT : out   std_logic_vector (1 downto 0);
RXCHARISCOMMA_OUT_LANE1 : out   std_logic_vector (1 downto 0);
RXCHARISK_OUT     : out   std_logic_vector (1 downto 0);
RXCHARISK_OUT_LANE1     : out   std_logic_vector (1 downto 0);
RXDISPERR_OUT     : out   std_logic_vector (1 downto 0);
RXDISPERR_OUT_LANE1     : out   std_logic_vector (1 downto 0);
RXNOTINTABLE_OUT  : out   std_logic_vector (1 downto 0);
RXNOTINTABLE_OUT_LANE1  : out   std_logic_vector (1 downto 0);
----------------- Receive Ports - Channel Bonding Ports -----------------
ENCHANSYNC_IN     : in    std_logic;
ENCHANSYNC_IN_LANE1     : in    std_logic;
CHBONDDONE_OUT    : out   std_logic;
CHBONDDONE_OUT_LANE1    : out   std_logic;
----------------- Receive Ports - Clock Correction Ports -----------------
RXBUFERR_OUT      : out   std_logic;
RXBUFERR_OUT_LANE1      : out   std_logic;
------------- Receive Ports - Comma Detection and Alignment --------------
RXREALIGN_OUT     : out   std_logic;
RXREALIGN_OUT_LANE1     : out   std_logic;
ENMCOMMAALIGN_IN  : in    std_logic;
ENMCOMMAALIGN_IN_LANE1  : in    std_logic;
ENPCOMMAALIGN_IN  : in    std_logic;
ENPCOMMAALIGN_IN_LANE1  : in    std_logic;
----------------- Receive Ports - RX Data Path interface -----------------
RXDATA_OUT        : out   std_logic_vector (15 downto 0);
RXDATA_OUT_LANE1        : out   std_logic_vector (15 downto 0);
RXRESET_IN        : in    std_logic;
RXRESET_IN_LANE1        : in    std_logic;
RXUSRCLK_IN                               : in    std_logic;
RXUSRCLK2_IN                              : in    std_logic;
----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
RX1N_IN           : in    std_logic;
RX1N_IN_LANE1           : in    std_logic;
RX1P_IN           : in    std_logic;
RX1P_IN_LANE1           : in    std_logic;
--------------- Receive Ports - RX Polarity Control Ports ----------------
RXPOLARITY_IN     : in    std_logic;
RXPOLARITY_IN_LANE1     : in    std_logic;
------------------- Shared Ports - Tile and PLL Ports --------------------
REFCLK                                    : in    std_logic;
INIT_CLK_IN                               : in  std_logic;
PLL_NOT_LOCKED                            : in    std_logic;
GTRESET_IN                                : in    std_logic;
PLLLKDET_OUT      : out   std_logic;
PLLLKDET_OUT_LANE1      : out   std_logic;
    gt0_txresetdone_out         : out    std_logic;
    gt0_rxresetdone_out         : out    std_logic;
    gt0_rxpmaresetdone_out                      : out    std_logic;
    gt0_txbufstatus_out         : out    std_logic_vector(1 downto 0);
    gt0_rxbufstatus_out         : out    std_logic_vector(2 downto 0);
    gt1_txresetdone_out         : out    std_logic;
    gt1_rxresetdone_out         : out    std_logic;
    gt1_rxpmaresetdone_out                      : out    std_logic;
    gt1_txbufstatus_out         : out    std_logic_vector(1 downto 0);
    gt1_rxbufstatus_out         : out    std_logic_vector(2 downto 0);
TX_RESETDONE_OUT                          : out    std_logic;
RX_RESETDONE_OUT                          : out    std_logic;
-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
TXCHARISK_IN      : in    std_logic_vector (1 downto 0);
TXCHARISK_IN_LANE1      : in    std_logic_vector (1 downto 0);
---------------- Transmit Ports - TX Data Path interface -----------------
TXDATA_IN         : in    std_logic_vector (15 downto 0);
TXDATA_IN_LANE1         : in    std_logic_vector (15 downto 0);
TXOUTCLK1_OUT     : out   std_logic;
TXOUTCLK1_OUT_LANE1     : out   std_logic;
TXRESET_IN        : in    std_logic;
TXRESET_IN_LANE1        : in    std_logic;
TXUSRCLK_IN                               : in    std_logic;  
TXUSRCLK2_IN                              : in    std_logic;
TXBUFERR_OUT      : out   std_logic;
TXBUFERR_OUT_LANE1      : out   std_logic;
------------- Transmit Ports - TX Driver and OOB signalling --------------
TX1N_OUT          : out   std_logic;
TX1N_OUT_LANE1          : out   std_logic;
TX1P_OUT          : out   std_logic;
TX1P_OUT_LANE1          : out   std_logic;
---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
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

GTRXRESET_IN                            : in    std_logic;
LINK_RESET_IN                           : in    std_logic;
RXFSM_DATA_VALID                        : in    std_logic; 
POWERDOWN_IN                            : in    std_logic
);

end gtp2e_aurora_8b10b_GT_WRAPPER;


architecture MAPPED of gtp2e_aurora_8b10b_GT_WRAPPER is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of MAPPED : architecture is "yes";
  attribute core_generation_info               : string;
attribute core_generation_info of MAPPED : architecture is "gtp2e_aurora_8b10b,aurora_8b10b_v10_3,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=2,c_column_used=None,c_gt_clock_1=GTPQ3,c_gt_clock_2=None,c_gt_loc_1=X,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=1,c_gt_loc_16=2,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=2,c_line_rate=25000,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}";

    -- Parameter Declarations --
    constant DLY : time := 1 ns;

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


--***************************** Compopnent Declaration ****************************

component gtp2e_aurora_8b10b_tx_startup_fsm
  Generic(
           GT_TYPE                  : string := "GTP";
           STABLE_CLOCK_PERIOD      : integer range 4 to 20 := 8; --Period of the stable clock driving this state-machine, unit is [ns]
           RETRY_COUNTER_BITWIDTH   : integer range 2 to 8  := 8; 
            TX_PLL0_USED             : boolean := False;           -- the TX and RX Reset FSMs must
           RX_PLL0_USED             : boolean := False;           -- share these two generic values
           PHASE_ALIGNMENT_MANUAL   : boolean := True             -- Decision if a manual phase-alignment is necessary or the automatic 
                                                                  -- is enough. For single-lane applications the automatic alignment is 
                                                                  -- sufficient              
         );     
    Port ( STABLE_CLOCK             : in  STD_LOGIC;              --Stable Clock, either a stable clock from the PCB
                                                                  --or reference-clock present at startup.
           TXUSERCLK                : in  STD_LOGIC;              --TXUSERCLK as used in the design
           SOFT_RESET               : in  STD_LOGIC;              --User Reset, can be pulled any time
           PLL0REFCLKLOST           : in  STD_LOGIC;              --PLL0 Reference-clock for the GT is lost
           PLL1REFCLKLOST           : in  STD_LOGIC;              --PLL1 Reference-clock for the GT is lost
           PLL0LOCK                 : in  STD_LOGIC;              --Lock Detect from the PLL0 of the GT
           PLL1LOCK                 : in  STD_LOGIC;              --Lock Detect from the PLL1 of the GT
           TXRESETDONE              : in  STD_LOGIC;      
           MMCM_LOCK                : in  STD_LOGIC;      
           GTTXRESET                : out STD_LOGIC:='0';      
           MMCM_RESET               : out STD_LOGIC:='0';      
           PLL0_RESET               : out STD_LOGIC:='0';        --Reset PLL0
           PLL1_RESET               : out STD_LOGIC:='0';        --Reset PLL1
           TX_FSM_RESET_DONE        : out STD_LOGIC:='0';        --Reset-sequence has sucessfully been finished.
           TXUSERRDY                : out STD_LOGIC:='0';
           RUN_PHALIGNMENT          : out STD_LOGIC:='0';
           RESET_PHALIGNMENT        : out STD_LOGIC:='0';
           PHALIGNMENT_DONE         : in  STD_LOGIC;
           
           RETRY_COUNTER            : out  STD_LOGIC_VECTOR (RETRY_COUNTER_BITWIDTH-1 downto 0):=(others=>'0')-- Number of 
                                                            -- Retries it took to get the transceiver up and running
           );
end component;

component gtp2e_aurora_8b10b_rx_startup_fsm
  Generic(
           EXAMPLE_SIMULATION       : integer :=  0;
           GT_TYPE                  : string  := "GTP";
           STABLE_CLOCK_PERIOD      : integer range 4 to 20 := 8; --Period of the stable clock driving this state-machine, unit is [ns]
           RETRY_COUNTER_BITWIDTH   : integer range 2 to 8  := 8; 
           TX_PLL0_USED             : boolean := False;           -- the TX and RX Reset FSMs must
           RX_PLL0_USED             : boolean := False;           -- share these two generic values
           PHASE_ALIGNMENT_MANUAL   : boolean := True             -- Decision if a manual phase-alignment is necessary or the automatic 
                                                                  -- is enough. For single-lane applications the automatic alignment is 
                                                                  -- sufficient                         
         );     
    Port ( STABLE_CLOCK             : in  STD_LOGIC;        --Stable Clock, either a stable clock from the PCB
                                                            --or reference-clock present at startup.
           RXUSERCLK                : in  STD_LOGIC;        --RXUSERCLK as used in the design
           SOFT_RESET               : in  STD_LOGIC;        --User Reset, can be pulled any time
           PLL0REFCLKLOST           : in  STD_LOGIC;        --PLL0 Reference-clock for the GT is lost
           RXPMARESETDONE           : in  STD_LOGIC;        
           RXOUTCLK                 : in  STD_LOGIC;    
           TXPMARESETDONE           : in  STD_LOGIC;        
           TXOUTCLK                 : in  STD_LOGIC;    
    
           PLL1REFCLKLOST           : in  STD_LOGIC;        --PLL1 Reference-clock for the GT is lost
           PLL0LOCK                 : in  STD_LOGIC;        --Lock Detect from the PLL0 of the GT
           PLL1LOCK                 : in  STD_LOGIC;        --Lock Detect from the PLL1 of the GT
           RXRESETDONE              : in  STD_LOGIC;
           MMCM_LOCK                : in  STD_LOGIC;
           RECCLK_STABLE            : in  STD_LOGIC;
           RECCLK_MONITOR_RESTART   : in  STD_LOGIC;
           DATA_VALID               : in  STD_LOGIC;
           TXUSERRDY                : in  STD_LOGIC;       --TXUSERRDY from GT 
           DONT_RESET_ON_DATA_ERROR : in  STD_LOGIC;
           GTRXRESET                : out STD_LOGIC:='0';
           MMCM_RESET               : out STD_LOGIC:='0';
           PLL0_RESET               : out STD_LOGIC:='0';  --Reset PLL0 (only if RX uses PLL0)
           PLL1_RESET               : out STD_LOGIC:='0';  --Reset PLL1 (only if RX uses PLL1)
           RX_FSM_RESET_DONE        : out STD_LOGIC:='0';  --Reset-sequence has sucessfully been finished.
           RXUSERRDY                : out STD_LOGIC:='0';
           RUN_PHALIGNMENT          : out STD_LOGIC;
           PHALIGNMENT_DONE         : in  STD_LOGIC; 
           RESET_PHALIGNMENT        : out STD_LOGIC:='0';           
           RETRY_COUNTER            : out STD_LOGIC_VECTOR (RETRY_COUNTER_BITWIDTH-1 downto 0):=(others=>'0')-- Number of 
                                                            -- Retries it took to get the transceiver up and running
           );
end component;

component gtp2e_aurora_8b10b_multi_gt is
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
end component;

  function get_cdrlock_time(is_sim : in integer) return integer is
    variable lock_time: integer;
  begin
    if (is_sim = 1) then
      lock_time := 1000;
    else
      lock_time := 50000 / integer(2.5); --Typical CDR lock time is 50,000UI as per DS181
    end if;
    return lock_time;
  end function;

--***********************************Parameter Declarations********************

    constant STABLE_CLOCK_PERIOD  : integer := 20;  --Period of the stable clock driving this state-machine, unit is [ns]
    constant RX_CDRLOCK_TIME      : integer := get_cdrlock_time(EXAMPLE_SIMULATION);       -- 200us
    constant WAIT_TIME_CDRLOCK    : integer := RX_CDRLOCK_TIME / STABLE_CLOCK_PERIOD;      -- 200 us time-out

   signal tied_to_ground_i                               : std_logic;
   signal tied_to_ground_vec_i                           : std_logic_vector (63 downto 0);
   signal tied_to_vcc_i                                  : std_logic;
signal chbondi                 : std_logic_vector (3 downto 0);
signal chbondo                 : std_logic_vector (3 downto 0);
signal chbondi_LANE1                 : std_logic_vector (3 downto 0);
signal chbondo_LANE1                 : std_logic_vector (3 downto 0);
   signal chbondi_unused_i                                    : std_logic_vector (3 downto 0);

   signal rx_cdrlock_counter              : integer range 0 to WAIT_TIME_CDRLOCK:= 0 ;
   signal rx_cdrlocked                    : std_logic;
   signal gt_recclk_stable_i                 : std_logic;
   signal gt_pll0refclklost_i             : std_logic; 
   signal gt_pll_lock_i                   : std_logic; 
   signal gt0_txresetdone_i        : std_logic;
   signal gt0_rxresetdone_i        : std_logic;
   signal gt1_txresetdone_i        : std_logic;
   signal gt1_rxresetdone_i        : std_logic;
   signal txfsm_txresetdone_i                : std_logic;
   signal rxfsm_rxresetdone_i                : std_logic;
   signal txfsm_txresetdone_r                : std_logic;
   signal rxfsm_rxresetdone_r                : std_logic;
   signal rxfsm_rxresetdone_r2               : std_logic;
   signal rxfsm_rxresetdone_r3               : std_logic;
   signal gt_tx_reset_i                      : std_logic;
   signal gt_rx_reset_i                      : std_logic;
   signal fsm_gt_rx_reset_t                  : std_logic;
   signal rxfsm_soft_reset_r                 : std_logic;
   signal gt_txuserrdy_i                     : std_logic;
   signal gt_rxuserrdy_i                     : std_logic;
   signal mmcm_lock_i                        : std_logic;

   signal gtrxreset_sync                     : std_logic;
   signal gtrxreset_r1                       : std_logic;
   signal gtrxreset_r2                       : std_logic;
   signal gtrxreset_r3                       : std_logic;
   signal gtrxreset_pulse                    : std_logic;
 

--Timing closure flipflops
   signal              gt0_txresetdone_r : std_logic;
   signal              gt0_txresetdone_r2 : std_logic;
   signal              gt0_txresetdone_r3 : std_logic;
   signal              gt0_rxresetdone_r : std_logic;
   signal              gt0_rxresetdone_r2 : std_logic;
   signal              gt0_rxresetdone_r3 : std_logic;
   signal              gt1_txresetdone_r : std_logic;
   signal              gt1_txresetdone_r2 : std_logic;
   signal              gt1_txresetdone_r3 : std_logic;
   signal              gt1_rxresetdone_r : std_logic;
   signal              gt1_rxresetdone_r2 : std_logic;
   signal              gt1_rxresetdone_r3 : std_logic;
 
   signal link_reset_r                       : std_logic;  
   signal link_reset_r2                      : std_logic;

   signal common_reset_i                     : std_logic;  
   
   --concatenation or temp signals
   signal powerdown_i              : std_logic_vector(1 downto 0);
signal rx_buf_status_i    : std_logic_vector(2 downto 0);
signal tx_buf_status_i    : std_logic_vector(1 downto 0);
signal rx_buf_status_lane1_i    : std_logic_vector(2 downto 0);
signal tx_buf_status_lane1_i    : std_logic_vector(1 downto 0);


begin

  tied_to_ground_i                    <= '0';
  tied_to_ground_vec_i(63 downto 0)   <= (others => '0');
  tied_to_vcc_i                       <= '1';


  powerdown_i               <=  POWERDOWN_IN & POWERDOWN_IN;
RXBUFERR_OUT        <=  rx_buf_status_i(2);
TXBUFERR_OUT        <=  tx_buf_status_i(1);
RXBUFERR_OUT_LANE1        <=  rx_buf_status_lane1_i(2);
TXBUFERR_OUT_LANE1        <=  tx_buf_status_lane1_i(1);


  chbondi_unused_i          <= "0000";


   --Connect channel bonding bus

   chbondi <= chbondi_unused_i;

   chbondi_LANE1 <= chbondo;

   PLLLKDET_OUT_LANE1  <= tied_to_vcc_i;


      gtrxreset_cdc_sync : gtp2e_aurora_8b10b_cdc_sync
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
           prmry_aclk      => RXUSRCLK2_IN          ,
           prmry_resetn     => '1'                ,
           prmry_in        => GTRXRESET_IN        ,
           prmry_vect_in   => "00"               ,
           scndry_aclk     => INIT_CLK_IN       ,
           scndry_resetn    => '1'                ,
           prmry_ack       => open               ,
           scndry_out      => gtrxreset_sync     ,
           scndry_vect_out => open  
          );

   process(INIT_CLK_IN)
   begin
     if(INIT_CLK_IN'event and INIT_CLK_IN='1') then
      gtrxreset_r1    <=  gtrxreset_sync after DLY;
      gtrxreset_r2    <=  gtrxreset_r1 after DLY;
      gtrxreset_r3    <=  gtrxreset_r2 after DLY;
      gtrxreset_pulse <=  gtrxreset_r2 AND (NOT gtrxreset_r3) after DLY;        
     end if;
   end process;

    process(INIT_CLK_IN)
    begin
        if(INIT_CLK_IN'event and INIT_CLK_IN='1') then
            link_reset_r           <=  LINK_RESET_IN after DLY;
            link_reset_r2          <=  link_reset_r after DLY;
            gt_rx_reset_i          <=  fsm_gt_rx_reset_t after DLY;
            rxfsm_soft_reset_r     <=  link_reset_r2 or GTRESET_IN or gtrxreset_pulse after DLY;
        end if;
    end process;

  mmcm_lock_i <= (not PLL_NOT_LOCKED);

  gt_common_reset_out <= common_reset_i;

  gt_pll0refclklost_i <= gt0_pll0refclklost_in;

  PLLLKDET_OUT      <= quad1_common_lock_in;

  gt_pll_lock_i <= quad1_common_lock_in;

    gt0_txresetdone_out  <=   gt0_txresetdone_i;
    gt0_rxresetdone_out  <=   gt0_rxresetdone_i;
    gt0_txbufstatus_out  <=   tx_buf_status_i;
    gt0_rxbufstatus_out  <=   rx_buf_status_i;
    gt1_txresetdone_out  <=   gt1_txresetdone_i;
    gt1_rxresetdone_out  <=   gt1_rxresetdone_i;
    gt1_txbufstatus_out  <=   tx_buf_status_lane1_i;
    gt1_rxbufstatus_out  <=   rx_buf_status_lane1_i;

      --TXRESETDONE for lane0
    process(TXUSRCLK2_IN)
    begin
        if(TXUSRCLK2_IN'event and TXUSRCLK2_IN='1') then
            gt0_txresetdone_r  <=  gt0_txresetdone_i after DLY;
            gt0_txresetdone_r2 <=  gt0_txresetdone_r after DLY;
            gt0_txresetdone_r3 <=  gt0_txresetdone_r2 after DLY;
        end if;
    end process;

      --TXRESETDONE for lane1
    process(TXUSRCLK2_IN)
    begin
        if(TXUSRCLK2_IN'event and TXUSRCLK2_IN='1') then
            gt1_txresetdone_r  <=  gt1_txresetdone_i after DLY;
            gt1_txresetdone_r2 <=  gt1_txresetdone_r after DLY;
            gt1_txresetdone_r3 <=  gt1_txresetdone_r2 after DLY;
        end if;
    end process;

      --RXRESETDONE for lane0
    process(RXUSRCLK2_IN)
    begin
        if(RXUSRCLK2_IN'event and RXUSRCLK2_IN='1') then
            gt0_rxresetdone_r  <=  gt0_rxresetdone_i after DLY;
            gt0_rxresetdone_r2 <=  gt0_rxresetdone_r after DLY;
            gt0_rxresetdone_r3 <=  gt0_rxresetdone_r2 after DLY;
        end if;
    end process;

      --RXRESETDONE for lane1
    process(RXUSRCLK2_IN)
    begin
        if(RXUSRCLK2_IN'event and RXUSRCLK2_IN='1') then
            gt1_rxresetdone_r  <=  gt1_rxresetdone_i after DLY;
            gt1_rxresetdone_r2 <=  gt1_rxresetdone_r after DLY;
            gt1_rxresetdone_r3 <=  gt1_rxresetdone_r2 after DLY;
        end if;
    end process;


  txfsm_txresetdone_i  <= gt0_txresetdone_r3 and gt1_txresetdone_r3 ;
  rxfsm_rxresetdone_i  <= gt0_rxresetdone_r3 and gt1_rxresetdone_r3 ;

    process(TXUSRCLK2_IN)
    begin
        if(TXUSRCLK2_IN'event and TXUSRCLK2_IN='1') then
            txfsm_txresetdone_r   <=  txfsm_txresetdone_i after DLY;
        end if;
    end process;

    process(RXUSRCLK2_IN)
    begin
        if(RXUSRCLK2_IN'event and RXUSRCLK2_IN='1') then
            rxfsm_rxresetdone_r   <=  rxfsm_rxresetdone_i after DLY;
            rxfsm_rxresetdone_r2  <=  rxfsm_rxresetdone_r after DLY;
            rxfsm_rxresetdone_r3  <=  rxfsm_rxresetdone_r2 after DLY;
        end if;
    end process;


  RX_RESETDONE_OUT <= rxfsm_rxresetdone_r3;



gt_txresetfsm_i:  gtp2e_aurora_8b10b_tx_startup_fsm 

  generic map(
           GT_TYPE                  => "GTP", --GTX or GTH or GTP
           STABLE_CLOCK_PERIOD      => STABLE_CLOCK_PERIOD,           -- Period of the stable clock driving this state-machine, unit is [ns]
           RETRY_COUNTER_BITWIDTH   => 8, 
           TX_PLL0_USED             => TRUE ,                        -- the TX and RX Reset FSMs must 
           RX_PLL0_USED             => TRUE,                         -- share these two generic values
           PHASE_ALIGNMENT_MANUAL   => FALSE                 -- Decision if a manual phase-alignment is necessary or the automatic 
                                                                     -- is enough. For single-lane applications the automatic alignment is 
                                                                     -- sufficient              
             )     
    port map ( 

        STABLE_CLOCK            =>     INIT_CLK_IN,
        TXUSERCLK               =>     TXUSRCLK2_IN,
        SOFT_RESET              =>     GTRESET_IN,
        PLL0REFCLKLOST          =>     gt_pll0refclklost_i,
        PLL0LOCK                =>     gt_pll_lock_i,
        PLL1REFCLKLOST          =>     tied_to_ground_i,
        PLL1LOCK                =>     tied_to_vcc_i,
        TXRESETDONE             =>     txfsm_txresetdone_r,
        MMCM_LOCK               =>     mmcm_lock_i,
        GTTXRESET               =>     gt_tx_reset_i,
        MMCM_RESET              =>     open,
        PLL0_RESET              =>     common_reset_i,
        PLL1_RESET              =>     open,
        TX_FSM_RESET_DONE       =>     TX_RESETDONE_OUT,
        TXUSERRDY               =>     gt_txuserrdy_i,
        RUN_PHALIGNMENT         =>     open,
        RESET_PHALIGNMENT       =>     open  ,
        PHALIGNMENT_DONE        =>     tied_to_vcc_i,
        RETRY_COUNTER           =>     open
           );



gt_rxresetfsm_i:  gtp2e_aurora_8b10b_rx_startup_fsm 

  generic map(
           EXAMPLE_SIMULATION       => EXAMPLE_SIMULATION,
           GT_TYPE                  => "GTP", --GTX or GTH or GTP
           STABLE_CLOCK_PERIOD      => STABLE_CLOCK_PERIOD,           --Period of the stable clock driving this state-machine, unit is [ns]
           RETRY_COUNTER_BITWIDTH   => 8, 
           TX_PLL0_USED             => TRUE ,                        -- the TX and RX Reset FSMs must 
           RX_PLL0_USED             => TRUE,                         -- share these two generic values
           PHASE_ALIGNMENT_MANUAL   =>  FALSE                        -- Decision if a manual phase-alignment is necessary or the automatic 
                                                                     -- is enough. For single-lane applications the automatic alignment is 
                                                                     -- sufficient              
             )     
    port map ( 
        STABLE_CLOCK               =>    INIT_CLK_IN,
        RXUSERCLK                  =>    RXUSRCLK2_IN,
        SOFT_RESET                 =>    rxfsm_soft_reset_r,
        RXPMARESETDONE             =>    tied_to_vcc_i,               
        RXOUTCLK                   =>    RXUSRCLK2_IN, 
        TXPMARESETDONE             =>    tied_to_vcc_i,               
        TXOUTCLK                   =>    TXUSRCLK2_IN, 
              
        DONT_RESET_ON_DATA_ERROR   =>    '0',
        PLL0REFCLKLOST             =>    gt_pll0refclklost_i,
        PLL0LOCK                   =>    gt_pll_lock_i,
        PLL1REFCLKLOST             =>    tied_to_ground_i,
        PLL1LOCK                   =>    tied_to_vcc_i,
        RXRESETDONE                =>    rxfsm_rxresetdone_r,
        MMCM_LOCK                  =>    tied_to_vcc_i,
        RECCLK_STABLE              =>    gt_recclk_stable_i,
        RECCLK_MONITOR_RESTART     =>    tied_to_ground_i,
        DATA_VALID                 =>    gt_rxuserrdy_i,
        TXUSERRDY                  =>    gt_txuserrdy_i,
        GTRXRESET                  =>    fsm_gt_rx_reset_t,
        MMCM_RESET              =>     open,
        PLL0_RESET                 =>    open,
        PLL1_RESET                 =>    open,
        RX_FSM_RESET_DONE          =>    open,
        RXUSERRDY                  =>    gt_rxuserrdy_i,
        RUN_PHALIGNMENT            =>    open,
        RESET_PHALIGNMENT          =>    open,
        PHALIGNMENT_DONE           =>    tied_to_vcc_i,
        RETRY_COUNTER              =>    open
           );

  cdrlock_timeout:process(INIT_CLK_IN)
  begin
    if rising_edge(INIT_CLK_IN) then
        if(gt_rx_reset_i = '1') then
          rx_cdrlocked       <= '0';
          rx_cdrlock_counter <=  0                        after DLY;
        elsif (rx_cdrlock_counter = WAIT_TIME_CDRLOCK) then
          rx_cdrlocked       <= '1';
          rx_cdrlock_counter <= rx_cdrlock_counter        after DLY;
        else
          rx_cdrlock_counter <= rx_cdrlock_counter + 1    after DLY;
        end if;
    end if;
  end process;

gt_recclk_stable_i                          <= rx_cdrlocked;


   gtp2e_aurora_8b10b_multi_gt_i : gtp2e_aurora_8b10b_multi_gt
    generic map
    (
        -- Simulation attributes
        WRAPPER_SIM_GTRESET_SPEEDUP    => SIM_GTRESET_SPEEDUP

    )
    port map
    (
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT0
    --____________________________CHANNEL PORTS________________________________
    GT0_DRP_BUSY_OUT     => open,
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
GT0_DRPADDR_IN          =>  DRPADDR_IN,
GT0_DRPCLK_IN           =>  DRPCLK_IN,
GT0_DRPDI_IN            =>  DRPDI_IN,
GT0_DRPDO_OUT           =>  DRPDO_OUT,
GT0_DRPEN_IN            =>  DRPEN_IN,
GT0_DRPRDY_OUT          =>  DRPRDY_OUT,
GT0_DRPWE_IN            =>  DRPWE_IN,
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT0_LOOPBACK_IN          =>  LOOPBACK_IN,
    GT0_RXPD_IN          =>  powerdown_i,
    GT0_TXPD_IN          =>  powerdown_i,
    ------------------------------- Receive Ports ------------------------------
    GT0_RXUSERRDY_IN          =>  gt_rxuserrdy_i,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
GT0_RXCHARISCOMMA_OUT          =>  RXCHARISCOMMA_OUT,
GT0_RXCHARISK_OUT          =>  RXCHARISK_OUT,
GT0_RXDISPERR_OUT          =>  RXDISPERR_OUT,
GT0_RXNOTINTABLE_OUT          =>  RXNOTINTABLE_OUT,
    ------------------------- Receive Ports - AFE Ports ------------------------
GT0_GTPRXN_IN          =>  RX1N_IN,
GT0_GTPRXP_IN          =>  RX1P_IN,
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT0_RXCHANBONDSEQ_OUT      =>  open,
GT0_RXCHBONDEN_IN          =>  ENCHANSYNC_IN,
GT0_RXCHBONDI_IN           =>  chbondi,
GT0_RXCHBONDLEVEL_IN       =>  CHAN_BOND_LEVEL,
GT0_RXCHBONDMASTER_IN      =>  CHAN_BOND_MASTER,
GT0_RXCHBONDO_OUT          =>  chbondo,
GT0_RXCHBONDSLAVE_IN       =>  CHAN_BOND_SLAVE,
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
GT0_RXCHANISALIGNED_OUT    =>  CHBONDDONE_OUT,
    GT0_RXCHANREALIGN_OUT      =>  open,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT0_RXCLKCORCNT_OUT          =>  open,
    --------------- Receive Ports - Comma Detection and Alignment --------------
GT0_RXBYTEREALIGN_OUT          =>  RXREALIGN_OUT,
GT0_RXMCOMMAALIGNEN_IN          =>  ENMCOMMAALIGN_IN,
GT0_RXPCOMMAALIGNEN_IN          =>  ENPCOMMAALIGN_IN,
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT0_GTRXRESET_IN          =>  gt_rx_reset_i,
GT0_RXDATA_OUT          =>  RXDATA_OUT,
    GT0_RXOUTCLK_OUT          =>  open,
    GT0_RXUSRCLK_IN          =>  RXUSRCLK_IN,
    GT0_RXUSRCLK2_IN          =>  RXUSRCLK2_IN,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT0_RXCDRLOCK_OUT          =>  open,
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
GT0_RXBUFSTATUS_OUT          =>  rx_buf_status_i,
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT0_RXRESETDONE_OUT          =>  gt0_rxresetdone_i,
        GT0_RXPMARESETDONE_OUT          => gt0_rxpmaresetdone_out,
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
GT0_RXPOLARITY_IN          =>  RXPOLARITY_IN,
    ------------------------------- Transmit Ports -----------------------------
    GT0_TXUSERRDY_IN          =>  gt_txuserrdy_i,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
GT0_TXCHARISK_IN          =>  TXCHARISK_IN,
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
GT0_TXBUFSTATUS_OUT          =>  tx_buf_status_i,
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT0_GTTXRESET_IN          =>  gt_tx_reset_i,
GT0_TXDATA_IN          =>  TXDATA_IN,
GT0_TXOUTCLK_OUT          =>  TXOUTCLK1_OUT,
    GT0_TXOUTCLKFABRIC_OUT          =>  open,
    GT0_TXOUTCLKPCS_OUT          =>  open,
    GT0_TXUSRCLK_IN          =>  TXUSRCLK_IN,
    GT0_TXUSRCLK2_IN          =>  TXUSRCLK2_IN,
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
GT0_GTPTXN_OUT          =>  TX1N_OUT,
GT0_GTPTXP_OUT          =>  TX1P_OUT,
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT0_TXRESETDONE_OUT          =>  gt0_txresetdone_i,
    --------------------- Transmit Ports - PCI Express Ports -------------------
    gt0_txelecidle_in            =>  POWERDOWN_IN,
         gt0_rxlpmhfhold_in                 => gt0_rxlpmhfhold_in,
         gt0_rxlpmlfhold_in                 => gt0_rxlpmlfhold_in,
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
        gt0_rxlpmreset_in               => gt0_rxlpmreset_in,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        gt0_rxlpmhfovrden_in            => gt0_rxlpmhfovrden_in,
        gt0_rxcdrhold_in                => gt0_rxcdrhold_in,
        gt0_dmonitorout_out             => gt0_dmonitorout_out,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        gt0_rxbufreset_in               => gt0_rxbufreset_in,
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        gt0_txprbsforceerr_in           => gt0_txprbsforceerr_in,
        gt0_txprbssel_in                => gt0_txprbssel_in,
        ------------------- Transmit Ports - TX Data Path interface -----------------
        gt0_txpcsreset_in               => gt0_txpcsreset_in,
        gt0_txpmareset_in               => gt0_txpmareset_in,
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GT1
    --____________________________CHANNEL PORTS________________________________
    GT1_DRP_BUSY_OUT     => open,
    ---------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
GT1_DRPADDR_IN          =>  DRPADDR_IN_LANE1,
GT1_DRPCLK_IN           =>  DRPCLK_IN_LANE1,
GT1_DRPDI_IN            =>  DRPDI_IN_LANE1,
GT1_DRPDO_OUT           =>  DRPDO_OUT_LANE1,
GT1_DRPEN_IN            =>  DRPEN_IN_LANE1,
GT1_DRPRDY_OUT          =>  DRPRDY_OUT_LANE1,
GT1_DRPWE_IN            =>  DRPWE_IN_LANE1,
    ------------------------ Loopback and Powerdown Ports ----------------------
    GT1_LOOPBACK_IN          =>  LOOPBACK_IN,
    GT1_RXPD_IN          =>  powerdown_i,
    GT1_TXPD_IN          =>  powerdown_i,
    ------------------------------- Receive Ports ------------------------------
    GT1_RXUSERRDY_IN          =>  gt_rxuserrdy_i,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
GT1_RXCHARISCOMMA_OUT          =>  RXCHARISCOMMA_OUT_LANE1,
GT1_RXCHARISK_OUT          =>  RXCHARISK_OUT_LANE1,
GT1_RXDISPERR_OUT          =>  RXDISPERR_OUT_LANE1,
GT1_RXNOTINTABLE_OUT          =>  RXNOTINTABLE_OUT_LANE1,
    ------------------------- Receive Ports - AFE Ports ------------------------
GT1_GTPRXN_IN          =>  RX1N_IN_LANE1,
GT1_GTPRXP_IN          =>  RX1P_IN_LANE1,
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    GT1_RXCHANBONDSEQ_OUT      =>  open,
GT1_RXCHBONDEN_IN          =>  ENCHANSYNC_IN_LANE1,
GT1_RXCHBONDI_IN           =>  chbondi_LANE1,
GT1_RXCHBONDLEVEL_IN       =>  CHAN_BOND_LEVEL_LANE1,
GT1_RXCHBONDMASTER_IN      =>  CHAN_BOND_MASTER_LANE1,
GT1_RXCHBONDO_OUT          =>  chbondo_LANE1,
GT1_RXCHBONDSLAVE_IN       =>  CHAN_BOND_SLAVE_LANE1,
    ------------------- Receive Ports - Channel Bonding Ports  -----------------
GT1_RXCHANISALIGNED_OUT    =>  CHBONDDONE_OUT_LANE1,
    GT1_RXCHANREALIGN_OUT      =>  open,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GT1_RXCLKCORCNT_OUT          =>  open,
    --------------- Receive Ports - Comma Detection and Alignment --------------
GT1_RXBYTEREALIGN_OUT          =>  RXREALIGN_OUT_LANE1,
GT1_RXMCOMMAALIGNEN_IN          =>  ENMCOMMAALIGN_IN_LANE1,
GT1_RXPCOMMAALIGNEN_IN          =>  ENPCOMMAALIGN_IN_LANE1,
    ------------------- Receive Ports - RX Data Path interface -----------------
    GT1_GTRXRESET_IN          =>  gt_rx_reset_i,
GT1_RXDATA_OUT          =>  RXDATA_OUT_LANE1,
    GT1_RXOUTCLK_OUT          =>  open,
    GT1_RXUSRCLK_IN          =>  RXUSRCLK_IN,
    GT1_RXUSRCLK2_IN          =>  RXUSRCLK2_IN,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GT1_RXCDRLOCK_OUT          =>  open,
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
GT1_RXBUFSTATUS_OUT          =>  rx_buf_status_lane1_i,
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GT1_RXRESETDONE_OUT          =>  gt1_rxresetdone_i,
        GT1_RXPMARESETDONE_OUT          => gt1_rxpmaresetdone_out,
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
GT1_RXPOLARITY_IN          =>  RXPOLARITY_IN_LANE1,
    ------------------------------- Transmit Ports -----------------------------
    GT1_TXUSERRDY_IN          =>  gt_txuserrdy_i,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
GT1_TXCHARISK_IN          =>  TXCHARISK_IN_LANE1,
    ------------ Transmit Ports - TX Buffer and Phase Alignment Ports ----------
GT1_TXBUFSTATUS_OUT          =>  tx_buf_status_lane1_i,
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT1_GTTXRESET_IN          =>  gt_tx_reset_i,
GT1_TXDATA_IN          =>  TXDATA_IN_LANE1,
GT1_TXOUTCLK_OUT          =>  TXOUTCLK1_OUT_LANE1,
    GT1_TXOUTCLKFABRIC_OUT          =>  open,
    GT1_TXOUTCLKPCS_OUT          =>  open,
    GT1_TXUSRCLK_IN          =>  TXUSRCLK_IN,
    GT1_TXUSRCLK2_IN          =>  TXUSRCLK2_IN,
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
GT1_GTPTXN_OUT          =>  TX1N_OUT_LANE1,
GT1_GTPTXP_OUT          =>  TX1P_OUT_LANE1,
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GT1_TXRESETDONE_OUT          =>  gt1_txresetdone_i,
    --------------------- Transmit Ports - PCI Express Ports -------------------
    gt1_txelecidle_in            =>  POWERDOWN_IN,
         gt1_rxlpmhfhold_in                 => gt1_rxlpmhfhold_in,
         gt1_rxlpmlfhold_in                 => gt1_rxlpmlfhold_in,
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
        gt1_rxlpmreset_in               => gt1_rxlpmreset_in,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        gt1_rxlpmhfovrden_in            => gt1_rxlpmhfovrden_in,
        gt1_rxcdrhold_in                => gt1_rxcdrhold_in,
        gt1_dmonitorout_out             => gt1_dmonitorout_out,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        gt1_rxbufreset_in               => gt1_rxbufreset_in,
        ------------------ Transmit Ports - Pattern Generator Ports ----------------
        gt1_txprbsforceerr_in           => gt1_txprbsforceerr_in,
        gt1_txprbssel_in                => gt1_txprbssel_in,
        ------------------- Transmit Ports - TX Data Path interface -----------------
        gt1_txpcsreset_in               => gt1_txpcsreset_in,
        gt1_txpmareset_in               => gt1_txpmareset_in,
    --____________________________COMMON PORTS________________________________
    GT0_PLL0OUTCLK_IN        =>  GT0_PLL0OUTCLK_IN, 
    GT0_PLL1OUTCLK_IN        =>  GT0_PLL1OUTCLK_IN, 
    GT0_PLL0OUTREFCLK_IN     =>  GT0_PLL0OUTREFCLK_IN,
    GT0_PLL1OUTREFCLK_IN     =>  GT0_PLL1OUTREFCLK_IN,
    GT0_PLL0RESET_IN         =>  common_reset_i
    );

end MAPPED;
 
