library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package gxbvxs_per_pkg is

	component gxbvxs_per is
		generic(
			ADDR_INFO				: PER_ADDR_INFO;
			PAYLOAD_INST			: integer;
			SIM_GTXRESET_SPEEDUP	: integer := 0;
			GTX_QUICKSIM			: boolean := false
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			SYSCLK_50			: in std_logic;
			ATXCLK				: in std_logic;

			-- Transceiver I/O
			PAYLOAD_RX2			: in std_logic;
			PAYLOAD_RX3			: in std_logic;
			PAYLOAD_TX2			: out std_logic;
			PAYLOAD_TX3			: out std_logic;

			CAL_BLK_POWERDOWN	: in std_logic;
			CAL_BLK_BUSY		: in std_logic;
			RECONFIG_FROMGXB	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB		: in std_logic_vector(3 downto 0);

			-- To trigger processing
			-- Note: uses CLK=125MHz when RATE_5G_2_5Gn = '0'
			--       uses CLK=250MHz when RATE_5G_2_5Gn = '1'
			CLK					: in std_logic;
			SYNC					: in std_logic;
			RX_D					: out std_logic_vector(31 downto 0);
			RX_SRC_RDY_N		: out std_logic;

			-- External Trigger for Monitor 
			EXT_TRIGGER			: in std_logic;

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

end gxbvxs_per_pkg;
