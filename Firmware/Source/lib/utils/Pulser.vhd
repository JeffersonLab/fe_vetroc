library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Pulser is
	port(
		CLK			: in std_logic;
		
		PERIOD		: in std_logic_vector(31 downto 0);
		LOW_CYCLES	: in std_logic_vector(31 downto 0);
		
		NPULSES		: in std_logic_vector(31 downto 0);
		START		: in std_logic;
		DONE		: out std_logic;
		
		OUTPUT		: out std_logic
	);
end Pulser;

architecture Synthesis of Pulser is
	signal COUNT			: std_logic_vector(31 downto 0) := (others=>'0');
	signal COUNT_DONE		: std_logic;
	signal START_Q			: std_logic_vector(2 downto 0) := (others=>'0');
	signal START_R			: std_logic;
	signal PULSER_COUNT	: std_logic_vector(31 downto 0) := (others=>'0');
	signal PULSER_DONE	: std_logic;
	signal PULSER_OUTPUT	: std_logic := '0';
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			START_Q <= START_Q(1 downto 0) & START;
			START_R <= START_Q(1) and not START_Q(2);
			DONE <= PULSER_DONE;
			OUTPUT <= PULSER_OUTPUT;
		end if;
	end process;

	PULSER_DONE <= '0' when NPULSES = x"FFFFFFFF" else
	               '1' when PULSER_COUNT >= NPULSES else
	               '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if START_R = '1' then
				PULSER_COUNT <= (others=>'0');
			elsif COUNT_DONE = '1' and PULSER_DONE = '0' then
				PULSER_COUNT <= PULSER_COUNT + 1;
			end if;
		end if;
	end process;

	COUNT_DONE <= '1' when COUNT >= PERIOD else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if START_R = '1' or COUNT_DONE = '1' then
				COUNT <= (others=>'0');
			else
				COUNT <= COUNT + 1;
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if PULSER_DONE = '1' or COUNT < LOW_CYCLES then
				PULSER_OUTPUT <= '0';
			else
				PULSER_OUTPUT <= '1';
			end if;
		end if;
	end process;

end Synthesis;

