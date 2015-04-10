----- 2eVME (64-bit) VME read cycle - version x3 - EJ

----- 2/16/09, 2/18/09, 2/24/09, 2/25/09, 3/4/09, 3/5/09 
----- use latch of VME transceivers to save 2 states - 3/23/08
----- supports token passing - 5/7/09 
----- change token passing logic - 5/28/09 

library ieee;
use ieee.std_logic_1164.all;

entity e2_cycle_x3 is
	port(  go_cycle: in std_logic;
		end_of_data: in std_logic;
	   select_multi: in std_logic;
			  token: in std_logic;
			   last: in std_logic;
			as_sync: in std_logic;
			ds_sync: in std_logic;
		  ds01_sync: in std_logic;
		 ds0n1_sync: in std_logic;
				clk: in std_logic;
			  reset: in std_logic;
			  dir_a: out std_logic;
			  dir_d: out std_logic;
			en_data: out std_logic;
				ack: out std_logic;
			  retry: out std_logic;
			   berr: out std_logic;
			 ce_ap1: out std_logic;
			 ce_ap2: out std_logic;
			 ce_ap3: out std_logic;
		  next_data: out std_logic;
		  done_data: out std_logic;
			en_fill: out std_logic;
			     le: out std_logic;
		 send_token: out std_logic);
end e2_cycle_x3;

architecture a1 of e2_cycle_x3 is																																														
--                                                   --+++++++++++++
	constant   s0: std_logic_vector(14 downto 0) := "000000000000000";
	constant   s4: std_logic_vector(14 downto 0) := "010000000000000";		
	constant s101: std_logic_vector(14 downto 0) := "100000000000000";	
	constant s104: std_logic_vector(14 downto 0) := "110000000000000";

	constant   s1: std_logic_vector(14 downto 0) := "000000000000010";

	constant   s2: std_logic_vector(14 downto 0) := "000000000100000";
	constant   s6: std_logic_vector(14 downto 0) := "010000000100000";	

	constant   s3: std_logic_vector(14 downto 0) := "000000000100100";		

	constant   s5: std_logic_vector(14 downto 0) := "000000000001000";	 

	constant   s7: std_logic_vector(14 downto 0) := "000000000110001";
	constant  s14: std_logic_vector(14 downto 0) := "010000000110001";
	constant  s26: std_logic_vector(14 downto 0) := "100000000110001";
	constant  s27: std_logic_vector(14 downto 0) := "110000000110001";

	constant   s8: std_logic_vector(14 downto 0) := "000100001010001";

	constant   s9: std_logic_vector(14 downto 0) := "000100000010001";

	constant  s10: std_logic_vector(14 downto 0) := "000000000010001";
	constant s102: std_logic_vector(14 downto 0) := "010000000010001";	

	constant  s11: std_logic_vector(14 downto 0) := "000100001110001";

	constant  s12: std_logic_vector(14 downto 0) := "000100000110001";

	constant  s20: std_logic_vector(14 downto 0) := "000001000010001";
	constant s115: std_logic_vector(14 downto 0) := "010001000010001";

	constant  s21: std_logic_vector(14 downto 0) := "000001000110001";
	constant s114: std_logic_vector(14 downto 0) := "010001000110001";

	constant  s22: std_logic_vector(14 downto 0) := "000000010110001";
	constant  s23: std_logic_vector(14 downto 0) := "010000010110001";

	constant  s24: std_logic_vector(14 downto 0) := "000010110110001";
		
	constant s103: std_logic_vector(14 downto 0) := "001010000000000";	
--                                                   --+++++++++++++

	signal ps,ns: std_logic_vector(14 downto 0);
	signal dir: std_logic;
																							
begin

-- Note the condition that  'go_cycle'  is true at each transition 
-- ensures that we are aware if the master has terminated the VME cycle unexpectedly
	
