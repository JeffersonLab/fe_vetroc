library ieee;
use ieee.std_logic_1164.all;

-- 32-bit tri-state in/out buffer with input and output registers

--   d: 32-bit data for output to io
-- clk: clock for data
--  oe: output enable for d
--  io: 32-bit tri-state in/out data
--  fb: 32-bit data input from io

entity io_buffer_reg_2 is
	port(  d: in std_logic_vector(31 downto 0);
		 clk: in std_logic;
		  oe: in std_logic;
		  io: inout std_logic_vector(31 downto 0);
		  fb: out std_logic_vector(31 downto 0));
end io_buffer_reg_2;

architecture a1 of io_buffer_reg_2 is

	component dffe_n is
		generic( bitlength : integer );
		port( 	  d: in std_logic_vector((bitlength - 1) downto 0);
				clk: in std_logic;
			reset_n: in std_logic;
			clk_ena: in std_logic;
				  q: out std_logic_vector((bitlength - 1) downto 0));
	end component;

	constant all_z: std_logic_vector(31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

	signal d_reg: std_logic_vector(31 downto 0); 
	signal fb_int: std_logic_vector(31 downto 0); 

	attribute iob: string;
	attribute iob of out_reg: label is "TRUE";
	attribute iob of in_reg: label is "TRUE";

begin

out_reg: dffe_n generic map ( bitlength => 32 )
			  port map ( 	  d => d,
							clk => clk,
						reset_n => '1',
						clk_ena => '1',
							  q => d_reg );
							  
	fb_int <= io;

in_reg: dffe_n generic map ( bitlength => 32 )
			  port map ( 	  d => fb_int,
							clk => clk,
						reset_n => '1',
						clk_ena => '1',
							  q => fb );
	
p1:	process (d_reg, oe)
	begin			
		if oe = '1' then io <= d_reg;
		else io <= all_z;
		end if;
	end process p1;
	
end a1;

		   