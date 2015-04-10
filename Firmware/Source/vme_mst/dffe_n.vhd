----- generic width DFFE with reset

library ieee;
use ieee.std_logic_1164.all;

entity dffe_n is
	generic( bitlength : integer );
	port( 	  d: in std_logic_vector((bitlength - 1) downto 0);
				clk: in std_logic;
		  reset_n: in std_logic;
		  clk_ena: in std_logic;
				  q: out std_logic_vector((bitlength - 1) downto 0));
end dffe_n;

architecture a1 of dffe_n is

begin
p1: process (reset_n, clk)
	begin
		if reset_n = '0' then q <= (others => '0');
		elsif rising_edge(clk) then
			if clk_ena = '1' then q <= d;
			end if;
		end if;
	end process p1;

end a1;
