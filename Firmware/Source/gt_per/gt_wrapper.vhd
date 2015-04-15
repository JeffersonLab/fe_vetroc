library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

entity gt_wrapper is
	generic(
		SIM_GTRESET_SPEEDUP	: integer := 0;
		TX_POLARITY				: std_logic_vector(0 to 1) := "00";
		RX_POLARITY				: std_logic_vector(0 to 1) := "00"
	);
	port(
		-- External Signals
		GT_REFCLK		: in std_logic;
		RXP				: in std_logic_vector(0 to 1);
		RXN				: in std_logic_vector(0 to 1);
		TXP				: out std_logic_vector(0 to 1);
		TXN				: out std_logic_vector(0 to 1);

		-- Parallel Interface
		CLK				: in std_logic;
		RX_D				: out std_logic_vector(31 downto 0);
		RX_SRC_RDY_N	: out std_logic;
		TX_D				: in std_logic_vector(31 downto 0);
		TX_SRC_RDY_N	: in std_logic;
		TX_DST_RDY_N	: out std_logic;
	
		-- DRP Interface
		DRP_CLK			: in std_logic;
		DRP_ADDR			: in std_logic_vector(8 downto 0);
		DRP_DI			: in std_logic_vector(15 downto 0);
		DRP_DO			: out std_logic_vector(15 downto 0);
		DRP_DEN			: in std_logic_vector(0 to 1);
		DRP_DWE			: in std_logic;
		DRP_RDY			: out std_logic;
		
		-- GTP configuration/status bits
		POWER_DOWN		: in std_logic;
		LOOPBACK			: in std_logic_vector(2 downto 0);
		PRBS_SEL			: in std_logic_vector(2 downto 0);
		ERR_RST			: in std_logic;
		ERR_CNT			: in slv16a(0 to 1);
		RXEQMIX			: in slv2a(0 to 1);
		TXPREEMPHASIS	: in slv3a(0 to 1);
		TXBUFDIFFCTRL	: in slv3a(0 to 1);
		TXDIFFCTRL		: in slv3a(0 to 1);

		HARD_ERR			: out std_logic;
		LANE_UP			: out std_logic_vector(0 to 1);
		CHANNEL_UP		: out std_logic;
		TX_LOCK			: out std_logic
	);
end gt_wrapper;


