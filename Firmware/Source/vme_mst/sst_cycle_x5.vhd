----- 2eSST (64-bit) VME read cycle - EJ

----- 8/24/11 - supports token passing

library ieee;
use ieee.std_logic_1164.all;

entity sst_cycle_x5 is
	port(  go_cycle: in std_logic;
		    rate_ok: in std_logic;
		end_of_data: in std_logic;
		 stop_cycle: in std_logic;
	   select_multi: in std_logic;
		      token: in std_logic;
		       last: in std_logic;
			as_sync: in std_logic;
			ds_sync: in std_logic;
		  ds01_sync: in std_logic;
		 ds0n1_sync: in std_logic;
			 ack_in: in std_logic;
			berr_in: in std_logic;
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
		 count_word: out std_logic;
		  done_data: out std_logic;
		    en_fill: out std_logic;
		 send_token: out std_logic;
		  sst_state: out std_logic_vector(16 downto 0));
end sst_cycle_x5;

architecture a1 of sst_cycle_x5 is																																														
--                                                    ----+++++++++++++
	constant    s0: std_logic_vector(16 downto 0) := "00000000000000000";	-- 0x00000
	constant    s4: std_logic_vector(16 downto 0) := "00010000000000000";	-- 0x02000
	constant s1001: std_logic_vector(16 downto 0) := "00100000000000000";	-- 0x04000
	constant  s134: std_logic_vector(16 downto 0) := "00110000000000000";	-- 0x06000
	constant  s135: std_logic_vector(16 downto 0) := "01000000000000000";	-- 0x08000
	constant  s102: std_logic_vector(16 downto 0) := "01010000000000000";	-- 0x0A000 t
	constant s1003: std_logic_vector(16 downto 0) := "01100000000000000";	-- 0x0C000 t
	constant  s104: std_logic_vector(16 downto 0) := "01110000000000000";	-- 0x0E000 t
	constant s1005: std_logic_vector(16 downto 0) := "10000000000000000";	-- 0x10000 t 
	constant  s106: std_logic_vector(16 downto 0) := "10010000000000000";	-- 0x12000 t
	constant  s722: std_logic_vector(16 downto 0) := "10100000000000000";	-- 0x14000 t
	constant  s155: std_logic_vector(16 downto 0) := "10110000000000000";	-- 0x16000 t
	constant s1009: std_logic_vector(16 downto 0) := "11000000000000000";	-- 0x18000 t

	constant    s1: std_logic_vector(16 downto 0) := "00000000000000010";	-- 0x00002
	constant  s101: std_logic_vector(16 downto 0) := "00010000000000010";	-- 0x02002 t

	constant    s2: std_logic_vector(16 downto 0) := "00000000000100000";	-- 0x00020
	constant    s6: std_logic_vector(16 downto 0) := "00010000000100000";	-- 0x02020

	constant    s3: std_logic_vector(16 downto 0) := "00000000000100100";	-- 0x00024

	constant    s5: std_logic_vector(16 downto 0) := "00000000000001000";	-- 0x00008
	constant  s105: std_logic_vector(16 downto 0) := "00010000000001000";	-- 0x02008 t 

	constant   s55: std_logic_vector(16 downto 0) := "00000000100000000";	-- 0x00100

	constant    s7: std_logic_vector(16 downto 0) := "00000000001110001";	-- 0x00071
	constant   s14: std_logic_vector(16 downto 0) := "00010000001110001";	-- 0x02071

	constant    s9: std_logic_vector(16 downto 0) := "00000000000010001";	-- 0x00011
	constant  s130: std_logic_vector(16 downto 0) := "00010000000010001";	-- 0x02011
	constant  s131: std_logic_vector(16 downto 0) := "00100000000010001";	-- 0x04011
	constant s1010: std_logic_vector(16 downto 0) := "00110000000010001";	-- 0x06011 t
	constant s1011: std_logic_vector(16 downto 0) := "01000000000010001";	-- 0x08011 t

	constant   s10: std_logic_vector(16 downto 0) := "00000000001010001";	-- 0x00051

	constant   s12: std_logic_vector(16 downto 0) := "00000000000110001";	-- 0x00031
	constant   s22: std_logic_vector(16 downto 0) := "00010000000110001";	-- 0x02031
	constant   s23: std_logic_vector(16 downto 0) := "00100000000110001";	-- 0x04031
	constant   s27: std_logic_vector(16 downto 0) := "00110000000110001";	-- 0x06031
	constant  s121: std_logic_vector(16 downto 0) := "01000000000110001";	-- 0x08031

	constant   s20: std_logic_vector(16 downto 0) := "00000001000010001";	-- 0x00211
	constant  s129: std_logic_vector(16 downto 0) := "00010001000010001";	-- 0x02211

	constant   s21: std_logic_vector(16 downto 0) := "00000001000110001";	-- 0x00231
	constant  s128: std_logic_vector(16 downto 0) := "00010001000110001";	-- 0x02231

	constant   s24: std_logic_vector(16 downto 0) := "00000010100110001";	-- 0x00531

	constant   s32: std_logic_vector(16 downto 0) := "00000000010110001";	-- 0x000B1
	constant   s33: std_logic_vector(16 downto 0) := "00010000010110001";	-- 0x020B1

	constant   s34: std_logic_vector(16 downto 0) := "00000000110110001";	-- 0x001B1	
	constant   s35: std_logic_vector(16 downto 0) := "00010000110110001";	-- 0x021B1
	
	constant   s36: std_logic_vector(16 downto 0) := "00010010110110001";	-- 0x025B1
	
	constant  s132: std_logic_vector(16 downto 0) := "00000100000000000";	-- 0x00800
	constant  s336: std_logic_vector(16 downto 0) := "00010100000000000";	-- 0x02800
	
	constant  s133: std_logic_vector(16 downto 0) := "00000110000000000";	-- 0x00C00

	
	constant  s103: std_logic_vector(16 downto 0) := "00000000000000100";	-- 0x00004 t
	
	constant  s109: std_logic_vector(16 downto 0) := "00001000000000000";	-- 0x01000 t
	constant s1012: std_logic_vector(16 downto 0) := "00011000000000000";	-- 0x03000 t	
