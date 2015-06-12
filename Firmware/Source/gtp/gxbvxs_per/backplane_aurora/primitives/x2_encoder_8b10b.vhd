library ieee;
use ieee.std_logic_1164.all;

entity x2_encoder_8b10b is
	generic(
		METHOD	: integer := 1
	);
	port(
		clk		: in std_logic;

		-- Data in is a special code, not all are legal.      
		kin_ena	: in std_logic_vector(1 downto 0);
		ein_dat	: in std_logic_vector(15 downto 0);
		eout_dat	: out std_logic_vector(19 downto 0)
	);
end x2_encoder_8b10b;

architecture Synthesis of x2_encoder_8b10b is
	component encoder_8b10b is
		generic(
			METHOD		: integer := 1
		);
		port(
			clk			: in std_logic;

			kin_ena		: in std_logic;
			ein_ena		: in std_logic;
			ein_dat		: in std_logic_vector(7 downto 0);
			ein_rd		: in std_logic;

			eout_val		: out std_logic := '0';
			eout_dat		: out std_logic_vector(9 downto 0) := "0000000000";
			eout_rdcomb	: out std_logic;
			eout_rdreg	: out std_logic := '0'
		);
	end component;

	signal eout_rdcomb		: std_logic_vector(1 downto 0);
	signal eout_rdreg			: std_logic_vector(1 downto 0);
begin

	encoder_8b10b_inst0: encoder_8b10b
		generic map(
			METHOD		=> METHOD
		)
		port map(
			clk			=> clk,
			kin_ena		=> kin_ena(0),
			ein_ena		=> '1',
			ein_dat		=> ein_dat(7 downto 0),
			ein_rd		=> eout_rdreg(1),
			eout_val		=> open,
			eout_dat		=> eout_dat(9 downto 0),
			eout_rdcomb	=> eout_rdcomb(0),
			eout_rdreg	=> eout_rdreg(0)
		);

	encoder_8b10b_inst1: encoder_8b10b
		generic map(
			METHOD		=> METHOD
		)
		port map(
			clk			=> clk,
			kin_ena		=> kin_ena(1),
			ein_ena		=> '1',
			ein_dat		=> ein_dat(15 downto 8),
			ein_rd		=> eout_rdcomb(0),
			eout_val		=> open,
			eout_dat		=> eout_dat(19 downto 10),
			eout_rdcomb	=> eout_rdcomb(1),
			eout_rdreg	=> eout_rdreg(1)
		);

end Synthesis;
