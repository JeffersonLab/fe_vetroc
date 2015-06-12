----- VME engine for FADC - 8/16/11  EJ

----- This version will simultaneously respond to A16, A24, A32, & A32 multi-board 
----- addressing modes, and supports 2eVME & 2eSST transfers

----- Supports interrupt acknowledge cycles
----- Handles token passing for multiboard address range

----- Add register to output signals 'dtack_n', 'oe_dtack', 'retry_n', 'oe_retry', 'berr_n', 
----- 'le_d', 'le_a' to compensate for pipeline register added to data path at output - 9/22/10

----- add 'temp' vector to output for debug
----- all external inputs assumed synchronous to 'clk'

----- supports token passing with SST cycles

library ieee;
use ieee.std_logic_1164.all;

entity v64xblk_x8 is
	port(            a: in std_logic_vector(31 downto 0);	-- all synchronized to 'clk' -- 
		            am: in std_logic_vector(5 downto 0);
		          as_n: in std_logic;
		        iack_n: in std_logic;
		           w_n: in std_logic;
		         ds0_n: in std_logic;
		         ds1_n: in std_logic;
		             d: in std_logic_vector(3 downto 0);	-------------------------------
		         
		       match16: in std_logic;
		       match24: in std_logic;
		       match32: in std_logic;
		      match32m: in std_logic;
		         a_reg: in std_logic_vector(7 downto 0);
		       
		      intack_n: in std_logic;
		       en_berr: in std_logic;
		    dtack_in_n: in std_logic;
		     berr_in_n: in std_logic;
		          busy: in std_logic;
		   fast_access: in std_logic;
		 block_trailer: in std_logic;
		   token_in_p0: in std_logic;
	    en_token_in_p0: in std_logic;
		   token_in_p2: in std_logic;
	    en_token_in_p2: in std_logic;
		 en_multiboard: in std_logic;
		   first_board: in std_logic;
		    last_board: in std_logic;
		    take_token: in std_logic;
		      		         		     
		           clk: in std_logic;
		       reset_n: in std_logic;
		    sysreset_n: in std_logic;
		  
		       dtack_n: out std_logic;
		        berr_n: out std_logic;
		       retry_n: out std_logic;
		      oe_dtack: out std_logic;
		      oe_retry: out std_logic;
		         dir_a: out std_logic;
		         dir_d: out std_logic;
		        oe_a_n: out std_logic;
		          le_d: out std_logic;
		       clkab_d: out std_logic;
		       clkba_d: out std_logic;
		          le_a: out std_logic;
		       clkab_a: out std_logic;
		       clkba_a: out std_logic;
		        ena1_n: out std_logic;
		        ena3_n: out std_logic;
		       oe_d1_n: out std_logic;
		       oe_d2_n: out std_logic;
		       
		       ce_addr: out std_logic;
		           ack: out std_logic;
		     end_cycle: out std_logic;
		      read_sig: out std_logic;
		     write_sig: out std_logic;
		      read_stb: out std_logic;
		     write_stb: out std_logic;
		          byte: out std_logic_vector(3 downto 0);
		        modsel: out std_logic;
		    data_cycle: out std_logic;
		    iack_cycle: out std_logic;
		     a24_cycle: out std_logic;
		     a32_cycle: out std_logic;
		    a32m_cycle: out std_logic;
		     d64_cycle: out std_logic;
		       en_fifo: out std_logic;
		     en_fifo_a: out std_logic;
		       rd_fifo: out std_logic;
		       en_fill: out std_logic;
		   berr_status: out std_logic;
		      selected: out std_logic;		       
		        go_sst: out std_logic;
		         token: out std_logic;
		     token_out: out std_logic;
		    done_block: out std_logic;
		    
		          temp: out std_logic_vector(31 downto 0);	-- for debug output 
		     sst_state: out std_logic_vector(16 downto 0);	-- for debug output 
		      sst_ctrl: out std_logic_vector(31 downto 0));	-- for debug output 
end v64xblk_x8;

