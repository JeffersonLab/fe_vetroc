----- cycle select state machine - EJ
----- 2/17/09, 2/24/09, 4/22/09 --- vhdl 2/17/10

library ieee;
use ieee.std_logic_1164.all;

entity cycle_select_x1 is
	port(  selected: in std_logic;
		     intack: in std_logic;
		  std_cycle: in std_logic;
			   mblt: in std_logic;
				 e2: in std_logic;
				sst: in std_logic;
				clk: in std_logic;
		 sysreset_n: in std_logic;
	
			  cycle: out std_logic_vector(2 downto 0);
		     go_std: out std_logic;
			go_mblt: out std_logic;
			  go_e2: out std_logic;
			 go_sst: out std_logic;
			 go_int: out std_logic);
end cycle_select_x1;

architecture a1 of cycle_select_x1 is

	constant s0: std_logic_vector(5 downto 0) := "000000";
	constant s1: std_logic_vector(5 downto 0) := "100000";
	constant s2: std_logic_vector(5 downto 0) := "000001";		----- std cycle
	constant s3: std_logic_vector(5 downto 0) := "000010";		----- mblt cycle
	constant s4: std_logic_vector(5 downto 0) := "000100";		----- e2 cycle
	constant s5: std_logic_vector(5 downto 0) := "001000";		----- sst cycle
	constant s6: std_logic_vector(5 downto 0) := "010000";		----- int cycle

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
	
p2:	process (ps, selected, intack, std_cycle, mblt, e2, sst)
	begin
		case ps is
			when s0 =>
				cycle <= "000";
				if ( selected = '1' ) then			----- normal slave cycle
					ns <= s1;
				elsif ( intack = '1' ) then			----- interrupt acknowledge cycle
					ns <= s6;
				else
					ns <= s0;
				end if;
			when  s1  =>
				cycle <= "000";
				if ( selected = '0' ) then
					ns <= s0 ;
				elsif ( selected = '1' and std_cycle = '1' ) then
					ns <= s2 ;
				elsif ( selected = '1' and mblt = '1' ) then
					ns <= s3 ;
				elsif ( selected = '1' and e2 = '1' ) then
					ns <= s4 ;
				elsif ( selected = '1' and sst = '1' ) then
					ns <= s5 ;
				else
					ns <= s0 ;
				end if;
			when  s2  => 
				cycle <= "001";
				if ( selected = '0' ) then
					ns <= s0 ;
				else
					ns <= s2 ;
				end if;
			when  s3  => 
				cycle <= "010";
				if ( selected = '0' ) then
					ns <= s0 ;
				else
					ns <= s3 ;
				end if;
			when  s4  =>
				cycle <= "011";
				if ( selected = '0' ) then
					ns <= s0 ;
				else
					ns <= s4 ;
				end if;
			when  s5  => 
				cycle <= "100";
				if ( selected = '0' ) then
					ns <= s0 ;
				else
					ns <= s5 ;
				end if;
			when  s6  => 
				cycle <= "101";
				if ( intack = '0' ) then
					ns <= s0 ;
				else
					ns <= s6 ;
				end if;
			when others =>
				cycle <= "000";
					ns <= s0;
		end case;
	end process p2;

	go_int  <= ps(4);
	go_sst  <= ps(3);
	go_e2   <= ps(2);
	go_mblt <= ps(1);
	go_std  <= ps(0);
	
end a1;
							

