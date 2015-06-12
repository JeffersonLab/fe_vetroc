----- synchronize signals - 10/14/10 - EJ

library ieee;
use ieee.std_logic_1164.all;

entity vme_sync is
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
end vme_sync;

architecture a1 of vme_sync is

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
	
	attribute iob: string;
	attribute iob of x1: label is "TRUE";
	attribute iob of x2: label is "TRUE";
	attribute iob of x3: label is "TRUE";
	attribute iob of x4: label is "TRUE";
	attribute iob of x5: label is "TRUE";
	attribute iob of x6: label is "TRUE";
	attribute iob of x7: label is "TRUE";
	attribute iob of x8: label is "TRUE";
	attribute iob of x9: label is "TRUE";
	attribute iob of x10: label is "TRUE";
	attribute iob of x11: label is "TRUE";
	attribute iob of x12: label is "TRUE";

begin	
	
x1: dffe_n generic map ( bitlength => 6 )
			  port map ( 		 d => am, 
							   clk => clk,
						   reset_n => '1', 
						   clk_ena => '1', 
							     q => am_sync );
							     
x2: dffe_1 port map( d => as_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => as_n_sync );

x3: dffe_1 port map( d => iack_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => iack_n_sync );

x4: dffe_1 port map( d => w_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => w_n_sync );

x5: dffe_1 port map( d => ds0_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => ds0_n_sync );

x6: dffe_1 port map( d => ds1_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => ds1_n_sync );

x7: dffe_1 port map( d => iackin_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => iackin_n_sync );

x8: dffe_1 port map( d => dtack_in_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => dtack_in_n_sync );

x9: dffe_1 port map( d => berr_in_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => berr_in_n_sync );

x10: dffe_1 port map( d => retry_in_n, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => retry_in_n_sync );

x11: dffe_1 port map( d => token_in_a, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => token_in_a_sync );

x12: dffe_1 port map( d => token_in_b, clk => clk, reset_n => '1', set_n => '1', clk_ena => '1', q => token_in_b_sync );

end a1;

		     
							    
