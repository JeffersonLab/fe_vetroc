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
--  aurora_4lane_fd_str
--
--
--  Description: This is the top level module for a 4 2-byte lane Aurora
--               reference design module. This module supports the following features:
--
--               * Supports Virtex 5
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_MISC.all;
-- synthesis translate_off
library UNISIM;
use UNISIM.all;
-- synthesis translate_on


entity aurora_4lane_fd_str is
	generic(
		SIM_GTXRESET_SPEEDUP   :integer :=   0      --Set to 1 to speed up sim reset
	);
	port(
		-- TX Stream Interface
		TX_D                 : in  std_logic_vector(0 to 63);
		TX_SRC_RDY_N         : in  std_logic;
		TX_DST_RDY_N         : out std_logic;
		
		-- RX Stream Interface
		RX_D                 : out std_logic_vector(0 to 63);
		RX_SRC_RDY_N         : out std_logic;
		
		-- Clock Correction Interface
		DO_CC               : in  std_logic;
		WARN_CC             : in  std_logic;    
		
		-- GTX Serial I/O
		RXP                 : in std_logic_vector(0 to 3);
		TXP                 : out std_logic_vector(0 to 3);
		
		--GTX Reference Clock Interface
		GTXD0_L       		: in std_logic;
		GTXD0_R       		: in std_logic;
		
		-- Error Detection Interface
		HARD_ERR          : out std_logic_vector(0 to 3);
		SOFT_ERR          : out std_logic_vector(0 to 3);
		
		-- Status
		CHANNEL_UP          : out std_logic;
		LANE_UP             : out std_logic_vector(0 to 3);
		
		-- System Interface
		USER_CLK            : in  std_logic;
		SYNC_CLK            : in  std_logic;
		RESET               : in  std_logic;
		POWER_DOWN          : in  std_logic;
		LOOPBACK            : in  std_logic_vector(2 downto 0);
		GT_RESET            : in  std_logic;
		TX_LOCK             : out std_logic;

		--SIV Specific
		CLK50						: in std_logic;
		CAL_BLK_POWERDOWN_L	: in std_logic;
		CAL_BLK_POWERDOWN_R	: in std_logic;
		CAL_BLK_BUSY_L			: in std_logic;
		CAL_BLK_BUSY_R			: in std_logic;
		RECONFIG_FROMGXB_L	: out std_logic_vector(67 downto 0);
		RECONFIG_FROMGXB_R	: out std_logic_vector(67 downto 0);
		RECONFIG_TOGXB_L		: in std_logic_vector(3 downto 0);
		RECONFIG_TOGXB_R		: in std_logic_vector(3 downto 0)
	);
end aurora_4lane_fd_str;


