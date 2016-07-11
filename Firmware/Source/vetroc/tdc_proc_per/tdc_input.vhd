library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library utils;
use utils.utils_pkg.all;

entity tdc_input is
	port(
		GCLK_125				: in std_logic;
		GCLK_500				: in std_logic;

		ENABLE_N				: in std_logic;
		HIT_TRIG_WIDTH		: in std_logic_vector(7 downto 0);
		TDC_INVERT			: in std_logic;

		HIT					: in std_logic;
		HIT_TRIG				: out std_logic;
		HIT_ASYNC			: out std_logic;

		TDC_HIT				: out std_logic;
		TDC_EDGE				: out std_logic;
		TDC_HIT_OFFSET		: out std_logic_vector(2 downto 0);
		
		SCALER_LATCH		: in std_logic;
		SCALER_RESET		: in std_logic;
		TDC_SCALER			: out std_logic_vector(31 downto 0)
	);
end tdc_input;

architecture synthesis of tdc_input is
	signal SREG						: std_logic_vector(7 downto 0);
	signal SREG_Q1					: std_logic_vector(7 downto 0);
	signal SREG_Q2					: std_logic_vector(7 downto 0);
	signal RE_HIT					: std_logic;
	signal RE_OFFSET				: std_logic_vector(2 downto 0);
	signal RE						: std_logic_vector(7 downto 0);
	signal FE_HIT					: std_logic;
	signal FE_OFFSET				: std_logic_vector(2 downto 0);
	signal FE						: std_logic_vector(7 downto 0);
	signal GCLK_500_N				: std_logic;
	signal HIT_TRIG_CNT_DONE	: std_logic;
	signal HIT_TRIG_CNT			: std_logic_vector(7 downto 0);