architecture synthesis of gt_wrapper is
	component gtp2e_aurora_8b10b_core is
		generic(
			SIM_GTRESET_SPEEDUP			: string  := "FALSE";
			EXAMPLE_SIMULATION			: integer := 0      
		);
		port(
			-- TX Stream Interface
			S_AXI_TX_TDATA					: in  std_logic_vector(0 to 31);
			S_AXI_TX_TVALID				: in  std_logic;
			S_AXI_TX_TREADY				: out std_logic;

			-- RX Stream Interface
			M_AXI_RX_TDATA					: out std_logic_vector(0 to 31);
			M_AXI_RX_TVALID				: out std_logic;

			-- Clock Correction Interface
			DO_CC								: in  std_logic;
			WARN_CC							: in  std_logic;    

			-- GT Serial I/O
			RXP								: in std_logic_vector(0 to 1);
			RXN								: in std_logic_vector(0 to 1);
			TXP								: out std_logic_vector(0 to 1);
			TXN								: out std_logic_vector(0 to 1);

			--GT Reference Clock Interface
			GT_REFCLK1						: in std_logic;

			-- Error Detection Interface
			HARD_ERR							: out std_logic;
			SOFT_ERR							: out std_logic;

			-- Status
			CHANNEL_UP						: out std_logic;
			LANE_UP							: out std_logic_vector(0 to 1);

			-- System Interface
			user_clk							: in  std_logic;
			sync_clk							: in  std_logic;
			RESET								: in  std_logic;
			POWER_DOWN						: in  std_logic;
			LOOPBACK							: in  std_logic_vector(2 downto 0);
			GT_RESET							: in  std_logic;
			init_clk_in						: in  std_logic;
			PLL_NOT_LOCKED					: in  std_logic;
			TX_RESETDONE_OUT				: out std_logic;
			RX_RESETDONE_OUT				: out std_logic;
			LINK_RESET_OUT					: out std_logic; 
			drpclk_in						: in   std_logic;
			DRPADDR_IN						: in   std_logic_vector(8 downto 0);
			DRPDI_IN							: in   std_logic_vector(15 downto 0);
			DRPDO_OUT						: out  std_logic_vector(15 downto 0);
			DRPEN_IN							: in   std_logic;
			DRPRDY_OUT						: out  std_logic;
			DRPWE_IN							: in   std_logic;
			DRPADDR_IN_LANE1				: in   std_logic_vector(8 downto 0);
			DRPDI_IN_LANE1					: in   std_logic_vector(15 downto 0);
			DRPDO_OUT_LANE1				: out  std_logic_vector(15 downto 0);
			DRPEN_IN_LANE1					: in   std_logic;
			DRPRDY_OUT_LANE1				: out  std_logic;
			DRPWE_IN_LANE1					: in   std_logic;

			TX_OUT_CLK						: out std_logic;
			gt_common_reset_out			: out std_logic;
			--____________________________COMMON PORTS_______________________________{
			gt0_pll0refclklost_in		: in  std_logic;
			quad1_common_lock_in			: in  std_logic;
			------------------------- Channel - Ref Clock Ports ------------------------
			GT0_PLL0OUTCLK_IN				: in   std_logic;
			GT0_PLL1OUTCLK_IN				: in   std_logic;
			GT0_PLL0OUTREFCLK_IN			: in   std_logic;
			GT0_PLL1OUTREFCLK_IN			: in   std_logic;
			--____________________________COMMON PORTS_______________________________}

			gt0_rxlpmhfhold_in			: in   std_logic;
			gt0_rxlpmlfhold_in			: in   std_logic;
			gt0_rxlpmhfovrden_in			: in   std_logic;
			gt0_rxlpmreset_in				: in   std_logic;
			gt0_rxcdrhold_in				: in   std_logic;
			gt0_eyescanreset_in			: in   std_logic;
			-------------------------- RX Margin Analysis Ports ------------------------
			gt0_eyescandataerror_out	: out  std_logic;
			gt0_eyescantrigger_in		: in   std_logic;
			gt0_rxbyteisaligned_out		: out  std_logic;
			gt0_rxcommadet_out			: out  std_logic;
			------------------- Receive Ports - Pattern Checker Ports ------------------
			gt0_rxprbserr_out				: out  std_logic;
			gt0_rxprbssel_in				: in   std_logic_vector(2 downto 0);
			------------------- Receive Ports - Pattern Checker ports ------------------
			gt0_rxprbscntreset_in		: in   std_logic;
			------------------- Receive Ports - RX Data Path interface -----------------
			gt0_rxpcsreset_in				: in   std_logic;
			gt0_rxpmareset_in				: in   std_logic;
			gt0_rxpmaresetdone_out		: out    std_logic;
			gt0_dmonitorout_out			: out  std_logic_vector(14 downto 0);
			-------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
			gt0_rxbufreset_in				: in   std_logic;
			gt0_rxresetdone_out			: out  std_logic;
			gt0_txresetdone_out			: out  std_logic;
			gt0_txbufstatus_out			: out  std_logic_vector(1 downto 0);
			gt0_rxbufstatus_out			: out  std_logic_vector(2 downto 0);
			------------------ Transmit Ports - Pattern Generator Ports ----------------
			gt0_txprbsforceerr_in		: in   std_logic;
			gt0_txprbssel_in				: in   std_logic_vector(2 downto 0); 
			------------------- Transmit Ports - TX Data Path interface -----------------
			gt0_txpcsreset_in				: in   std_logic;
			gt0_txpmareset_in				: in   std_logic;
			------------------------ TX Configurable Driver Ports ----------------------
			gt0_txpostcursor_in			: in   std_logic_vector(4 downto 0);
			gt0_txprecursor_in			: in   std_logic_vector(4 downto 0);
			------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
			gt0_txchardispmode_in		: in   std_logic_vector(1 downto 0);
			gt0_txchardispval_in			: in   std_logic_vector(1 downto 0);
			gt0_txdiffctrl_in				: in   std_logic_vector(3 downto 0);
			gt0_txmaincursor_in			: in   std_logic_vector(6 downto 0);
			----------------- Transmit Ports - TX Polarity Control Ports ---------------
			gt0_txpolarity_in				: in   std_logic;
			gt0_rx_disp_err_out			: out  std_logic_vector(1 downto 0);
			gt0_rx_not_in_table_out		: out  std_logic_vector(1 downto 0);
			gt0_rx_realign_out			: out  std_logic;
			gt0_rx_buf_err_out			: out  std_logic;
			gt0_tx_buf_err_out			: out  std_logic;

			gt1_rxlpmhfhold_in			: in   std_logic;
			gt1_rxlpmlfhold_in			: in   std_logic;
			gt1_rxlpmhfovrden_in			: in   std_logic;
			gt1_rxlpmreset_in				: in   std_logic;
			gt1_rxcdrhold_in				: in   std_logic;
			gt1_eyescanreset_in			: in   std_logic;
			-------------------------- RX Margin Analysis Ports ------------------------
			gt1_eyescandataerror_out	: out  std_logic;
			gt1_eyescantrigger_in		: in   std_logic;
			gt1_rxbyteisaligned_out		: out  std_logic;
			gt1_rxcommadet_out			: out  std_logic;
			------------------- Receive Ports - Pattern Checker Ports ------------------
			gt1_rxprbserr_out				: out  std_logic;
			gt1_rxprbssel_in				: in   std_logic_vector(2 downto 0);
			------------------- Receive Ports - Pattern Checker ports ------------------
			gt1_rxprbscntreset_in		: in   std_logic;
			------------------- Receive Ports - RX Data Path interface -----------------
			gt1_rxpcsreset_in				: in   std_logic;
			gt1_rxpmareset_in				: in   std_logic;
			gt1_rxpmaresetdone_out		: out    std_logic;
			gt1_dmonitorout_out			: out  std_logic_vector(14 downto 0);
			-------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
			gt1_rxbufreset_in				: in   std_logic;
			gt1_rxresetdone_out			: out  std_logic;
			gt1_txresetdone_out			: out  std_logic;
			gt1_txbufstatus_out			: out  std_logic_vector(1 downto 0);
			gt1_rxbufstatus_out			: out  std_logic_vector(2 downto 0);
			------------------ Transmit Ports - Pattern Generator Ports ----------------
			gt1_txprbsforceerr_in		: in   std_logic;
			gt1_txprbssel_in				: in   std_logic_vector(2 downto 0); 
			------------------- Transmit Ports - TX Data Path interface -----------------
			gt1_txpcsreset_in				: in   std_logic;
			gt1_txpmareset_in				: in   std_logic;
			------------------------ TX Configurable Driver Ports ----------------------
			gt1_txpostcursor_in			: in   std_logic_vector(4 downto 0);
			gt1_txprecursor_in			: in   std_logic_vector(4 downto 0);
			------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
			gt1_txchardispmode_in		: in   std_logic_vector(1 downto 0);
			gt1_txchardispval_in			: in   std_logic_vector(1 downto 0);
			gt1_txdiffctrl_in				: in   std_logic_vector(3 downto 0);
			gt1_txmaincursor_in			: in   std_logic_vector(6 downto 0);
			----------------- Transmit Ports - TX Polarity Control Ports ---------------
			gt1_txpolarity_in				: in   std_logic;
			gt1_rx_disp_err_out			: out  std_logic_vector(1 downto 0);
			gt1_rx_not_in_table_out		: out  std_logic_vector(1 downto 0);
			gt1_rx_realign_out			: out  std_logic;
			gt1_rx_buf_err_out			: out  std_logic;
			gt1_tx_buf_err_out			: out  std_logic;

			sys_reset_out					: out std_logic;
			TX_LOCK							: out std_logic
		);
	end component;

	signal DRPDO_OUT						: slv16a(0 to 1);
	signal DRPRDY_OUT						: std_logic_vector(0 to 1);
	signal SOFT_ERR			: std_logic;
