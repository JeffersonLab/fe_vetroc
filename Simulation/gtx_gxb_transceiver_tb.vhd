library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library gtp;
use gtp.all;

library vetroc;
use vetroc.all;

entity gtx_gxb_transceiver_tb is
end gtx_gxb_transceiver_tb;

architecture testbench of gtx_gxb_transceiver_tb is

	component aurora_5G is
		generic(
			STARTING_CHANNEL_NUMBER   : NATURAL;
			PMA_DIRECT                : STD_LOGIC := '0';
			SIM_GTXRESET_SPEEDUP   :integer :=   0      --Set to 1 to speed up sim reset
		);
		port(
			-- TX Stream Interface
			TX_D                 : in  std_logic_vector(0 to 31);
			TX_SRC_RDY_N         : in  std_logic;
			TX_DST_RDY_N         : out std_logic;

			-- RX Stream Interface
			RX_D                 : out std_logic_vector(0 to 31);
			RX_SRC_RDY_N         : out std_logic;

			-- Clock Correction Interface
			DO_CC               : in  std_logic;
			WARN_CC             : in  std_logic;    

			-- GTX Serial I/O
			RXP                 : in std_logic_vector(0 to 1);
			TXP                 : out std_logic_vector(0 to 1);

			--GTX Reference Clock Interface
			GTXD0       : in std_logic;

			-- Error Detection Interface
			HARD_ERR          : out std_logic_vector(0 to 1);
			SOFT_ERR          : out std_logic_vector(0 to 1);

			-- Status
			CHANNEL_UP          : out std_logic;
			LANE_UP             : out std_logic_vector(0 to 1);

			-- System Interface
			USER_CLK            : in  std_logic;
			SYNC_CLK            : in  std_logic;
			RESET               : in  std_logic;
			POWER_DOWN          : in  std_logic;
			LOOPBACK            : in  std_logic_vector(2 downto 0);
			GT_RESET            : in  std_logic;
			TX_OUT_CLK          : out std_logic;
			TX_LOCK             : out std_logic;

			--SIV Specific
			CLK50					: in std_logic;
			CAL_BLK_POWERDOWN	: in std_logic;
			CAL_BLK_BUSY		: in std_logic;
			RECONFIG_FROMGXB	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB		: in std_logic_vector(3 downto 0)
		);
	end component;

	component gt_wrapper is
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
	end component;

	signal GXB_TX_D					: std_logic_vector(0 to 31) := (others=>'0');
	signal GXB_TX_SRC_RDY_N			: std_logic := '1';
	signal GXB_TX_DST_RDY_N			: std_logic := '1';
	signal GXB_RX_D					: std_logic_vector(0 to 31) := (others=>'0');
	signal GXB_RX_SRC_RDY_N			: std_logic := '1';
	signal GXB_DO_CC					: std_logic := '0';
	signal GXB_WARN_CC				: std_logic := '0';    
	signal GXB_RXP						: std_logic_vector(0 to 1) := (others=>'0');
	signal GXB_TXP						: std_logic_vector(0 to 1) := (others=>'0');
	signal GXB_GTXD0					: std_logic := '0';
	signal GXB_HARD_ERR				: std_logic_vector(0 to 1) := (others=>'0');
	signal GXB_SOFT_ERR				: std_logic_vector(0 to 1) := (others=>'0');
	signal GXB_CHANNEL_UP			: std_logic := '0';
	signal GXB_LANE_UP				: std_logic_vector(0 to 1) := (others=>'0');
	signal GXB_USER_CLK				: std_logic := '0';
	signal GXB_SYNC_CLK				: std_logic := '0';
	signal GXB_RESET					: std_logic := '0';
	signal GXB_POWER_DOWN			: std_logic := '0';
	signal GXB_LOOPBACK				: std_logic_vector(2 downto 0) := (others=>'0');
	signal GXB_GT_RESET				: std_logic := '0';
	signal GXB_TX_OUT_CLK			: std_logic := '0';
	signal GXB_TX_LOCK				: std_logic := '0';
	signal GXB_CLK50					: std_logic := '0';
	signal GXB_CAL_BLK_POWERDOWN	: std_logic := '0';
	signal GXB_CAL_BLK_BUSY			: std_logic := '0';
	signal GXB_RECONFIG_FROMGXB	: std_logic_vector(67 downto 0) := (others=>'0');
	signal GXB_RECONFIG_TOGXB		: std_logic_vector(3 downto 0) := (others=>'0');

	signal GTX_GT_REFCLK				: std_logic := '0';
	signal GTX_RXP						: std_logic_vector(0 to 1) := (others=>'0');
	signal GTX_RXN						: std_logic_vector(0 to 1) := (others=>'0');
	signal GTX_TXP						: std_logic_vector(0 to 1) := (others=>'0');
	signal GTX_TXN						: std_logic_vector(0 to 1) := (others=>'0');
	signal GTX_CLK						: std_logic := '0';
	signal GTX_RX_D					: std_logic_vector(31 downto 0) := (others=>'0');
	signal GTX_RX_SRC_RDY_N			: std_logic := '1';
	signal GTX_TX_D					: std_logic_vector(31 downto 0) := (others=>'0');
	signal GTX_TX_SRC_RDY_N			: std_logic := '1';
	signal GTX_TX_DST_RDY_N			: std_logic := '1';
	signal GTX_DRP_CLK				: std_logic := '0';
	signal GTX_DRP_ADDR				: std_logic_vector(8 downto 0) := (others=>'0');
	signal GTX_DRP_DI					: std_logic_vector(15 downto 0) := (others=>'0');
	signal GTX_DRP_DO					: std_logic_vector(15 downto 0) := (others=>'0');
	signal GTX_DRP_DEN				: std_logic_vector(0 to 1) := (others=>'0');
	signal GTX_DRP_DWE				: std_logic := '0';
	signal GTX_DRP_RDY				: std_logic := '0';
	signal GTX_POWER_DOWN			: std_logic := '0';
	signal GTX_GT_RESET				: std_logic := '0';
	signal GTX_RESET					: std_logic := '0';
	signal GTX_LOOPBACK				: std_logic_vector(2 downto 0) := (others=>'0');
	signal GTX_PRBS_SEL				: std_logic_vector(2 downto 0) := (others=>'0');
	signal GTX_ERR_RST				: std_logic := '0';
	signal GTX_ERR_CNT				: std_logic_vector(15 downto 0) := (others=>'0');
	signal GTX_HARD_ERR				: std_logic := '0';
	signal GTX_LANE_UP				: std_logic_vector(0 to 1) := (others=>'0');
	signal GTX_CHANNEL_UP			: std_logic := '0';
	signal GTX_TX_LOCK				: std_logic := '0';
