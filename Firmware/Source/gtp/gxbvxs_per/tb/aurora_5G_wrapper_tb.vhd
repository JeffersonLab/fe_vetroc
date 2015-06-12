library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

entity aurora_5G_wrapper_tb is
end aurora_5G_wrapper_tb;

architecture testbench of aurora_5G_wrapper_tb is
	component aurora_5G_wrapper is
		generic(
			STARTING_CHANNEL_NUMBER		: natural;
			PMA_DIRECT						: std_logic := '0';
			SIM_GTXRESET_SPEEDUP			: integer := 0;
			GTX_QUICKSIM					: boolean := false
		);
		port(
			CLK					: in std_logic;

			-- TX Stream Interface
			TX_D					: in std_logic_vector(31 downto 0);
			TX_SRC_RDY_N		: in std_logic;
			TX_DST_RDY_N		: out std_logic;

			-- RX Stream Interface
			RX_D					: out std_logic_vector(31 downto 0);
			RX_SRC_RDY_N		: out std_logic;

			-- GTX Serial I/O
			RXP					: in std_logic_vector(0 to 1);
			TXP					: out std_logic_vector(0 to 1);

			--GTX Reference Clock Interface
			GTXD0					: in std_logic;

			--SIV Specific
			CLK50					: in std_logic;
			CAL_BLK_POWERDOWN	: in std_logic;
			CAL_BLK_BUSY		: in std_logic;
			RECONFIG_FROMGXB	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB		: in std_logic_vector(3 downto 0);

			-- Registers
			GXB_CTRL				: in std_logic_vector(31 downto 0);
			GXB_STATUS			: out std_logic_vector(31 downto 0);
			GXB_ERR_TILE		: out std_logic_vector(31 downto 0);
			GXB_ERR				: out std_logic
		);
	end component;

	signal CLK						: std_logic;
	signal TX_D						: std_logic_vector(31 downto 0);
	signal TX_SRC_RDY_N			: std_logic;
	signal TX_DST_RDY_N			: std_logic;
	signal RX_D						: std_logic_vector(31 downto 0);
	signal RX_SRC_RDY_N			: std_logic;
	signal RXP						: std_logic_vector(0 to 1);
	signal TXP						: std_logic_vector(0 to 1);
	signal GTXD0					: std_logic;
	signal CLK50					: std_logic;
	signal CAL_BLK_POWERDOWN	: std_logic;
	signal CAL_BLK_BUSY			: std_logic;
	signal RECONFIG_FROMGXB		: std_logic_vector(67 downto 0);
	signal RECONFIG_TOGXB		: std_logic_vector(3 downto 0);
	signal GXB_CTRL				: std_logic_vector(31 downto 0);
	signal GXB_STATUS				: std_logic_vector(31 downto 0);
	signal GXB_ERR_TILE			: std_logic_vector(31 downto 0);
	signal GXB_ERR					: std_logic;

	signal RX_D_EXPECTED			: std_logic_vector(31 downto 0);
	signal RX_D_ERROR				: std_logic;
begin

	aurora_5G_wrapper_inst: aurora_5G_wrapper
		generic map(
			STARTING_CHANNEL_NUMBER		=> 1,
			PMA_DIRECT						=> '1',
			SIM_GTXRESET_SPEEDUP			=> 1,
			GTX_QUICKSIM					=> false
		)
		port map(
			CLK					=> CLK,
			TX_D					=> TX_D,
			TX_SRC_RDY_N		=> TX_SRC_RDY_N,
			TX_DST_RDY_N		=> TX_DST_RDY_N,
			RX_D					=> RX_D,
			RX_SRC_RDY_N		=> RX_SRC_RDY_N,
			RXP					=> RXP,
			TXP					=> TXP,
			GTXD0					=> GTXD0,
			CLK50					=> CLK50,
			CAL_BLK_POWERDOWN	=> CAL_BLK_POWERDOWN,
			CAL_BLK_BUSY		=> CAL_BLK_BUSY,
			RECONFIG_FROMGXB	=> RECONFIG_FROMGXB,
			RECONFIG_TOGXB		=> RECONFIG_TOGXB,
			GXB_CTRL				=> GXB_CTRL,
			GXB_STATUS			=> GXB_STATUS,
			GXB_ERR_TILE		=> GXB_ERR_TILE,
			GXB_ERR				=> GXB_ERR
		);

	-- Run clocks
	GTXD0 <= CLK;

	process
	begin
		CLK <= '0';
		wait for 2 ns;
		CLK <= '1';
		wait for 2 ns;
	end process;

	process
	begin
		CLK50 <= '0';
		wait for 10 ns;
		CLK50 <= '1';
		wait for 10 ns;
	end process;

	-- Loopback SerDes
	RXP(0) <= transport TXP(0) after 0 ns;
	RXP(1) <= transport TXP(1) after 20 ns;

	-- Calibration interface not used in simulation
	CAL_BLK_POWERDOWN <= '0';
	CAL_BLK_BUSY <= '0';
	--RECONFIG_FROMGXB
	RECONFIG_TOGXB <= (others=>'0');

	-- Generate transmit data sequence
	TX_SRC_RDY_N <= TX_DST_RDY_N;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if TX_DST_RDY_N = '1' then
				TX_D <= x"00000000";
			else
				TX_D <= TX_D + 1;
			end if;
		end if;
	end process;

	-- Test receive data sequence
	RX_D_ERROR <= '1' when (RX_SRC_RDY_N = '0') and (RX_D /= RX_D_EXPECTED) else '0';

	process(CLK)
		function to_string(slv : std_logic_vector) return string is
			variable result	: string(1 to slv'length);
		begin
			for I in result'range loop
				if slv(I) = '1' then
					result(I) := '1';
				elsif slv(I) = '0' then
					result(I) := '0';
				else
					result(I) := 'X';
				end if;
			end loop;

			return result;
		end to_string;
	begin
		if rising_edge(CLK) then
			if RX_SRC_RDY_N = '1' then
				RX_D_EXPECTED <= x"00000000";
			elsif RX_SRC_RDY_N = '0' then
				RX_D_EXPECTED <= RX_D_EXPECTED + 1;
			end if;

			if RX_D_ERROR = '1' then
				report "Error in receive sequence: Expected " & to_string(RX_D_EXPECTED) & ", but got " & to_string(RX_D) severity warning;
			end if;
		end if;
	end process;

	-- Configure SerDes
	process
	begin
		GXB_CTRL <= x"00000001";
		wait for 100 ns;
		wait until rising_edge(CLK);
		GXB_CTRL <= x"00000000";
		wait;
	end process;

	--GXB_STATUS
	--GXB_ERR_TILE
	--GXB_ERR

end testbench;
