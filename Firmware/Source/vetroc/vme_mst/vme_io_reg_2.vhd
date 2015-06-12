-- VME I/O -- interface to VME address/data transceivers -- EJ
-- include output register just before tri-state buffer - 9/22/10
-- include input register - 9/27/10
-----------------------------------------------------------------------------------
-- NOTES:
--
-- a_vme(31..0) (bidir, tri-state) tied to VME address tx/rx (a_vme(0) = lword*)
-- d_vme(31..0) (bidir, tri-state) tied to VME data tx/rx
--
-- a_in(31..0) is VME address into chip
--
-- d_in(31..0)  is VME data into chip (VME write)
-- d_out(31..0) is VME data out of chip (register/local bus only) (VME read)
--
-- data1_out(31..0) is VME data out of chip (from main data source 1) (VME read)
-- data2_out(31..0) is VME data out of chip (from main data source 2) (VME read)
--
-- The main data source is assumed to be a 64-bit word.  The most significant half
-- (bits 63-32) is data1_out(31..0).  The least significant half (bits 31-0) is
-- data2_out(31..0).  The data is structured so that data1_out(31..0) may be 
-- driven onto the VME address lines (during D64 read cycles); data2_out(31-0) is 
-- driven only onto the VME data lines.

-- oe_a = '1'  enables data (source 1 only) to be driven onto VME address lines
--             (64-bit VME read)
--
-- oe_d = '1'  enables data (source 2 or register/local bus) to be driven onto 
--             VME data lines (VME read)
--
-- select_d = '0'  selects main data source (1,2) to be driven onto VME data lines
--            '1'  selects register/local bus data source to be driven onto VME 
--                 data lines during read
--  
-- word_shift = '0'  maps register/local data d(31-0)  <=>  vme_d(31-0)
--              '1'  maps register/local data d(31-16) <=>  vme_d(15-0)
--
-- (NOTE: word_shift has NO effect on data read from source 1 or 2)
--  
--  d_in_byte: least significant byte of data input from d_vme (for SST data transfers)
--
-----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity vme_io_reg_2 is
	port( 		a_vme: inout std_logic_vector(31 downto 0);	-- VME address tx/rx
				d_vme: inout std_logic_vector(31 downto 0);	-- VME data tx/rx
							
				 a_in: out std_logic_vector(31 downto 0);	-- address in
				 
				 d_in: out std_logic_vector(31 downto 0);	-- data to local/register bus
			    d_out: in std_logic_vector(31 downto 0);	-- data from local/register bus
			    
			d_in_byte: out std_logic_vector(7 downto 0);	-- least significant byte of data from d_vme
			    
			data1_out: in std_logic_vector(31 downto 0);	-- data from source 1 (main)
			data2_out: in std_logic_vector(31 downto 0);	-- data from source 2 (main)
			
				  clk: in std_logic;						-- clock for pipeline registers
			
				 oe_a: in std_logic;						-- enable for data onto VME address
				 oe_d: in std_logic;						-- enable for data onto VME data
			 select_d: in std_logic;						-- select for data source onto VME data
		   word_shift: in std_logic);						-- control for word mapping (reg/local bus)
end vme_io_reg_2;

architecture a1 of vme_io_reg_2 is

	component io_buffer_reg_2 is
		port(  d: in std_logic_vector(31 downto 0);
			 clk: in std_logic;
			  oe: in std_logic;
			  io: inout std_logic_vector(31 downto 0);
			  fb: out std_logic_vector(31 downto 0));
	end component;

	component io_mux_reg_2 is
		port( 		da: in std_logic_vector(31 downto 0);
					db: in std_logic_vector(31 downto 0);
			 select_ab: in std_logic;
				   clk: in std_logic;
				 oe_ab: in std_logic;
					dt: inout std_logic_vector(31 downto 0);
			 select_in: in std_logic;
				   din: out std_logic_vector(31 downto 0);
			  din_byte: out std_logic_vector(7 downto 0));
	end component;
	
	component vme_tx_rx is
		port( 		da_in: in std_logic_vector(31 downto 0);
				   da_out: out std_logic_vector(31 downto 0);
					db_in: in std_logic_vector(31 downto 0);
				   db_out: out std_logic_vector(31 downto 0);
			   word_shift: in std_logic);
	end component;

	signal data_local_in:  std_logic_vector(31 downto 0);
	signal data_local_out: std_logic_vector(31 downto 0);

begin

-- buffer for address line input and data output (source 1) onto address lines
x1: io_buffer_reg_2 port map (  d => data1_out,
							  clk => clk,
							   oe => oe_a,
							   io => a_vme,
							   fb => a_in );

-- buffer for data line input and data output (local bus or source 2) onto data lines						 
x2:	io_mux_reg_2 port map ( 		da => data2_out,
								    db => data_local_out,
						     select_ab => select_d,
							       clk => clk,
							     oe_ab => oe_d,
									dt => d_vme,
							 select_in => '0',
								   din => data_local_in,
							  din_byte => d_in_byte );

x3: vme_tx_rx port map ( 	  da_in => data_local_in,
						     da_out => data_local_out,
							  db_in => d_out,
						     db_out => d_in,
					     word_shift => word_shift);

end a1;

