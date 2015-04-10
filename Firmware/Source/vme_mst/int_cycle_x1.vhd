----- interrupt acknowledge VME cycle - EJ
----- 4/22/09

library ieee;
use ieee.std_logic_1164.all;

entity int_cycle_x1 is
	port( 	 go_cycle: in std_logic;
			  ds_sync: in std_logic;
				  clk: in std_logic;
	       sysreset_n: in std_logic;
			      ack: out std_logic;
		     read_sig: out std_logic);
end int_cycle_x1;

architecture a1 of int_cycle_x1 is

	constant  s0: std_logic_vector(1 downto 0) := "00";
	constant  s1: std_logic_vector(1 downto 0) := "01";
	constant  s2: std_logic_vector(1 downto 0) := "11";		

	signal ps,ns: std_logic_vector(1 downto 0);

begin

----- VME interrupt acknowledge cycle

p1:	process (sysreset_n,clk)
	begin
		if sysreset_n = '0' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, ds_sync, go_cycle)
	begin
		case ps is
			when  s0  =>
				if ( (ds_sync = '1') and (go_cycle = '1') ) then
					ns <= s1 ;
				else
					ns <= s0 ;
				end if;
			when  s1  =>
					ns <= s2;
			when  s2  =>									
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s2 ;
				end if;

			when others =>
					ns <= s0;					
		end case;
	end process p2;

	ack      <= ps(1);
	read_sig <= ps(0);
		
end a1;

