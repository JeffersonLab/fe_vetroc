----- VME interface 8 -- 8/16/11 -- EJ

----- token support for SST

library ieee;
use ieee.std_logic_1164.all;

entity vme_interface_8 is
	generic( LOCAL_ADDR_SIZE: integer );
	port(            a: inout std_logic_vector(31 downto 0);	-- vme bus signals
		            am: in std_logic_vector(5 downto 0);
		          as_n: in std_logic;
		        iack_n: in std_logic;
		           w_n: in std_logic;
		         ds0_n: in std_logic;
		         ds1_n: in std_logic;
		            dt: inout std_logic_vector(31 downto 0);
		            
		    dtack_in_n: in std_logic;
		     berr_in_n: in std_logic; 
		    sysreset_n: in std_logic;
		       dtack_n: out std_logic;
		        berr_n: out std_logic;
		       retry_n: out std_logic;

				 i_lev: in std_logic_vector(2 downto 0);
		      iackin_n: in std_logic;
		     iackout_n: out std_logic;
				 irq_n: out std_logic_vector(7 downto 1);
------------------------------------------------------------------------------------------
																-- vme tx/rx chip controls
		       oe_d1_n: out std_logic;							-- (data 15..0)						
		       oe_d2_n: out std_logic;							-- (data 31..16)
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
------------------------------------------------------------------------------------------				 
			   d_fifo1: in std_logic_vector(35 downto 0);	-- data from output fifo 1 (data(71..36))
			    empty1:	in std_logic;						-- fifo 1 empty flag		 
			    rdreq1:	out std_logic;						-- fifo 1 read request (synced to clk_x2)		 
			   d_fifo2: in std_logic_vector(35 downto 0);	-- data from output fifo 2 (data(35..0))			 
			    empty2:	in std_logic;						-- fifo 2 empty flag		 
			    rdreq2:	out std_logic;						-- fifo 2 read request (synced to clk_x2)		 
				 
		      d_reg_in: out std_logic_vector(31 downto 0);	-- data for write to A24 register space of module
		     d_reg_out: in std_logic_vector(31 downto 0);	-- data from read of A24 register space of module

		      intr_stb: in std_logic;						-- assert to trigger interrupt request by module		         		     
------------------------------------------------------------------------------------------				 
		         adr24: in std_logic_vector(23 downto LOCAL_ADDR_SIZE);	-- A24 address of module (A23...local_addr_size)
		         adr32: in std_logic_vector(8 downto 0);	-- A32 address of module (A31...A23) (8 MB)
		      en_adr32: in std_logic;						-- assert to enable A32 addressing of module
		    adr32m_min: in std_logic_vector(8 downto 0);	-- minimum A32 multiboard address of module (A31...A23)
		    adr32m_max: in std_logic_vector(8 downto 0);	-- maximum A32 multiboard address of module (A31...A23)
		     en_adr32m: in std_logic;						-- assert to enable common A32 multiboard addressing of module
------------------------------------------------------------------------------------------				 
		 en_multiboard: in std_logic;						-- assert to enable multiboard token passing protocol
		   first_board: in std_logic;						-- assert to identify module as first in multiboard set
		    last_board: in std_logic;						-- assert to identify module as last in multiboard set
		en_token_in_p0: in std_logic;						-- assert to enable module to accept token in from p0
		   token_in_p0: in std_logic;						-- token in from previous module on p0
		en_token_in_p2: in std_logic;						-- assert to enable module to accept token in from p2
		   token_in_p2: in std_logic;						-- token in from previous module on p2
		    take_token: in std_logic;						-- assert to force first module to recover token
------------------------------------------------------------------------------------------				 		  
		          busy: in std_logic;						-- assert to hold off ack (wait for register data)
		   fast_access: in std_logic;						-- assert for read of main data (fifo)
------------------------------------------------------------------------------------------				 		   
		        modsel: out std_logic;
				  addr: out std_logic_vector((LOCAL_ADDR_SIZE - 1) downto 0);	-- latched local address
				  byte: out std_logic_vector(3 downto 0);	-- bytes selected for register access
		    data_cycle: out std_logic;						-- asserted for data cycle
		    iack_cycle: out std_logic;						-- asserted for interrupt ack cycle
			  read_sig: out std_logic;						-- asserted during register read cycle
			  read_stb: out std_logic;						-- pulse (1 clk) to latch data for read
			 write_sig: out std_logic;						-- asserted during register write cycle
			 write_stb: out std_logic;						-- pulse (1 clk) to latch data for write
		     a24_cycle: out std_logic;						-- asserted for A24 address access
		     a32_cycle: out std_logic;						-- asserted for A32 address access
		    a32m_cycle: out std_logic;						-- asserted for A32 multiboard address access
		     d64_cycle: out std_logic;						-- asserted for D64 data access (read only)
		     end_cycle: out std_logic;						-- asserted to signal end of current vme cycle
		   berr_status: out std_logic;						-- asserted if BERR has been driven for cycle
			   ds_sync: out std_logic;						-- OR (positive asserted) of VME data strobes (sync to clk_x2)
			  w_n_sync: out std_logic;						-- VME write signal (sync to clk_x2)
------------------------------------------------------------------------------------------				 		       
		         token: out std_logic;						-- asserted when module has token
		     token_out: out std_logic;						-- pulse to transfer token to next module
		    done_block: out std_logic;						-- asserted when block of events has been extracted
------------------------------------------------------------------------------------------				 		       		       
		       en_berr: in std_logic;						-- enable BERR response of module
------------------------------------------------------------------------------------------				 		       		       
		 ev_count_down: out std_logic;						-- use to decrement event counter (events on board)
		  event_header: out std_logic;						-- asserted when data word is an event header
		  block_header: out std_logic;						-- asserted when data word is a block header
		 block_trailer: out std_logic;						-- asserted when data word is a block trailer
------------------------------------------------------------------------------------------				 		       		       
		        clk_x2: in std_logic;						-- clk_x2, clk_x4 are in phase
		        clk_x4: in std_logic;						-- (may be same frequency as clk_x2, or 2x clk_x2)
		         reset: in std_logic;
------------------------------------------------------------------------------------------				 		       		       		         
		      dnv_word: in std_logic_vector(31 downto 0);	-- word output when no valid data is available (empty)
		   filler_word: in std_logic_vector(31 downto 0);   -- word output as a filler for 2eVME and 2eSST cycles
		   
		          temp: out std_logic_vector(31 downto 0);  -- for debug
		     sst_state: out std_logic_vector(16 downto 0);
		      sst_ctrl: out std_logic_vector(31 downto 0));
				 		         
