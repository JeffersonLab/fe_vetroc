library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity scaler is
	generic(
		LEN			: integer := 32;
		EDGE_DET		: boolean := true;
		BUFFERED		: boolean := true
	);
	port(
		CLK			: in std_logic;
		GATE			: in std_logic;
		LATCH			: in std_logic;
		RESET			: in std_logic;
		INPUT			: in std_logic;
		SCALER		: out std_logic_vector(LEN-1 downto 0)
	);
end scaler;

architecture synthesis of scaler is
	signal CNT			: std_logic_vector(LEN-1 downto 0) := (others=>'0');
	signal CNT_OVF		: std_logic;
	signal CNT_RST		: std_logic;
	signal CNT_INC		: std_logic;
	signal INPUT_Q		: std_logic_vector(2 downto 0);
	signal GATE_Q		: std_logic_vector(2 downto 0);
	signal RESET_Q		: std_logic_vector(2 downto 0);
	signal LATCH_Q		: std_logic_vector(2 downto 0);
	signal COUNT_EN	: std_logic;
begin

	EdgeGen_true: if EDGE_DET = true generate
		COUNT_EN <= INPUT_Q(1) and not INPUT_Q(2);
	end generate;

	EdgeGen_false: if EDGE_DET = false generate
		COUNT_EN <= INPUT_Q(2);
	end generate;

	bufferedGen_true: if BUFFERED = true generate
		signal CNT_LATCH	: std_logic;
	begin
		CNT_LATCH <= LATCH_Q(1) and not LATCH_Q(2);
		CNT_INC <= COUNT_EN and GATE_Q(2) and not CNT_OVF;

		process(CLK)
		begin
			if rising_edge(CLK) then
				if CNT_LATCH = '1' then
					SCALER <= CNT;
				end if;
			end if;
		end process;
	end generate;

	bufferedGen_false: if BUFFERED = false generate	
		CNT_INC <= COUNT_EN and GATE_Q(2) and not CNT_OVF and not LATCH_Q(2);
		SCALER <= CNT;
	end generate;

	CNT_RST <= RESET_Q(2) and not RESET_Q(1);

	process(CLK)
	begin
		if rising_edge(CLK) then
			GATE_Q <= GATE_Q(1 downto 0) & GATE;
			LATCH_Q <= LATCH_Q(1 downto 0) & LATCH;
			RESET_Q <= RESET_Q(1 downto 0) & RESET;
			INPUT_Q <= INPUT_Q(1 downto 0) & INPUT;
		end if;
	end process;
	
	CNT_OVF <= '1' when CNT = conv_std_logic_vector(-1, LEN) else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if CNT_RST = '1' then
				CNT <= (others=>'0');
			elsif CNT_INC = '1' then
				CNT <= CNT + 1;
			end if;
		end if;
	end process;

end synthesis;
