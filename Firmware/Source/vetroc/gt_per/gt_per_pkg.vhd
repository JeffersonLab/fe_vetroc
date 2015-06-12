library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package gt_per_pkg is

	component gt_per is
		generic(
			SIM_GTRESET_SPEEDUP	: string := "FALSE";
			ADDR_INFO				: PER_ADDR_INFO
		);
		port(
			-- User ports --------------------------------------
			GT_REFCLK     	: in std_logic;
			RXP				: in std_logic_vector(0 to 1);
			RXN				: in std_logic_vector(0 to 1);
			TXP				: out std_logic_vector(0 to 1);
			TXN				: out std_logic_vector(0 to 1);

			CLK				: in std_logic;
			TX_D				: in std_logic_vector(31 downto 0);
			TX_SRC_RDY_N	: in std_logic;

			-- Bus interface ports -----------------------------
			BUS_CLK			: in std_logic;
			BUS_RESET		: in std_logic;
			BUS_RESET_SOFT	: in std_logic;
			BUS_DIN			: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT			: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR			: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR			: in std_logic;
			BUS_RD			: in std_logic;
			BUS_ACK			: out std_logic
		);
	end component;

end gt_per_pkg;
