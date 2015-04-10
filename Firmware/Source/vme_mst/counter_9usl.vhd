----- 9-bit up counter with synchronous load - 3/20/09 - EJ

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter_9usl is
	port( count_up: in std_logic;
			 sload: in std_logic;
		      data: in std_logic_vector(8 downto 0);
			   clk: in std_logic;
		     reset: in std_logic;
		zero_count: out std_logic;
		 max_count: out std_logic;
		   counter: out std_logic_vector(8 downto 0));
end counter_9usl;
		
architecture a1 of counter_9usl is
														
	signal count_int: std_logic_vector(8 downto 0);
							
begin
	
p1:	process (clk, reset, sload, count_up)
	begin
		if ( reset = '1' ) then
			count_int <= "000000000";
		elsif ( rising_edge(clk) ) then
			if ( sload = '1' ) then
				count_int <= data;
			elsif ( count_up = '1' ) then
				count_int <= count_int + 1;
			else
			end if;
		end if;
	end process p1;
	
	zero_count <= '1' when (count_int = "000000000") else
				  '0';

	max_count <= '1' when (count_int = "111111111") else
				 '0';
		
	counter <= count_int;
	
END;

