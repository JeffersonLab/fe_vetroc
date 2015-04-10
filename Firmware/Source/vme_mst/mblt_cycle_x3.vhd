----- MBLT (64-bit) VME read cycle - EJ" 

library ieee;
use ieee.std_logic_1164.all;

entity mblt_cycle_x3 is
	port(  go_cycle: in std_logic;
			as_sync: in std_logic;
			ds_sync: in std_logic;
		  ds01_sync: in std_logic;
		end_of_data: in std_logic;
	   select_multi: in std_logic;
		      token: in std_logic;
		       last: in std_logic;
				clk: in std_logic;
		      reset: in std_logic;
			  dir_a: out std_logic;
			  dir_d: out std_logic;
			en_data: out std_logic;
			    ack: out std_logic;
			   berr: out std_logic;
		      ce_ap: out std_logic;
		  next_data: out std_logic;
		  done_data: out std_logic;
		         le: out std_logic;
		 send_token: out std_logic);
end mblt_cycle_x3;

architecture a1 of mblt_cycle_x3 is
--                                                  --+++++++++
	constant  s0: std_logic_vector(10 downto 0) := "00000000000";
	constant s21: std_logic_vector(10 downto 0) := "01000000000";
	constant s32: std_logic_vector(10 downto 0) := "10000000000";
			
	constant  s1: std_logic_vector(10 downto 0) := "00000000010";
	
	constant  s2: std_logic_vector(10 downto 0) := "00000000100";
	
	constant  s3: std_logic_vector(10 downto 0) := "00000001001";
	constant  s6: std_logic_vector(10 downto 0) := "01000001001";	
	constant s22: std_logic_vector(10 downto 0) := "10000001001";	
			
	constant  s4: std_logic_vector(10 downto 0) := "00000111101";
			
	constant  s5: std_logic_vector(10 downto 0) := "00000011101";
		 
	constant  s7: std_logic_vector(10 downto 0) := "00011001001";
		
	constant s31: std_logic_vector(10 downto 0) := "00110000000";	
--                                                  --+++++++++	
	signal ps,ns: std_logic_vector(10 downto 0);

begin

p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, as_sync, ds_sync, ds01_sync, go_cycle, select_multi, end_of_data, last, token)
	begin
		case ps is
			when s0 =>
				if( (as_sync = '1') and (ds01_sync = '1') and (go_cycle = '1') 
						and ((select_multi = '0') or ((select_multi = '1') and (token = '1')) ) ) then
					ns <= s1 ;
				elsif ( (as_sync = '1') and (ds01_sync = '1') and (go_cycle = '1') 
						and (select_multi = '1') and (token = '0') ) then
					ns <= s21 ;
				else
					ns <= s0 ;
				end if;
			
			when s1  =>									
				if ( go_cycle = '1' ) then
					ns <= s2 ;
				else
					ns <= s0 ;
				end if;

			when s2  =>									
				if ( (ds_sync = '0') and (go_cycle = '1') ) then
					ns <= s3 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s2 ;
				end if;

			when s3  =>
				if ( (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '0') ) then		
					ns <= s4 ;
				elsif ( (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '1') and 
						((select_multi = '0') or ((select_multi = '1') and (last = '1')) ) ) then	
					ns <= s7 ;
				elsif ( (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '1') and 
						(select_multi = '1') and (last = '0') ) then	
					ns <= s31 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s3 ;
				end if;

			when s4  =>
				if ( (as_sync = '0') or (go_cycle = '0') ) THEN
					ns <= s0 ;
				else
					ns <= s5 ;
				end if;
				
			when s5  =>
				if ( (as_sync  = '1')and (ds_sync = '0') and (go_cycle = '1') ) then
					ns <= s6 ;
				elsif ( (as_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s5 ;
				end if;
				
			when  s6  =>
				if ( (as_sync = '1') and (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '0') ) then
					ns <= s4 ;
				elsif ( (as_sync = '1') and (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '1') 
						and ((select_multi = '0') or ((select_multi = '1') and (last = '1'))) ) then
					ns <= s7 ;
				elsif ( (as_sync = '1') and (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '1') 
						and (select_multi = '1') and (last = '0') ) then
					ns <= s31 ;
				elsif ( (as_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s6;
				end if ;
				
			when  s7  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s7 ;
				end if;
			
			when  s21  =>
				if ( (as_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				elsif ( token = '1' ) then
					ns <= s22 ;
				else
					ns <= s21 ;
				end if;
				
			when  s22  =>
				if ( (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '0') ) then
					ns <= s4 ;
				elsif ( (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '1') ) then
					ns <= s31 ;
				elsif ( go_cycle = '0' ) then
					ns <= s31 ;
				else
					ns <= s22 ;
				end if;
				
			when  s31  =>
					ns <= s32 ;
					
			when  s32  =>
					ns <= s0 ;
					
			when others =>
					ns <= s0;					
		end case;
	end process p2;
		
	send_token <= ps(8);
	done_data  <= ps(7);
	berr       <= ps(6);
	next_data  <= ps(5);
	le         <= ps(4);
	en_data    <= ps(3);
	ack        <= ps(2);
	ce_ap      <= ps(1);
	dir_a      <= ps(0);
	dir_d      <= ps(0);

end a1;



