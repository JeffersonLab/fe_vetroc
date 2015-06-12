----- 2 to 1 multiplexor ('bitlength' wide)

-- sel = '0', d0_in -> d_out
-- sel = '1', d1_in -> d_out 

library ieee;
use ieee.std_logic_1164.all;

entity mux2_to_1 is
	generic( bitlength: integer );
	port( d0_in: in std_logic_vector((bitlength-1) downto 0);
		  d1_in: in std_logic_vector((bitlength-1) downto 0);
			sel: in std_logic;
		  d_out: out std_logic_vector((bitlength-1) downto 0));
end mux2_to_1;

architecture a1 of mux2_to_1 is
begin
p1: process (sel, d0_in, d1_in)
	begin
		if sel = '0' then
			d_out <= d0_in;
		elsif sel = '1' then
			d_out <= d1_in;
		else
			d_out <= d0_in;
		end if;
	end process p1;
end a1;