p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, as_sync, ds_sync, ds01_sync, ds0n1_sync, go_cycle, select_multi, end_of_data, last, token)
	begin
		case ps is
			when  s0  =>
				if ( (as_sync = '1') and (ds0n1_sync = '1') and (go_cycle = '1') 
						and ((select_multi = '0') or ((select_multi = '1') and (token = '1'))) ) then
					ns <= s1 ;
				elsif ( (as_sync = '1') and (ds0n1_sync = '1') and (go_cycle = '1') 
						and (select_multi = '1') and (token = '0') ) then
					ns <= s101 ;
				else
					ns <= s0 ;
				end if;
			when  s1  =>
				if ( go_cycle = '1' ) then
					ns <= s2 ;
				else
					ns <= s0 ;
				end if;
			when  s2  =>									
				if ( (ds_sync = '0') and (go_cycle = '1') ) then
					ns <= s3 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s2 ;
				end if;
			when  s3  =>
				if ( go_cycle = '1' ) then
					ns <= s4 ;
				else
					ns <= s0 ;
				end if;
			when  s4  =>									
				if ( (ds0n1_sync = '1') and (go_cycle = '1') ) then
					ns <= s5 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s4 ;
				end if;
			when  s5  =>
				if ( go_cycle = '1' ) then
					ns <= s6 ;
				else
					ns <= s0 ;
				end if;
			when  s6  =>									
				if ( (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '0') ) then
					ns <= s7 ;
				elsif ( (ds01_sync = '1') and (go_cycle = '1') and (end_of_data = '1') ) then
					ns <= s22 ;
				elsif ( (ds_sync = '0') and (go_cycle = '1') ) then
					ns <= s27 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s6 ;
				end if;
			when  s7  =>
				if ( go_cycle = '1' ) then
					ns <= s8 ;
				else
					ns <= s0 ;
				end if;
			when  s8  =>									-- strobe ODD data --
				if ( go_cycle = '1' ) then
					ns <= s9 ;
				else
					ns <= s0 ;
				end if;
			when  s9  =>									-- strobe ODD data --
				if ( (ds0n1_sync = '1') and (go_cycle = '1') ) then
					ns <= s10 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s9 ;
				end if;
			when  s10  =>
				if ( (go_cycle = '1') and (end_of_data = '0') ) then
					ns <= s11 ;
				elsif ( (go_cycle = '1') and (end_of_data = '1') 
						and ((select_multi = '0') or ((select_multi = '1') and (last = '1'))) ) then
					ns <= s20 ;
				elsif ( (go_cycle = '1') and (end_of_data = '1') 
						and (select_multi = '1') and (last = '0') ) then
					ns <= s103 ;
				else
					ns <= s0 ;
				end if;
			when  s11  =>									-- strobe EVEN data --
				if ( go_cycle = '1' ) then
					ns <= s12 ;
				else
					ns <= s0 ;
				end if;
			when  s12  =>									-- strobe EVEN data --
				if ( (ds01_sync = '1') and (go_cycle = '1') ) then
					ns <= s14 ;
				elsif ( (ds_sync = '0') and (go_cycle = '1') ) then
					ns <= s26 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s12 ;
				end if;
			when  s14  =>
				if ( (go_cycle = '1') and (end_of_data = '0') ) then
					ns <= s8 ;
				elsif ( (go_cycle = '1') and (end_of_data = '1') 
						and ((select_multi = '0') or ((select_multi = '1') and (last = '1'))) ) then
					ns <= s22 ;
				elsif ( (go_cycle = '1') and (end_of_data = '1') 
						and (select_multi = '1') and (last = '0') ) then
					ns <= s114 ;
				else
					ns <= s0 ;
				end if;
			when  s20  =>
				if ( go_cycle = '1' ) then
					ns <= s21 ;
				else
					ns <= s0 ;
				end if;
			when  s21  =>									-- strobe EVEN filler data --
				if ( (ds01_sync = '1') and (go_cycle = '1') ) then
					ns <= s22 ;
				elsif ( (ds_sync = '0') and (go_cycle = '1') ) then
					ns <= s26 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s21 ;
				end if;
			when  s22  =>
					ns <= s23 ;
			when  s23  =>
					ns <= s24 ;
			when  s24  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s24 ;
				end if;
			when  s26  =>
				if ( go_cycle = '1' ) then
					ns <= s27 ;
				else
					ns <= s0 ;
				end if;
			when  s27  =>
					ns <= s0 ;

			when  s101  =>
				if ( (token = '1') and (go_cycle = '1') ) then
					ns <= s102 ;
				elsif ( (as_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s101 ;
				end if;
			when  s102  =>
				if ( (go_cycle = '1') and (end_of_data = '0') ) then
					ns <= s11 ;
				elsif ( (go_cycle = '1') and (end_of_data = '1') ) then
					ns <= s103 ;
				else
					ns <= s0 ;
				end if;
			when  s103  =>						-- send token --
					ns <= s104 ;
			when  s104  =>			
					ns <= s0 ;
				
			when  s114  =>						-- enable filler word --
				if ( go_cycle = '1' ) then
					ns <= s115 ;
				else
					ns <= s0 ;
				end if;
			when  s115  =>						-- strobe filler word --
				if ( ((ds0n1_sync = '1') or (ds_sync = '0')) and (go_cycle = '1') ) then
					ns <= s103 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s115 ;
				end if;

			when others =>
					ns <= s0;					
		end case;
	end process p2;

	send_token <= ps(12);
	le         <= ps(11);
	done_data  <= ps(10);
	en_fill    <= ps(9);
	berr       <= ps(8);
	retry      <= ps(7);
	next_data  <= ps(6);
	ack        <= ps(5);
	en_data    <= ps(4);
	ce_ap3     <= ps(3);
	ce_ap2     <= ps(2);
	ce_ap1     <= ps(1);
	dir	       <= ps(0);
	
	dir_a <= ps(0);
	dir_d <= ps(0);
			
end a1;

