-- 2-input multiplexor
--
-- sel = 0:  data_0 => data_out
--       1:  data_1 => data_out
--
library ieee;
use ieee.std_logic_1164.all;

entity mux2_to_1_old is
	port( data_0: in std_logic;
		  data_1: in std_logic;
			 sel: in std_logic;
		data_out: out std_logic);
end mux2_to_1_old;

architecture a1 of mux2_to_1_old is
begin
p1: process (sel, data_0, data_1)
	begin
		if sel = '0' then
			data_out <= data_0;
		elsif sel = '1' then
			data_out <= data_1;
		else
			data_out <= data_0;
		end if;
	end process p1;
end a1;

