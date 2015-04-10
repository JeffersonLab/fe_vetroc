-- Data not valid flag for FADC - 4/6/09, 4/9/09; 5/18/10 (VHDL)   EJ" ;

library ieee;
use ieee.std_logic_1164.all;

entity data_not_valid is
	port( empty_buffer: in std_logic;
					le: in std_logic;
			  selected: in std_logic;
			 next_data: in std_logic;
			    go_sst: in std_logic;
			       clk: in std_logic;
				 reset: in std_logic;
			  dnv_flag: out std_logic);
end data_not_valid;

architecture a1 of data_not_valid is
							
	constant s0: std_logic  := '0';
	constant s1: std_logic  := '1';

	signal ps,ns: std_logic;
								
begin

-- data not valid state machine
-- The DNV flag is set when the empty flag of the buffer is detected.  Note that the transition from 
-- not empty to empty can only be caused by a READ of the buffer (resulting in a 'next_data' assertion).
-- The DNV flag is cleared when: 
--			(1) buffer is not empty AND no cycle is active (i.e. not selected)
--		OR	(2) buffer is not empty AND cycle active AND: (a) latch enable asserted
--													   OR (b) SST cycle AND next_data not asserted
-- These conditions assure that the DNV flag doesn't change during data output
 
p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, empty_buffer, selected, le, go_sst, next_data)
	begin
		case ps is
			when  s0  =>
				if ( empty_buffer = '1' ) then
					ns <= s1 ;
				else
					ns <= s0 ;
				end if;
			
			when  s1  =>
				if (  (empty_buffer = '0') and 
				      ( (selected = '0') or 
					    ( (selected = '1') and (le = '1') ) or 
					    ( (go_sst = '1') and (next_data = '0') ) )  ) then
					ns <= s0 ;
				else
					ns <= s1 ;
				end if;
			
			when others =>			
					ns <= s0;
		end case;
	end process p2;
	
	dnv_flag <= ps;
		
end;
