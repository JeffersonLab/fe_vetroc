-- Output data router with special word insertion
-- (this version uses external words to insert - 9/15/10)

-- For implementing VME D32 or D64 readout (including 2eVME and 2eSST).

-- A 72-bit internal word ( in_0(35..0), in_1(35..0) )is 
-- mapped to a 72-bit output word ( out_a(35..0), out_b(35..0) ).
 
-- always:         in_0 -> out_a
-- if sel_b = '0', in_0 -> out_b   
-- if sel_b = '1', in_1 -> out_b

-- out_a(31..0) drives VME address lines A(31..0) for D64 transfers  
-- out_b(31..0) drives VME data lines D(31..0)

-- sel_b allows the upper or lower portion or the internal word to be
-- applied to out_b (i.e. VME D(31..0)) for D32 transfers

-- dnv0 (dnv1) asserted indicates that the data on in_0 (in_1) is NOT VALID.
-- (e.g. output buffer is empty).  A special word ('dnv_word') is written onto
-- the output word.

-- filler asserted forces a special word ('filler_word') onto both output words.
-- (This 'extra' 8-byte word is used with dual-edge VME transfers 
-- (2eVME, 2eSST) that do not end on a 16-byte boundary.)


library ieee;
use ieee.std_logic_1164.all;

entity data_route4 is
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
end data_route4;

architecture a1 of data_route4 is

	component tag_special_2 is
		port(  input: in std_logic_vector(35 downto 0);
			     dnv: in std_logic;
		    dnv_word: in std_logic_vector(31 downto 0);
		      filler: in std_logic;
	     filler_word: in std_logic_vector(31 downto 0);
			  output: out std_logic_vector(35 downto 0));
	end component;

	component mux36_2_to_1 is
		port( da_in: in std_logic_vector(35 downto 0);
			  db_in: in std_logic_vector(35 downto 0);
				sel: in std_logic;
			  d_out: out std_logic_vector(35 downto 0));
	end component;

	signal in_0_int: std_logic_vector(35 downto 0);
	signal in_1_int: std_logic_vector(35 downto 0);

begin

x1:	tag_special_2 port map (  input => in_0,
							    dnv => dnv0,
						   dnv_word => dnv_word,
						     filler => filler,
						filler_word => filler_word,
						     output => in_0_int);

x2:	tag_special_2 port map (  input => in_1,
							    dnv => dnv1,
						   dnv_word => dnv_word,
						     filler => filler,
						filler_word => filler_word,
						     output => in_1_int);

x3: mux36_2_to_1 port map ( da_in => in_0_int,
							db_in => in_1_int,
							  sel => sel_b,
							d_out => out_b);

	out_a <= in_0_int;

end a1;