begin

	aurora_5G_inst: aurora_5G
		generic map(
			STARTING_CHANNEL_NUMBER		=> 0,
			PMA_DIRECT						=> '0',
			SIM_GTXRESET_SPEEDUP			=> 0
		)
		port map(
			TX_D					=> GXB_TX_D,
			TX_SRC_RDY_N		=> GXB_TX_SRC_RDY_N,
			TX_DST_RDY_N		=> GXB_TX_DST_RDY_N,
			RX_D					=> GXB_RX_D,
			RX_SRC_RDY_N		=> GXB_RX_SRC_RDY_N,
			DO_CC					=> GXB_DO_CC,
			WARN_CC				=> GXB_WARN_CC,
			RXP					=> GXB_RXP,
			TXP					=> GXB_TXP,
			GTXD0					=> GXB_GTXD0,
			HARD_ERR				=> GXB_HARD_ERR,
			SOFT_ERR				=> GXB_SOFT_ERR,
			CHANNEL_UP			=> GXB_CHANNEL_UP,
			LANE_UP				=> GXB_LANE_UP,
			USER_CLK				=> GXB_USER_CLK,
			SYNC_CLK				=> GXB_SYNC_CLK,
			RESET					=> GXB_RESET,
			POWER_DOWN			=> GXB_POWER_DOWN,
			LOOPBACK				=> GXB_LOOPBACK,
			GT_RESET				=> GXB_GT_RESET,
			TX_OUT_CLK			=> GXB_TX_OUT_CLK,
			TX_LOCK				=> GXB_TX_LOCK,
			CLK50					=> GXB_CLK50,
			CAL_BLK_POWERDOWN	=> GXB_CAL_BLK_POWERDOWN,
			CAL_BLK_BUSY		=> GXB_CAL_BLK_BUSY,
			RECONFIG_FROMGXB	=> GXB_RECONFIG_FROMGXB,
			RECONFIG_TOGXB		=> GXB_RECONFIG_TOGXB
		);

	gt_wrapper_inst: gt_wrapper
		generic map(
			SIM_GTRESET_SPEEDUP => "FALSE"
		)
		port map(
			GT_REFCLK			=> GTX_GT_REFCLK,
			RXP					=> GTX_RXP,
			RXN					=> GTX_RXN,
			TXP					=> GTX_TXP,
			TXN					=> GTX_TXN,
			CLK					=> GTX_CLK,
			RX_D					=> GTX_RX_D,
			RX_SRC_RDY_N		=> GTX_RX_SRC_RDY_N,
			TX_D					=> GTX_TX_D,
			TX_SRC_RDY_N		=> GTX_TX_SRC_RDY_N,
			TX_DST_RDY_N		=> GTX_TX_DST_RDY_N,
			DRP_CLK				=> GTX_DRP_CLK,
			DRP_ADDR				=> GTX_DRP_ADDR,
			DRP_DI				=> GTX_DRP_DI,
			DRP_DO				=> GTX_DRP_DO,
			DRP_DEN				=> GTX_DRP_DEN,
			DRP_DWE				=> GTX_DRP_DWE,
			DRP_RDY				=> GTX_DRP_RDY,
			POWER_DOWN			=> GTX_POWER_DOWN,
			GT_RESET				=> GTX_GT_RESET,
			RESET					=> GTX_RESET,
			LOOPBACK				=> GTX_LOOPBACK,
			PRBS_SEL				=> GTX_PRBS_SEL,
			ERR_RST				=> GTX_ERR_RST,
			ERR_CNT				=> GTX_ERR_CNT,
			HARD_ERR				=> GTX_HARD_ERR,
			LANE_UP				=> GTX_LANE_UP,
			CHANNEL_UP			=> GTX_CHANNEL_UP,
			TX_LOCK				=> GTX_TX_LOCK
		);

 	GTX_RXP <= GXB_TXP;
 	GTX_RXN <= not GXB_TXP;
 
 	GXB_RXP <= GTX_TXP;
 	--GTX_TXN

