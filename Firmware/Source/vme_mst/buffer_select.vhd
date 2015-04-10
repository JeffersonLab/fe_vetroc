-- Buffer select for FADC  -  4/6/09, 5/17/10 (VHDL)  EJ" ;

library ieee;
use ieee.std_logic_1164.all;

entity buffer_select is
	port(	rd_buff_0: in std_logic;
			rd_buff_1: in std_logic;
			   stream: in std_logic;
			      clk: in std_logic;
				reset: in std_logic;
			  buff0_n: out std_logic);
end buffer_select;

architecture a1 of buffer_select is

	constant s0: std_logic  := '0';
	constant s1: std_logic  := '1';

	signal ps,ns: std_logic;
	
begin

-- buffer select state machine
-- don't change buffer assignment for D64 cycles (both rd_buff_0 & rd_buff_1 asserted) (1/10/05)
	
p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, rd_buff_0, rd_buff_1, stream)
	begin
		case ps is
			when  s0  =>
				if ( (rd_buff_0 = '1') and (rd_buff_1 = '0') and (stream = '0') ) then
					ns <= s1 ;
				else
					ns <= s0 ;
				end if;
			
			when  s1  =>
				if ( ((rd_buff_0 = '0') and (rd_buff_1 = '1')) or (stream = '1') ) then
					ns <= s0 ;
				else
					ns <= s1 ;
				end if;
			
			when others =>			
					ns <= s0;
		end case;
	end process p2;
	
	buff0_n <= ps;
		
end;
