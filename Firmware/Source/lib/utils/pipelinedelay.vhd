library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity pipelinedelay is
	generic(
		LEN		: integer := 0
	);
	port(
		CLK		: in std_logic;
		SIN		: in std_logic;
		SOUT		: out std_logic
	);
end pipelinedelay;

architecture synthesis of pipelinedelay is
	signal SREG		: std_logic_vector(LEN downto 0);
begin

	gen0: if LEN = 0 generate
		SOUT <= SIN;
	end generate;
	
	gen1: if LEN /= 0 generate
		process(CLK, SREG, SIN)
		begin
			SOUT <= SREG(LEN-1);
			
			if rising_edge(CLK) then
				SREG <= SREG(LEN-1 downto 0) & SIN;
			end if;
		end process;
	end generate;

end synthesis;
