library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package la_pkg is

	constant LA_CMD_MODE_DC		: std_logic_vector(2 downto 0) := "000";
	constant LA_CMD_MODE_EQ		: std_logic_vector(2 downto 0) := "001";
	constant LA_CMD_MODE_NE		: std_logic_vector(2 downto 0) := "010";
	constant LA_CMP_MODE_LT		: std_logic_vector(2 downto 0) := "011";
	constant LA_CMP_MODE_GT		: std_logic_vector(2 downto 0) := "100";

	component la_cmp is
		generic(
			D_WIDTH		: integer := 32
		);
		port(
			CLK			: in std_logic;

			MODE			: in std_logic_vector(2 downto 0);
			THR			: in std_logic_vector(D_WIDTH-1 downto 0);
			DIN			: in std_logic_vector(D_WIDTH-1 downto 0);

			TRG			: out std_logic
		);
	end component;

	component la_mask is
		generic(
			D_WIDTH		: integer := 32
		);
		port(
			CLK			: in std_logic;

			EN				: in std_logic_vector(D_WIDTH-1 downto 0);
			VAL			: in std_logic_vector(D_WIDTH-1 downto 0);
			DIN			: in std_logic_vector(D_WIDTH-1 downto 0);

			TRG			: out std_logic
		);
	end component;

	component la_ram is
		generic(
			D_WIDTH		: integer := 32
		);
		port(
			CLK			: in std_logic;

			WREN			: in std_logic;
			DI				: in std_logic_vector(D_WIDTH-1 downto 0);

			RDADDR_LD	: in std_logic;
			RDEN			: in std_logic;
			DO				: out std_logic_vector(D_WIDTH-1 downto 0)
		);
	end component;

	component la_sm is
		port(
			CLK			: in std_logic;
			TRIGGER		: in std_logic;
			LA_ENABLE	: in std_logic;
			LA_READY		: out std_logic
		);
	end component;

end la_pkg;
