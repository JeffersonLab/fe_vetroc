library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity ibufds_path is
	generic(
		DIFF_INVERT	: boolean := false;
		SYNC_STAGES	: integer := 2
	);
	port(
		CLK			: in std_logic;
		IN_P			: in std_logic;
		IN_N			: in std_logic;
		OUT_ASYNC	: out std_logic;
		OUT_SYNC		: out std_logic
	);
end ibufds_path;

architecture Synthesis of ibufds_path is
	signal O			: std_logic;
	signal OB		: std_logic;
	signal I			: std_logic;
	signal IB		: std_logic;
	signal O_SEL	: std_logic;
begin

	OUT_ASYNC <= O_SEL;

	DiffInvert_gen_true: if DIFF_INVERT = true generate
		I <= IN_N;
		IB <= IN_P;
		O_SEL <= OB;
	end generate;

	DiffInvert_gen_false: if DIFF_INVERT = false generate
		I <= IN_P;
		IB <= IN_N;
		O_SEL <= O;
	end generate;

	Sync_gen_1: if SYNC_STAGES = 1 generate
		process(CLK)
		begin
			if rising_edge(CLK) then
				OUT_SYNC <= O_SEL;
			end if;
		end process;
	end generate;

	Sync_gen_2: if SYNC_STAGES > 1 generate
		signal O_SEL_Q		: std_logic_vector(SYNC_STAGES-1 downto 0);
	begin
		process(CLK)
		begin
			if rising_edge(CLK) then
				O_SEL_Q <= O_SEL_Q(SYNC_STAGES-2 downto 0) & O_SEL;
			end if;
		end process;
		OUT_SYNC <= O_SEL_Q(SYNC_STAGES-1);
	end generate;

	IBUFDS_inst: IBUFDS_DIFF_OUT
		generic map(
			DIFF_TERM	=> TRUE,
			IOSTANDARD	=> "LVDS_25"
		)
		port map(
			O	=> O,
			OB	=> OB,
			I	=> I,
			IB	=> IB
		);

end Synthesis;