begin

	gtp2e_aurora_8b10b_core_inst: gtp2e_aurora_8b10b_core
		generic map(
			SIM_GTRESET_SPEEDUP			=> SIM_GTRESET_SPEEDUP
			EXAMPLE_SIMULATION			=> 0      
		)
		port map(
			S_AXI_TX_TDATA					=> TX_D,
			S_AXI_TX_TVALID				=> TX_SRC_RDY_N,
			S_AXI_TX_TREADY				=> TX_DST_RDY_N,
			M_AXI_RX_TDATA					=> RX_D,
			M_AXI_RX_TVALID				=> RX_SRC_RDY_N,
			DO_CC								=> '0',
			WARN_CC							=> '0',
			RXP								=> RXP,
			RXN								=> RXN,
			TXP								=> TXP,
			TXN								=> TXN,
			GT_REFCLK1						=> GT_REFCLK,
			HARD_ERR							=> HARD_ERR,
			SOFT_ERR							=> SOFT_ERR,
			CHANNEL_UP						=> CHANNEL_UP,
			LANE_UP							=> LANE_UP,
			user_clk							=> CLK,
			sync_clk							=> CLK,
			RESET								: in  std_logic;
			POWER_DOWN						: in  std_logic;
			LOOPBACK							=> LOOPBACK,
			GT_RESET							: in  std_logic;
			init_clk_in						=> DRP_CLK,
			PLL_NOT_LOCKED					: in  std_logic;
			TX_RESETDONE_OUT				: out std_logic;
			RX_RESETDONE_OUT				: out std_logic;
			LINK_RESET_OUT					: out std_logic; 
			drpclk_in						=> DRP_CLK,
			DRPADDR_IN						=> DRP_ADDR,
			DRPDI_IN							=> DRP_DI,
			DRPDO_OUT						=> DRPDO_OUT(0),
			DRPEN_IN							=> DRP_DEN(0),
			DRPRDY_OUT						=> DRPRDY_OUT(0),
			DRPWE_IN							=> DRP_DWE,
			DRPADDR_IN_LANE1				=> DRP_ADDR,
			DRPDI_IN_LANE1					=> DRP_DI,
			DRPDO_OUT_LANE1				=> DRPDO_OUT(1),
			DRPEN_IN_LANE1					=> DRP_DEN(1),
			DRPRDY_OUT_LANE1				=> DRPRDY_OUT(1),
			DRPWE_IN_LANE1					=> DRP_DWE,




			TX_OUT_CLK						: out std_logic;
			gt_common_reset_out			: out std_logic;
			--____________________________COMMON PORTS_______________________________{
			gt0_pll0refclklost_in		: in  std_logic;
			quad1_common_lock_in			: in  std_logic;
			------------------------- Channel - Ref Clock Ports ------------------------
			GT0_PLL0OUTCLK_IN				: in   std_logic;
			GT0_PLL1OUTCLK_IN				: in   std_logic;
			GT0_PLL0OUTREFCLK_IN			: in   std_logic;
			GT0_PLL1OUTREFCLK_IN			: in   std_logic;
			--____________________________COMMON PORTS_______________________________}

			gt0_rxlpmhfhold_in			: in   std_logic;
			gt0_rxlpmlfhold_in			: in   std_logic;
			gt0_rxlpmhfovrden_in			: in   std_logic;
			gt0_rxlpmreset_in				: in   std_logic;
			gt0_rxcdrhold_in				: in   std_logic;
			gt0_eyescanreset_in			: in   std_logic;
			-------------------------- RX Margin Analysis Ports ------------------------
			gt0_eyescandataerror_out	: out  std_logic;
			gt0_eyescantrigger_in		: in   std_logic;
			gt0_rxbyteisaligned_out		: out  std_logic;
			gt0_rxcommadet_out			: out  std_logic;
			------------------- Receive Ports - Pattern Checker Ports ------------------
			gt0_rxprbserr_out				: out  std_logic;
			gt0_rxprbssel_in				: in   std_logic_vector(2 downto 0);
			------------------- Receive Ports - Pattern Checker ports ------------------
			gt0_rxprbscntreset_in		: in   std_logic;
			------------------- Receive Ports - RX Data Path interface -----------------
			gt0_rxpcsreset_in				: in   std_logic;
			gt0_rxpmareset_in				: in   std_logic;
			gt0_rxpmaresetdone_out		: out    std_logic;
			gt0_dmonitorout_out			: out  std_logic_vector(14 downto 0);
			-------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
			gt0_rxbufreset_in				: in   std_logic;
			gt0_rxresetdone_out			: out  std_logic;
			gt0_txresetdone_out			: out  std_logic;
			gt0_txbufstatus_out			: out  std_logic_vector(1 downto 0);
			gt0_rxbufstatus_out			: out  std_logic_vector(2 downto 0);
			------------------ Transmit Ports - Pattern Generator Ports ----------------
			gt0_txprbsforceerr_in		: in   std_logic;
			gt0_txprbssel_in				: in   std_logic_vector(2 downto 0); 
			------------------- Transmit Ports - TX Data Path interface -----------------
			gt0_txpcsreset_in				: in   std_logic;
			gt0_txpmareset_in				: in   std_logic;
			------------------------ TX Configurable Driver Ports ----------------------
			gt0_txpostcursor_in			: in   std_logic_vector(4 downto 0);
			gt0_txprecursor_in			: in   std_logic_vector(4 downto 0);
			------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
			gt0_txchardispmode_in		: in   std_logic_vector(1 downto 0);
			gt0_txchardispval_in			: in   std_logic_vector(1 downto 0);
			gt0_txdiffctrl_in				: in   std_logic_vector(3 downto 0);
			gt0_txmaincursor_in			: in   std_logic_vector(6 downto 0);
			----------------- Transmit Ports - TX Polarity Control Ports ---------------
			gt0_txpolarity_in				=> TX_POLARITY(0),
			gt0_rx_disp_err_out			=> open,
			gt0_rx_not_in_table_out		=> open,
			gt0_rx_realign_out			=> open,
			gt0_rx_buf_err_out			=> open,
			gt0_tx_buf_err_out			=> open,

			gt1_rxlpmhfhold_in			: in   std_logic;
			gt1_rxlpmlfhold_in			: in   std_logic;
			gt1_rxlpmhfovrden_in			: in   std_logic;
			gt1_rxlpmreset_in				: in   std_logic;
			gt1_rxcdrhold_in				: in   std_logic;
			gt1_eyescanreset_in			: in   std_logic;
			-------------------------- RX Margin Analysis Ports ------------------------
			gt1_eyescandataerror_out	: out  std_logic;
			gt1_eyescantrigger_in		: in   std_logic;
			gt1_rxbyteisaligned_out		: out  std_logic;
			gt1_rxcommadet_out			: out  std_logic;
			------------------- Receive Ports - Pattern Checker Ports ------------------
			gt1_rxprbserr_out				: out  std_logic;
			gt1_rxprbssel_in				: in   std_logic_vector(2 downto 0);
			------------------- Receive Ports - Pattern Checker ports ------------------
			gt1_rxprbscntreset_in		: in   std_logic;
			------------------- Receive Ports - RX Data Path interface -----------------
			gt1_rxpcsreset_in				: in   std_logic;
			gt1_rxpmareset_in				: in   std_logic;
			gt1_rxpmaresetdone_out		: out    std_logic;
			gt1_dmonitorout_out			: out  std_logic_vector(14 downto 0);
			-------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
			gt1_rxbufreset_in				: in   std_logic;
			gt1_rxresetdone_out			: out  std_logic;
			gt1_txresetdone_out			: out  std_logic;
			gt1_txbufstatus_out			: out  std_logic_vector(1 downto 0);
			gt1_rxbufstatus_out			: out  std_logic_vector(2 downto 0);
			------------------ Transmit Ports - Pattern Generator Ports ----------------
			gt1_txprbsforceerr_in		: in   std_logic;
			gt1_txprbssel_in				: in   std_logic_vector(2 downto 0); 
			------------------- Transmit Ports - TX Data Path interface -----------------
			gt1_txpcsreset_in				: in   std_logic;
			gt1_txpmareset_in				: in   std_logic;
			------------------------ TX Configurable Driver Ports ----------------------
			gt1_txpostcursor_in			: in   std_logic_vector(4 downto 0);
			gt1_txprecursor_in			: in   std_logic_vector(4 downto 0);
			------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
			gt1_txchardispmode_in		: in   std_logic_vector(1 downto 0);
			gt1_txchardispval_in			: in   std_logic_vector(1 downto 0);
			gt1_txdiffctrl_in				: in   std_logic_vector(3 downto 0);
			gt1_txmaincursor_in			: in   std_logic_vector(6 downto 0);
			----------------- Transmit Ports - TX Polarity Control Ports ---------------
			gt1_txpolarity_in				=> TX_POLARITY(1),
			gt1_rx_disp_err_out			=> open,
			gt1_rx_not_in_table_out		=> open,
			gt1_rx_realign_out			=> open,
			gt1_rx_buf_err_out			=> open,
			gt1_tx_buf_err_out			=> open,

			sys_reset_out					: out std_logic;
			TX_LOCK							=> TX_LOCK
		);

	process(DRP_CLK)
	begin
		if rising_edge(DRP_CLK) then
			if DRP_DEN /= "00" then
				DRP_RDY <= '0';
			elsif DRPRDY_OUT(0) = '1' then
				DRPDO <= DRPDO_OUT(0);
				DRP_RDY <= '1';
			elsif DRPRDY_OUT(1) = '1' then
				DRPDO <= DRPDO_OUT(1);
				DRP_RDY <= '1';
			end if;
		end if;
	end process;

