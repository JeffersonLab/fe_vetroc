library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity LEDPulser is
	generic(
		LEN			: integer := 16;
		INVERT		: boolean := false;
		MIN_OFF_EN	: boolean := false;
		CONTINUOUS	: boolean := false
	);
	port(
		CLK			: in std_logic;
		INPUT			: in std_logic;
		OUTPUT		: out std_logic
	);
end LEDPulser;

architecture Synthesis of LEDPulser is
	signal COUNTER			: std_logic_vector(LEN-1 downto 0) := (others=>'0');
	signal COUNTER_DONE	: std_logic;
	signal INPUT_Q			: std_logic_vector(3 downto 0);
	signal INPUT_UP		: std_logic;
	signal OUTPUT_i		: std_logic;
begin

	process(INPUT, CLK)
	begin
		if INPUT = '1' then
			INPUT_Q(0) <= '1';
		elsif rising_edge(CLK) then
			if INPUT_Q(2) = '1' then
				INPUT_Q(0) <= '0';
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			INPUT_Q(1) <= INPUT_Q(0);
			INPUT_Q(2) <= INPUT_Q(1);
			INPUT_Q(3) <= INPUT_Q(2);
		end if;
	end process;

	COUNTER_DONE <= '1' when COUNTER = conv_std_logic_vector(2**LEN-1, LEN) else '0';

	continuous_true: if CONTINUOUS = true generate
		INPUT_UP <= '1';
	end generate;

	continuous_false: if CONTINUOUS = false generate
		INPUT_UP <= INPUT_Q(2) and not INPUT_Q(3);
	end generate;

	min_off_true: if (MIN_OFF_EN = true) or (CONTINUOUS = true) generate
		process(CLK)
		begin
			if rising_edge(CLK) then
				OUTPUT_i <= not COUNTER(LEN-1);
			end if;
		end process;
	end generate;

	min_off_false: if (MIN_OFF_EN = false) and (CONTINUOUS = false) generate
		process(CLK)
		begin
			if rising_edge(CLK) then
				OUTPUT_i <= COUNTER_DONE;
			end if;
		end process;
	end generate;

	output_invert: if INVERT = true generate
		OUTPUT <= not OUTPUT_i;
	end generate;
	
	output_true: if INVERT = false generate
		OUTPUT <= OUTPUT_i;
	end generate;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if (INPUT_UP = '1') and (COUNTER_DONE = '1') then
				COUNTER <= (others=>'0');
			elsif COUNTER_DONE = '0' then
				COUNTER <= COUNTER + 1;
			end if;
		end if;
	end process;

end Synthesis;
