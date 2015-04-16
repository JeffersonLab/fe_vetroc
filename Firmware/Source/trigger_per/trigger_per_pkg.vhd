library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package trigger_per_pkg is

	component trigger_per is
--		generic(
--			ADDR_INFO				: PER_ADDR_INFO
--		);
		port(
			-- User ports --------------------------------------
			CLK					: in std_logic;
			SYNC					: in std_logic;

			HIT_TRIG				: in std_logic_vector(127 downto 0);

			GT_TX_D				: out std_logic_vector(31 downto 0);
			GT_TX_SRC_RDY_N	: out std_logic

 			-- Bus interface ports -----------------------------
-- 			BUS_CLK				: in std_logic;
-- 			BUS_RESET			: in std_logic;
-- 			BUS_RESET_SOFT		: in std_logic;
-- 			BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
-- 			BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
-- 			BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
-- 			BUS_WR				: in std_logic;
-- 			BUS_RD				: in std_logic;
-- 			BUS_ACK				: out std_logic
		);
	end component;

end trigger_per_pkg;
