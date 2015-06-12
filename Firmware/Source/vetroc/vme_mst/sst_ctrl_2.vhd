----- SST cycle control logic - 3/19/09, 9/16/10 - EJ

library ieee;
use ieee.std_logic_1164.all;

entity sst_ctrl_2 is
	port(  start_adr: in std_logic_vector(11 downto 0);
			 n_beats: in std_logic_vector(8 downto 0);
		load_counter: in std_logic;
		    count_up: in std_logic;
				 clk: in std_logic;
		       reset: in std_logic;
		 current_adr: out std_logic_vector(11 downto 0);
	   current_beats: out std_logic_vector(8 downto 0);
		  done_beats: out std_logic;
		  boundary_0: out std_logic;
		  boundary_1: out std_logic;
		  stop_cycle: out std_logic);
end sst_ctrl_2;

architecture a1 of sst_ctrl_2 is

	component compare is
		generic( bitlength: integer );
		port(    a,b: in std_logic_vector((bitlength - 1) downto 0);
			  a_eq_b: out std_logic;
			  a_gt_b: out std_logic;
			  a_lt_b: out std_logic );
	end component;
	
	component counter_9usl is
		port( count_up: in std_logic;
				 sload: in std_logic;
				  data: in std_logic_vector(8 downto 0);
				   clk: in std_logic;
				 reset: in std_logic;
			zero_count: out std_logic;
			 max_count: out std_logic;
			   counter: out std_logic_vector(8 downto 0));
	end component;
	
	component counter_12u8sl is
		port( count_up: in std_logic;
				 sload: in std_logic;
				  data: in std_logic_vector(11 downto 0);
				   clk: in std_logic;
				 reset: in std_logic;
			zero_count: out std_logic;
			 max_count: out std_logic;
			   counter: out std_logic_vector(11 downto 0));
	end component;
	
	signal zero_value: std_logic_vector(11 downto 0);
	signal boundary_value: std_logic_vector(11 downto 0);
	signal current_beats_int: std_logic_vector(8 downto 0);
	signal current_adr_int: std_logic_vector(11 downto 0);
	signal boundary_0_int, boundary_1_int: std_logic;
	signal done_beats_int: std_logic;
	signal z0, z2, m0, m2: std_logic;

begin
	
	zero_value <= "000000000000";
	boundary_value <= "100000000000";		-- 2048 byte address boundary

-- 8-byte word (beat) counter
x0: counter_9usl port map( count_up, load_counter, zero_value(8 downto 0), clk, reset, 
						   z0, m0, current_beats_int(8 downto 0) );

x1:	compare generic map ( bitlength => 9 )
			   port map (      a => n_beats,
						       b => current_beats_int,
						  a_eq_b => done_beats_int,
						  a_gt_b => open,
						  a_lt_b => open );
	
-- internal byte address counter (8-byte words)
x2: counter_12u8sl port map( count_up, load_counter, start_adr(11 downto 0), clk, reset, 
						   z2, m2, current_adr_int(11 downto 0) );
	
x3:	compare generic map ( bitlength => 12 )
			   port map (      a => zero_value,
						       b => current_adr_int,
						  a_eq_b => boundary_0_int,
						  a_gt_b => open,
						  a_lt_b => open );
	
x4:	compare generic map ( bitlength => 12 )
			   port map (      a => boundary_value,
						       b => current_adr_int,
						  a_eq_b => boundary_1_int,
						  a_gt_b => open,
						  a_lt_b => open );
	
	stop_cycle <= done_beats_int or boundary_0_int or boundary_1_int;

	current_beats <= current_beats_int;
	done_beats <= done_beats_int;
	current_adr <= current_adr_int;
	boundary_0 <= boundary_0_int;
	boundary_1 <= boundary_1_int;
		
end a1;


