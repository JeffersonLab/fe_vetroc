----- 1-bit dff with clock enable and synchronous reset (negative asserted)

library ieee;
use ieee.std_logic_1164.all;

entity dffe_1s is
	port( 	  d: in std_logic;
			clk: in std_logic;
	   reset_ns: in std_logic;
		clk_ena: in std_logic;
			  q: out std_logic);
end dffe_1s;

architecture a1 of dffe_1s is
begin
p1: process (clk)
	begin
		if rising_edge(clk) then
			if reset_ns = '0' then q <= '0';
			elsif clk_ena = '1' then q <= d;
			end if;
		end if;
	end process p1;
end a1;


		