library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity sramclk is
	port(
		CLK			: in std_logic;
		RESET			: in std_logic;
		
		SRAM_CLK		: out std_logic;
		SRAM_CLK_O	: out std_logic;
		SRAM_CLK_I	: in std_logic;
		
		USER_CLK		: out std_logic
	);
end sramclk;

architecture synthesis of sramclk is
	signal CLK0						: std_logic;
	signal CLKFB					: std_logic;
	signal CLK_N					: std_logic;
	signal SRAM_CLK_I_bufg		: std_logic;
	signal SRAM_CLK_I_bufio2	: std_logic;
	signal CLK0_BUFG				: std_logic;
begin

	SRAM_CLK <= CLK0_BUFG;

	CLK_N <= not CLK;

	ODDR2_clk: ODDR2
		generic map(
			DDR_ALIGNMENT	=> "NONE",
			INIT			=> '0',
			SRTYPE			=> "SYNC"
		)
		port map(
			Q	=> SRAM_CLK_O,
			C0	=> CLK,
			C1	=> CLK_N,
			CE	=> '1',
			D0	=> '1',
			D1	=> '0',
			R	=> '0',
			S	=> '0'
		);

	ODDR2_SRAM_CLK: ODDR2
		generic map(
			DDR_ALIGNMENT	=> "NONE",
			INIT			=> '0',
			SRTYPE			=> "SYNC"
		)
		port map(
			Q	=> SRAM_CLK,
			C0	=> CLK,
			C1	=> CLK_N,
			CE	=> '1',
			D0	=> '1',
			D1	=> '0',
			R	=> '0',
			S	=> '0'
		);
		
	IBUFG_sramclk: IBUFG
		generic map(
			IBUF_LOW_PWR	=> TRUE,
			IOSTANDARD		=> "DEFAULT"
		)
		port map(
			I	=> SRAM_CLK_I_bufg,
			O	=> USER_CLK
		);

	BUFIO2_sramclk: BUFIO2
		generic map(
			DIVIDE			=> 1,
			DIVIDE_BYPASS	=> TRUE,
			I_INVERT			=> FALSE,
			USE_DOUBLER		=> FALSE
		)
		port map(
			DIVCLK			=> SRAM_CLK_I_bufio2,
			IOCLK				=> open,
			SERDESSTROBE	=> open,
			I					=> SRAM_CLK_I_bufg
		);

	BUFIO2FB_sramclk: BUFIO2FB
		generic map(
			DIVIDE_BYPASS => TRUE
		)
		port map(
			O	=> CLKFB,
			I	=> CLK0_BUFG 
		);
	
	BUFG_sramclk: BUFG
		port map(
			O => CLK0_BUFG,
			I => CLK0
		);
		   
	DCM_SP_inst: DCM_SP
		generic map(
			CLKDV_DIVIDE				=> 2.0,
			CLKFX_DIVIDE				=> 1,
			CLKFX_MULTIPLY				=> 2,
			CLKIN_DIVIDE_BY_2			=> FALSE,
			CLKIN_PERIOD				=> 8.0,
			CLKOUT_PHASE_SHIFT		=> "FIXED",
			CLK_FEEDBACK				=> "1X",
			DESKEW_ADJUST				=> "SYSTEM_SYNCHRONOUS",
			DFS_FREQUENCY_MODE		=> "LOW",
			DLL_FREQUENCY_MODE		=> "LOW",
			DSS_MODE						=> "NONE",
			DUTY_CYCLE_CORRECTION	=> TRUE,
			FACTORY_JF					=> X"c080",
			PHASE_SHIFT					=> -3,
			STARTUP_WAIT				=> FALSE
		)
		port map(
			CLK0			=> CLK0,
			CLK180		=> open,
			CLK270		=> open,
			CLK2X			=> open,
			CLK2X180		=> open,
			CLK90			=> open,
			CLKDV			=> open,
			CLKFX			=> open,
			CLKFX180		=> open,
			LOCKED		=> open,
			PSDONE		=> open,
			STATUS		=> open,
			CLKFB			=> CLKFB,
			CLKIN			=> SRAM_CLK_I_bufio2,
			DSSEN			=> '0',
			PSCLK			=> '0',
			PSEN			=> '0',
			PSINCDEC		=> '0',
			RST			=> RESET
		);

end synthesis;
