library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

package tigtp_per_pkg is

	component tigtp_per is
		generic(
			ADDR_INFO				: PER_ADDR_INFO
		);
		port(
			CLK_REF					: in std_logic;

			-- Serial pins to/from TI
			TI_GTP_TX				: out std_logic;
			TI_GTP_RX				: in std_logic;

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_CLK					: in std_logic;
			BUS_RESET				: in std_logic;
			BUS_RESET_SOFT			: in std_logic;
			BUS_DIN					: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT					: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR					: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR					: in std_logic;
			BUS_RD					: in std_logic;
			BUS_ACK					: out std_logic;
			BUS_IRQ					: out std_logic
		);
	end component;

end tigtp_per_pkg;
