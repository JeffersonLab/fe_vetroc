library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

package trigger_per_pkg is

	constant PAYLOAD_TO_SLOTIDX				: inta(0 to 15) := (7,8,6,9,5,10,4,11,3,12,2,13,1,14,0,15);

	component trigger_per is
		generic(
			ADDR_INFO				: PER_ADDR_INFO
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			CLK						: in std_logic;
			CLK_DIV4					: in std_logic;

			SYNC						: in std_logic;

			-- Payload port serial data input
			RX_D						: in slv32a(15 downto 0);
			RX_SRC_RDY_N			: in std_logic_vector(15 downto 0);

			-- Trigger decisions
			TRIG_BIT_OUT			: out std_logic_vector(31 downto 0);

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_RESET				: in std_logic;
			BUS_RESET_SOFT			: in std_logic;
			BUS_DIN					: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT					: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR					: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR					: in std_logic;
			BUS_RD					: in std_logic;
			BUS_ACK					: out std_logic
		);
	end component;

end trigger_per_pkg;