--	GTX_RXP <= GTX_TXP;
--	GTX_RXN <= GTX_TXN;

--	GXB_RXP <= GXB_TXP;

	process
	begin
		GXB_USER_CLK <= '0';
		GXB_SYNC_CLK <= '0';
		GXB_GTXD0 <= '0';
		wait for 4 ns;
		GXB_USER_CLK <= '1';
		GXB_SYNC_CLK <= '1';
		GXB_GTXD0 <= '1';
		wait for 4 ns;
	end process;

	process
	begin
		GXB_CLK50 <= '0';
		wait for 10 ns;
		GXB_CLK50 <= '1';
		wait for 10 ns;
	end process;

	process
	begin
		GXB_POWER_DOWN <= '1';
		GXB_RESET <= '1';
		GXB_GT_RESET <= '1';
		wait for 100 ns;
		wait until rising_edge(GXB_USER_CLK) and GXB_TX_LOCK = '1';
		GXB_POWER_DOWN <= '0';
		GXB_GT_RESET <= '0';

		wait for 100 ns;
		wait until rising_edge(GXB_USER_CLK);
		GXB_RESET <= '0';

		wait until GXB_CHANNEL_UP = '1';
		wait until rising_edge(GXB_USER_CLK);

		while true loop
			GXB_TX_SRC_RDY_N <= '0';
			GXB_TX_D <= GXB_TX_D + 1;
			wait until rising_edge(GXB_USER_CLK);
		end loop;
	end process;

--GXB_RX_D
--GXB_RX_SRC_RDY_N
-- GXB_TX_DST_RDY_N
-- GXB_DO_CC
-- GXB_WARN_CC
-- GXB_HARD_ERR
-- GXB_SOFT_ERR
-- GXB_LANE_UP
-- GXB_POWER_DOWN
-- GXB_LOOPBACK
-- GXB_TX_OUT_CLK
-- GXB_CAL_BLK_POWERDOWN
-- GXB_CAL_BLK_BUSY
-- GXB_RECONFIG_FROMGXB
-- GXB_RECONFIG_TOGXB

	process
	begin
		GTX_GT_REFCLK <= '0';
		GTX_CLK <= '0';
		wait for 4 ns;
		GTX_GT_REFCLK <= '1';
		GTX_CLK <= '1';
		wait for 4 ns;
	end process;

	process
	begin
		GTX_DRP_CLK <= '0';
		wait for 10 ns;
		GTX_DRP_CLK <= '1';
		wait for 10 ns;
	end process;

	process
	begin
		GTX_RESET <= '1';
--		GTX_GT_RESET <= '1';
--		GTX_POWER_DOWN <= '1';
		wait for 2 us;
		wait until rising_edge(GTX_CLK) and GTX_TX_LOCK = '1';
		GTX_GT_RESET <= '0';
		GTX_POWER_DOWN <= '0';

		wait for 100 ns;
		wait until rising_edge(GTX_CLK);
		GTX_RESET <= '0';

		wait until GTX_CHANNEL_UP = '1';
		wait until rising_edge(GTX_CLK);

		while true loop
			GTX_TX_SRC_RDY_N <= '0';
			GTX_TX_D <= GTX_TX_D + 1;
			wait until rising_edge(GTX_CLK);
		end loop;
	end process;

--GTX_RX_D
--GTX_RX_SRC_RDY_N
-- GTX_TX_DST_RDY_N
-- GTX_DRP_CLK
-- GTX_DRP_ADDR
-- GTX_DRP_DI
-- GTX_DRP_DO
-- GTX_DRP_DEN
-- GTX_DRP_DWE
-- GTX_DRP_RDY
-- GTX_POWER_DOWN
-- GTX_LOOPBACK
-- GTX_PRBS_SEL
-- GTX_ERR_RST
-- GTX_ERR_CNT
-- GTX_HARD_ERR
-- GTX_LANE_UP

end testbench;
