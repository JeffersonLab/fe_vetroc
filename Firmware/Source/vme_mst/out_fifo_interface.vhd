-- dual 36-bit output FIFO interface and data router

-- For implementing VME D32 or D64 readout (including 2eVME and 2eSST).

--	                  d_fifo1 -> DFF_36 -					  -> VME A(31..0)
--							              \                 /
--							               -> DATA_ROUTE_3 -
--	  						              /				    \ 
--					  d_fifo2 -> DFF_36 -					  -> VME D(31..0)


-- A 72-bit word ( d_fifo1(35..0), d_fifo2(35..0) )is 
-- mapped to a 72-bit output word ( out_a(35..0), out_b(35..0) ).
 
-- always:             d_fifo1  -> out_a
-- if select1_n = '0', d_fifo2  -> out_b   
-- if select1_n = '1', d_fifo2  -> out_b  ???

-- out_a(31..0) drives VME address lines A(31..0) for D64 transfers  
-- out_b(31..0) drives VME data lines D(31..0)

-- select1_n allows the upper or lower portion or the internal word to be
-- applied to out_b (i.e. VME D(31..0)) for D32 transfers

-- The internal data tags (d_fifo1(35..32), d_fifo2(35..0)) along with the empty
-- flags of the fifos are used externally to define the signals dnv1, dnv2, and 
-- filler.

-- dnv1 (dnv2) asserted indicates that the fifo output d_fifo1 (d_fifo2) is NOT VALID.
-- (e.g. output buffer is empty).  A special word ('dnv_word') overwrites the output word.

-- filler asserted forces a special word ('filler_word') onto both output words.
-- (This 'extra' 8-byte word is used with dual-edge VME transfers (2eVME, 2eSST) 
--  that do not end on a 16-byte boundary.)


library ieee;
use ieee.std_logic_1164.all;

entity out_fifo_interface is
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
end out_fifo_interface;

architecture a1 of out_fifo_interface is

	component dff_36 is
		port( 	  d: in std_logic_vector(35 downto 0);
				clk: in std_logic;
			reset_n: in std_logic;
			  set_n: in std_logic;
				  q: out std_logic_vector(35 downto 0));
	end component;

	component data_route4 is
		port(  in_0: in std_logic_vector(35 downto 0);
			   dnv0: in std_logic;
			   in_1: in std_logic_vector(35 downto 0);
			   dnv1: in std_logic;
			 filler: in std_logic;
		   dnv_word: in std_logic_vector(31 downto 0);
		filler_word: in std_logic_vector(31 downto 0);
			  sel_b: in std_logic;
			  out_a: out std_logic_vector(35 downto 0);
			  out_b: out std_logic_vector(35 downto 0));
	end component;

	signal q_reg1: std_logic_vector(35 downto 0);
	signal q_reg2: std_logic_vector(35 downto 0);
	
	signal reset_n: std_logic;
	

begin

	reset_n <= not reset;

x2: dff_36 port map ( 	  d => d_fifo1,
						clk => rdclk,
					reset_n => reset_n,
					  set_n => '1',
						  q => q_reg1 );
			
x4: dff_36 port map ( 	   d => d_fifo2,
						 clk => rdclk,
					 reset_n => reset_n,
					   set_n => '1',
						   q => q_reg2 );
			
x5: data_route4	port map(   in_0 => q_reg1,
							dnv0 => dnv1,
							in_1 => q_reg2,
							dnv1 => dnv2,
						  filler => filler,
						dnv_word => dnv_word,
					 filler_word => filler_word,
						   sel_b => select1_n,
						   out_a => out_a,
						   out_b => out_b );

end a1;

