----- end block state machine (v3) - 9/16/10  EJ

library ieee;
use ieee.std_logic_1164.all;

entity end_block_x3 is
	port(    end_detect: in std_logic;
		  block_trailer: in std_logic;
			  next_data: in std_logic;
			  done_data: in std_logic;
				    clk: in std_logic;
	              reset: in std_logic;
		    end_of_data: out std_logic);
end end_block_x3;
	
architecture a1 of end_block_x3 is
																													
	constant s0:  std_logic := '0';
	constant s1:  std_logic := '1';
	
	signal ps,ns: std_logic;
	
begin

p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
-- 'end_detect' must be asserted for 'end_of_data' generation	
	
p2:	process (ps, end_detect, block_trailer, next_data, done_data)
	begin
		case ps is
		when  s0  =>
			if ( (end_detect = '1') and (block_trailer = '1') and (next_data = '1') ) then
				ns <= s1;
			else
				ns <= s0;
			end if;			
		when  s1  =>
			if ( done_data = '1' ) then
				ns <= s0 ;
			else
				ns <= s1 ;
			end if;		
		when others =>
				ns <= s0;
		end case;
	end process p2;
	
	end_of_data <= ps;

end a1;
	