end process;







	signal RXENPRBSTST			: std_logic_vector(1 downto 0);
	signal RXENPRBSTST_Q			: std_logic_vector(1 downto 0);
	signal RXPRBSERR				: std_logic;
	signal RXPRBSERR_LANE1		: std_logic;
	signal TXBUFDIFFCTRL			: std_logic_vector(2 downto 0);
	signal TXBUFDIFFCTRL_LANE1	: std_logic_vector(2 downto 0);
	signal TXDIFFCTRL				: std_logic_vector(2 downto 0);
	signal TXDIFFCTRL_LANE1		: std_logic_vector(2 downto 0);
	signal TXPREEMPHASIS			: std_logic_vector(3 downto 0);
	signal TXPREEMPHASIS_LANE1	: std_logic_vector(3 downto 0);
	signal TXENPRBSTST			: std_logic_vector(1 downto 0);
	signal TXENPRBSTST_Q			: std_logic_vector(1 downto 0);
	signal TXPOLARITY				: std_logic;
	signal TXPOLARITY_LANE1		: std_logic;
	signal RXPOLARITY				: std_logic;
	signal RXPOLARITY_LANE1		: std_logic;
	signal RXEQMIX					: std_logic_vector(1 downto 0);
	signal RXEQMIX_LANE1			: std_logic_vector(1 downto 0);
	signal HARD_ERR				: std_logic_vector(0 to 1);
	signal SOFT_ERR				: std_logic_vector(0 to 1);
	signal CHANNEL_UP				: std_logic;
	signal LANE_UP					: std_logic_vector(0 to 1);
	signal RESET					: std_logic;
	signal RESET_Q					: std_logic;
	signal POWER_DOWN				: std_logic;
	signal LOOPBACK				: std_logic_vector(2 downto 0);
	signal GT_RESET				: std_logic;
	signal TX_LOCK					: std_logic;
	signal DADDR					: std_logic_vector(6 downto 0);
	signal DEN_TILE0				: std_logic;
	signal DI						: std_logic_vector(15 downto 0);
	signal DO_TILE0				: std_logic_vector(15 downto 0);
	signal DRDY_TILE0				: std_logic;
	signal DWE						: std_logic;
	signal GTX_ERR					: std_logic_vector(1 downto 0);
	signal GTXERR_RST				: std_logic;
	signal GTXERR_EN				: std_logic;
