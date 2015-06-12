library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library utils;
use utils.utils_pkg.all;

entity gt_wrapper is
	generic(
		SIM_GTRESET_SPEEDUP			: string := "FALSE"
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
		GT_RESET			: in std_logic;
		RESET				: in std_logic;
		LOOPBACK			: in std_logic_vector(2 downto 0);
		PRBS_SEL			: in std_logic_vector(2 downto 0);
		ERR_RST			: in std_logic;
		ERR_CNT			: out std_logic_vector(15 downto 0);

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
			USER_CLK							: in  std_logic;
			SYNC_CLK							: in  std_logic;
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
			GT_COMMON_RESET_OUT			: out std_logic;
			--____________________________COMMON PORTS_______________________________{
			GT0_PLL0REFCLKLOST_IN		: in  std_logic;
			QUAD1_COMMON_LOCK_IN			: in  std_logic;
			------------------------- Channel - Ref Clock Ports ------------------------
			GT0_PLL0OUTCLK_IN				: in   std_logic;
			GT0_PLL1OUTCLK_IN				: in   std_logic;
			GT0_PLL0OUTREFCLK_IN			: in   std_logic;
			GT0_PLL1OUTREFCLK_IN			: in   std_logic;
			SYS_RESET_OUT					: out std_logic;
			TX_LOCK							: out std_logic
		);
	end component;

	signal GT_COMMON_RESET_OUT			: std_logic;
	signal GT0_PLL0REFCLKLOST_IN		: std_logic;
	signal QUAD1_COMMON_LOCK_IN		: std_logic;
	signal GT0_PLL0OUTCLK_IN			: std_logic;
	signal GT0_PLL1OUTCLK_IN			: std_logic;
	signal GT0_PLL0OUTREFCLK_IN		: std_logic;
	signal GT0_PLL1OUTREFCLK_IN		: std_logic;

	signal DRPDO_OUT						: slv16a(0 to 1);
	signal DRPRDY_OUT						: std_logic_vector(0 to 1);
	signal SOFT_ERR						: std_logic;
begin

	gtpe2_common_inst: gtpe2_common
		generic map(
			SIM_RESET_SPEEDUP		=> SIM_GTRESET_SPEEDUP,
			SIM_PLL0REFCLK_SEL	=> ("001"),
			SIM_PLL1REFCLK_SEL	=> ("001"),
			SIM_VERSION				=> ("2.0"),
			PLL0_FBDIV				=> 4,
			PLL0_FBDIV_45			=> 5,
			PLL0_REFCLK_DIV		=> 1,
			PLL1_FBDIV				=> 4,
			PLL1_FBDIV_45			=> 5,
			PLL1_REFCLK_DIV		=> 1,
			BIAS_CFG					=> (x"0000000000050001"),
			COMMON_CFG				=> (x"00000000"),
			PLL0_CFG					=> (x"01F03DC"),
			PLL0_DMON_CFG			=> ('0'),
			PLL0_INIT_CFG			=> (x"00001E"),
			PLL0_LOCK_CFG			=> (x"1E8"),
			PLL1_CFG					=> (x"01F03DC"),
			PLL1_DMON_CFG			=> ('0'),
			PLL1_INIT_CFG			=> (x"00001E"),
			PLL1_LOCK_CFG			=> (x"1E8"),
			PLL_CLKOUT_CFG			=> (x"00"),
			RSVD_ATTR0				=> (x"0000"),
			RSVD_ATTR1				=> (x"0000")
		)
		port map(
			DMONITOROUT				=> open,	
			DRPADDR					=> (others=>'0'),
			DRPCLK					=> '0',
			DRPDI						=> (others=>'0'),
			DRPDO						=> open,
			DRPEN						=> '0',
			DRPRDY					=> open,
			DRPWE						=> '0',
			BGRCALOVRDENB			=> '1',
			GTEASTREFCLK0			=> '0',
			GTEASTREFCLK1			=> '0',
			GTGREFCLK0				=> '0',
			GTGREFCLK1				=> '0',
			GTREFCLK0				=> GT_REFCLK,
			GTREFCLK1				=> '0',
			GTWESTREFCLK0			=> '0',
			GTWESTREFCLK1			=> '0',
			PLL0FBCLKLOST			=> open,
			PLL0LOCK					=> QUAD1_COMMON_LOCK_IN,
			PLL0LOCKDETCLK			=> DRP_CLK,
			PLL0LOCKEN				=> '1',
			PLL0OUTCLK				=> GT0_PLL0OUTCLK_IN,
			PLL0OUTREFCLK			=> GT0_PLL0OUTREFCLK_IN,
			PLL0PD					=> '0',
			PLL0REFCLKLOST			=> GT0_PLL0REFCLKLOST_IN,
			PLL0REFCLKSEL			=> "001",
			PLL0RESET				=> GT_COMMON_RESET_OUT,
			PLL1FBCLKLOST			=> open,
			PLL1LOCK					=> open,
			PLL1LOCKDETCLK			=> '0',
			PLL1LOCKEN				=> '1',
			PLL1OUTCLK				=> GT0_PLL1OUTCLK_IN,
			PLL1OUTREFCLK			=> GT0_PLL1OUTREFCLK_IN,
			PLL1PD					=> '1',
			PLL1REFCLKLOST			=> open,
			PLL1REFCLKSEL			=> "001",
			PLL1RESET				=> '0',
			PLLRSVD1					=> "0000000000000000",
			PLLRSVD2					=> "00000",
			PMARSVDOUT				=> open,
			REFCLKOUTMONITOR0		=> open,
			REFCLKOUTMONITOR1		=> open,
			BGBYPASSB				=> '1',
			BGMONITORENB			=> '1',
			BGPDB						=> '1',
			BGRCALOVRD				=> "11111",
			PMARSVD					=> "00000000",
			RCALENB					=> '1'
		);

	gtp2e_aurora_8b10b_core_inst: gtp2e_aurora_8b10b_core
		generic map(
			SIM_GTRESET_SPEEDUP			=> SIM_GTRESET_SPEEDUP,
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
			RESET								=> RESET,
			POWER_DOWN						=> POWER_DOWN,
			LOOPBACK							=> LOOPBACK,
			GT_RESET							=> GT_RESET,
			init_clk_in						=> DRP_CLK,
			PLL_NOT_LOCKED					=> '0',
			TX_RESETDONE_OUT				=> open,
			RX_RESETDONE_OUT				=> open,
			LINK_RESET_OUT					=> open,
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
			TX_OUT_CLK						=> open,
			GT_COMMON_RESET_OUT			=> GT_COMMON_RESET_OUT,
			GT0_PLL0REFCLKLOST_IN		=> GT0_PLL0REFCLKLOST_IN,
			QUAD1_COMMON_LOCK_IN			=> QUAD1_COMMON_LOCK_IN,
			GT0_PLL0OUTCLK_IN				=> GT0_PLL0OUTCLK_IN,
			GT0_PLL1OUTCLK_IN				=> GT0_PLL1OUTCLK_IN,
			GT0_PLL0OUTREFCLK_IN			=> GT0_PLL0OUTREFCLK_IN,
			GT0_PLL1OUTREFCLK_IN			=> GT0_PLL1OUTREFCLK_IN,
			SYS_RESET_OUT					=> open,
			TX_LOCK							=> TX_LOCK
		);

	process(DRP_CLK)
	begin
		if rising_edge(DRP_CLK) then
			if DRP_DEN /= "00" then
				DRP_DO <= x"FFFF";
				DRP_RDY <= '0';
			elsif DRPRDY_OUT(0) = '1' then
				DRP_DO <= DRPDO_OUT(0);
				DRP_RDY <= '1';
			elsif DRPRDY_OUT(1) = '1' then
				DRP_DO <= DRPDO_OUT(1);
				DRP_RDY <= '1';
			end if;
		end if;
	end process;

	counter_soft_err_inst: counter
		generic map(
			LEN	=> 16
		)
		port map(
			CLK	=> CLK,
			RST	=> ERR_RST,
			EN		=> '1',
			INC	=> SOFT_ERR,
			CNT	=> ERR_CNT
		);
	
end synthesis;
