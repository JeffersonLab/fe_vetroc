library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity PulseStretcher is
	generic(
		LEN			: integer := 8;
		UPDATING		: boolean := false;
		EDGE_DET		: boolean := false
	);
	port(
		CLK			: in std_logic;
		
		PULSE_IN		: in std_logic;
		PULSE_OUT	: out std_logic;
		PULSE_WIDTH	: in std_logic_vector(LEN-1 downto 0)
	);
end PulseStretcher;

architecture Synthesis of PulseStretcher is
	signal COUNTER			: std_logic_vector(LEN-1 downto 0) := (others=>'0');
	signal COUNTER_DONE	: std_logic;
	signal COUNTER_RST	: std_logic;
	signal PULSE_IN_Q		: std_logic_vector(1 downto 0);
begin

	process(PULSE_IN_Q, COUNTER_DONE)
		variable counter_rst_result	: std_logic;
	begin
		if EDGE_DET = false then
			counter_rst_result := PULSE_IN_Q(0);
		else
			counter_rst_result := PULSE_IN_Q(0) and not PULSE_IN_Q(1); 
		end if;
		
		if UPDATING = false then
			counter_rst_result := counter_rst_result and COUNTER_DONE;
		end if;
		
		COUNTER_RST <= counter_rst_result;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			PULSE_IN_Q <= PULSE_IN_Q(0) & PULSE_IN;
			PULSE_OUT <= not COUNTER_DONE;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if COUNTER_RST = '1' then
				COUNTER <= (others=>'0');
			elsif COUNTER_DONE = '0' then
				COUNTER <= COUNTER + 1;
			end if;
		end if;
	end process;
	
	COUNTER_DONE <= '1' when COUNTER > PULSE_WIDTH else '0';
	
end Synthesis;
