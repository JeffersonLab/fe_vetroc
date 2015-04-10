----- VME interface for FADC --	8/11/11 --  EJ

library ieee;
use ieee.std_logic_1164.all;

entity interface_24 is
	generic( LOCAL_ADDR_SIZE: integer );
	port(            a: in std_logic_vector(31 downto 0);
		            am: in std_logic_vector(5 downto 0);
		          as_n: in std_logic;
		        iack_n: in std_logic;
		           w_n: in std_logic;
		         ds0_n: in std_logic;
		         ds1_n: in std_logic;
		             d: in std_logic_vector(3 downto 0);
		         
		       en_berr: in std_logic;
		    dtack_in_n: in std_logic;
		     berr_in_n: in std_logic;
		    retry_in_n: in std_logic;
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
		      
		      intr_stb: in std_logic;
		      iackin_n: in std_logic;
				 i_lev: in std_logic_vector(3 downto 1);
		         
		          sw_a: in std_logic_vector(31 downto 23);
		      en_adr32: in std_logic;
		          sw_b: in std_logic_vector(23 downto LOCAL_ADDR_SIZE);
		          sw_c: in std_logic_vector(31 downto 23);
		          sw_d: in std_logic_vector(31 downto 23);
		     en_adr_mb: in std_logic;
		     
		           clk: in std_logic;
		       reset_n: in std_logic;
		    sysreset_n: in std_logic;
		  
		          addr: out std_logic_vector((LOCAL_ADDR_SIZE - 1) downto 0);
		       dtack_n: out std_logic;
		        berr_n: out std_logic;
		       retry_n: out std_logic;
		           ack: out std_logic;
		       ds_sync: out std_logic;
		      w_n_sync: out std_logic;
		     end_cycle: out std_logic;
		      read_sig: out std_logic;
		     write_sig: out std_logic;
		      read_stb: out std_logic;
		     write_stb: out std_logic;
		          byte: out std_logic_vector(3 downto 0);
		        modsel: out std_logic;
		        ena1_n: out std_logic;
		        ena3_n: out std_logic;
		       oe_d1_n: out std_logic;
		       oe_d2_n: out std_logic;
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
		       
		        go_sst: out std_logic;
		         token: out std_logic;
		     token_out: out std_logic;
		    done_block: out std_logic;
		       		       
		     iackout_n: out std_logic;
				 irq_n: out std_logic_vector(7 downto 1);
		          temp: out std_logic_vector(31 downto 0);
		     sst_state: out std_logic_vector(16 downto 0);
		      sst_ctrl: out std_logic_vector(31 downto 0));
end interface_24;

