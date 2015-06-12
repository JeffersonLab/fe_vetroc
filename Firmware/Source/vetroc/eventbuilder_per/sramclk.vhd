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
	signal SRAM_CLK_I_IBUFG		: std_logic;
	signal CLKOUT0					: std_logic;
	signal CLKFBOUT				: std_logic;
	signal CLKFBIN					: std_logic;
	signal CLK_N					: std_logic;
begin

	mmcme2_base_inst: mmcme2_base
		generic map(
			BANDWIDTH				=> "OPTIMIZED",
			CLKFBOUT_MULT_F		=> 8.0,
			CLKFBOUT_PHASE			=> 0.0,
			CLKIN1_PERIOD			=> 8.0,
			CLKOUT0_DIVIDE_F		=> 8.0,
			CLKOUT1_DIVIDE			=> 1,
			CLKOUT2_DIVIDE			=> 1,
			CLKOUT3_DIVIDE			=> 1,
			CLKOUT4_DIVIDE			=> 1,
			CLKOUT5_DIVIDE			=> 1,
			CLKOUT6_DIVIDE			=> 1,
			CLKOUT0_DUTY_CYCLE	=> 0.5,
			CLKOUT1_DUTY_CYCLE	=> 0.5,
			CLKOUT2_DUTY_CYCLE	=> 0.5,
			CLKOUT3_DUTY_CYCLE	=> 0.5,
			CLKOUT4_DUTY_CYCLE	=> 0.5,
			CLKOUT5_DUTY_CYCLE	=> 0.5,
			CLKOUT6_DUTY_CYCLE	=> 0.5,
			CLKOUT0_PHASE			=> 0.0,
			CLKOUT1_PHASE			=> 0.0,
			CLKOUT2_PHASE			=> 0.0,
			CLKOUT3_PHASE			=> 0.0,
			CLKOUT4_PHASE			=> 0.0,
			CLKOUT5_PHASE			=> 0.0,
			CLKOUT6_PHASE			=> 0.0,
			CLKOUT4_CASCADE		=> FALSE,
			DIVCLK_DIVIDE			=> 1,
			REF_JITTER1				=> 0.1,
			STARTUP_WAIT			=> FALSE
		)
		port map(
			CLKOUT0		=> CLKOUT0,
			CLKOUT0B		=> open,
			CLKOUT1		=> open,
			CLKOUT1B		=> open,
			CLKOUT2		=> open,
			CLKOUT2B		=> open,
			CLKOUT3		=> open,
			CLKOUT3B		=> open,
			CLKOUT4		=> open,
			CLKOUT5		=> open,
			CLKOUT6		=> open,
			CLKFBOUT		=> CLKFBOUT,
			CLKFBOUTB	=> open,
			LOCKED		=> open,
			CLKIN1		=> SRAM_CLK_I_IBUFG,
			PWRDWN		=> '0',
			RST			=> RESET,
			CLKFBIN		=> CLKFBIN
		);

	IBUFG_sramclk: IBUFG
		generic map(
			IBUF_LOW_PWR	=> TRUE,
			IOSTANDARD		=> "DEFAULT"
		)
		port map(
			I	=> SRAM_CLK_I,
			O	=> SRAM_CLK_I_IBUFG
		);

	BUFG_CLKOUT0: BUFG
		port map(
			I => CLKOUT0,
			O => USER_CLK
		);

	BUFG_CLKFBOUT: BUFG
		port map(
			I => CLKFBOUT,
			O => CLKFBIN
		);

	CLK_N <= not CLK;

	ODDR2_clk: ODDR2
		generic map(
			DDR_ALIGNMENT	=> "NONE",
			INIT				=> '0',
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
			INIT				=> '0',
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

end synthesis;
