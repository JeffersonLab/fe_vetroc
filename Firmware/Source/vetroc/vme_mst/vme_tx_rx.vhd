----- VME word shifter ----- EJ
--
--  enables VME access to registers/local bus in long words (32-bit), 
--  words (16-bit), or bytes

--  Background:
--  ----------
--	The smallest addressable unit of storage is the byte location, to which 
--  a unique binary address is assigned.  There are four categories of bytes 
--  distinguished by the least significant two bits of their address:
--
--			xx...x00     BYTE(0)
--			xx...x01     BYTE(1)
--			xx...x10     BYTE(2)
--			xx...x11     BYTE(3).
--
--  A set of byte locations differing only in the two least significant bits 
--  defines a four byte BYTE(0-3) group.  
--
--  The VME data transfer protocols allow a master to access 1, 2, 3, or 4 byte 
--  locations from the same group simultaneously:
--
-- 	Single byte access - BYTE(0), BYTE(1), BYTE(2), BYTE(3),
--	Double byte access - BYTE(0-1), BYTE(1-2), BYTE(2-3),
--	Triple byte access - BYTE(0-2), BYTE(1-3),
--	Quad byte access   - BYTE(0-3).
--
--  For example, the 32-bits of data stored in a 4-byte group of a D32 slave may 
--  be accessed by a D32 master in a single bus cycle via the BYTE(0-3) transfer, 
--  or in 4 bus cycles via the BYTE(n) transfer.  However, a 16-bit master would 
--  require a minimum of 2 bus cycles (BYTE(0-1) & BYTE(2-3)) to accomplish the 
--  same data transmission.
--
--  For our 32-bit slave modules, each individual register or memory location is 
--  defined to be a 4-byte group.  The local address given for each register is 
--  the address of BYTE(0) for that register.  Data is stored in the 4-byte 
--  registers as follows:
--
--			D(31..24)	BYTE(0)
--			D(23..16)	BYTE(1)
--			D(15..08)	BYTE(2)
--			D(07..00)	BYTE(3).
--
--  For a quad byte access, the register data bits D(31..0) map 1:1 to the VME bus
--  data lines DBus(31..0).  This 1:1 mapping holds for the following transfers:
--
--  	BYTE(2), BYTE(3), BYTE(1-2), BYTE(2-3), BYTE(0-2), BYTE(1-3), BYTE(0-3).
--
--  *******************************************************************************
--  For the following transfers, the register data bits D(31..16) are mapped to the
--  VME bus data lines DBus(15..0):
--
--		BYTE(0), BYTE(1), BYTE(0-1).
--
--  This allows a 16-bit master (using only DBus(15..0)) to access all bytes of a
--  32-bit slave module.
--  *******************************************************************************
-- 
-----------------------------------------------------------------------------------
--
-- NOTES:
--
-- da(31..0) is VME side, db(31..0) is board side
--
-- word_shift = '0':   D(31..0)  <-> DBus(31..0)   ************
--
-- word_shift = '1':   D(31..16) <-> DBus(15..0)   ************
--				   	     "FFFF"  <-> DBus(31..16)  ************
--
-----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity vme_tx_rx is
	port( 		da_in: in std_logic_vector(31 downto 0);
			   da_out: out std_logic_vector(31 downto 0);
			    db_in: in std_logic_vector(31 downto 0);
			   db_out: out std_logic_vector(31 downto 0);
		   word_shift: in std_logic);
end vme_tx_rx;

architecture a1 of vme_tx_rx is

	component vme_word_select is
		port( 		d_in: in std_logic_vector(31 downto 0);
			  low_select: in std_logic;
			 high_select: in std_logic;
				   d_out: out std_logic_vector(31 downto 0));
	end component;
	
begin

x1: vme_word_select	port map ( 		 d_in => da_in,
							   low_select => word_shift,
							  high_select => word_shift,
								    d_out => db_out );
								    
								    
x2: vme_word_select	port map ( 		 d_in => db_in,
							   low_select => word_shift,
							  high_select => word_shift,
								    d_out => da_out );

end a1;

