library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity gclkpll is
	port(
		GCLK_125_REF_RST	: in std_logic;
		CLK125F_P			: in std_logic;
		CLK125F_N			: in std_logic;
		
		GCLK_125_RESET		: out std_logic;
		GCLK_125				: out std_logic;
		GCLK_250				: out std_logic;
		GCLK_500				: out std_logic;

		GCLK_PLLLOCKED		: out std_logic
	);
end gclkpll;

architecture synthesis of gclkpll is
	signal PLLLOCKED			: std_logic;
	signal GCLK_125_RESET_Q	: std_logic_vector(7 downto 0);
	signal GCLK_125_i			: std_logic;
	signal CLKFBOUT			: std_logic;
	signal CLKFBIN				: std_logic;
	signal CLKOUT0				: std_logic;
	signal CLKOUT1				: std_logic;
	signal CLKOUT2				: std_logic;
	signal CLKOUT3				: std_logic;
	signal CLK125F				: std_logic;
begin

	IBUFGDS_inst: IBUFGDS
		generic map(
			DIFF_TERM	=> TRUE
		)
		port map(
			I	=> CLK125F_P,
			IB	=> CLK125F_N,
			O	=> CLK125F
		);

	mmcm_adv_inst: MMCME2_ADV
		generic map(
			BANDWIDTH            => "OPTIMIZED",
			CLKOUT4_CASCADE      => FALSE,
			COMPENSATION         => "ZHOLD",
			STARTUP_WAIT         => FALSE,
			DIVCLK_DIVIDE        => 1,
			CLKFBOUT_MULT_F      => 8.000,
			CLKFBOUT_PHASE       => 0.000,
			CLKFBOUT_USE_FINE_PS => FALSE,
			CLKOUT0_DIVIDE_F     => 8.000,
			CLKOUT0_PHASE        => 0.000,
			CLKOUT0_DUTY_CYCLE   => 0.5,
			CLKOUT0_USE_FINE_PS  => FALSE,
			CLKOUT1_DIVIDE       => 4,
			CLKOUT1_PHASE        => 0.000,
			CLKOUT1_DUTY_CYCLE   => 0.5,
			CLKOUT1_USE_FINE_PS  => FALSE,
			CLKOUT2_DIVIDE       => 2,
			CLKOUT2_PHASE        => 0.000,
			CLKOUT2_DUTY_CYCLE   => 0.5,
			CLKOUT2_USE_FINE_PS  => FALSE,
			CLKOUT3_DIVIDE       => 8,
			CLKOUT3_PHASE        => 0.000,
			CLKOUT3_DUTY_CYCLE   => 0.5,
			CLKOUT3_USE_FINE_PS  => FALSE,
			CLKIN1_PERIOD        => 8.000,
			REF_JITTER1          => 0.100
		)
		port map(
			CLKFBOUT             => CLKFBOUT,
			CLKFBOUTB            => open,
			CLKOUT0              => CLKOUT0,
			CLKOUT0B             => open,
			CLKOUT1              => CLKOUT1,
			CLKOUT1B             => open,
			CLKOUT2              => CLKOUT2,
			CLKOUT2B             => open,
			CLKOUT3              => open,
			CLKOUT3B             => open,
			CLKOUT4              => open,
			CLKOUT5              => open,
			CLKOUT6              => open,
			CLKFBIN              => CLKFBIN,
			CLKIN1               => CLK125F,
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
			LOCKED               => PLLLOCKED,
			CLKINSTOPPED         => open,
			CLKFBSTOPPED         => open,
			PWRDWN               => '0',
			RST                  => GCLK_125_REF_RST
		);  

	bufg_clkfb: BUFG
		port map(
			I     => CLKFBOUT,
			O     => CLKFBIN
		);

	bufg_clkout0: BUFG
		port map(
			I     => CLKOUT0,
			O     => GCLK_125_i
		);

	bufg_clkout1: BUFG
		port map(
			I     => CLKOUT1,
			O     => GCLK_250
		);

	bufg_clkout2: BUFG
		port map(
			I     => CLKOUT2,
			O     => GCLK_500
		);

	process(GCLK_125_i, PLLLOCKED)
	begin
		if PLLLOCKED = '0' then
			GCLK_125_RESET_Q <= (others=>'1');
		elsif rising_edge(GCLK_125_i) then
			GCLK_125_RESET_Q <= GCLK_125_RESET_Q(GCLK_125_RESET_Q'length-2 downto 0) & '0';
		end if;
	end process;

	GCLK_125 <= GCLK_125_i;
	GCLK_125_RESET <= GCLK_125_RESET_Q(GCLK_125_RESET_Q'length-1);

	GCLK_PLLLOCKED <= PLLLOCKED;

end synthesis;