end vme_interface_8;


architecture a1 of vme_interface_8 is

	component vme_io_reg_2 is
		port( 		a_vme: inout std_logic_vector(31 downto 0);	-- VME address tx/rx
					d_vme: inout std_logic_vector(31 downto 0);	-- VME data tx/rx
							
					 a_in: out std_logic_vector(31 downto 0);	-- address in
				 
					 d_in: out std_logic_vector(31 downto 0);	-- data to local/register bus
					d_out: in std_logic_vector(31 downto 0);	-- data from local/register bus
			    
				d_in_byte: out std_logic_vector(7 downto 0);	-- least significant byte of data from d_vme
			    
				data1_out: in std_logic_vector(31 downto 0);	-- data from source 1 (main)
				data2_out: in std_logic_vector(31 downto 0);	-- data from source 2 (main)
				
					  clk: in std_logic;						-- clock for pipeline register
			
					 oe_a: in std_logic;						-- enable for data onto VME address
					 oe_d: in std_logic;						-- enable for data onto VME data
				 select_d: in std_logic;						-- select for data source onto VME data
			   word_shift: in std_logic);						-- control for word mapping (reg/local bus)
	end component;

	component interface_24 is
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
	end component;

	component buffer_out_ctrl_12 is
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
	end component;
	
	component out_fifo_interface is
		port(  	d_fifo1: in std_logic_vector(35 downto 0);  -- data from fifo1 (bits 71-36) 
				d_fifo2: in std_logic_vector(35 downto 0);  -- data from fifo2 (bits 35-0)
				  rdclk: in std_logic;						-- fifo read side clock
				  reset: in std_logic;
		      
				  out_a: out std_logic_vector(35 downto 0);
				  out_b: out std_logic_vector(35 downto 0);
			  
				   dnv1: in std_logic;
				   dnv2: in std_logic;
				 filler: in std_logic;
			   dnv_word: in std_logic_vector(31 downto 0);
			filler_word: in std_logic_vector(31 downto 0);
			  select1_n: in std_logic);
	end component;
	
	signal reset_n: std_logic;
	signal ack: std_logic;
	signal din_byte: std_logic_vector(7 downto 0);
	signal a_in: std_logic_vector(31 downto 0);
	signal oe_a, oe_d: std_logic;
	signal out_a, out_b: std_logic_vector(35 downto 0);

	signal oe_a_n_int: std_logic;
	signal select_out1_n: std_logic;
	signal latch_ena, mem_bypass: std_logic;
	signal le_d_int: std_logic;
	signal d64_cycle_int: std_logic;
	signal block_trailer_int: std_logic;
	signal word_shift: std_logic;
	signal select_d: std_logic;
	signal dir_d_int: std_logic;

	signal ena1_n, ena3_n: std_logic;
	signal en_fifo, en_fifo_a, rd_fifo, en_fill: std_logic;
	signal dnv_1, dnv_2: std_logic;
	signal selected, go_sst: std_logic;
		
begin

	reset_n <= not reset;
	latch_ena <= not le_d_int;
	oe_a <= not oe_a_n_int;
	word_shift <= not ena3_n;
	select_d <= not en_fifo;
	dir_d <= dir_d_int;
	
	le_d <= le_d_int;
	d64_cycle <= d64_cycle_int;
	block_trailer <= block_trailer_int;
	oe_a_n <= oe_a_n_int;
	oe_d <= dir_d_int and (en_fifo or (not ena3_n) or (not ena1_n));

