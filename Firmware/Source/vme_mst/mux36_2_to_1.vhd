----- 36-bit 2 to 1 multiplexor 

-- sel = '0', da_in(35..0) -> d_out(35..0) 
-- sel = '1', db_in(35..0) -> d_out(35..0) 

library ieee;
use ieee.std_logic_1164.all;

entity mux36_2_to_1 is
	port( da_in: in std_logic_vector(35 downto 0);
		  db_in: in std_logic_vector(35 downto 0);
			sel: in std_logic;
		  d_out: out std_logic_vector(35 downto 0));
end mux36_2_to_1;

architecture a1 of mux36_2_to_1 is
begin
p1: process (sel, da_in, db_in)
	begin
		if sel = '0' then
			d_out <= da_in;
		elsif sel = '1' then
			d_out <= db_in;
		else
			d_out <= da_in;
		end if;
	end process p1;
end a1;

