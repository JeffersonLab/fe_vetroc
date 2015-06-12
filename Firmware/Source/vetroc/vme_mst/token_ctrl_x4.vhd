----- Multiboard token Control - EJ" - 8/11/11

-- in multiboard mode, modsel = token
-- for all cycles token is held until end of cycle ONLY for last board

library ieee;
use ieee.std_logic_1164.all;

entity token_ctrl_x4 is
	port(    en_mb: in std_logic;
			 first: in std_logic;
		      last: in std_logic;
	    take_token: in std_logic;
		  token_in: in std_logic;
		 done_data: in std_logic;
		send_token: in std_logic;
		   ds_sync: in std_logic;
			   clk: in std_logic;
		     reset: in std_logic;
			 token: out std_logic;
	     token_out: out std_logic);
end token_ctrl_x4;

architecture a1 of token_ctrl_x4 is
		
	component dff_1 is
		port( 	  d: in std_logic;
				clk: in std_logic;
			reset_n: in std_logic;
			  set_n: in std_logic;
				  q: out std_logic);
	end component;
--                                                 ---++
	constant s0: std_logic_vector(4 downto 0)  := "00000";
	
	constant s1: std_logic_vector(4 downto 0)  := "00001";
	constant s2: std_logic_vector(4 downto 0)  := "00101";
	constant s11: std_logic_vector(4 downto 0) := "01101";
	constant s12: std_logic_vector(4 downto 0) := "10001";
	
	constant s4: std_logic_vector(4 downto 0)  := "00010";
	constant s5: std_logic_vector(4 downto 0)  := "00110";
	constant s6: std_logic_vector(4 downto 0)  := "01010";
--                                                 ---++

	signal ps,ns: std_logic_vector(4 downto 0);
	signal reset_n, token_in_sync: std_logic;

begin

	reset_n <= not reset;
x0:	dff_1 port map (token_in, clk, reset_n, '1', token_in_sync);
	
p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, en_mb, first, last, take_token, token_in_sync, done_data, send_token, ds_sync)
	begin
		case ps is
			when  s0  =>
				if ( (en_mb = '1') and 
				 ( ((first = '1') and (take_token = '1')) or ((first = '0') and (token_in_sync = '1')) ) ) then
					ns <= s1 ;
				else
					ns <= s0 ;
				end if;
			
			when  s1  =>
				if ( (en_mb = '1') and (last = '0') ) then
					ns <= s2 ;
				elsif ( (en_mb = '1') and (last = '1') ) then
					ns <= s11 ;
				else
					ns <= s0 ;
				end if;
			
			when  s2  =>							-- all but LAST board
				if ( (en_mb = '1') and (send_token = '1') ) then
					ns <= s4 ;
				elsif ( (en_mb = '0') ) then
					ns <= s0 ;
				else
					ns <= s2 ;
				end if;
			
			when  s4  =>							-- drive token_out signal for 3 clock cycles (60 ns)		
					ns <= s5 ;
				
			when  s5  =>									
					ns <= s6 ;
				
			when  s6  =>									
					ns <= s0 ;
				
			when  s11  =>								-- hold token for LAST board		
				if ( (en_mb = '1') and (done_data = '1') ) then		
					ns <= s12 ;
				elsif ( en_mb = '0' ) then
					ns <= s0 ;
				else
					ns <= s11 ;
				end if;
			
			when  s12  =>								-- for LAST board hold token until end of cycle		
				if ( (en_mb = '0') or (ds_sync = '0')  ) then		
					ns <= s0 ;
				else
					ns <= s12 ;
				end if;
				
			when others =>			
					ns <= s0;
		end case;
	end process p2;
	
	token_out <= ps(1);
	token     <= ps(0);
					
end a1;

