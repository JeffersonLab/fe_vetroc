library ieee;
use ieee.std_logic_1164.all;

entity x2_decoder_8b10b is
	generic(
		METHOD		: integer := 1
	);
	port(
		clk			: in std_logic;

		din_dat		: in std_logic_vector(19 downto 0);
		dout_dat		: out std_logic_vector(15 downto 0);
		dout_k		: out std_logic_vector(1 downto 0);
		dout_kerr	: out std_logic_vector(1 downto 0);
		dout_rderr	: out std_logic_vector(1 downto 0);
		dout_rdcomb	: out std_logic_vector(1 downto 0);
		dout_rdreg	: out std_logic_vector(1 downto 0)
	);
end x2_decoder_8b10b;

architecture Synthesis of x2_decoder_8b10b is
	component decoder_8b10b is
		generic(
			METHOD		: integer := 1
		);
		port(
			clk			: in std_logic;
			din_ena		: in std_logic;
			din_dat		: in std_logic_vector(9 downto 0);
			din_rd		: in std_logic;
			dout_val		: out std_logic := '0';
			dout_kerr	: out std_logic := '0';
			dout_dat		: out std_logic_vector(7 downto 0) := "00000000";
			dout_k		: out std_logic := '0';
			dout_rderr	: out std_logic := '0';
			dout_rdcomb	: out std_logic;
			dout_rdreg	: out std_logic := '0'
		);
	end component;
	
	signal dout_rdcomb_i		: std_logic_vector(1 downto 0);
	signal dout_rdreg_i		: std_logic_vector(1 downto 0);
begin

	dout_rdcomb <= dout_rdcomb_i;
	dout_rdreg <= dout_rdreg_i;

	dec1: decoder_8b10b
		generic map(
			METHOD		=> METHOD
		)
		port map(
			clk			=> clk,
    		din_ena		=> '1',
    		din_dat		=> din_dat(19 downto 10),
    		din_rd		=> dout_rdcomb_i(0),
    		dout_val		=> open,
    		dout_kerr	=> dout_kerr(1),
    		dout_dat		=> dout_dat(15 downto 8),
    		dout_k		=> dout_k(1),
    		dout_rderr	=> dout_rderr(1),
			dout_rdcomb	=> dout_rdcomb_i(1),
    		dout_rdreg	=> dout_rdreg_i(1)
		);
	
	dec0: decoder_8b10b
		generic map(
			METHOD		=> METHOD
		)
		port map(
			clk			=> clk,
    		din_ena		=> '1',
    		din_dat		=> din_dat(9 downto 0),
    		din_rd		=> dout_rdreg_i(1),
    		dout_val		=> open,
    		dout_kerr	=> dout_kerr(0),
    		dout_dat		=> dout_dat(7 downto 0),
    		dout_k		=> dout_k(0),
    		dout_rderr	=> dout_rderr(0),
			dout_rdcomb	=> dout_rdcomb_i(0),
    		dout_rdreg	=> dout_rdreg_i(0)
		);

end Synthesis;
