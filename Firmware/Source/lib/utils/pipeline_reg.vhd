library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity pipeline_reg is
	generic(
		WIDTH		: integer := 8;
		DELAY		: integer := 1
	);
	port(
		CLK		: in std_logic;
		ENABLE	: in std_logic;
			
		REG_IN	: in std_logic_vector(WIDTH-1 downto 0);
		REG_OUT	: out std_logic_vector(WIDTH-1 downto 0)
	);
end pipeline_reg;

architecture synthesis of pipeline_reg is
	type SHIFT_REG is array (DELAY downto 0) of std_logic_vector(WIDTH-1 downto 0);
	
	signal REG_DELAYS		: SHIFT_REG := (others=>(others=>'0'));
	
	attribute shreg_extract		: string;
	attribute shreg_extract of REG_DELAYS	: signal is "yes";
begin

	REG_DELAYS(0) <= REG_IN;
	REG_OUT <= REG_DELAYS(DELAY);
	
	gen_0: if DELAY /= 0 generate
		process(CLK)
		begin
			if rising_edge(CLK) then
				if ENABLE = '1' then
					REG_DELAYS(DELAY downto 1) <= REG_DELAYS(DELAY-1 downto 0);
				end if;
			end if;
		end process;
	end generate;

end synthesis;
