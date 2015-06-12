library ieee;
use ieee.std_logic_1164.all;

entity muxx8_to_1 is
	port(data_in: in std_logic_vector(0 to 7);
			 sel: in std_logic_vector(2 downto 0);
		data_out: out std_logic);
end muxx8_to_1;

architecture b1 of muxx8_to_1 is
begin
p1: process (sel,data_in)
	begin
		if sel = "000" then
			data_out <= data_in(0);
		elsif sel = "001" then
			data_out <= data_in(1);
		elsif sel = "010" then
			data_out <= data_in(2);
		elsif sel = "011" then
			data_out <= data_in(3);
		elsif sel = "100" then
			data_out <= data_in(4);
		elsif sel = "101" then
			data_out <= data_in(5);
		elsif sel = "110" then 
			data_out <= data_in(6);
		elsif sel = "111" then
			data_out <= data_in(7);
		else
			data_out <= data_in(0);
		end if;
	end process p1;
end b1;

