library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package gxbconfig_per_pkg is

	component gxbconfig_per is
		generic(
			ADDR_INFO		: PER_ADDR_INFO
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			SYSCLK_50			: in std_logic;
			CAL_BLK_POWERDOWN	: out std_logic;
			CAL_BLK_BUSY		: out std_logic;
			RECONFIG_TOGXB		: out std_logic_vector(3 downto 0);
			RECONFIG_FROMGXB	: in std_logic_vector(611 downto 0);

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_RESET			: in std_logic;
			BUS_RESET_SOFT	: in std_logic;
			BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR				: in std_logic;
			BUS_RD				: in std_logic;
			BUS_ACK				: out std_logic
		);
	end component;

end gxbconfig_per_pkg;
