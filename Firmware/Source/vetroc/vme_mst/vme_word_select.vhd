----- vme word selector for mapping words and long words

-- low_select  = '0', d_in(15..0)  -> d_out(15..0)
--				 '1', d_in(31..16) -> d_out(15..0)

-- high_select = '0', d_in(31..16) -> d_out(31..16)
--				 '1',         FFFF -> d_out(31..16)

library ieee;
use ieee.std_logic_1164.all;

entity vme_word_select is
	port( 		d_in: in std_logic_vector(31 downto 0);
		  low_select: in std_logic;
		 high_select: in std_logic;
			   d_out: out std_logic_vector(31 downto 0));
end vme_word_select;

architecture a1 of vme_word_select is

	component mux16_2_to_1 is
		port( da_in: in std_logic_vector(15 downto 0);
			  db_in: in std_logic_vector(15 downto 0);
				sel: in std_logic;
			  d_out: out std_logic_vector(15 downto 0));
	end component;
	
	constant all_ones: std_logic_vector(15 downto 0) := "1111111111111111";
	
begin

-- select low word
x1: mux16_2_to_1 port map ( da_in => d_in(15 downto 0),
							db_in => d_in(31 downto 16),
						      sel => low_select,
							d_out => d_out(15 downto 0));

-- select high word
x2: mux16_2_to_1 port map ( da_in => d_in(31 downto 16),
							db_in => all_ones,
						      sel => high_select,
							d_out => d_out(31 downto 16));

end a1;

