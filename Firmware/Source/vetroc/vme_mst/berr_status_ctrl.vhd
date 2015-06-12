----- berr status state machine - EJ

library ieee;
use ieee.std_logic_1164.all;

entity berr_status_ctrl is
	port(       berr: in std_logic;
			selected: in std_logic;
		   a32_cycle: in std_logic;
		         clk: in std_logic;
	           reset: in std_logic;
		 berr_status: out std_logic);
end berr_status_ctrl;

architecture a1 of berr_status_ctrl is	
--                                                 -+
	constant s0: std_logic_vector(1 downto 0)  := "00";
	constant s1: std_logic_vector(1 downto 0)  := "01";
	constant s2: std_logic_vector(1 downto 0)  := "11";
	
	signal ps,ns: std_logic_vector(1 downto 0);
	
begin

p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, berr, selected, a32_cycle)
	begin
		case ps is
			when  s0  =>
				if ( berr = '1' ) then
					ns <= s1 ;
				else
					ns <= s0 ;
				end if;
			when  s1  =>					-- berr status set
				if ( selected = '0' ) then
					ns <= s2 ;
				else
					ns <= s1 ;
				end if;
			when  s2  =>					-- berr status held until NEXT a32 access of board (single or multi)
				if ( a32_cycle = '1' ) then
					ns <= s0 ;
				else
					ns <= s2 ;
				end if;
			when others =>			
					ns <= s0;
		end case;
	end process p2;
		
	berr_status <= ps(0);

end a1;



