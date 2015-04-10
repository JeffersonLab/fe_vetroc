-- Buffer output control 12 for FADC  -  10/04/07, 3/5/09, 4/6/09; 5/18/10 (VHDL)  EJ" ;

library ieee;
use ieee.std_logic_1164.all;

entity buffer_out_ctrl_12 is
	port(	   selected: in std_logic;
					 le: in std_logic;
			     go_sst: in std_logic;
			  next_data: in std_logic;
				  tag_0: in std_logic_vector(3 downto 0);
				  tag_1: in std_logic_vector(3 downto 0);
		   buff_empty_0: in std_logic;
		   buff_empty_1: in std_logic;
			  d64_cycle: in std_logic;
			     stream: in std_logic;
		buff_select_ext: in std_logic;
			        clk: in std_logic;
				  reset: in std_logic;
				
			  select0_n: out std_logic;
			  rd_buff_0: out std_logic;
			  rd_buff_1: out std_logic;
		  ev_count_down: out std_logic;
		   event_header: out std_logic;
		   block_header: out std_logic;
	      block_trailer: out std_logic;
				  dnv_0: out std_logic;
				  dnv_1: out std_logic);
end buffer_out_ctrl_12;

architecture a1 of buffer_out_ctrl_12 is

	component buffer_select is
		port(	rd_buff_0: in std_logic;
				rd_buff_1: in std_logic;
				   stream: in std_logic;
					  clk: in std_logic;
					reset: in std_logic;
				  buff0_n: out std_logic);
	end component;

	component data_not_valid is
		port( empty_buffer: in std_logic;
						le: in std_logic;
				  selected: in std_logic;
				 next_data: in std_logic;
					go_sst: in std_logic;
					   clk: in std_logic;
					 reset: in std_logic;
				  dnv_flag: out std_logic);
	end component;
	
	component mux2_to_1_old is
		port(  data_0: in std_logic;
			   data_1: in std_logic;
				  sel: in std_logic;
			 data_out: out std_logic);
	end component;

	constant s0: std_logic  := '0';
	constant s1: std_logic  := '1';

	signal ps,ns: std_logic;
	
	signal buff_select_0, buff_select_1: std_logic;
	signal event_header_0, event_header_1: std_logic;
	signal count_event: std_logic;
	signal buff0_n, buff0x_n: std_logic;
	signal bh, bt: std_logic;
	signal rd_buff_0_int, rd_buff_1_int: std_logic;
	signal dnv_0_int, dnv_1_int: std_logic;
							
begin

-- The internal fifo buffers are configured in "look ahead mode" - this means that after the first
-- data word is written into the fifo, it appears at the output and can be used.
-- The read pulse is applied AFTER the data has been used, and serves to eject the data.
-- The next data word (if present) then appears at the output

-- Data not valid flags are asserted when the relevant buffer is empty.
-- The read pulse is not applied to a buffer whose output is not valid - this protects against
-- ejecting new data written to the fifo during the current VME cycle.
-- The buffer assignment will not switch when a read from a non-valid buffer is attempted.
-- For a D64 cycle, BOTH buffers must be valid to eject the current word pair.
-- Thus, the user must reject the word pair if EITHER word has a DNV flag set (!).
-- In streaming mode, the buffer selection is forced by input 'buff_select_ext'. 
	
x1: data_not_valid port map ( empty_buffer => buff_empty_0,
										le => le,
								  selected => selected,
								 next_data => next_data,
									go_sst => go_sst,
									   clk => clk,
									 reset => reset,
								  dnv_flag => dnv_0_int );
	
x2: data_not_valid port map ( empty_buffer => buff_empty_1,
										le => le,
								  selected => selected,
								 next_data => next_data,
									go_sst => go_sst,
									   clk => clk,
									 reset => reset,
								  dnv_flag => dnv_1_int );
								  
x3: buffer_select port map ( rd_buff_0 => rd_buff_0_int,
							 rd_buff_1 => rd_buff_1_int,
								stream => stream,
								   clk => clk,
								 reset => reset,
							   buff0_n => buff0x_n );
								  		
x4: mux2_to_1_old port map (  data_0 => buff0x_n,
							  data_1 => buff_select_ext,
								 sel => stream,
							data_out => buff0_n );

	buff_select_0 <= ( (not d64_cycle) and (not buff0_n) and (not dnv_0_int) )
				  or (      d64_cycle  and (not dnv_0_int)   and (not dnv_1_int) );

	buff_select_1 <= ( (not d64_cycle) and buff0_n     and (not dnv_1_int) )
				  or (      d64_cycle  and (not dnv_0_int) and (not dnv_1_int) );

	rd_buff_0_int <= next_data and buff_select_0;		-- eject the current word at the end of the cycle
	rd_buff_1_int <= next_data and buff_select_1;

	select0_n <= (buff0_n and (not d64_cycle)) or d64_cycle;

	bh <= '1' when (tag_0 = "0100") else			-- block header always in buffer 0		
		  '0';

	bt <= '1' when (tag_1 = "1000") else			-- block trailer always in buffer 1		
		  '0';

	block_header  <= bh and buff_select_0;			-- block header always in buffer 0
	block_trailer <= bt and buff_select_1;			-- block trailer always in buffer 1		
	
	event_header_0 <= '1' when (tag_0 = "0001") else		
					  '0';

	event_header_1 <= '1' when (tag_1 = "0001") else		
					  '0';

	event_header <= (event_header_0 and buff_select_0) or (event_header_1 and buff_select_1);

	count_event <= (rd_buff_0_int and event_header_0) or (rd_buff_1_int and event_header_1); 

-- event count down state machine - count down when an event header word is detected
	
p1:	process (reset,clk)
	begin
		if reset = '1' then 
			ps <= s0;
		elsif rising_edge(clk) then 
			ps <= ns;
		end if;
	end process p1;
	
p2:	process (ps, count_event, stream)
	begin
		case ps is
			when  s0  =>
				if ( (count_event = '1') and (stream = '0') ) THEN
					ns <= s1 ;
				else
					ns <= s0 ;
				end if;
		
			when  s1  =>
					ns <= s0 ;
					
			when others  =>
					ns <= s0 ;										
		end case;
	end process p2;
					
	ev_count_down <= ps;
	
	rd_buff_0 <= rd_buff_0_int;
	rd_buff_1 <= rd_buff_1_int;
	
	dnv_0 <= dnv_0_int;
	dnv_1 <= dnv_1_int;
			
end;

