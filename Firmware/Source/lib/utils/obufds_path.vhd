library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity obufds_path is
	generic(
		DIFF_INVERT	: boolean := false
	);
	port(
		I	: in std_logic;
		O_P	: out std_logic;
		O_N	: out std_logic
	);
end obufds_path;

architecture Synthesis of obufds_path is
	signal OBUFDS_I		: std_logic;
	signal OBUFDS_O		: std_logic;
	signal OBUFDS_OB		: std_logic;
begin

	DiffInvert_gen_true: if DIFF_INVERT = true generate
		OBUFDS_I <= not I;
		O_P <= OBUFDS_OB;
		O_N <= OBUFDS_O;
	end generate;

	DiffInvert_gen_false: if DIFF_INVERT = false generate
		OBUFDS_I <= I;
		O_P <= OBUFDS_O;
		O_N <= OBUFDS_OB;
	end generate;
	
	OBUFDS_inst: OBUFDS
		generic map(
			IOSTANDARD => "LVDS_25"
		)
		port map(
			O	=> OBUFDS_O,
			OB	=> OBUFDS_OB,
			I	=> OBUFDS_I
		);

end Synthesis;
