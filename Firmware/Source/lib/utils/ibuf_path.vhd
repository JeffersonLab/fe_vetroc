library ieee;
use ieee.std_logic_1164.all;

entity ibuf_path is
	generic(
		SYNC_STAGES	: integer := 2;
		INVERT		: boolean := false
	);
	port(
		CLK			: in std_logic;
		I				: in std_logic;
		OUT_ASYNC	: out std_logic;
		OUT_SYNC		: out std_logic
	);
end ibuf_path;

architecture Synthesis of ibuf_path is
	signal I_Q		: std_logic_vector(SYNC_STAGES-1 downto 0);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			I_Q <= I_Q(I_Q'length-2 downto 0) & I;
		end if;
	end process;

	invert_true_gen: if INVERT = true generate
		OUT_ASYNC <= not I;
		OUT_SYNC <= not I_Q(I_Q'length-1);
	end generate;

	invert_false_gen: if INVERT = false generate
		OUT_ASYNC <= I;
		OUT_SYNC <= I_Q(I_Q'length-1);
	end generate;

end synthesis;
