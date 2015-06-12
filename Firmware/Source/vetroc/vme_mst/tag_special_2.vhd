----- data not valid /  filler word (2eVME,2eSST) tagger -  2/24/09   EJ
----- vhdl version - 5/07/10
----- this version accepts external data for filler word and data not valid word - 9/15/10

library ieee;
use ieee.std_logic_1164.all;

entity tag_special_2 is
	port(	input: in std_logic_vector(35 downto 0);
			  dnv: in std_logic;
		 dnv_word: in std_logic_vector(31 downto 0);
		   filler: in std_logic;
	  filler_word: in std_logic_vector(31 downto 0);
		   output: out std_logic_vector(35 downto 0));
end tag_special_2;

architecture a1 of tag_special_2 is

	signal special: std_logic_vector(1 downto 0);

begin

	special <= filler & dnv;
					
	with special select
		output <= input(35 downto 0)     when "00",		-- normal data word
				  ("0000" & dnv_word)    when "01",		-- data not valid word 
				  ("0000" & filler_word) when "10",		-- filler word
				  ("0000" & filler_word) when others;	-- filler overrides data not valid 
		
end;
	