--                                                    ----+++++++++++++
				
	signal ps,ns: std_logic_vector(16 downto 0);
	signal dir: std_logic;
																							
begin

----- Note the condition that  'go_cycle'  is true at each transition
----- ensures that we are aware if the master has terminated the VME cycle unexpectedly
	
p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, as_sync, ds_sync, ds01_sync, ds0n1_sync, go_cycle, select_multi, 
				end_of_data, last, token, rate_ok, stop_cycle, ack_in, berr_in )
	begin
		case ps is
			when  s0  =>
				if ( (as_sync = '1') and (ds0n1_sync = '1') and (go_cycle = '1') 
						and ((select_multi = '0') or ((select_multi = '1') and (token = '1'))) ) then
					ns <= s1 ;
				elsif ( (as_sync = '1') and (ds0n1_sync = '1') and (go_cycle = '1') 
						and ((select_multi = '1') and (token = '0')) ) then
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
				if ( (go_cycle = '1') and (rate_ok = '1') ) then
					ns <= s6 ;
				elsif ( (go_cycle = '1') and (rate_ok = '0') ) then
					ns <= s55 ;
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
			when  s7  =>			----- next_data asserted early to compensate for register in data path
				if ( go_cycle = '1' ) then
					ns <= s9 ;
				else
					ns <= s0 ;
				end if;						
			when  s9  =>									-- strobe ODD data
				if ( (go_cycle = '1') and (end_of_data = '0')  ) then
					ns <= s10 ;
				elsif ( ((go_cycle = '1') and (end_of_data = '1') and (select_multi = '0')) 
					 or ((go_cycle = '1') and (end_of_data = '1') and (select_multi = '1') and (last = '1')) ) then
					ns <= s20 ;
				elsif ( ((go_cycle = '1') and (end_of_data = '1') and (select_multi = '1') and (last = '0')) ) then
					ns <= s130 ;
				elsif ( go_cycle = '0' ) then
					ns <= s0 ;
				else
					ns <= s9 ;
				end if;						
			when  s10  =>			----- next_data asserted early to compensate for register in data path								
				if ( go_cycle = '1' ) then
					ns <= s12 ;
				else
					ns <= s0 ;
				end if;
			when  s12  =>			----- strobe EVEN data
				if ( (go_cycle = '1') and (end_of_data = '0') and (stop_cycle = '0') ) then
					ns <= s14 ;
				elsif ( (go_cycle = '1') and (stop_cycle = '1') and 
					  ( ((select_multi = '0') and (end_of_data = '0')) or 
							((select_multi = '1') and (end_of_data = '1') and (last = '0')) ) ) then
					ns <= s32 ;
				elsif ( (go_cycle = '1') and (end_of_data = '1') 
						and ((select_multi = '0') or ((select_multi = '1') and (last = '1'))) ) then
					ns <= s22 ;
				elsif ( (go_cycle = '1') and (end_of_data = '1') and (select_multi = '1') 
						and (stop_cycle = '0') and (last = '0') ) then
					ns <= s128 ;
				elsif ( (go_cycle = '1') and (end_of_data = '0') and (select_multi = '1') 
						and (stop_cycle = '1') ) then
					ns <= s32 ;
				else
					ns <= s0 ;
				end if;			
			when  s14  =>			----- next_data asserted early to compensate for register in data path						
				if ( go_cycle = '1' ) then
					ns <= s9 ;
				else
					ns <= s0 ;
				end if;
			when  s20  =>
				if ( go_cycle = '1' ) then
					ns <= s21 ;
				else
					ns <= s0 ;
				end if;
			when  s21  =>			----- strobe EVEN filler data
				if ( go_cycle = '1' ) then
					ns <= s121 ;
				else
					ns <= s0 ;
				end if;
			when  s121  =>								
				if ( (go_cycle = '1') and ((select_multi = '0') or ((select_multi = '1') 
						and (last = '1'))) ) then
					ns <= s22 ;
				elsif ( (go_cycle = '1') and (select_multi = '1') and (last = '0') ) then
					ns <= s132 ;
				else
					ns <= s0 ;
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
			
			when  s32  =>
					ns <= s33 ;
			when  s33  =>
					ns <= s34 ;
			when  s34  =>
				if ( (go_cycle = '1') and (select_multi = '1') and (end_of_data = '1')) then
					ns <= s36 ;
				else
					ns <= s35 ;
				end if;
			
			when  s35  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s35 ;
				end if;
			
			when  s36  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s336 ;
				else
					ns <= s36 ;
				end if;
			
			when  s27  =>
					ns <= s0 ;

			when  s55  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s55 ;
				end if;
			
			
			when  s128  =>					
					ns <= s129 ;
			when  s129  =>			
					ns <= s130 ;
					
			when  s130  =>			----- token passing			
					ns <= s131 ;
			when  s131  =>			
					ns <= s133 ;
					
			when  s133  =>			----- send token
				ns <= s134 ;				
					
			when  s336  =>			----- send token
					ns <= s134 ;
					
			when  s134  =>			----- and wait a little so that we realize token is no longer ours
					ns <= s135 ;
			when  s135  =>
					ns <= s0 ;
					
		----------------------------------------------------------------------------------------------------------
		----- multiboard cycle without token - listen, count words, and wait for token			
			when  s101  =>			----- assert 'ce_ap1' to load starting address of SST cycle			
				if ( (go_cycle = '1') ) then
					ns <= s1001;
				else
					ns <= s0 ;
				end if;

			when  s1001  =>			----- follow SST address phases (no acknowlege)			
				if ( (as_sync = '1') and (ack_in = '1') ) then
					ns <= s102 ;
				elsif ( (as_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s1001 ;
				end if;

			when  s102  =>
				if ( (go_cycle = '1') and (ds_sync = '0') ) then
					ns <= s103 ;
				elsif ( (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s102 ;
				end if;

			when  s103  =>			----- assert 'ce_ap2' to load word count expected of SST cycle
				if ( (go_cycle = '1') ) then
					ns <= s1003 ;
				else
					ns <= s0 ;
				end if;
				
			when  s1003  =>
				if ( (go_cycle = '1') and (ack_in = '0') ) then
					ns <= s104 ;
				elsif ( (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s1003 ;
				end if;
				
			when  s104  =>
				if ( (go_cycle = '1') and (ds0n1_sync = '1') ) then
					ns <= s105 ;
				elsif ( (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s104 ;
				end if;

			when  s105  =>			----- assert 'ce_ap3' for SST cycle
				if ( (go_cycle = '1') ) then
					ns <= s1005 ;
				else
					ns <= s0 ;
				end if;

			when  s1005  =>
				if ( (go_cycle = '1') and (ack_in = '1') ) then
					ns <= s106 ;
				elsif ( (go_cycle = '1') and (berr_in = '1') ) then
					ns <= s155 ;
				elsif ( (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s1005 ;
				end if;

			when  s106  =>
				if ( (go_cycle = '1') and (ds01_sync = '1') ) then
					ns <= s722 ;
				elsif ( (go_cycle = '1') and (berr_in = '1') ) then
					ns <= s155 ;
				elsif ( (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s106 ;
				end if;

			when  s722  =>
				if ( (go_cycle = '1') and (ack_in = '0') ) then
					ns <= s109 ;
				elsif ( (go_cycle = '1') and (berr_in = '1') and (ack_in = '1') ) then
					ns <= s155 ;
				elsif ( (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s722 ;
				end if;

			when  s109  =>						-- count ODD word
				if ( (go_cycle = '1') ) then
					ns <= s1009 ;
				else
					ns <= s0 ;
				end if;

			when  s1009  =>
				if ( (go_cycle = '1') and (ack_in = '1') and (token = '0') ) then
					ns <= s1012 ;
				elsif ( (token = '1') ) then
					ns <= s1010 ;
				else
					ns <= s1009 ;
				end if;

			when  s1012  =>						-- count EVEN word
				if ( (go_cycle = '1') ) then
					ns <= s722 ;
				else
					ns <= s0 ;
				end if;

			when  s1010  =>						-- received token - drive bus
					ns <= s1011 ;

			when  s1011  =>						-- drive bus and take control - begin with EVEN word (s10!)
					ns <= s10 ;


			when  s155  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s155 ;
				end if;
		----------------------------------------------------------------------------------------------------------

			when others =>
					ns <= s0;					
		end case;
	end process p2;

	count_word <= ps(12);
	send_token <= ps(11);
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
	
	sst_state <= ps;
		
end a1;

