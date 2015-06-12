----- comparator

library ieee;
use ieee.std_logic_1164.all;

entity compare is
	generic( bitlength: integer );
	port(    a,b: in std_logic_vector((bitlength - 1) downto 0);
		  a_eq_b: out std_logic;
		  a_gt_b: out std_logic;
		  a_lt_b: out std_logic);
end compare;

architecture a1 of compare is
begin
	a_eq_b <= '1' when (a = b) else
		      '0';
	a_gt_b <= '1' when (a > b) else
		      '0';
	a_lt_b <= '1' when (a < b) else
		      '0';
end a1;