x1: out_fifo_interface 	port map (  	d_fifo1 => d_fifo1, 
										d_fifo2 => d_fifo2,
										  rdclk => clk_x2,
										  reset => reset,
		      
										  out_a => out_a,
										  out_b => out_b,
			  
										   dnv1 => dnv_1,
										   dnv2 => dnv_2,
										 filler => en_fill,
									   dnv_word => dnv_word,
									filler_word => filler_word,
									  select1_n => select_out1_n);
	
x2:	buffer_out_ctrl_12 port map (  	   selected => selected,
											 le => latch_ena,
										 go_sst => go_sst,
									  next_data => rd_fifo,
										  tag_0 => d_fifo1(35 downto 32),
										  tag_1 => d_fifo2(35 downto 32),
								   buff_empty_0 => empty1,
								   buff_empty_1 => empty2,
									  d64_cycle => d64_cycle_int,
										 stream => '0',
								buff_select_ext => '0',
											clk => clk_x4,
										  reset => reset,
				
									  select0_n => select_out1_n,
									  rd_buff_0 => rdreq1,
									  rd_buff_1 => rdreq2,
								  ev_count_down => ev_count_down,
								   event_header => event_header,
								   block_header => block_header,
								  block_trailer => block_trailer_int,
										  dnv_0 => dnv_1,
										  dnv_1 => dnv_2 );
									
x3:	vme_io_reg_2 port map ( 	a_vme => a,
								d_vme => dt,
							
								 a_in => a_in,
				 
								 d_in => d_reg_in,
								d_out => d_reg_out,
			    
							d_in_byte => din_byte,
			    
							data1_out => out_a(31 downto 0),
							data2_out => out_b(31 downto 0),
							
								  clk => clk_x2,
			
								 oe_a => en_fifo_a,
								 oe_d => oe_d,
							 select_d => select_d,
						   word_shift => word_shift );

x4:	interface_24 generic map( LOCAL_ADDR_SIZE => LOCAL_ADDR_SIZE )
				 port map (             a => a_in,
									   am => am,
									 as_n => as_n,
								   iack_n => iack_n,
									  w_n => w_n,
									ds0_n => ds0_n,
									ds1_n => ds1_n,
										d => din_byte(3 downto 0),
		         
								  en_berr => en_berr,
							   dtack_in_n => dtack_in_n,
								berr_in_n => berr_in_n,
								retry_in_n => '1',
									 busy => busy,
							  fast_access => fast_access,
							block_trailer => block_trailer_int,
							  token_in_p0 => token_in_p0,
						   en_token_in_p0 => en_token_in_p0,
							  token_in_p2 => token_in_p2,
						   en_token_in_p2 => en_token_in_p2,
							en_multiboard => en_multiboard,
							  first_board => first_board,
							   last_board => last_board,
							   take_token => take_token,
		      
								 intr_stb => intr_stb,
								 iackin_n => iackin_n,
									i_lev => i_lev(2 downto 0),
		         
									 sw_a => adr32(8 downto 0),
								 en_adr32 => en_adr32,
									 sw_b => adr24,
									 sw_c => adr32m_min(8 downto 0),
									 sw_d => adr32m_max(8 downto 0),
								en_adr_mb => en_adr32m,
		     
									  clk => clk_x2,
								  reset_n => reset_n,
							   sysreset_n => sysreset_n,
		  
									 addr => addr,
								  dtack_n => dtack_n,
								   berr_n => berr_n,
								  retry_n => retry_n,
									  ack => ack,
								  ds_sync => ds_sync,
								 w_n_sync => w_n_sync,
								end_cycle => end_cycle,
								 read_sig => read_sig,
								write_sig => write_sig,
								 read_stb => read_stb,
								write_stb => write_stb,
									 byte => byte,
								   modsel => modsel,
								   ena1_n => ena1_n,
								   ena3_n => ena3_n,
								  oe_d1_n => oe_d1_n,
								  oe_d2_n => oe_d2_n,
							   data_cycle => data_cycle,
							   iack_cycle => iack_cycle,
								a24_cycle => a24_cycle,
								a32_cycle => a32_cycle,
							   a32m_cycle => a32m_cycle,
								d64_cycle => d64_cycle_int,
								  en_fifo => en_fifo,
								en_fifo_a => en_fifo_a,
								  rd_fifo => rd_fifo,
								  en_fill => en_fill,
							  berr_status => berr_status,
							     selected => selected,
								 oe_dtack => oe_dtack,
								 oe_retry => oe_retry,
									dir_a => dir_a,
									dir_d => dir_d_int,
								   oe_a_n => oe_a_n_int,
									 le_d => le_d_int,
								  clkab_d => clkab_d,
								  clkba_d => clkba_d,
								     le_a => le_a,
								  clkab_a => clkab_a,
								  clkba_a => clkba_a,
		       
								   go_sst => go_sst,
									token => token,
								token_out => token_out,
							   done_block => done_block,
		       		       
								iackout_n => iackout_n,
									irq_n => irq_n,
									
									 temp => temp,
								sst_state => sst_state,
								 sst_ctrl => sst_ctrl );

end a1;






		

		  
		  