library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package richclkrst_per_pkg is

	component richclkrst_per is
		generic(
			ADDR_INFO			: PER_ADDR_INFO
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			-- CLK_33MHZ is local always running 30MHz clock
			CLK_33MHZ			: in std_logic;
			
			-- SYSCLK_# derived from CLK_33MHZ local oscillator
			-- SYSCLK_RESET synchronous to SYSCLK_#
			SYSCLK_50_RESET	: out std_logic;
			SYSCLK_50			: out std_logic;

			SYSCLK_200_RESET	: out std_logic;
			SYSCLK_200			: out std_logic;

			GCLK_125_REF_RST	: in std_logic;
			GCLK_125_REF		: in std_logic;
			GCLK_125_RESET		: out std_logic;
			GCLK_125				: out std_logic;
			GCLK_250				: out std_logic;
			GCLK_500				: out std_logic;
			GCLK_500_180		: out std_logic;

			CONFIGROM_D			: out std_logic;
			CONFIGROM_Q			: in std_logic;
			CONFIGROM_S_N		: out std_logic;

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_CLK				: in std_logic;
			BUS_RESET			: in std_logic;
			BUS_RESET_SOFT		: out std_logic;
			BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR				: in std_logic;
			BUS_RD				: in std_logic;
			BUS_ACK				: out std_logic
		);
	end component;

end richclkrst_per_pkg;
