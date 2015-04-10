----- 36-bit DFF with reset, set

library ieee;
use ieee.std_logic_1164.all;

entity dff_36 is
	port( 	  d: in std_logic_vector(35 downto 0);
			clk: in std_logic;
		reset_n: in std_logic;
		  set_n: in std_logic;
			  q: out std_logic_vector(35 downto 0));
end dff_36;

architecture a1 of dff_36 is
begin
p1: process (reset_n,set_n,clk)
	begin
		if reset_n = '0' then q <= "000000000000000000000000000000000000";
		elsif set_n = '0' then q <= "111111111111111111111111111111111111";
		elsif rising_edge(clk) then q <= d;
		end if;
	end process p1;
end a1;


		