begin

	-----------------------------------
	-- Register GTX_DRP_CTRL Mapping
	-----------------------------------	
	DI <= GTX_DRP_CTRL(15 downto 0);
	DADDR <= GTX_DRP_CTRL(22 downto 16);
	DWE <= GTX_DRP_CTRL(24);
	DEN_TILE0 <= GTX_DRP_CTRL(25);
	
	-----------------------------------
	-- Register GTX_CTRL Mapping
	-----------------------------------
	POWER_DOWN <= GTX_CTRL(0);
	GT_RESET <= GTX_CTRL(1);
	LOOPBACK <= GTX_CTRL(4 downto 2);
	GTXERR_RST <= GTX_CTRL(10);
	GTXERR_EN <= GTX_CTRL(11);
	
	RXENPRBSTST <= GTX_CTRL(6 downto 5);
	TXENPRBSTST <= GTX_CTRL(8 downto 7);			
	RESET <= GTX_CTRL(9);
	
	-----------------------------------
	-- Register GTX_STATUS Mapping
	-----------------------------------
	GTX_STATUS(0) <= HARD_ERR(0);
	GTX_STATUS(1) <= HARD_ERR(1);
	GTX_STATUS(2) <= '0';
	GTX_STATUS(3) <= '0';
	GTX_STATUS(4) <= LANE_UP(0);
	GTX_STATUS(5) <= LANE_UP(1);
	GTX_STATUS(6) <= '0';
	GTX_STATUS(7) <= '0';
	GTX_STATUS(8) <= RXPOLARITY;
	GTX_STATUS(9) <= RXPOLARITY_LANE1;
	GTX_STATUS(10) <= '0';
	GTX_STATUS(11) <= '0';
	GTX_STATUS(12) <= CHANNEL_UP;
	GTX_STATUS(13) <= TX_LOCK;
	GTX_STATUS(14) <= '0';

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			if DEN_TILE0 = '1' then
				GTX_STATUS(15) <= '0';
				GTX_STATUS(31 downto 16) <= x"0000";
			elsif DRDY_TILE0 = '1' then
				GTX_STATUS(31 downto 16) <= DO_TILE0;
				GTX_STATUS(15) <= '1';
			end if;
		end if;
	end process;
	
	-----------------------------------
	-- Register GTX_CTRL_TILE0 Mapping
	-----------------------------------
	RXEQMIX					<= GTX_CTRL_TILE0(1 downto 0);
	TXPREEMPHASIS			<= GTX_CTRL_TILE0(5 downto 2);
	TXBUFDIFFCTRL			<= GTX_CTRL_TILE0(8 downto 6);
	TXDIFFCTRL				<= GTX_CTRL_TILE0(11 downto 9);

	RXEQMIX_LANE1			<= GTX_CTRL_TILE0(17 downto 16);
	TXPREEMPHASIS_LANE1	<= GTX_CTRL_TILE0(21 downto 18);
	TXBUFDIFFCTRL_LANE1	<= GTX_CTRL_TILE0(24 downto 22);
	TXDIFFCTRL_LANE1		<= GTX_CTRL_TILE0(27 downto 25);
	
	-----------------------------------
	-- Counters
	-----------------------------------	
	GTX_ERR(0) <= SOFT_ERR(0) or RXPRBSERR;
	GTX_ERR(1) <= SOFT_ERR(1) or RXPRBSERR_LANE1;
	
	Counter_ErrLane0: Counter
		generic map(
			LEN	=> 16
		)
		port map(
			CLK	=> CLK,
			RST	=> GTXERR_RST,
			EN		=> GTXERR_EN,
			INC	=> GTX_ERR(0),
			CNT	=> GTX_ERR_TILE0(15 downto 0)
		);
	
	Counter_ErrLane1: Counter
		generic map(
			LEN	=> 16
		)
		port map(
			CLK	=> CLK,
			RST	=> GTXERR_RST,
			EN		=> GTXERR_EN,
			INC	=> GTX_ERR(1),
			CNT	=> GTX_ERR_TILE0(31 downto 16)
		);

	TXPOLARITY <= '0';
	TXPOLARITY_LANE1 <= '1';

	-----------------------------------
	-- Aurora Transceivers
	-----------------------------------
	aurora_2lane_fd_str_inst: aurora_2lane_fd_str
		generic map(
			SIM_GTXRESET_SPEEDUP	=> SIM_GTXRESET_SPEEDUP
		)
		port map(
			DADDR						=> DADDR,
			DCLK						=> BUS_CLK,
			DEN_TILE0				=> DEN_TILE0,
			DI							=> DI,
			DO_TILE0					=> DO_TILE0,
			DRDY_TILE0				=> DRDY_TILE0,
			DWE						=> DWE,
			RXENPRBSTST				=> RXENPRBSTST,
			RXPRBSERR				=> RXPRBSERR,
			RXPRBSERR_LANE1		=> RXPRBSERR_LANE1,
			TXBUFDIFFCTRL			=> TXBUFDIFFCTRL,
			TXBUFDIFFCTRL_LANE1	=> TXBUFDIFFCTRL_LANE1,
			TXDIFFCTRL				=> TXDIFFCTRL,
			TXDIFFCTRL_LANE1		=> TXDIFFCTRL_LANE1,
			TXPREEMPHASIS			=> TXPREEMPHASIS,
			TXPREEMPHASIS_LANE1	=> TXPREEMPHASIS_LANE1,
			TXENPRBSTST				=> TXENPRBSTST,
			TXPOLARITY				=> TXPOLARITY,
			TXPOLARITY_LANE1		=> TXPOLARITY_LANE1,
			RXPOLARITY				=> RXPOLARITY,
			RXPOLARITY_LANE1		=> RXPOLARITY_LANE1,
			RXEQMIX					=> RXEQMIX,
			RXEQMIX_LANE1			=> RXEQMIX_LANE1,
			TX_D						=> TX_D,
			TX_SRC_RDY_N			=> TX_SRC_RDY_N,
			TX_DST_RDY_N			=> TX_DST_RDY_N,
			RX_D						=> RX_D,
			RX_SRC_RDY_N			=> RX_SRC_RDY_N,
			DO_CC						=> '0',
			WARN_CC					=> '0',
			RXP						=> RXP,
			RXN						=> RXN,
			TXP						=> TXP,
			TXN						=> TXN,
			GTXD10					=> GTXD10,
			HARD_ERR					=> HARD_ERR,
			SOFT_ERR					=> SOFT_ERR,
			CHANNEL_UP				=> CHANNEL_UP,
			LANE_UP					=> LANE_UP,
			USER_CLK					=> CLK,
			SYNC_CLK					=> CLK,
			RESET						=> RESET,
			POWER_DOWN				=> POWER_DOWN,
			LOOPBACK					=> LOOPBACK,
			GT_RESET					=> GT_RESET,
			TX_LOCK           	=> TX_LOCK
		);

end Synthesis;
