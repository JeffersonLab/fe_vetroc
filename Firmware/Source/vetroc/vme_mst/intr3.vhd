----- VME Interrupter chip (synchronous version) 

library ieee;
use ieee.std_logic_1164.all;

entity intr3 is
	port( int_stb: in std_logic;						-- all inputs synchronous to 'clk'
				a: in std_logic_vector(3 downto 1);
			 as_n: in std_logic;
			ds0_n: in std_logic;
		  reset_n: in std_logic;
		 iackin_n: std_logic;
			i_lev: std_logic_vector(3 downto 1);
			  clk: in std_logic;
				
		iackout_n: out std_logic;
		 intack_n: out std_logic;
			irq_n: out std_logic_vector(7 downto 1));
end intr3;

architecture a1 of intr3 is
	
	component dff_1 is
		port( 	  d: in std_logic;
				clk: in std_logic;
			reset_n: in std_logic;
			  set_n: in std_logic;
				  q: out std_logic);
	end component;
	
	constant t0:  std_logic:= '0';
	constant t1:  std_logic:= '1';
	signal ps_a, ns_a: std_logic;
	
--												  ---++
	constant s0:  std_logic_vector(4 downto 0):= "00000";
	constant s1:  std_logic_vector(4 downto 0):= "00100";
	constant s2:  std_logic_vector(4 downto 0):= "01000";
	constant s3:  std_logic_vector(4 downto 0):= "01100";
	constant s31: std_logic_vector(4 downto 0):= "10000";
	constant s5:  std_logic_vector(4 downto 0):= "10100";
	
	constant s4:  std_logic_vector(4 downto 0):= "00001";

	constant s30: std_logic_vector(4 downto 0):= "00010";	
--												  ---++
	signal ps_b, ns_b: std_logic_vector(4 downto 0);

	signal as, ds0: std_logic;
	signal clk_iackout, iackin, iackout: std_logic;
	signal request, level_match, match, intack: std_logic;
	
	attribute iob: string;						-- request placement in io block
	attribute iob of x1: label is "TRUE";

begin

	as <= not as_n;
	ds0 <= not ds0_n;
	iackin <= not iackin_n;
	
	iackout_n <= not iackout;
	intack_n <= not intack;
	
----- latch interrupt signal 'int_stb' from board to generate interrupt request
	request <= ps_a;
	
----- drive (low) appropriate interrupt request line
	irq_n(7) <= '0' when ( (request = '1') and (i_lev = "111") ) else
				'1';
	irq_n(6) <= '0' when ( (request = '1') and (i_lev = "110") ) else
				'1';
	irq_n(5) <= '0' when ( (request = '1') and (i_lev = "101") ) else
				'1';
	irq_n(4) <= '0' when ( (request = '1') and (i_lev = "100") ) else
				'1';
	irq_n(3) <= '0' when ( (request = '1') and (i_lev = "011") ) else
				'1';
	irq_n(2) <= '0' when ( (request = '1') and (i_lev = "010") ) else
				'1';
	irq_n(1) <= '0' when ( (request = '1') and (i_lev = "001") ) else
				'1';	

----- interrupt select logic	
	level_match <= '1' when (a = i_lev) else
				   '0';
	match <= request and level_match;
	
	intack 		<= ps_b(0);			----- select module for our request
	clk_iackout <= ps_b(1);			----- drive 'iackout' if not our request
	
----- VME spec requires 'iackout' de-asserted within 40 ns of de-assertion of 'as', so
----- drive 'iackout' from dff reset by 'as'	
x1:	dff_1 port map (d => '1', clk => clk_iackout, reset_n => as, set_n => '1', q => iackout);
	
----- interrupt request state machine -----
----- (interrupt request negated on interrupt acknowledge (ROAK))

p1:	process (reset_n, clk)
	begin
		if reset_n = '0' then 
			ps_a <= t0;
		elsif rising_edge(clk) then 
			ps_a <= ns_a;
		end if;
	end process p1;
	
p2:	process (ps_a, int_stb, intack)
	begin
		case ps_a is
			when t0 =>
				if ( int_stb = '1' ) then
					ns_a <= t1;
				else
					ns_a <= t0;
				end if;
				
			when  t1  =>
				if ( intack = '1' ) then
					ns_a <= t0 ;
				else
					ns_a <= t1 ;
				end if;
				
			when others =>
					ns_a <= t0;				
		end case;
	end process p2;
	
--------------------------------------------

----- interrupt response state machine -----
		
p3:	process (reset_n, clk)
	begin
		if reset_n = '0' then 
			ps_b <= s0;
		elsif rising_edge(clk) then 
			ps_b <= ns_b;
		end if;
	end process p3;
	
p4:	process (ps_b, iackin, as, match, ds0)
	begin
		case ps_b is
			when s0 =>
				if ( (iackin = '1') and (as = '1') ) then						--- require 'as' and 'iackin' to begin
					ns_b <= s1;
				else
					ns_b <= s0;
				end if;
				
			when s1 =>
				if ( (iackin = '1') and (as = '1') ) then
					ns_b <= s2;
				else
					ns_b <= s0;
				end if;
				
			when  s2  =>
				if ( (iackin = '1') and (match = '1') and (as = '1') ) then		--- my request
					ns_b <= s3 ;
				elsif ( (iackin = '1') and (match = '0') and (as = '1') ) then	--- not my request
					ns_b <= s30 ;
				else															--- cycle ended
					ns_b <= s0;
				end if;
				
			when  s3  =>														--- my request
				if ( (iackin = '1') and (as = '1') and (ds0 = '1') ) then 
					ns_b <= s4 ;
				elsif ( (iackin = '0') or (as = '0') ) then 
					ns_b <= s0 ;
				else 
					ns_b <= s3;
				end if;
				
			when  s4  =>														--- assert 'intack' to select module
				if ( (iackin = '0') and (ds0 = '0') ) then
					ns_b <= s0 ;
				elsif ( (iackin = '1') and (ds0 = '0') ) then
					ns_b <= s5 ;
				else
					ns_b <= s4;
				end if;
				
			when  s5  =>
				if ( iackin = '0' ) then
					ns_b <= s0 ;
				else
					ns_b <= s5;
				end if;
				
			when  s30  =>														--- not my request - drive 'iackout'
					ns_b <= s31 ;
					
			when  s31  =>
				if ( iackin = '0' ) then
					ns_b <= s0 ;
				else
					ns_b <= s31;
				end if;
				
			when others =>
					ns_b <= s0;				
		end case;
	end process p4;
--------------------------------------------
		
end a1;


