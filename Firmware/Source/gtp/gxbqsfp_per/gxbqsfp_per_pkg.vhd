library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package gxbqsfp_per_pkg is

	component gxbqsfp_per is
		generic(
			ADDR_INFO					: PER_ADDR_INFO;
			SIM_GTXRESET_SPEEDUP		: integer := 0;
			GTX_QUICKSIM				: boolean := false
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			SYSCLK_50				: in std_logic;
			ATXCLK_L					: in std_logic;
			ATXCLK_R					: in std_logic;

			-- Transceiver I/O
			FIBER_RX					: in std_logic_vector(0 to 3);
			FIBER_TX					: out std_logic_vector(0 to 3);

			CAL_BLK_POWERDOWN_L	: in std_logic;
			CAL_BLK_POWERDOWN_R	: in std_logic;
			CAL_BLK_BUSY_L			: in std_logic;
			CAL_BLK_BUSY_R			: in std_logic;
			RECONFIG_FROMGXB_L	: out std_logic_vector(67 downto 0);
			RECONFIG_FROMGXB_R	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB_L		: in std_logic_vector(3 downto 0);
			RECONFIG_TOGXB_R		: in std_logic_vector(3 downto 0);

			CLK					: in std_logic;
			SYNC					: in std_logic;
			TX_D					: in std_logic_vector(63 downto 0);
			TX_SRC_RDY_N		: in std_logic;

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_RESET			: in std_logic;
			BUS_RESET_SOFT		: in std_logic;
			BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR				: in std_logic;
			BUS_RD				: in std_logic;
			BUS_ACK				: out std_logic
		);
	end component;

end gxbqsfp_per_pkg;