architecture MAPPED of aurora_4lane_fd_str is
    component aurora_4lane_fd_str_AURORA_LANE 
    port (
    
       -- GTX Interface
   
        RX_DATA           : in std_logic_vector(15 downto 0);  -- 2-byte data bus from the GTX.
        RX_NOT_IN_TABLE   : in std_logic_vector(1 downto 0);   -- Invalid 10-bit code was recieved.
        RX_DISP_ERR       : in std_logic_vector(1 downto 0);   -- Disparity error detected on RX interface.
        RX_CHAR_IS_K      : in std_logic_vector(1 downto 0);   -- Indicates which bytes of RX_DATA are control.
        RX_CHAR_IS_COMMA  : in std_logic_vector(1 downto 0);   -- Comma received on given byte.
        RX_STATUS         : in std_logic_vector(5 downto 0);   -- Part of GTX status and error bus.
        RX_BUF_ERR        : in std_logic;                      -- Overflow/Underflow of RX buffer detected.
        TX_BUF_ERR        : in std_logic;                      -- Overflow/Underflow of TX buffer detected.
        RX_REALIGN        : in std_logic;                      -- SERDES was realigned because of a new comma.
        RX_POLARITY       : out std_logic;                     -- Controls interpreted polarity of serial data inputs.
        RX_RESET          : out std_logic;                     -- Reset RX side of GTX logic.
        TX_CHAR_IS_K      : out std_logic_vector(1 downto 0);  -- TX_DATA byte is a control character.
        TX_DATA           : out std_logic_vector(15 downto 0); -- 2-byte data bus to the GTX.
        TX_RESET          : out std_logic;                     -- Reset TX side of GTX logic.
   
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
   
        -- System Interface
      
        USER_CLK          : in std_logic;                      -- System clock for all non-GTX Aurora Logic.
        RESET_SYMGEN      : in std_logic;                      -- Reset the SYM_GEN module.
        RESET             : in std_logic                       -- Reset the lane.
     );
   end component;
  
	component aurora_4lane_fd_str_altera is
		port(
			--Serial IO
			RX1P_IN						: in std_logic_vector(0 to 3);
			TX1P_OUT						: out std_logic_vector(0 to 3);
			
			--Reference Clocks and User Clock
			REFCLK_L						: in std_logic;
			REFCLK_R						: in std_logic;
			PLLLKDET_OUT				: out std_logic_vector(1 downto 0);
			RXUSRCLK_IN					: in std_logic;
			TXUSRCLK_IN					: in std_logic;
			
			--Global Logic Interface
			ENCHANSYNC_IN				: in std_logic;
			CHBONDDONE_OUT				: out std_logic_vector(3 DOWNTO 0);
			
			RXRESET_IN					: in std_logic_vector(3 DOWNTO 0);
			RXBUFERR_OUT				: out std_logic_vector(3 DOWNTO 0);
			RXDATA_OUT					: out std_logic_vector (63 downto 0);
			RXCHARISCOMMA_OUT			: out std_logic_vector (7 downto 0);
			RXCHARISK_OUT				: out std_logic_vector (7 downto 0);
			RXDISPERR_OUT				: out std_logic_vector (7 downto 0);
			RXNOTINTABLE_OUT			: out std_logic_vector (7 downto 0);
			RXREALIGN_OUT				: out std_logic_vector(3 DOWNTO 0);
			
			TXRESET_IN					: in std_logic_vector(3 downto 0);
			TXDATA_IN					: in std_logic_vector(63 downto 0);
			TXCHARISK_IN				: in std_logic_vector(7 downto 0);
			TXBUFFER_OUT				: out std_logic_vector(3 downto 0);
			
			-- Phase Align Interface
			ENMCOMMAALIGN_IN			: in std_logic_vector(3 DOWNTO 0);
			ENPCOMMAALIGN_IN			: in std_logic_vector(3 DOWNTO 0);
			
			--System Interface
			GTXRESET_IN					: in std_logic;
			LOOPBACK_IN					: in std_logic_vector (2 downto 0);
			POWERDOWN_IN				: in std_logic;
			
			--SIV Specific
			CLK50							: in std_logic;
			CAL_BLK_POWERDOWN_L		: in std_logic;
			CAL_BLK_POWERDOWN_R		: in std_logic;
			CAL_BLK_BUSY_L				: in std_logic;
			CAL_BLK_BUSY_R				: in std_logic;
			RECONFIG_FROMGXB_L		: out std_logic_vector(67 downto 0);
			RECONFIG_FROMGXB_R		: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB_L			: in std_logic_vector(3 downto 0);
			RECONFIG_TOGXB_R			: in std_logic_vector(3 downto 0)
		);
	end component;

    component aurora_4lane_fd_str_GLOBAL_LOGIC
    port
    (
        -- GTX Interface
        CH_BOND_DONE       : in std_logic_vector(0 to 3);
        EN_CHAN_SYNC       : out std_logic;


        -- Aurora Lane Interface
        LANE_UP            : in std_logic_vector(0 to 3);
        SOFT_ERR         : in std_logic_vector(0 to 3);
        HARD_ERR         : in std_logic_vector(0 to 3);
        CHANNEL_BOND_LOAD  : in std_logic_vector(0 to 3);
        GOT_A              : in std_logic_vector(0 to 7);
        GOT_V              : in std_logic_vector(0 to 3);
        GEN_A              : out std_logic_vector(0 to 3);
        GEN_K              : out std_logic_vector(0 to 7);
        GEN_R              : out std_logic_vector(0 to 7);
        GEN_V              : out std_logic_vector(0 to 7);
        RESET_LANES        : out std_logic_vector(0 to 3);


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


    component aurora_4lane_fd_str_TX_STREAM
    port
    (
        -- Data interface
        TX_D                : in  std_logic_vector(0 to 63);
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
        TX_PE_DATA_V    : out std_logic_vector(0 to 3);
        GEN_PAD         : out std_logic_vector(0 to 3);
        TX_PE_DATA      : out std_logic_vector(0 to 63);
        GEN_CC          : out std_logic;


        -- System Interface
        USER_CLK        : in  std_logic


    );
    end component;


    component aurora_4lane_fd_str_RX_STREAM 
    port
    (
        -- LocalLink PDU Interface
        RX_D                : out std_logic_vector(0 to 63);
        RX_SRC_RDY_N        : out std_logic;


        -- Global Logic Interface
        START_RX        : in  std_logic;


        -- Aurora Lane Interface
        RX_PAD          : in  std_logic_vector(0 to 3);
        RX_PE_DATA      : in  std_logic_vector(0 to 63);
        RX_PE_DATA_V    : in  std_logic_vector(0 to 3);
        RX_SCP          : in  std_logic_vector(0 to 3);
        RX_ECP          : in  std_logic_vector(0 to 3);
        -- System Interface
        USER_CLK        : in  std_logic
    );
    end component;
    
--*********************************Wire Declarations**********************************

    signal TX1N_OUT_unused                 : std_logic_vector(0 to 3);
    signal TX1P_OUT_unused                 : std_logic_vector(0 to 3);
    signal RX1N_IN_unused                  : std_logic_vector(0 to 3);
    signal RX1P_IN_unused                  : std_logic_vector(0 to 3);
    signal rx_char_is_comma_i_unused       : std_logic_vector(7 downto 0);    
    signal rx_char_is_k_i_unused           : std_logic_vector(7 downto 0);    
    signal rx_data_i_unused                : std_logic_vector(63 downto 0);    
    signal rx_disp_err_i_unused            : std_logic_vector(7 downto 0);    
    signal rx_not_in_table_i_unused        : std_logic_vector(7 downto 0);    
    signal rx_realign_i_unused             : std_logic_vector(3 downto 0);    
    signal ch_bond_done_i_unused           : std_logic_vector(3 downto 0);








    signal ch_bond_done_i           :   std_logic_vector(3 downto 0);
    signal ch_bond_done_r1          :   std_logic_vector(3 downto 0);
    signal ch_bond_done_r2          :   std_logic_vector(3 downto 0);
    signal ch_bond_load_not_used_i  :   std_logic_vector(0 to 3);
    signal channel_up_i             :   std_logic;
    signal chbondi_not_used_i       :   std_logic_vector(4 downto 0);         
    signal chbondo_not_used_i       :   std_logic_vector(19 downto 0);          
    signal combus_in_not_used_i     :   std_logic_vector(15 downto 0);            
    signal combusout_out_not_used_i :   std_logic_vector(15 downto 0);            
    signal en_chan_sync_i               :   std_logic;
    signal ena_comma_align_i            :   std_logic_vector(3 downto 0);
    signal gen_a_i                      :   std_logic_vector(0 to 3);
    signal gen_cc_i                     :   std_logic;
    signal gen_ecp_i                    :   std_logic;
    signal gen_k_i                      :   std_logic_vector(0 to 7);
    signal gen_pad_i                    :   std_logic_vector(0 to 3);
    signal gen_r_i                      :   std_logic_vector(0 to 7);
    signal gen_scp_i                    :   std_logic;
    signal gen_v_i                      :   std_logic_vector(0 to 7);
    signal got_a_i                      :   std_logic_vector(0 to 7);
    signal got_v_i                      :   std_logic_vector(0 to 3);
    signal hard_err_i                 :   std_logic_vector(0 to 3);
    signal lane_up_i                    :   std_logic_vector(0 to 3);
    signal reset_lanes_i                :   std_logic_vector(0 to 3);
    signal rx_buf_err_i                 :   std_logic_vector(3 downto 0);
    signal rx_char_is_comma_i           :   std_logic_vector(7 downto 0);
    signal rx_char_is_k_i               :   std_logic_vector(7 downto 0);
    signal rx_clk_cor_cnt_i             :   std_logic_vector(11 downto 0);
    signal rx_data_i                    :   std_logic_vector(63 downto 0);
    signal rx_disp_err_i                :   std_logic_vector(7 downto 0);
    signal rx_ecp_i                     :   std_logic_vector(0 to 3);
    signal rx_not_in_table_i            :   std_logic_vector(7 downto 0);
    signal rx_pad_i                     :   std_logic_vector(0 to 3);
    signal rx_pe_data_i                 :   std_logic_vector(0 to 63);
    signal rx_pe_data_v_i               :   std_logic_vector(0 to 3);
    signal rx_polarity_i                :   std_logic_vector(3 downto 0);
    signal rx_realign_i                 :   std_logic_vector(3 downto 0);
    signal rx_reset_i                   :   std_logic_vector(3 downto 0);
    signal rx_scp_i                     :   std_logic_vector(0 to 3);
    signal rxmclk_out_not_used_i        :   std_logic_vector(0 to 3);            
    signal rxpcshclkout_not_used_i      :   std_logic_vector(0 to 3);            
    signal soft_err_i                 :   std_logic_vector(0 to 3);
    signal start_rx_i                   :   std_logic;
    signal tied_to_ground_i             :   std_logic;
    signal tied_to_ground_vec_i         :   std_logic_vector(47 downto 0);
    signal tied_to_vcc_i                :   std_logic;
    signal tx_buf_err_i                 :   std_logic_vector(3 downto 0);
    signal tx_char_is_k_i               :   std_logic_vector(7 downto 0);
    signal tx_data_i                    :   std_logic_vector(63 downto 0);
    signal tx_lock_i                    :   std_logic_vector(0 to 1);
    signal tx_pe_data_i                 :   std_logic_vector(0 to 63);
    signal tx_pe_data_v_i               :   std_logic_vector(0 to 3);
    signal tx_reset_i                   :   std_logic_vector(3 downto 0);
    signal txoutclk2_out_not_used_i   :   std_logic_vector(0 to 3);            
    signal txpcshclkout_not_used_i    :   std_logic_vector(0 to 3);            
    signal ch_bond_load_pulse_i         :   std_logic_vector(0 to 3);
    signal ch_bond_done_dly_i           :   std_logic_vector(0 to 3);
begin
--*********************************Main Body of Code**********************************

    --Tie off top level constants
    tied_to_ground_vec_i    <=  (others => '0');
    tied_to_ground_i        <=  '0';
    tied_to_vcc_i           <=  '1';

    --Connect top level logic
    CHANNEL_UP          <=  channel_up_i;

    --Connect TX_LOCK to tx_lock_i from lane 0
    TX_LOCK    <=   AND_REDUCE(tx_lock_i);

    --_________________________Instantiate Lane 0______________________________

    LANE_UP(0) <=   lane_up_i(0);

    aurora_lane_0_i : aurora_4lane_fd_str_AURORA_LANE
    port map
    (
    
        
        --GTX Interface
        RX_DATA             => rx_data_i(15 downto 0),
        RX_NOT_IN_TABLE     => rx_not_in_table_i(1 downto 0),
        RX_DISP_ERR         => rx_disp_err_i(1 downto 0),
        RX_CHAR_IS_K        => rx_char_is_k_i(1 downto 0),
        RX_CHAR_IS_COMMA    => rx_char_is_comma_i(1 downto 0),
        RX_STATUS           => tied_to_ground_vec_i(5 downto 0),
        TX_BUF_ERR          => tx_buf_err_i(0),
        RX_BUF_ERR          => rx_buf_err_i(0),
        RX_REALIGN          => rx_realign_i(0),
        RX_POLARITY         => rx_polarity_i(0),
        RX_RESET            => rx_reset_i(0),
        TX_CHAR_IS_K        => tx_char_is_k_i(1 downto 0),
        TX_DATA             => tx_data_i(15 downto 0),
        TX_RESET            => tx_reset_i(0),
        
        --Comma Detect Phase Align Interface
        ENA_COMMA_ALIGN     => ena_comma_align_i(0),


        --TX_LL Interface
        GEN_SCP             => gen_scp_i,
        GEN_ECP             => tied_to_ground_i,
        GEN_PAD             => gen_pad_i(0),
        TX_PE_DATA          => tx_pe_data_i(0 to 15),
        TX_PE_DATA_V        => tx_pe_data_v_i(0),
        GEN_CC              => gen_cc_i,


        --RX_LL Interface
        RX_PAD              => rx_pad_i(0),
        RX_PE_DATA          => rx_pe_data_i(0 to 15),
        RX_PE_DATA_V        => rx_pe_data_v_i(0),
        RX_SCP              => rx_scp_i(0),
        RX_ECP              => rx_ecp_i(0),

        --Global Logic Interface
        GEN_A               => gen_a_i(0),
        GEN_K               => gen_k_i(0 to 1),
        GEN_R               => gen_r_i(0 to 1),
        GEN_V               => gen_v_i(0 to 1),
        LANE_UP             => lane_up_i(0),
        SOFT_ERR          => soft_err_i(0),
        HARD_ERR          => hard_err_i(0),
        CHANNEL_BOND_LOAD   => ch_bond_load_not_used_i(0),
        GOT_A               => got_a_i(0 to 1),
        GOT_V               => got_v_i(0),

        --System Interface
        USER_CLK            => USER_CLK,
        RESET_SYMGEN        => RESET,
        RESET               => reset_lanes_i(0)
    );
    --_________________________Instantiate Lane 1______________________________

    LANE_UP(1) <=   lane_up_i(1);

    aurora_lane_1_i : aurora_4lane_fd_str_AURORA_LANE
    port map
    (
    
        
        --GTX Interface
        RX_DATA             => rx_data_i(31 downto 16),
        RX_NOT_IN_TABLE     => rx_not_in_table_i(3 downto 2),
        RX_DISP_ERR         => rx_disp_err_i(3 downto 2),
        RX_CHAR_IS_K        => rx_char_is_k_i(3 downto 2),
        RX_CHAR_IS_COMMA    => rx_char_is_comma_i(3 downto 2),
        RX_STATUS           => tied_to_ground_vec_i(5 downto 0),
        TX_BUF_ERR          => tx_buf_err_i(1),
        RX_BUF_ERR          => rx_buf_err_i(1),
        RX_REALIGN          => rx_realign_i(1),
        RX_POLARITY         => rx_polarity_i(1),
        RX_RESET            => rx_reset_i(1),
        TX_CHAR_IS_K        => tx_char_is_k_i(3 downto 2),
        TX_DATA             => tx_data_i(31 downto 16),
        TX_RESET            => tx_reset_i(1),
        
        --Comma Detect Phase Align Interface
        ENA_COMMA_ALIGN     => ena_comma_align_i(1),


        --TX_LL Interface
        GEN_SCP             => tied_to_ground_i,
        
        GEN_ECP             => tied_to_ground_i,
        GEN_PAD             => gen_pad_i(1),
        TX_PE_DATA          => tx_pe_data_i(16 to 31),
        TX_PE_DATA_V        => tx_pe_data_v_i(1),
        GEN_CC              => gen_cc_i,


        --RX_LL Interface
        RX_PAD              => rx_pad_i(1),
        RX_PE_DATA          => rx_pe_data_i(16 to 31),
        RX_PE_DATA_V        => rx_pe_data_v_i(1),
        RX_SCP              => rx_scp_i(1),
        RX_ECP              => rx_ecp_i(1),

        --Global Logic Interface
        GEN_A               => gen_a_i(1),
        GEN_K               => gen_k_i(2 to 3),
        GEN_R               => gen_r_i(2 to 3),
        GEN_V               => gen_v_i(2 to 3),
        LANE_UP             => lane_up_i(1),
        SOFT_ERR          => soft_err_i(1),
        HARD_ERR          => hard_err_i(1),
        CHANNEL_BOND_LOAD   => ch_bond_load_not_used_i(1),
        GOT_A               => got_a_i(2 to 3),
        GOT_V               => got_v_i(1),

        --System Interface
        USER_CLK            => USER_CLK,
        RESET_SYMGEN        => RESET,
        RESET               => reset_lanes_i(1)
    );
    --_________________________Instantiate Lane 2______________________________

    LANE_UP(2) <=   lane_up_i(2);

    aurora_lane_2_i : aurora_4lane_fd_str_AURORA_LANE
    port map
    (
    
        
        --GTX Interface
        RX_DATA             => rx_data_i(47 downto 32),
        RX_NOT_IN_TABLE     => rx_not_in_table_i(5 downto 4),
        RX_DISP_ERR         => rx_disp_err_i(5 downto 4),
        RX_CHAR_IS_K        => rx_char_is_k_i(5 downto 4),
        RX_CHAR_IS_COMMA    => rx_char_is_comma_i(5 downto 4),
        RX_STATUS           => tied_to_ground_vec_i(5 downto 0),
        TX_BUF_ERR          => tx_buf_err_i(2),
        RX_BUF_ERR          => rx_buf_err_i(2),
        RX_REALIGN          => rx_realign_i(2),
        RX_POLARITY         => rx_polarity_i(2),
        RX_RESET            => rx_reset_i(2),
        TX_CHAR_IS_K        => tx_char_is_k_i(5 downto 4),
        TX_DATA             => tx_data_i(47 downto 32),
        TX_RESET            => tx_reset_i(2),
        
        --Comma Detect Phase Align Interface
        ENA_COMMA_ALIGN     => ena_comma_align_i(2),


        --TX_LL Interface
        GEN_SCP             => tied_to_ground_i,
        
        GEN_ECP             => tied_to_ground_i,
        GEN_PAD             => gen_pad_i(2),
        TX_PE_DATA          => tx_pe_data_i(32 to 47),
        TX_PE_DATA_V        => tx_pe_data_v_i(2),
        GEN_CC              => gen_cc_i,


        --RX_LL Interface
        RX_PAD              => rx_pad_i(2),
        RX_PE_DATA          => rx_pe_data_i(32 to 47),
        RX_PE_DATA_V        => rx_pe_data_v_i(2),
        RX_SCP              => rx_scp_i(2),
        RX_ECP              => rx_ecp_i(2),

        --Global Logic Interface
        GEN_A               => gen_a_i(2),
        GEN_K               => gen_k_i(4 to 5),
        GEN_R               => gen_r_i(4 to 5),
        GEN_V               => gen_v_i(4 to 5),
        LANE_UP             => lane_up_i(2),
        SOFT_ERR          => soft_err_i(2),
        HARD_ERR          => hard_err_i(2),
        CHANNEL_BOND_LOAD   => ch_bond_load_not_used_i(2),
        GOT_A               => got_a_i(4 to 5),
        GOT_V               => got_v_i(2),

        --System Interface
        USER_CLK            => USER_CLK,
        RESET_SYMGEN        => RESET,
        RESET               => reset_lanes_i(2)
    );
    --_________________________Instantiate Lane 3______________________________

    LANE_UP(3) <=   lane_up_i(3);

    aurora_lane_3_i : aurora_4lane_fd_str_AURORA_LANE
    port map
    (
    
        
        --GTX Interface
        RX_DATA             => rx_data_i(63 downto 48),
        RX_NOT_IN_TABLE     => rx_not_in_table_i(7 downto 6),
        RX_DISP_ERR         => rx_disp_err_i(7 downto 6),
        RX_CHAR_IS_K        => rx_char_is_k_i(7 downto 6),
        RX_CHAR_IS_COMMA    => rx_char_is_comma_i(7 downto 6),
        RX_STATUS           => tied_to_ground_vec_i(5 downto 0),
        TX_BUF_ERR          => tx_buf_err_i(3),
        RX_BUF_ERR          => rx_buf_err_i(3),
        RX_REALIGN          => rx_realign_i(3),
        RX_POLARITY         => rx_polarity_i(3),
        RX_RESET            => rx_reset_i(3),
        TX_CHAR_IS_K        => tx_char_is_k_i(7 downto 6),
        TX_DATA             => tx_data_i(63 downto 48),
        TX_RESET            => tx_reset_i(3),
        
        --Comma Detect Phase Align Interface
        ENA_COMMA_ALIGN     => ena_comma_align_i(3),


        --TX_LL Interface
        GEN_SCP             => tied_to_ground_i,
        
        GEN_ECP             => gen_ecp_i,
        GEN_PAD             => gen_pad_i(3),
        TX_PE_DATA          => tx_pe_data_i(48 to 63),
        TX_PE_DATA_V        => tx_pe_data_v_i(3),
        GEN_CC              => gen_cc_i,


        --RX_LL Interface
        RX_PAD              => rx_pad_i(3),
        RX_PE_DATA          => rx_pe_data_i(48 to 63),
        RX_PE_DATA_V        => rx_pe_data_v_i(3),
        RX_SCP              => rx_scp_i(3),
        RX_ECP              => rx_ecp_i(3),

        --Global Logic Interface
        GEN_A               => gen_a_i(3),
        GEN_K               => gen_k_i(6 to 7),
        GEN_R               => gen_r_i(6 to 7),
        GEN_V               => gen_v_i(6 to 7),
        LANE_UP             => lane_up_i(3),
        SOFT_ERR          => soft_err_i(3),
        HARD_ERR          => hard_err_i(3),
        CHANNEL_BOND_LOAD   => ch_bond_load_not_used_i(3),
        GOT_A               => got_a_i(6 to 7),
        GOT_V               => got_v_i(3),

        --System Interface
        USER_CLK            => USER_CLK,
        RESET_SYMGEN        => RESET,
        RESET               => reset_lanes_i(3)
    );

    --_________________________Instantiate GTX Wrapper ______________________________

	gtx_wrapper_i: aurora_4lane_fd_str_altera
		port map(
			--Serial IO
			RX1P_IN						=> RXP,
			TX1P_OUT						=> TXP,
			
			--Reference Clocks and User Clock
			REFCLK_L						=> GTXD0_L,
			REFCLK_R						=> GTXD0_R,
			PLLLKDET_OUT				=> tx_lock_i,
			RXUSRCLK_IN					=> USER_CLK,
			TXUSRCLK_IN					=> USER_CLK,
			
			--Global Logic Interface
			ENCHANSYNC_IN				=> en_chan_sync_i,
			CHBONDDONE_OUT				=> ch_bond_done_i,
			
			RXRESET_IN					=> rx_reset_i,
			RXBUFERR_OUT				=> rx_buf_err_i,
			RXDATA_OUT					=> rx_data_i,
			RXCHARISCOMMA_OUT			=> rx_char_is_comma_i,
			RXCHARISK_OUT				=> rx_char_is_k_i,
			RXDISPERR_OUT				=> rx_disp_err_i,
			RXNOTINTABLE_OUT			=> rx_not_in_table_i,
			RXREALIGN_OUT				=> rx_realign_i,

			TXRESET_IN					=> tx_reset_i,
			TXDATA_IN					=> tx_data_i,
			TXCHARISK_IN				=> tx_char_is_k_i,
			TXBUFFER_OUT				=> tx_buf_err_i,

			-- Phase Align Interface
			ENMCOMMAALIGN_IN			=> ena_comma_align_i,
			ENPCOMMAALIGN_IN			=> ena_comma_align_i,
			
			--System Interface
			GTXRESET_IN					=> GT_RESET,
			LOOPBACK_IN					=> LOOPBACK,
			POWERDOWN_IN				=> POWER_DOWN,
			
			--SIV Specific
			CLK50							=> CLK50,
			CAL_BLK_POWERDOWN_L		=> CAL_BLK_POWERDOWN_L,
			CAL_BLK_POWERDOWN_R		=> CAL_BLK_POWERDOWN_R,
			CAL_BLK_BUSY_L				=> CAL_BLK_BUSY_L,
			CAL_BLK_BUSY_R				=> CAL_BLK_BUSY_R,
			RECONFIG_FROMGXB_L		=> RECONFIG_FROMGXB_L,
			RECONFIG_FROMGXB_R		=> RECONFIG_FROMGXB_R,
			RECONFIG_TOGXB_L			=> RECONFIG_TOGXB_L,
			RECONFIG_TOGXB_R			=> RECONFIG_TOGXB_R
		);

    --__________Instantiate Global Logic to combine Lanes into a Channel______

-- FF stages added for timing closure
process (USER_CLK)
begin
  if (USER_CLK 'event and USER_CLK = '1') then
    ch_bond_done_r1 <= ch_bond_done_i;
  end if;
end process;

process (USER_CLK)
begin
  if (USER_CLK 'event and USER_CLK = '1') then
    ch_bond_done_r2 <= ch_bond_done_r1;
  end if;
end process;

process(USER_CLK)
begin
  if(USER_CLK='1' and USER_CLK'event)then
    if(RESET='1')then
      ch_bond_done_dly_i  <=  (others => '0');
    elsif(en_chan_sync_i='1')then
      ch_bond_done_dly_i  <=  ch_bond_done_r2;
    else
      ch_bond_done_dly_i  <=  (others => '0');
    end if;
  end if;
end process;

process(USER_CLK)
begin
  if(USER_CLK='1' and USER_CLK'event)then
    if(RESET='1')then
      ch_bond_load_pulse_i  <=  (others => '0');
    elsif(en_chan_sync_i='1')then
      ch_bond_load_pulse_i  <=  ch_bond_done_r2 and not ch_bond_done_dly_i;
    else
      ch_bond_load_pulse_i  <=  (others => '0');
    end if;
  end if;
end process;

process(USER_CLK)
begin
	if rising_edge(USER_CLK) then
		for I in 0 to 3 loop
			SOFT_ERR(I) <= soft_err_i(I) and channel_up_i;
		end loop;
		HARD_ERR <= hard_err_i;
	end if;
end process;

	global_logic_i : aurora_4lane_fd_str_GLOBAL_LOGIC
		port map(
			-- GTX Interface
			CH_BOND_DONE		=> ch_bond_done_i,
			EN_CHAN_SYNC		=> en_chan_sync_i,
			-- Aurora Lane Interface
			LANE_UP				=> lane_up_i,
			SOFT_ERR			=> soft_err_i,
			HARD_ERR			=> hard_err_i,
			CHANNEL_BOND_LOAD	=> ch_bond_load_pulse_i,
			GOT_A				=> got_a_i,
			GOT_V				=> got_v_i,
			GEN_A				=> gen_a_i,
			GEN_K				=> gen_k_i,
			GEN_R				=> gen_r_i,
			GEN_V				=> gen_v_i,
			RESET_LANES			=> reset_lanes_i,
			-- System Interface
			USER_CLK			=> USER_CLK,
			RESET				=> RESET,
			POWER_DOWN			=> POWER_DOWN,
			CHANNEL_UP			=> channel_up_i,
			START_RX			=> start_rx_i,
			CHANNEL_SOFT_ERR	=> open,
			CHANNEL_HARD_ERR	=> open
		);

    --_____________________________Instantiate TX_STREAM___________________________
    tx_stream_i : aurora_4lane_fd_str_TX_STREAM
    port map
    (
        -- Data interface
        TX_D            =>  TX_D,
        TX_SRC_RDY_N    =>  TX_SRC_RDY_N,
        TX_DST_RDY_N    =>  TX_DST_RDY_N,

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
        USER_CLK        =>  USER_CLK 
    );

    --______________________________________Instantiate RX_STREAM__________________________________
    rx_stream_i : aurora_4lane_fd_str_RX_STREAM
    port map
    (
        -- LocalLink PDU Interface
        RX_D                =>  RX_D, 
        RX_SRC_RDY_N        =>  RX_SRC_RDY_N,

        -- Global Logic Interface
        START_RX        =>  start_rx_i,

        -- Aurora Lane Interface
        RX_PAD          =>  rx_pad_i,
        RX_PE_DATA      =>  rx_pe_data_i,
        RX_PE_DATA_V    =>  rx_pe_data_v_i,
        RX_SCP          =>  rx_scp_i,
        RX_ECP          =>  rx_ecp_i,
        -- System Interface
        USER_CLK        =>  USER_CLK
    );

end MAPPED;
