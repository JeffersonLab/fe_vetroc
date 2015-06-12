----- io multiplexor with tri-state control onto bi-directional bus
--    input and output registers included in 'io_buffer_reg_2'

--        da: 32-bit data for output to dt
--        db: 32-bit data for output to dt
-- select_ab: 0: da => dt (if oe = 1)
--            1: db => dt (if oe = 1)
--       clk: clock for data input and output data registers
--        oe: output enable for selected data to dt
--        dt: 32-bit bi-directional data bus (pins on FPGA)
--       din: 32-bit data input from dt
-- select_in: 0: dt => din
--            1: FFFFFFFF => din (can keep internal input data bus quiet during reads)
--  din_byte: least significant byte of data input from dt (for SST data transfers)
--			  (not affected by state of select_in)

library ieee;
use ieee.std_logic_1164.all;

entity io_mux_reg_2 is
	port( 		da: in std_logic_vector(31 downto 0);
			    db: in std_logic_vector(31 downto 0);
		 select_ab: in std_logic;
			   clk: in std_logic;
		     oe_ab: in std_logic;
			    dt: inout std_logic_vector(31 downto 0);
		 select_in: in std_logic;
			   din: out std_logic_vector(31 downto 0);
		  din_byte: out std_logic_vector(7 downto 0));
end io_mux_reg_2;

architecture a1 of io_mux_reg_2 is

	component io_buffer_reg_2 is
		port(  d: in std_logic_vector(31 downto 0);
			 clk: in std_logic;
			  oe: in std_logic;
			  io: inout std_logic_vector(31 downto 0);
			  fb: out std_logic_vector(31 downto 0));
	end component;

	component mux2_to_1 is
		generic( bitlength: integer );
		port( d0_in: in std_logic_vector((bitlength-1) downto 0);
			  d1_in: in std_logic_vector((bitlength-1) downto 0);
				sel: in std_logic;
			  d_out: out std_logic_vector((bitlength-1) downto 0));
	end component;
														
	signal d_out_mux: std_logic_vector(31 downto 0);
	signal dt_in: std_logic_vector(31 downto 0);
	
	constant all_ones: std_logic_vector(31 downto 0) := "11111111111111111111111111111111";
	
begin

	din_byte <= dt_in(7 downto 0);

-- select data to output
x1: mux2_to_1 generic map ( bitlength => 32 )
				 port map ( d0_in => da,
							d1_in => db,
						      sel => select_ab,
							d_out => d_out_mux);
							
-- tri-state buffer for output
x2: io_buffer_reg_2 port map (  d => d_out_mux,
							  clk => clk,
							   oe => oe_ab,
							   io => dt,
							   fb => dt_in );
						 
-- select data to input bus (dt or FFFFFFFF)						 
x3: mux2_to_1 generic map ( bitlength => 32 )
				 port map ( d0_in => dt_in,
							d1_in => all_ones,
						      sel => select_in,
							d_out => din);
							
													
end a1;