architecture a1 of interface_24 is

	component compare is
		generic( bitlength: integer );
		port(    a,b: in std_logic_vector((bitlength - 1) downto 0);
			  a_eq_b: out std_logic;
			  a_gt_b: out std_logic;
			  a_lt_b: out std_logic );
	end component;
	
	component dffe_n is
		generic( bitlength : integer );
		port( 	  d: in std_logic_vector((bitlength - 1) downto 0);
				clk: in std_logic;
			reset_n: in std_logic;
			clk_ena: in std_logic;
				  q: out std_logic_vector((bitlength - 1) downto 0));
	end component;
		
	component vme_sync is
		port(  		  	 am: in std_logic_vector(5 downto 0);
					   as_n: in std_logic;
					 iack_n: in std_logic;
						w_n: in std_logic;
					  ds0_n: in std_logic;
					  ds1_n: in std_logic;
				   iackin_n: in std_logic;
				 dtack_in_n: in std_logic;
				  berr_in_n: in std_logic;
				 retry_in_n: in std_logic;
				 token_in_a: in std_logic;
				 token_in_b: in std_logic;
						clk: in std_logic;
				 
					am_sync: out std_logic_vector(5 downto 0);
				  as_n_sync: out std_logic;
				iack_n_sync: out std_logic;
				   w_n_sync: out std_logic;
				 ds0_n_sync: out std_logic;
				 ds1_n_sync: out std_logic;
			  iackin_n_sync: out std_logic;
			dtack_in_n_sync: out std_logic;
			 berr_in_n_sync: out std_logic;
			retry_in_n_sync: out std_logic;
			token_in_a_sync: out std_logic;
			token_in_b_sync: out std_logic );
	end component;

	component intr3 is
		port( int_stb: in std_logic;
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
	end component;
	
	component v64xblk_x8 is
		port(        a: in std_logic_vector(31 downto 0);
		            am: in std_logic_vector(5 downto 0);
		          as_n: in std_logic;
		        iack_n: in std_logic;
		           w_n: in std_logic;
		         ds0_n: in std_logic;
		         ds1_n: in std_logic;
		             d: in std_logic_vector(3 downto 0);
		         
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
		          temp: out std_logic_vector(31 downto 0);
			 sst_state: out std_logic_vector(16 downto 0);	
		      sst_ctrl: out std_logic_vector(31 downto 0));
	end component;

	signal cmp_a1: std_logic;
	signal cmp_c1, cmp_c2: std_logic;
	signal cmp_d3: std_logic;
	signal match24, match32, match32m: std_logic;
	signal as_out: std_logic;	
	signal iackout: std_logic;	
	signal addr_reg: std_logic_vector(31 downto 0);
	signal aa: std_logic_vector(31 downto 0);
	signal am_reg: std_logic_vector(5 downto 0);
	signal as, iack_reg_n, ce_addr, intack_n, match16: std_logic;
	signal sw_b_s: std_logic_vector(23 downto LOCAL_ADDR_SIZE);
	
	signal am_sync:	std_logic_vector(5 downto 0);
	signal as_n_sync, iack_n_sync, w_n_sync_int, ds0_n_sync, ds1_n_sync, iackin_n_sync: std_logic;
	signal dtack_in_n_sync, berr_in_n_sync, retry_in_n_sync, token_in_p0_sync, token_in_p2_sync: std_logic;
		
begin

	w_n_sync <= w_n_sync_int;

x0: dffe_n generic map ( bitlength => 32 )
			  port map ( 	  	 d => a,
							   clk => clk,
						   reset_n => sysreset_n,
						   clk_ena => ce_addr,
								 q => addr_reg );
								 
	addr <= addr_reg((LOCAL_ADDR_SIZE - 1) downto 0);

x1: dffe_n generic map ( bitlength => (24 - LOCAL_ADDR_SIZE) )		----- sync switch for FPGA timing analysis
			  port map ( 	  	 d => sw_b(23 downto LOCAL_ADDR_SIZE),
							   clk => clk,
						   reset_n => '1',
						   clk_ena => '1',
								 q => sw_b_s(23 downto LOCAL_ADDR_SIZE));

x2:	compare generic map ( bitlength => (24 - LOCAL_ADDR_SIZE) ) 	----- A24 match
			   port map (      a => a(23 downto LOCAL_ADDR_SIZE),
						       b => sw_b_s(23 downto LOCAL_ADDR_SIZE),
						  a_eq_b => match24,
						  a_gt_b => open,
						  a_lt_b => open );
	
x3:	compare generic map ( bitlength => 9 )							----- A32 match
			   port map (      a => a(31 downto 23),
						       b => sw_a(31 downto 23),
						  a_eq_b => cmp_a1,
						  a_gt_b => open,
						  a_lt_b => open );
	
x4:	compare generic map ( bitlength => 9 )							----- A32m match
			   port map (      a => a(31 downto 23),
						       b => sw_c(31 downto 23),
						  a_eq_b => cmp_c1,
						  a_gt_b => cmp_c2,
						  a_lt_b => open );
	
x5:	compare generic map ( bitlength => 9 )
			   port map (      a => a(31 downto 23),
						       b => sw_d(31 downto 23),
						  a_eq_b => open,
						  a_gt_b => open,
						  a_lt_b => cmp_d3 );
	
	match16 <= '0';
	match32 <= cmp_a1 and en_adr32;
	match32m <= (cmp_c1 or cmp_c2) and cmp_d3 and en_adr32;
		
x6: vme_sync port map (  		  	 am => am,
								   as_n => as_n,
								 iack_n => iack_n,
									w_n => w_n,
								  ds0_n => ds0_n,
								  ds1_n => ds1_n,
							   iackin_n => iackin_n,
							 dtack_in_n => dtack_in_n,
							  berr_in_n => berr_in_n,
							 retry_in_n => retry_in_n,
							 token_in_a => token_in_p0,
							 token_in_b => token_in_p2,
									clk => clk,
				 
								am_sync => am_sync,
							  as_n_sync => as_n_sync,
							iack_n_sync => iack_n_sync,
							   w_n_sync => w_n_sync_int,
							 ds0_n_sync => ds0_n_sync,
							 ds1_n_sync => ds1_n_sync,
						  iackin_n_sync => iackin_n_sync,
						dtack_in_n_sync => dtack_in_n_sync,
						 berr_in_n_sync => berr_in_n_sync,
						retry_in_n_sync => retry_in_n_sync,
						token_in_a_sync => token_in_p0_sync,
						token_in_b_sync => token_in_p2_sync );
						
	ds_sync <= not (ds0_n_sync and ds1_n_sync);

x7:	intr3 port map (  int_stb => intr_stb,
						    a => a(3 downto 1),
						 as_n => as_n_sync,
						ds0_n => ds0_n_sync,
					  reset_n => reset_n,
					 iackin_n => iackin_n_sync,
						i_lev => i_lev,
						  clk => clk,
					iackout_n => iackout_n,
					 intack_n => intack_n,
						irq_n => irq_n);
  	
x8: v64xblk_x8 port map (        a => a,
								am => am_sync,
							  as_n => as_n_sync,
							iack_n => iack_n_sync,
							   w_n => w_n_sync_int,
							 ds0_n => ds0_n_sync,
							 ds1_n => ds1_n_sync,
								 d => d(3 downto 0),
		         
						   match16 => match16,
						   match24 => match24,
						   match32 => match32,
						  match32m => match32m,
							 a_reg => addr_reg(7 downto 0),
		       
						  intack_n => intack_n,
						   en_berr => en_berr,
						dtack_in_n => dtack_in_n_sync,
						 berr_in_n => berr_in_n_sync,
							  busy => busy,
					   fast_access => fast_access,
					 block_trailer => block_trailer,
					   token_in_p0 => token_in_p0_sync,
					en_token_in_p0 => en_token_in_p0,
					   token_in_p2 => token_in_p2_sync,
					en_token_in_p2 => en_token_in_p2,
					 en_multiboard => en_multiboard,
					   first_board => first_board,
						last_board => last_board,
						take_token => take_token,
		      		         		     
							   clk => clk,
						   reset_n => reset_n,
						sysreset_n => sysreset_n,
		  
						   dtack_n => dtack_n,
							berr_n => berr_n,
						   retry_n => retry_n,
						  oe_dtack => oe_dtack,
						  oe_retry => oe_retry,
							 dir_a => dir_a,
							 dir_d => dir_d,
							oe_a_n => oe_a_n,
							  le_d => le_d,
						   clkab_d => clkab_d,
						   clkba_d => clkba_d,
							  le_a => le_a,
						   clkab_a => clkab_a,
						   clkba_a => clkba_a,
							ena1_n => ena1_n,
							ena3_n => ena3_n,
						   oe_d1_n => oe_d1_n,
						   oe_d2_n => oe_d2_n,
		       
						   ce_addr => ce_addr,
							   ack => ack,
						 end_cycle => end_cycle,
						  read_sig => read_sig,
						 write_sig => write_sig,
						  read_stb => read_stb,
						 write_stb => write_stb,
							  byte => byte,
							modsel => modsel,
						data_cycle => data_cycle,
						iack_cycle => iack_cycle,
						 a24_cycle => a24_cycle,
						 a32_cycle => a32_cycle,
						a32m_cycle => a32m_cycle,
						 d64_cycle => d64_cycle,
						   en_fifo => en_fifo,
						 en_fifo_a => en_fifo_a,
						   rd_fifo => rd_fifo,
						   en_fill => en_fill,
					   berr_status => berr_status,
						  selected => selected,		       
							go_sst => go_sst,
							 token => token,
						 token_out => token_out,
						done_block => done_block,
							  temp => temp,
						 sst_state => sst_state,
						  sst_ctrl => sst_ctrl );
				       
end a1;






		

		  
		  