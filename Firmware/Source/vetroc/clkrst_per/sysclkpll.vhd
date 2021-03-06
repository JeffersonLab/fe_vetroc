library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity sysclkpll is
	port(
		CLK_50MHZ			: in std_logic;
		
		SYSCLK_50_RESET	: out std_logic;
		SYSCLK_50			: out std_logic;
		SYSCLK_125			: out std_logic
	);
end sysclkpll;

architecture synthesis of sysclkpll is
	signal CLK_50MHZ_IBUFG			: std_logic;
	signal SYSCLK_PLLLOCKED			: std_logic;
	signal SYSCLK_PLLRST				: std_logic;
	signal SYSCLK_50_RESET_Q		: std_logic_vector(7 downto 0);
	signal SYSCLK_50_i				: std_logic;
	signal CLKFBOUT					: std_logic;
	signal CLKOUT0						: std_logic;
	signal CLKOUT1						: std_logic;
begin

	SYSCLK_50 <= SYSCLK_50_i;
	SYSCLK_50_RESET <= SYSCLK_50_RESET_Q(SYSCLK_50_RESET_Q'length-1);

	IBUFG_inst: IBUFG
		port map(
			O	=> CLK_50MHZ_IBUFG,
			I	=> CLK_50MHZ
		);

	mmcm_adv_inst: MMCME2_ADV
		generic map(
			BANDWIDTH            => "OPTIMIZED",
			CLKOUT4_CASCADE      => FALSE,
			COMPENSATION         => "ZHOLD",
			STARTUP_WAIT         => FALSE,
			DIVCLK_DIVIDE        => 1,
			CLKFBOUT_MULT_F      => 20.000,
			CLKFBOUT_PHASE       => 0.000,
			CLKFBOUT_USE_FINE_PS => FALSE,
			CLKOUT0_DIVIDE_F     => 20.000,
			CLKOUT0_PHASE        => 0.000,
			CLKOUT0_DUTY_CYCLE   => 0.5,
			CLKOUT0_USE_FINE_PS  => FALSE,
			CLKOUT1_DIVIDE			=> 8,
			CLKOUT1_PHASE			=> 0.000,
			CLKOUT1_DUTY_CYCLE   => 0.5,
			CLKOUT1_USE_FINE_PS  => FALSE,
			CLKIN1_PERIOD        => 20.000,
			REF_JITTER1          => 0.010
		)
		port map(
			CLKFBOUT             => CLKFBOUT,
			CLKFBOUTB            => open,
			CLKOUT0              => CLKOUT0,
			CLKOUT0B             => open,
			CLKOUT1              => CLKOUT1,
			CLKOUT1B             => open,
			CLKOUT2              => open,
			CLKOUT2B             => open,
			CLKOUT3              => open,
			CLKOUT3B             => open,
			CLKOUT4              => open,
			CLKOUT5              => open,
			CLKOUT6              => open,
			CLKFBIN              => CLKFBOUT,
			CLKIN1               => CLK_50MHZ_IBUFG,
			CLKIN2               => '0',
			CLKINSEL             => '1',
			DADDR                => (others=>'0'),
			DCLK                 => '0',
			DEN                  => '0',
			DI                   => (others=>'0'),
			DO                   => open,
			DRDY                 => open,
			DWE                  => '0',
			PSCLK                => '0',
			PSEN                 => '0',
			PSINCDEC             => '0',
			PSDONE               => open,
			LOCKED               => SYSCLK_PLLLOCKED,
			CLKINSTOPPED         => open,
			CLKFBSTOPPED         => open,
			PWRDWN               => '0',
			RST                  => '0'
		);  

	bufg_clk50mhz: BUFG
		port map(
			I     => CLKOUT0,
			O     => SYSCLK_50_i
		);
		
	bufg_clk125mhz: BUFG
		port map(
			I     => CLKOUT1,
			O     => SYSCLK_125
		);

	process(SYSCLK_50_i, SYSCLK_PLLLOCKED)
	begin
		if SYSCLK_PLLLOCKED = '0' then
			SYSCLK_50_RESET_Q <= (others=>'1');
		elsif rising_edge(SYSCLK_50_i) then
			SYSCLK_50_RESET_Q <= SYSCLK_50_RESET_Q(SYSCLK_50_RESET_Q'length-2 downto 0) & '0';
		end if;
	end process;

end synthesis;
