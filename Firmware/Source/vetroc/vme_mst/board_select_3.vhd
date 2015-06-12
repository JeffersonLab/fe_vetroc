----- board select state machine - 2/24/09; vhdl 2/12/10, 2/17/10, 9/28/10, 10/7/10 - EJ" ;

library ieee;
use ieee.std_logic_1164.all;

entity board_select_3 is
	port( 	  myboard: in std_logic;
		      as_sync: in std_logic;
		      ds_sync: in std_logic;
		 cycle_active: in std_logic;
				  clk: in std_logic;
		   sysreset_n: in std_logic;
	
			 selected: out std_logic;
			 ce_cycle: out std_logic;
		data_transfer: out std_logic;
		  ce_datapath: out std_logic;
		 not_selected: out std_logic);
end board_select_3;

architecture a1 of board_select_3 is
--												  -+++++
	constant s0:  std_logic_vector(5 downto 0):= "000000";	----- manual state encoding
	constant s1:  std_logic_vector(5 downto 0):= "100000";
	constant s2:  std_logic_vector(5 downto 0):= "000011";
	constant s10: std_logic_vector(5 downto 0):= "010000";
	constant s20: std_logic_vector(5 downto 0):= "000001";
	constant s30: std_logic_vector(5 downto 0):= "001101";
	constant s3:  std_logic_vector(5 downto 0):= "000101";
	constant s4:  std_logic_vector(5 downto 0):= "100101";
--												  -+++++
	signal ps,ns: std_logic_vector(5 downto 0);
	
begin

p1:	process (sysreset_n,clk)
	begin
		if sysreset_n = '0' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, myboard, as_sync, ds_sync, cycle_active)
	begin
		case ps is
			when s0 =>
				if ( (as_sync = '1') and (cycle_active = '0') ) then			----- new cycle
					ns <= s1;
				else
					ns <= s0;
				end if;
				
			when s1 =>
				if ( (as_sync = '1') and (myboard = '1') ) then					----- board selected
					ns <= s2;
				elsif ( (as_sync = '1') and (myboard = '0') ) then				----- board NOT selected
					ns <= s10;
				else
					ns <= s0;
				end if;
				
			when  s2  =>
				if ( (as_sync = '1') and (ds_sync = '1') ) then
					ns <= s30 ;
				elsif ( (as_sync = '1') and (ds_sync = '0') ) then
					ns <= s20 ;
				else
					ns <= s0 ;
				end if;
				
			when  s10  =>														----- NOT my cycle 
				if ( as_sync = '0' ) then
					ns <= s0 ;
				else
					ns <= s10 ;
				end if;
				
			when  s20  =>
				if ( (as_sync = '1') and (ds_sync = '1') ) then
					ns <= s30 ;
				elsif ( (as_sync = '1') and (ds_sync = '0') ) then
					ns <= s20 ;
				else
					ns <= s0 ;
				end if;
				
			when  s30  =>
					ns <= s3 ;
				
			when  s3  =>
				if ( (as_sync = '0') and (ds_sync = '0') ) then
					ns <= s0 ;
				elsif ( (as_sync = '0') and (ds_sync = '1') ) then
					ns <= s4 ;
				else
					ns <= s3 ;
				end if;
				
			when  s4  =>
				if ( ds_sync = '0') then
					ns <= s0 ;
				else
					ns <= s4 ;
				end if;
				
			when others =>
					ns <= s0;
		end case;
	end process p2;
	
	not_selected  <= ps(4);		----- outputs are state register values
	ce_datapath   <= ps(3);
	data_transfer <= ps(2);
	ce_cycle      <= ps(1);
	selected      <= ps(0);
	
end a1;
			