begin

	--------------------------------
	-- TDC Scaler
	--------------------------------
	scaler_inst: scaler
		generic map(
			LEN			=> 32,
			EDGE_DET		=> false,
			BUFFERED		=> false
		)
		port map(
			CLK			=> GCLK_125,
			GATE			=> '1',
			LATCH			=> SCALER_LATCH,
			RESET			=> SCALER_RESET,
			INPUT			=> RE_HIT,
			SCALER		=> TDC_SCALER
		);

	--------------------------------
	-- TDC Channel 1GHz Sampler
	--------------------------------
	GCLK_500_N <= not GCLK_500;

	ISERDESE2_inst: ISERDESE2
		generic map(
			DATA_RATE			=> "DDR",
			DATA_WIDTH			=> 8,
			DYN_CLKDIV_INV_EN	=> "FALSE",
			DYN_CLK_INV_EN		=> "FALSE",
			INIT_Q1				=> '0',
			INIT_Q2				=> '0',
			INIT_Q3				=> '0',
			INIT_Q4				=> '0',
			INTERFACE_TYPE		=> "NETWORKING",
			IOBDELAY				=> "NONE",
			NUM_CE				=> 2,
			OFB_USED				=> "FALSE",
			SERDES_MODE			=> "MASTER",
			SRVAL_Q1				=> '0',
			SRVAL_Q2				=> '0',
			SRVAL_Q3				=> '0',
			SRVAL_Q4				=> '0' 
		)
		port map(
			O					=> HIT_ASYNC,
			Q1					=> SREG(0),
			Q2					=> SREG(1),
			Q3					=> SREG(2),
			Q4					=> SREG(3),
			Q5					=> SREG(4),
			Q6					=> SREG(5),
			Q7					=> SREG(6),
			Q8					=> SREG(7),
			SHIFTOUT1		=> open,
			SHIFTOUT2		=> open,
			BITSLIP			=> '0',
			CE1				=> '1',
			CE2				=> '1',
			CLKDIVP			=> '0',
			CLK				=> GCLK_500,
			CLKB				=> GCLK_500_N,
			CLKDIV			=> GCLK_125,
			OCLK				=> '0',
			DYNCLKDIVSEL	=> '0',
			DYNCLKSEL		=> '0',
			D					=> HIT,
			DDLY				=> '0',
			OFB				=> '0',
			OCLKB				=> '0',
			RST				=> ENABLE_N,
			SHIFTIN1			=> '0',
			SHIFTIN2			=> '0'
		);

	--------------------------------
	-- TDC Leading/Trailing Edge Detector
	--------------------------------
	process(GCLK_125)
	begin
		if rising_edge(GCLK_125) then
			SREG_Q1 <= SREG;
			SREG_Q2 <= SREG_Q1;

			if RE_HIT = '1' then
				TDC_HIT <= '1';
				TDC_EDGE <= '0';
				TDC_HIT_OFFSET <= RE_OFFSET;	
			elsif FE_HIT = '1' then
				TDC_HIT <= '1';
				TDC_EDGE <= '1';
				TDC_HIT_OFFSET <= FE_OFFSET;	
			else
				TDC_HIT <= '0';
				TDC_EDGE <= '0';
				TDC_HIT_OFFSET <= "000";
			end if;
		end if;
	end process;
	
	RE_HIT <= or_reduce(RE); 
	FE_HIT <= or_reduce(FE); 

	process(TDC_INVERT, SREG_Q2, SREG_Q1)
	begin
		if TDC_INVERT = '1' then
			RE(0) <= SREG_Q2(4) and (not SREG_Q2(3));
			RE(1) <= SREG_Q2(3) and (not SREG_Q2(2));
			RE(2) <= SREG_Q2(2) and (not SREG_Q2(1));
			RE(3) <= SREG_Q2(1) and (not SREG_Q2(0));
			RE(4) <= SREG_Q2(0) and (not SREG_Q1(7));
			RE(5) <= SREG_Q1(7) and (not SREG_Q1(6));
			RE(6) <= SREG_Q1(6) and (not SREG_Q1(5));
			RE(7) <= SREG_Q1(5) and (not SREG_Q1(4));
	
			FE(0) <= (not SREG_Q2(4)) and SREG_Q2(3);
			FE(1) <= (not SREG_Q2(3)) and SREG_Q2(2);
			FE(2) <= (not SREG_Q2(2)) and SREG_Q2(1);
			FE(3) <= (not SREG_Q2(1)) and SREG_Q2(0);
			FE(4) <= (not SREG_Q2(0)) and SREG_Q1(7);
			FE(5) <= (not SREG_Q1(7)) and SREG_Q1(6);
			FE(6) <= (not SREG_Q1(6)) and SREG_Q1(5);
			FE(7) <= (not SREG_Q1(5)) and SREG_Q1(4);
		else
			RE(0) <= (not SREG_Q2(4)) and SREG_Q2(3);
			RE(1) <= (not SREG_Q2(3)) and SREG_Q2(2);
			RE(2) <= (not SREG_Q2(2)) and SREG_Q2(1);
			RE(3) <= (not SREG_Q2(1)) and SREG_Q2(0);
			RE(4) <= (not SREG_Q2(0)) and SREG_Q1(7);
			RE(5) <= (not SREG_Q1(7)) and SREG_Q1(6);
			RE(6) <= (not SREG_Q1(6)) and SREG_Q1(5);
			RE(7) <= (not SREG_Q1(5)) and SREG_Q1(4);
	
			FE(0) <= SREG_Q2(4) and (not SREG_Q2(3));
			FE(1) <= SREG_Q2(3) and (not SREG_Q2(2));
			FE(2) <= SREG_Q2(2) and (not SREG_Q2(1));
			FE(3) <= SREG_Q2(1) and (not SREG_Q2(0));
			FE(4) <= SREG_Q2(0) and (not SREG_Q1(7));
			FE(5) <= SREG_Q1(7) and (not SREG_Q1(6));
			FE(6) <= SREG_Q1(6) and (not SREG_Q1(5));
			FE(7) <= SREG_Q1(5) and (not SREG_Q1(4));
		end if;
	end process;

	-- Encode 1ns offset inside 8ns period
	RE_OFFSET <= "000" when RE(0) = '1' else
	             "001" when RE(1) = '1' else
	             "010" when RE(2) = '1' else
	             "011" when RE(3) = '1' else
	             "100" when RE(4) = '1' else
	             "101" when RE(5) = '1' else
	             "110" when RE(6) = '1' else
	             "111";

	FE_OFFSET <= "000" when FE(0) = '1' else
	             "001" when FE(1) = '1' else
	             "010" when FE(2) = '1' else
	             "011" when FE(3) = '1' else
	             "100" when FE(4) = '1' else
	             "101" when FE(5) = '1' else
	             "110" when FE(6) = '1' else
	             "111";

	--------------------------------
	-- Trigger Pulser Width Generator
	--------------------------------
	HIT_TRIG_CNT_DONE <= '1' when HIT_TRIG_CNT = conv_std_logic_vector(0, HIT_TRIG_CNT'length) else '0';
	
	process(GCLK_125)
	begin
		if rising_edge(GCLK_125) then
			HIT_TRIG <= not HIT_TRIG_CNT_DONE;
		
			if RE_HIT = '1' then
				HIT_TRIG_CNT <= HIT_TRIG_WIDTH;
			elsif HIT_TRIG_CNT_DONE = '0' then
				HIT_TRIG_CNT <= HIT_TRIG_CNT - 1;
			end if;
		end if;
	end process;

end synthesis;

