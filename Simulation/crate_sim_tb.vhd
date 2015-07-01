library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library modelsim_lib;
use modelsim_lib.util.all;

library std;
use std.textio.all;
use std.standard.all;

library vetroc;
use vetroc.vetroc_pkg.all;

library gtp;
use gtp.gtp_pkg.all;

entity crate_sim_tb is
	generic(
		SSP_READOUT_EN		: std_logic := '1';
		FADC_READOUT_EN	: std_logic := '0';
		PP_TOP_FADC_EN		: std_logic_vector(15 downto 0) := x"FFFC";
		PP_BOT_FADC_EN		: std_logic_vector(15 downto 0) := x"FFFC";
		TOP_GTP_EN			: std_logic := '1';
		BOP_GTP_EN			: std_logic := '1';
		TOP_SSP_EN			: std_logic := '1';
		GTX_QUICKSIM		: boolean := true
	);
end crate_sim_tb;

architecture testbench of crate_sim_tb is
	component crate is
		generic(
			SSP_READOUT_EN		: std_logic := '0';
			FADC_READOUT_EN	: std_logic := '0';
			PP_FADC_EN			: std_logic_vector(15 downto 0) := x"FFFC";
			GTP_EN				: std_logic := '1';
			SSP_EN				: std_logic := '0';
			GTX_QUICKSIM		: boolean := false;
			EVENT_FILENAME		: string
		);
		port(
			CONFIG_DONE		: out std_logic;

			-- VXS Signal Distribution
			GLOBAL_CLK		: in std_logic;
			SYNC				: in std_logic;
			TRIG				: in std_logic;

			-- FADC inputs
			ADC_IN			: in integer_vector(0 to 255);

			-- GTP fiber
			GTP_FIBER_RX	: in std_logic_vector(0 to 3);
			GTP_FIBER_TX	: out std_logic_vector(0 to 3);

			-- SSP fiber
			SSP_FIBER_RX0	: in std_logic_vector(0 to 3);
			SSP_FIBER_TX0	: out std_logic_vector(0 to 3);

			SSP_FIBER_RX1	: in std_logic_vector(0 to 3);
			SSP_FIBER_TX1	: out std_logic_vector(0 to 3);

			SSP_FP_OUTPUT	: out std_logic_vector(4 downto 0)
		);
	end component;

	signal GLOBAL_CLK			: std_logic := '0';
	signal SYNC					: std_logic := '0';
	signal TRIG					: std_logic := '0';

	signal CONFIG_DONE_TOP	: std_logic := '0';
	signal CONFIG_DONE_BOT	: std_logic := '0';
	signal ADC_IN_TOP			: integer_vector(0 to 255) := (others=>0);
	signal ADC_IN_BOT			: integer_vector(0 to 255) := (others=>0);
	signal GTP_FIBER_RX_TOP	: std_logic_vector(0 to 3) := "0000";
	signal GTP_FIBER_RX_BOT	: std_logic_vector(0 to 3) := "0000";
	signal GTP_FIBER_TX_TOP	: std_logic_vector(0 to 3) := "0000";
	signal GTP_FIBER_TX_BOT	: std_logic_vector(0 to 3) := "0000";
	signal SSP_FP_OUTPUT		: std_logic_vector(4 downto 0);
	signal TRIGGER				: std_logic;
begin

	crate_inst1: crate
		generic map(
			SSP_READOUT_EN		=> SSP_READOUT_EN,
			FADC_READOUT_EN	=> FADC_READOUT_EN,
			PP_FADC_EN			=> PP_TOP_FADC_EN,
			GTP_EN				=> TOP_GTP_EN,
			SSP_EN				=> TOP_SSP_EN,
			GTX_QUICKSIM		=> GTX_QUICKSIM,
			EVENT_FILENAME		=> "hps1_events.txt"
		)
		port map(
			CONFIG_DONE			=> CONFIG_DONE_TOP,
			GLOBAL_CLK			=> GLOBAL_CLK,
			SYNC					=> SYNC,
			TRIG					=> TRIG,
			ADC_IN				=> ADC_IN_TOP,
			GTP_FIBER_RX		=> GTP_FIBER_RX_TOP,
			GTP_FIBER_TX		=> GTP_FIBER_TX_TOP,
			SSP_FIBER_RX0		=> GTP_FIBER_TX_TOP,
			SSP_FIBER_TX0		=> GTP_FIBER_RX_TOP,
			SSP_FIBER_RX1		=> GTP_FIBER_TX_BOT,
			SSP_FIBER_TX1		=> GTP_FIBER_RX_BOT,
			SSP_FP_OUTPUT		=> SSP_FP_OUTPUT
		);

	process
	begin
		GLOBAL_CLK <= '0';
		wait for 2 ns;
		GLOBAL_CLK <= '1';
		wait for 2 ns;
	end process;

	TRIGGER <= or_reduce(SSP_FP_OUTPUT);

	process
	begin
		TRIG <= '0';
		SYNC <= '1';
		wait until rising_edge(GLOBAL_CLK) and (CONFIG_DONE_BOT = '1') and (CONFIG_DONE_TOP = '1');
		wait for 4 us;
		SYNC <= '0';

		wait for 4 us;

		while true loop
			wait until rising_edge(TRIGGER);
			wait until rising_edge(GLOBAL_CLK);
			TRIG <= transport '1' after 944 ns;
			TRIG <= transport '0' after 1044 ns;
			wait for 1100 ns;
		end loop;
	end process;

	process
	begin
		
		wait until rising_edge(GLOBAL_CLK) and (CONFIG_DONE_BOT = '1') and (CONFIG_DONE_TOP = '1') and (SYNC = '0');
		wait for 10 us;

		wait;
	end process;

end testbench;