architecture a1 of v64xblk_x8 is
																													
	component dffe_n is
		generic( bitlength : integer );
		port( 	  d: in std_logic_vector((bitlength - 1) downto 0);
				clk: in std_logic;
			reset_n: in std_logic;
			clk_ena: in std_logic;
				  q: out std_logic_vector((bitlength - 1) downto 0));
	end component;
		
	component dffe_1 is
		port( 	  d: in std_logic;
				clk: in std_logic;
			reset_n: in std_logic;
			  set_n: in std_logic;
			clk_ena: in std_logic;
				  q: out std_logic);
	end component;
	
	component dffe_1s is
		port( 	  d: in std_logic;
				clk: in std_logic;
		   reset_ns: in std_logic;
			clk_ena: in std_logic;
				  q: out std_logic);
	end component;
	
	component board_select_3 is
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
	end component;
	
	component cycle_select_x1 is
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
	end component;
	
	component muxx8_to_1 is
		port(data_in: in std_logic_vector(0 to 7);
				 sel: in std_logic_vector(2 downto 0);
			data_out: out std_logic);
	end component;
	
	component std_cycle_x5 is
		port(  go_cycle: in std_logic;
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
	end component;
	
	component mblt_cycle_x3 is
		port(  go_cycle: in std_logic;
				as_sync: in std_logic;
				ds_sync: in std_logic;
			  ds01_sync: in std_logic;
			end_of_data: in std_logic;
		   select_multi: in std_logic;
			      token: in std_logic;
			       last: in std_logic;
					clk: in std_logic;
			      reset: in std_logic;
				  dir_a: out std_logic;
				  dir_d: out std_logic;
				en_data: out std_logic;
				    ack: out std_logic;
				   berr: out std_logic;
			      ce_ap: out std_logic;
			  next_data: out std_logic;
			  done_data: out std_logic;
			         le: out std_logic;
			 send_token: out std_logic);
	end component;
	
	component e2_cycle_x3 is
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
	end component;
	
	component sst_cycle_x5 is
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
	end component;
	
	component int_cycle_x1 is
		port( 	 go_cycle: in std_logic;
				  ds_sync: in std_logic;
					  clk: in std_logic;
		       sysreset_n: in std_logic;
				      ack: out std_logic;
			     read_sig: out std_logic);
	end component;
	
	component end_block_x3 is
		port(    end_detect: in std_logic;
			  block_trailer: in std_logic;
				  next_data: in std_logic;
				  done_data: in std_logic;
					    clk: in std_logic;
		              reset: in std_logic;
			    end_of_data: out std_logic);
	end component;
	
	component sst_ctrl_2 is
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
	end component;
	
	component token_ctrl_x4 is
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
	end component;
	
	component berr_status_ctrl is
		port(       berr: in std_logic;
				selected: in std_logic;
			   a32_cycle: in std_logic;
			         clk: in std_logic;
		           reset: in std_logic;
			 berr_status: out std_logic);
	end component;
	
	signal b0, b1, b2, b3, b01, b12, b23, b012, b123, b0123: std_logic;
	signal bad_1, bad_2, error_flag: std_logic;
	signal std16, std24, blk24, blk24_64: std_logic;
	signal std32, blk32, blk32_64: std_logic;
	signal e2_64, sst_64, std32m, blk32m, blk32_64m, e2_64m, sst_64m: std_logic;
	signal single, multi, myboard, std_access, blt, e2, sst, block_cycle: std_logic;
	signal std_type, mblt: std_logic;
	signal ds, ds01, ds0n1: std_logic;
	signal cycle_active, intack, ce_cycle, data_transfer, not_selected: std_logic;
	signal hold_ack, selected_int: std_logic;
	signal select_single, select_multi, select_std, select_blt, select_mblt: std_logic;
	signal select_e2, select_sst, select_block, select_std_type: std_logic;
	signal a16_cycle, a32_cycle_int, a32_type, mblt64_cycle, e64_cycle, sst64_cycle, d64_cycle_int: std_logic;
	signal cycle: std_logic_vector(2 downto 0);
	signal go_std, go_mblt, go_e2, go_sst_int, go_int: std_logic;
	signal end_of_data, token_int: std_logic;
	signal sysreset, rate_ok, stop_cycle, ena1_int_n: std_logic;
	signal ack_std, berr_std, dir_a_std, dir_d_std, done_data_std, next_data_std, ena1_std_n, ena3_std_n, 
		   en_data_std, ce_ap1_std, ce_ap2_std, ce_ap3_std, retry_std, en_fill_std, le_std,
		   send_token_std, read_std: std_logic;
	signal ack_mblt, berr_mblt, dir_a_mblt, dir_d_mblt, done_data_mblt, next_data_mblt, ena1_mblt_n, ena3_mblt_n, 
		   en_data_mblt, ce_ap1_mblt, ce_ap2_mblt, ce_ap3_mblt, retry_mblt, en_fill_mblt, le_mblt,
		   send_token_mblt, read_mblt: std_logic;
	signal ack_e2, berr_e2, dir_a_e2, dir_d_e2, done_data_e2, next_data_e2, ena1_e2_n, ena3_e2_n, 
		   en_data_e2, ce_ap1_e2, ce_ap2_e2, ce_ap3_e2, retry_e2, en_fill_e2, le_e2,
		   send_token_e2, read_e2: std_logic;
	signal ack_sst, berr_sst, dir_a_sst, dir_d_sst, done_data_sst, next_data_sst, ena1_sst_n, ena3_sst_n, 
		   en_data_sst, ce_ap1_sst, ce_ap2_sst, ce_ap3_sst, retry_sst, en_fill_sst, le_sst,
		   send_token_sst, read_sst: std_logic;
	signal ack_int, read_int: std_logic;
	signal next_data, done_data, reset_sst: std_logic;
	signal ack_mux,	berr_mux, retry_mux, next_data_mux,	done_data_mux, dir_a_mux, dir_d_mux, ena1_mux,
		   ena3_mux, en_fifo_mux, en_fifo_a_mux, ce_ap1_mux, ce_ap2_mux, ce_ap3_mux, en_fill_mux,
		   latch_ena_d_mux,	latch_ena_a_mux, read_sig_mux, send_token_mux: std_logic_vector(0 to 7);
	signal berr, retry, ce_ap1, ce_ap2, ce_ap3, latch_ena_d, latch_ena_a, send_token, ack_i: std_logic;
	signal start_adr: std_logic_vector(31 downto 0);
	signal current_adr: std_logic_vector(11 downto 0);
	signal cycle_count: std_logic_vector(7 downto 0);
	signal n_beats, current_beats: std_logic_vector(8 downto 0);
	signal rate: std_logic_vector(3 downto 0);
	signal ld_count_sst, done_beats, boundary_0, boundary_1, en_mb, token_in: std_logic;
	signal cycles1, cycles3: std_logic;
	signal select_cycles1, select_cycles3: std_logic;
	signal cycles1_latched, cycles3_latched: std_logic;
	signal data_transfer_n, modsel_int, data_cycle_int, rd_fifo_int: std_logic;
	signal end_cycle_int, done_block_int, ce_addr_int: std_logic;
	
	signal intack_d  : std_logic;
    signal C24 : std_logic;
    signal B64 : std_logic; 
    signal E64  : std_logic; 
    signal S64  : std_logic; 
    signal M64  : std_logic;
    
    signal end_detect: std_logic;
    
    signal as: std_logic;   
    signal select_cycle, ce_datapath: std_logic;   
    signal ack_i_n, berr_i_n, retry_i_n, le_a_i, le_d_i: std_logic;
    
	signal ack_in, berr_in, count_word, count_word_sst: std_logic;
     
	attribute iob: string;						-- request placement in io blocks
	attribute iob of x65: label is "TRUE";
	attribute iob of x66: label is "TRUE";
	attribute iob of x67: label is "TRUE";
	attribute iob of x68: label is "TRUE";
	attribute iob of x69: label is "TRUE";
	attribute iob of x70: label is "TRUE";
	attribute iob of x71: label is "TRUE";

begin

-- temp outputs for debug
	temp(0) <= cycles1;
	temp(1) <= cycles3;
	temp(2) <= ce_datapath;
	temp(3) <= select_cycles1;
	temp(4) <= select_cycles3;
	temp(5) <= cycle(0);
	temp(6) <= cycle(1);
	temp(7) <= cycle(2);
	temp(8) <= ce_cycle;
	temp(9) <= myboard;
	temp(10) <= single;
	temp(11) <= multi;
	temp(12) <= std_access;
	temp(13) <= blt;
	temp(14) <= e2;
	temp(15) <= sst;
	
	temp(16) <= end_detect;
	temp(17) <= en_berr;
	temp(18) <= en_multiboard;
	temp(19) <= block_trailer;
	temp(20) <= next_data;
	temp(21) <= done_data;
	temp(22) <= end_of_data;
	temp(23) <= end_cycle_int;
	temp(24) <= done_block_int;
	temp(25) <= cycle_active;
	temp(26) <= block_cycle;
	temp(27) <= ce_addr_int;
	temp(28) <= modsel_int;
	temp(29) <= rd_fifo_int;
	temp(30) <= select_cycle;
	temp(31) <= reset_sst;

	sysreset <= not sysreset_n;

	as <= not as_n;
	ds   <= not (ds0_n and ds1_n);								-- ds0 or ds1
	ds01 <= not (ds0_n or ds1_n);								-- ds0 and ds1
	ds0n1 <=  (not ds0_n) and ds1_n;							-- ds0 and not ds1

	cycle_active <= (not dtack_in_n) or (not berr_in_n);

	intack <= not intack_n;
	
	ack_in  <= not dtack_in_n;
	berr_in <= not berr_in_n;

------------ board select logic -----------------

	std16    <=  match16 and iack_n 
				 and am(5) and (not am(4)) and am(3) and (not am(1)) and am(0);					-- AM codes 2D, 29

	std24    <=  match24 and iack_n 
				 and am(5) and am(4) and am(3) and (not am(1)) and am(0);       				-- AM codes 3D, 39
				 
	blk24    <=  match24 and iack_n 
				 and am(5) and am(4) and am(3) and am(1) and am(0);	 							-- AM codes 3F, 3B (BLT)

	blk24_64 <=  match24 and iack_n 
				 and am(5) and am(4) and am(3) and (not am(1)) and (not am(0)); 				-- AM codes 3F, 3B (MBLT)

	std32    <=  match32 and iack_n 
				 and (not am(5)) and (not am(4)) and am(3) and (not am(1)) and am(0); 			-- AM codes 0D, 09

	blk32    <=  match32 and iack_n 
				 and (not am(5)) and (not am(4)) and am(3) and am(1) and am(0); 				-- AM codes 0F, 0B (BLT)
				  
	blk32_64 <=  match32 and iack_n 
				 and (not am(5)) and (not am(4)) and am(3) and (not am(1)) and (not am(0));		-- AM codes 0C, 08 (MBLT)%

	e2_64    <=  match32 and iack_n 
				 and am(5) and (not am(4)) and (not am(3)) and (not am(2)) and (not am(1)) and (not am(0))
				 and (not a(7)) and (not a(6)) and (not a(5)) and (not a(4)) 
				 and (not a(3)) and (not a(2)) and (not a(1)) and  a(0); 						-- AM code 20, XAM code 01 (2eVME)

	sst_64   <=  match32 and iack_n 
				 and am(5) and (not am(4)) and (not am(3)) and (not am(2)) and (not am(1)) and (not am(0))
				 and (not a(7)) and (not a(6)) and (not a(5)) and a(4) 
				 and (not a(3)) and (not a(2)) and (not a(1)) and a(0); 						-- AM code 20, XAM code 11 (2eSST)

	std32m    <= match32m and iack_n 
				 and (not am(5)) and (not am(4)) and am(3) and (not am(1)) and am(0);  			-- AM codes  0D, 09

	blk32m    <= match32m and iack_n 
				 and (not am(5)) and (not am(4)) and am(3) and am(1) and am(0);					-- AM codes  0F, 0B  (BLT)

	blk32_64m <= match32m and iack_n 
				 and (not am(5)) and (not am(4)) and am(3) and (not am(1)) and (not am(0)); 	-- AM codes  0C, 08 (MBLT)

	e2_64m    <= match32m and iack_n 
				 and am(5) and (not am(4)) and (not am(3)) and (not am(2)) and (not am(1)) and (not am(0))
			     and (not a(7)) and (not a(6)) and (not a(5)) and (not a(4)) 
			     and (not a(3)) and (not a(2)) and (not a(1)) and  a(0); 						-- AM code 20, XAM code 01 (2eVME)

	sst_64m   <= match32m and iack_n 
				 and am(5) and (not am(4)) and (not am(3)) and (not am(2)) and (not am(1)) and (not am(0))
				 and (not a(7)) and (not a(6)) and (not a(5)) and a(4) 
				 and (not a(3)) and (not a(2)) and (not a(1)) and a(0); 						-- AM code 20, XAM code 11 (2eSST)

	single <= (std16 or std24 or std32) or (blk24 or blk32) or (blk24_64 or blk32_64) or (e2_64) or (sst_64) ; 
	multi <= std32m or blk32m or blk32_64m or e2_64m or sst_64m ;
	myboard <= single or multi ;
			 	
-- board select state machine - 'myboard' is sampled 2 clk cycles after 'as' asserted
x11: board_select_3 port map ( 	   myboard => myboard, 
								   as_sync => as, 
								   ds_sync => ds, 
							  cycle_active => cycle_active, 
								       clk => clk, 
								sysreset_n => sysreset_n,
								  selected => selected_int, 
								  ce_cycle => ce_cycle, 
							 data_transfer => data_transfer,
							   ce_datapath => ce_datapath, 
							  not_selected => not_selected );
							  
	std_access <= std16 or std24 or std32 or std32m;
	blt <= blk24 or blk32 or blk32m;
	
	std_type <= std_access or blt;					-- 32-bit single edge handshaked cycle (includes BLT)
	mblt <= blk24_64 or blk32_64 or blk32_64m;		-- 64-bit single edge cycle handshaked cycle
	e2 <= e2_64 or e2_64m;							-- 64-bit dual edge handshaked cycle
	sst <= sst_64 or sst_64m;						-- 64-bit dual edge non-handshaked cycle

	block_cycle <= blt or mblt or e2 or sst;
	
-- capture cycle characteristics using 'ce_cycle' from board select state machine; 
-- characteristics will be reset after de-assertion of 'selected_int' from board select state machine 
-- by use of synchronous reset flip-flop
x12: dffe_1s port map ( d => single, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_single);
x14: dffe_1s port map ( d => multi, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_multi);
	
x15: dffe_1s port map ( d => std_access, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_std);
x16: dffe_1s port map ( d => blt, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_blt);
x17: dffe_1s port map ( d => mblt, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_mblt);
x18: dffe_1s port map ( d => e2, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_e2);
x19: dffe_1s port map ( d => sst, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_sst);
x20: dffe_1s port map ( d => block_cycle, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_block);
	
x21: dffe_1s port map ( d => std_type, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => select_std_type);
	
x22: dffe_1s port map ( d => std16, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => a16_cycle);

	C24 <= std24 or blk24 or blk24_64;
x23: dffe_1s port map ( d => C24, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => a24_cycle);

	a32_type <= std32 or blk32 or blk32_64 or e2_64 or sst_64 or multi;
x24: dffe_1s port map ( d => a32_type, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => a32_cycle_int);

	a32m_cycle <= select_multi;

    B64 <= blk24_64 or blk32_64 or blk32_64m;
    E64 <= e2_64 or e2_64m;
    S64 <= sst_64 or sst_64m;
    M64 <= mblt or e2 or sst;
x25: dffe_1s port map ( d => B64, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => mblt64_cycle);
x26: dffe_1s port map ( d => E64, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => e64_cycle);
x27: dffe_1s port map ( d => S64, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => sst64_cycle);
x28: dffe_1s port map ( d => M64, clk => clk, reset_ns => selected_int, clk_ena => ce_cycle, q => d64_cycle_int);

-- clock enable signal to save internal address
	ce_addr_int <= ce_cycle;
	
-- WAIT until 'data_transfer' asserted (from board select state machine) to select and start cycle - this allows 
-- data access width (8, 16, 32 bits) to be determined (needs 'ds0', 'ds1') for register access (not 'fast_access')	
		select_cycle <= selected_int and data_transfer;
x29: cycle_select_x1 port map ( selected => select_cycle, 
							      intack => intack, 
							   std_cycle => select_std_type, 
								    mblt => select_mblt, 
									  e2 => select_e2, 
									 sst => select_sst, 
									 clk => clk, 
							  sysreset_n => sysreset_n,
							  
								   cycle => cycle, 
								  go_std => go_std, 
								 go_mblt => go_mblt, 
								   go_e2 => go_e2, 
								  go_sst => go_sst_int, 
								  go_int => go_int);
							   
-- std cycle state machine
x30: std_cycle_x5 port map ( go_std, ds, w_n, busy, fast_access, hold_ack, end_of_data, select_multi,
							 token_int, last_board, clk, sysreset_n,
							 dir_a_std, dir_d_std, ack_std, berr_std, read_std, read_stb, write_sig, write_stb,
							 next_data_std, done_data_std, le_std, send_token_std);

-- mblt cycle state machine
x31: mblt_cycle_x3 port map ( go_mblt, as, ds, ds01, end_of_data, select_multi, token_int, last_board, 
							  clk, sysreset,
							  dir_a_mblt, dir_d_mblt, en_data_mblt, ack_mblt, berr_mblt, ce_ap1_mblt, 
							  next_data_mblt, done_data_mblt, le_mblt, send_token_mblt);

-- 2eVME cycle state machine
x32: e2_cycle_x3 port map ( go_e2, end_of_data, select_multi, token_int, last_board, as, ds, ds01, 
							ds0n1, clk, sysreset,
							dir_a_e2, dir_d_e2, en_data_e2, ack_e2, retry_e2, berr_e2, ce_ap1_e2, 
							ce_ap2_e2, ce_ap3_e2, next_data_e2, done_data_e2, en_fill_e2, le_e2, send_token_e2);

-- 2eSST cycle state machine - with token passing
x33: sst_cycle_x5 port map (   go_cycle => go_sst_int, 
								rate_ok => rate_ok, 
							end_of_data => end_of_data, 
							 stop_cycle => stop_cycle, 
						   select_multi => select_multi, 
								  token => token_int, 
								   last => last_board, 
								as_sync => as, 
								ds_sync => ds, 
							  ds01_sync => ds01, 
							 ds0n1_sync => ds0n1, 
								 ack_in => ack_in, 
								berr_in => berr_in, 
									clk => clk, 
								  reset => sysreset,
								  dir_a => dir_a_sst, 
								  dir_d => dir_d_sst, 
								en_data => en_data_sst, 
									ack => ack_sst, 
								  retry => retry_sst, 
								   berr => berr_sst, 
								 ce_ap1 => ce_ap1_sst, 
								 ce_ap2 => ce_ap2_sst, 
								 ce_ap3 => ce_ap3_sst, 
							  next_data => next_data_sst, 
							 count_word => count_word, 
							  done_data => done_data_sst, 
								en_fill => en_fill_sst, 
							 send_token => send_token_sst,
							  sst_state => sst_state );

-- interrupt acknowledge cycle state machine
x34: int_cycle_x1 port map ( go_int, ds, clk, sysreset_n,
							 ack_int, read_int);

-- flag for end of data in block
	end_detect <= en_berr or en_multiboard;		-- detect block trailers under these conditions
x35: end_block_x3 port map ( end_detect, block_trailer, next_data, done_data, clk, reset_sst,
							 end_of_data);

	en_data_std <= a32_cycle_int and w_n;		-- for STD cycles accessing data space

-- output & control signals chosen from active cycle
	ack_mux <= '0' & ack_std & ack_mblt & ack_e2 & ack_sst & ack_int & '0' & '0' ;
	berr_mux <= '0' & berr_std & berr_mblt & berr_e2 & berr_sst & '0' &'0' & '0';
	retry_mux <= '0' & '0' & '0' & retry_e2 & retry_sst & '0' & '0' & '0';
	next_data_mux <= '0' & next_data_std & next_data_mblt & next_data_e2 & next_data_sst & '0' & '0' & '0';
	done_data_mux <= '0' & done_data_std & done_data_mblt & done_data_e2 & done_data_sst & '0' & '0' & '0';
	dir_a_mux <= '0' & '0' & dir_a_mblt & dir_a_e2 & dir_a_sst & '0' & '0' & '0';
	dir_d_mux <= '0' & dir_d_std & dir_d_mblt & dir_d_e2 & dir_d_sst & '1' & '0' & '0';
	ena1_mux <= '0' & ena1_std_n & '1' & '1' & '1' & ena1_int_n & '0' & '0';
	ena3_mux <= '1' & ena3_std_n & '1' & '1' & '1' & '1' & '0' & '0';
	en_fifo_mux <= '0' & en_data_std & en_data_mblt & en_data_e2 & en_data_sst & '0' & '0' & '0';
	
	en_fifo_a_mux <= '0' & '0' & en_data_mblt & en_data_e2 & en_data_sst & '0' & '0' & '0';
	ce_ap1_mux <= '0' & '0' & ce_ap1_mblt & ce_ap1_e2 & ce_ap1_sst & '0' & '0' & '0';
	ce_ap2_mux <= '0' & '0' & '0' & ce_ap2_e2 & ce_ap2_sst & '0' & '0' & '0';
	ce_ap3_mux <= '0' & '0' & '0' & ce_ap3_e2 & ce_ap3_sst & '0' & '0' & '0';
	en_fill_mux <= '0' & '0' & '0' & en_fill_e2 & en_fill_sst & '0' & '0' & '0';
	latch_ena_d_mux <= '0' & le_std & le_mblt & le_e2 & '0' & '0' & '0' & '0';
	latch_ena_a_mux <= '0' & '0' & le_mblt & le_e2 & '0' & '0' & '0' & '0';
	read_sig_mux <= '0' & read_std & '0' & '0' & '0' & read_int & '0' & '0';
	send_token_mux <= '0' & send_token_std & send_token_mblt & send_token_e2 & send_token_sst & '0' & '0' & '0';
	
x36: muxx8_to_1 port map ( ack_mux, cycle, ack_i);
x37: muxx8_to_1 port map ( berr_mux, cycle, berr);
x38: muxx8_to_1 port map ( retry_mux, cycle, retry);
x39: muxx8_to_1 port map ( next_data_mux, cycle, next_data);
x40: muxx8_to_1 port map ( done_data_mux, cycle, done_data);
x41: muxx8_to_1 port map ( dir_a_mux, cycle, dir_a);
x42: muxx8_to_1 port map ( dir_d_mux, cycle, dir_d);
x43: muxx8_to_1 port map ( ena1_mux, cycle, ena1_n);
x44: muxx8_to_1 port map ( ena3_mux, cycle, ena3_n);
x45: muxx8_to_1 port map ( en_fifo_mux, cycle, en_fifo);
x46: muxx8_to_1 port map ( en_fifo_a_mux, cycle, en_fifo_a);
x47: muxx8_to_1 port map ( ce_ap1_mux, cycle, ce_ap1);
x48: muxx8_to_1 port map ( ce_ap2_mux, cycle, ce_ap2);
x49: muxx8_to_1 port map ( ce_ap3_mux, cycle, ce_ap3);
x50: muxx8_to_1 port map ( en_fill_mux, cycle, en_fill);
x51: muxx8_to_1 port map ( latch_ena_d_mux, cycle, latch_ena_d);
x52: muxx8_to_1 port map ( latch_ena_a_mux, cycle, latch_ena_a);
x53: muxx8_to_1 port map ( read_sig_mux, cycle, read_sig);
x54: muxx8_to_1 port map ( send_token_mux, cycle, send_token);
	
-- SST cycle parameters --	
x55: dffe_n generic map ( bitlength => 24 )
			   port map ( 		  d => a(31 downto 8), 
							    clk => clk, 
						    reset_n => reset_n,  
						    clk_ena => ce_ap1, 
							      q => start_adr(31 downto 8));
							    
x56: dffe_n generic map ( bitlength => 8 )
			   port map ( 		  d => a(7 downto 0), 
							    clk => clk, 
						    reset_n => reset_n, 
						    clk_ena => ce_ap2, 
								  q => start_adr(7 downto 0));

x57: dffe_n generic map ( bitlength => 8 )
			   port map ( 		  d => a(15 downto 8), 
							    clk => clk, 
						    reset_n => reset_n, 
						    clk_ena => ce_ap2, 
								  q => cycle_count(7 downto 0));

	n_beats(8 downto 0) <= cycle_count(7 downto 0) & '0';    -- number of beats <= 2x cycle count
	
x58: dffe_n generic map ( bitlength => 4 )
			  port map ( 		 d => d(3 downto 0), 
							   clk => clk,
						   reset_n => reset_n, 
						   clk_ena => ce_ap2, 
							     q => rate(3 downto 0));
							    
	rate_ok <= '1' when (rate(3 downto 0) = "0001") else
			   '1' when (rate(3 downto 0) = "0010") else
			   '0';											-- participate only in 267 or 320 SST cycles
			    										
x59: dffe_1 port map ( ce_ap2, clk, '1', '1', '1', ld_count_sst);	-- load values after captured
		reset_sst <= (not reset_n) or sysreset;

	count_word_sst <= next_data_sst or count_word;

x60: sst_ctrl_2 port map (  start_adr => start_adr(11 downto 0),
							  n_beats => n_beats,
						 load_counter => ld_count_sst,
							 count_up => count_word_sst,
								  clk => clk,
							    reset => reset_sst,
						  current_adr => current_adr,
						current_beats => current_beats,
						   done_beats => done_beats,
						   boundary_0 => boundary_0,
						   boundary_1 => boundary_1,
						   stop_cycle => stop_cycle );
						   
	sst_ctrl(11 downto 0)  <= current_adr;
	sst_ctrl(20 downto 12) <= current_beats;
	sst_ctrl(23 downto 21) <= "000";
	sst_ctrl(24) <= ld_count_sst;
	sst_ctrl(25) <= count_word_sst;
	sst_ctrl(26) <= next_data_sst;
	sst_ctrl(27) <= count_word;
	sst_ctrl(28) <= done_beats;
	sst_ctrl(29) <= stop_cycle;
	sst_ctrl(30) <= reset_sst;
	sst_ctrl(31) <= '0';

x61: token_ctrl_x4 port map (    en_mb => en_multiboard, 
								 first => first_board, 
								  last => last_board, 
							take_token => take_token, 
							  token_in => token_in, 
							 done_data => done_data, 
							send_token => send_token, 
							   ds_sync => ds, 
								   clk => clk, 
								 reset => reset_sst, 
								 token => token_int,
							 token_out => token_out );
	
	modsel_int <= select_single or (select_multi and token_int) or intack ;
	 
	data_cycle_int <= select_single or (select_multi and token_int) ;	-- data cycle
	iack_cycle <= intack ;												-- interrupt acknowledge cycle	 

-----------------------------------------------------------------------------------------
----- for byte selection, use REGISTERED address bits (saved at 'ce_cycle' assertion)
----- in case the master pipelines address (early release and re-asseretion of 'as', 'a()',
----- 'am()' after 'dtack' asserted by slave)
  
----- single byte transfers
	b0    <= (not ds1_n) and      ds0_n  and (not a_reg(1)) and  	 a_reg(0) ;
	b1    <=      ds1_n  and (not ds0_n) and (not a_reg(1)) and      a_reg(0) ;
	b2    <= (not ds1_n) and      ds0_n  and      a_reg(1)  and      a_reg(0) ;
	b3    <=      ds1_n  and (not ds0_n) and      a_reg(1)  and      a_reg(0) ;
	
----- double byte transfers
	b01   <= (not ds1_n) and (not ds0_n) and (not a_reg(1)) and      a_reg(0) ;
	b12   <= (not ds1_n) and (not ds0_n) and      a_reg(1)  and (not a_reg(0)) ;
	b23   <= (not ds1_n) and (not ds0_n) and      a_reg(1)  and      a_reg(0) ;
	
----- triple byte transfers %
	b012  <= (not ds1_n) and      ds0_n  and (not a_reg(1)) and (not a_reg(0)) ;
	b123  <=      ds1_n  and (not ds0_n) and (not a_reg(1)) and (not a_reg(0)) ;
	
----- quad byte transfers
	b0123 <= (not ds1_n) and (not ds0_n) and (not a_reg(1)) and (not a_reg(0)) ;

----- illegal transfers
	bad_1 <=      ds1_n  and (not ds0_n) and  	  a_reg(1)  and (not a_reg(0)) ;
	bad_2 <= (not ds1_n) and      ds0_n  and  	  a_reg(1)  and (not a_reg(0)) ;
	
----- acceptable cycles for 32-bit slave or interrupter
--    normal cycle:  b0, b1, b2, b3, b01, b12, b23, b012, b123, b0123
--      iack cycle:  b1, b3, b01, b23, b0123 (read only!)
	
----- unacceptable data cycles for 32-bit slave or interrupter %
	error_flag <= bad_1 or bad_2
	           or ( (b0 or b2 or b12 or b012 or b123 or (not w_n) ) and (not iack_n) ) ; 
	
-- bytes accessed for acceptable data cycles (REGISTER access only!)
	byte(0) <= (b0 or b01        or b012         or b0123 ) and data_cycle_int;
	byte(1) <= (b1 or b01 or b12 or b012 or b123 or b0123 ) and data_cycle_int;
	byte(2) <= (b2 or b12 or b23 or b012 or b123 or b0123 ) and data_cycle_int;
	byte(3) <= (b3 or b23        or b123         or b0123 ) and data_cycle_int;		
-------------------------------------------------------------------------------

	cycles1 <= b2 or b3 or b12 or b23 or b012 or b123 or b0123;
	cycles3 <= b0 or b1 or b01;
	
x62: dffe_1s port map ( d => cycles1, clk => clk, reset_ns => selected_int, clk_ena => ce_datapath, q => select_cycles1);
x63: dffe_1s port map ( d => cycles3, clk => clk, reset_ns => selected_int, clk_ena => ce_datapath, q => select_cycles3);

-- enables for FPGA transceivers (REGISTER access only - fast_access NOT asserted!)
	ena1_std_n <= not (modsel_int and (not fast_access) and iack_n and selected_int and select_cycles1);
	ena1_int_n <= intack_n;
	ena3_std_n <= not (modsel_int and (not fast_access) and iack_n and selected_int and select_cycles3);
	
	token_in <= (token_in_p0 and en_token_in_p0) or (token_in_p2 and en_token_in_p2);
	
	end_cycle_int <= (not ds) and ack_i;
	done_block_int <= block_trailer and rd_fifo_int;
	selected <= selected_int;
	a32_cycle <= a32_cycle_int;
	d64_cycle <= d64_cycle_int;
	token <= token_int;
	hold_ack <= '0';
	go_sst <= go_sst_int;
	modsel <= modsel_int;
	data_cycle <= data_cycle_int;
	rd_fifo <= rd_fifo_int;
	end_cycle <= end_cycle_int;
	done_block <= done_block_int;
	ce_addr <= ce_addr_int;

x64: berr_status_ctrl port map ( berr, selected_int, a32_cycle_int, clk, reset_sst,
							     berr_status);
							     
-- pipeline register for output signals 'dtack_n', 'oe_dtack', 'retry_n', 'oe_retry', 'berr_n',  
--                               'le_d', 'le_a'
	ack_i_n <= not ack_i;
x65: dffe_1 port map ( ack_i_n, clk, '1', '1', '1', dtack_n );
	ack <= ack_i;

	berr_i_n <= not berr;
x66: dffe_1 port map ( berr_i_n, clk, '1', '1', '1', berr_n );

	retry_i_n <= not retry;
x67: dffe_1 port map ( retry_i_n, clk, '1', '1', '1', retry_n );

	rd_fifo_int <= next_data;

-- enables for VME transceivers
	le_a_i <= not latch_ena_a;			-- latch enable for address transceivers
x68: dffe_1 port map ( le_a_i, clk, '1', '1', '1', le_a );

	le_d_i <= not latch_ena_d;			-- latch enable for data transceivers
x69: dffe_1 port map ( le_d_i, clk, '1', '1', '1', le_d );

x70: dffe_1 port map ( modsel_int, clk, '1', '1', '1', oe_dtack );

x71: dffe_1 port map ( modsel_int, clk, '1', '1', '1', oe_retry );
	
	oe_d1_n <= not modsel_int;
	oe_d2_n <= not modsel_int;
	oe_a_n <= '0';						-- address transceivers are ALWAYS enabled
	clkab_d <= '0';						-- transceiver register clocking not used
	clkba_d <= '0';
	clkab_a <= '0';
	clkba_a <= '0';	
							     		
end a1;

