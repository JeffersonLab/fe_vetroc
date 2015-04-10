----- standard read/write VME cycle - EJ
----- includes BLT cycle - fast access uses transceiver latch enable
----- supports token passing
----- vhdl version
----- 9/14/10 - now 2 clock periods from 'x_stb' valid to test of 'busy' (single cycle read or write)
----- 10/12/10 - remove latch - 'dir_d <= w_n;' 

library ieee;
use ieee.std_logic_1164.all;

entity std_cycle_x5 is
	port( 	go_cycle: in std_logic;
			 ds_sync: in std_logic;
			     w_n: in std_logic;
				busy: in std_logic;
		 fast_access: in std_logic;
			hold_ack: in std_logic;
		 end_of_data: in std_logic;
		select_multi: in std_logic;
			   token: in std_logic;
			    last: in std_logic;
				 clk: in std_logic;
		  sysreset_n: in std_logic;
	
			   dir_a: out std_logic;
			   dir_d: out std_logic;
				 ack: out std_logic;
				berr: out std_logic;
			read_sig: out std_logic;
			read_stb: out std_logic;
		   write_sig: out std_logic;
		   write_stb: out std_logic;
		   next_data: out std_logic;
		   done_data: out std_logic;
				  le: out std_logic;
		  send_token: out std_logic);
end std_cycle_x5;

architecture a1 of std_cycle_x5 is

--                                                  --++++++++++
	constant  s0: std_logic_vector(11 downto 0) := "000000000000";
	constant  s2: std_logic_vector(11 downto 0) := "010000000000";
	constant s14: std_logic_vector(11 downto 0) := "100000000000";		----- 
	constant s17: std_logic_vector(11 downto 0) := "110000000000";		----- 
	
	constant  s3: std_logic_vector(11 downto 0) := "000000010010";
			
	constant  s5: std_logic_vector(11 downto 0) := "000000000010";		-----
	constant s55: std_logic_vector(11 downto 0) := "010000000010";		-----
	 
	constant  s6: std_logic_vector(11 downto 0) := "000000001010";		-----
	 
	constant  s7: std_logic_vector(11 downto 0) := "000000100100";		-----
	 
	constant  s8: std_logic_vector(11 downto 0) := "000000000100";		-----
	constant s88: std_logic_vector(11 downto 0) := "010000000100";		-----
	 
	constant  s9: std_logic_vector(11 downto 0) := "000000001100";		-----
	 
	constant s11: std_logic_vector(11 downto 0) := "000001001011";		-----
	 
	constant s12: std_logic_vector(11 downto 0) := "000000001011";		-----
	 
	constant s15: std_logic_vector(11 downto 0) := "000110000000";		-----
	 
	constant s16: std_logic_vector(11 downto 0) := "001100000000";		-----	 
--                                                  --++++++++++

	signal ps,ns: std_logic_vector(11 downto 0);
	signal select_status: std_logic;
	signal ack_int, ack_n: std_logic;

begin

	dir_a <= '1';							----- address always into board for STD cycle
	ack <= ack_int;
	
	dir_d <= w_n;							----- supports read-modify-write cycles
	
	select_status <= (not select_multi) or (select_multi and token) ;	

p1:	process (sysreset_n,clk)
	begin
		if sysreset_n = '0' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, ds_sync, w_n, go_cycle, fast_access, select_multi, end_of_data, select_status, busy, last, hold_ack)
	begin
		case ps is
			when s0 =>
				if( (w_n = '0') and (ds_sync = '1') and (go_cycle = '1') and (select_multi = '0') ) then		  ----- write
					ns <= s2 ;
				elsif ( (w_n = '1') and (ds_sync = '1') and (go_cycle = '1') and (fast_access = '0') ) then		  ----- read register
					ns <= s3 ;
				elsif ( (w_n = '1') and (ds_sync = '1') and (go_cycle = '1') and (fast_access = '1') 
														and (end_of_data = '0') and (select_status = '1') ) then  ----- read memory
					ns <= s11 ;
				elsif ( (w_n = '1') and (ds_sync = '1') and (go_cycle = '1') and (fast_access = '1')
													    and (end_of_data = '1') and (select_status = '1') ) then  ----- berr or token cycle
					ns <= s14 ;
				else
					ns <= s0 ;
				end if;
			
			when s2  =>									
				if ( (ds_sync = '1') and (go_cycle = '1') ) then
					ns <= s7 ;
				else
					ns <= s0 ;
				end if;

			when s3  =>									
				if ( (ds_sync = '1') and (go_cycle = '1') ) then
					ns <= s5 ;
				else
					ns <= s0 ;
				end if;

			when s5  =>
				if ( (ds_sync = '1') and (go_cycle = '1') ) then						----- wait for test of 'busy'
					ns <= s55 ;
				else 
					ns <= s0 ;
				end if;

			when s55  =>
				if ( (ds_sync = '1') and (go_cycle = '1') and (busy = '0') ) then		----- data ready
					ns <= s6 ;
				elsif ( (ds_sync = '1') and (go_cycle = '1') and (busy = '1') ) then	----- data not ready
					ns <= s55 ;
				else
					ns <= s0 ;
				end if;

			when s6  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else 
					ns <= s6 ;
				end if;
				
			when s7  =>
				if ( (ds_sync = '1') and (go_cycle = '1') ) then
					ns <= s8 ;
				else
					ns <= s0;
				end if ;

			when s8  =>
				if ( (ds_sync = '1') and (go_cycle = '1') ) then						----- wait for test of 'busy'
					ns <= s88 ;
				else
					ns <= s0;
				end if ;

			when s88  =>
				if ( (ds_sync = '1') and (go_cycle = '1') and (busy = '0') ) then
					ns <= s9 ;
				elsif ( (ds_sync = '1') and (go_cycle = '1') and (busy = '1') ) then
					ns <= s88 ;
				else
					ns <= s0;
				end if;

			when s9  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else 
					ns <= s9 ;
				end if;
				
			when s11  =>
					ns <= s12;
					
			when s12  =>
				if ( (ds_sync = '0') and (hold_ack = '0') ) then
					ns <= s0 ;
				else
					ns <= s12;
				end if;

			when s14  =>
				if ( (select_multi = '1') and (last = '0') ) then
					ns <= s16 ;
				else
					ns <= s15;
				end if;
				
			when s15  =>
				if ( (ds_sync = '0') or (go_cycle = '0') ) then
					ns <= s0 ;
				else
					ns <= s15;
				end if;
				
			when s16  =>
					ns <= s17;
					
			when s17  =>
					ns <= s0;

			when others =>
					ns <= s0;					
		end case;
	end process p2;

	send_token <= ps(9);
	done_data  <= ps(8);
	berr       <= ps(7);
	next_data  <= ps(6);
	write_stb  <= ps(5);
	read_stb   <= ps(4);
	ack_int    <= ps(3);
	write_sig  <= ps(2);
	read_sig   <= ps(1);
	le         <= ps(0);

end a1;


