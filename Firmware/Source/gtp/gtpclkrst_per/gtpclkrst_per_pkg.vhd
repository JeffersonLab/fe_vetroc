library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package gtpclkrst_per_pkg is

	component gtpclkrst_per is
		generic(
			ADDR_INFO			: PER_ADDR_INFO
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			CLK25_B				: in std_logic;
			CLK25_R				: in std_logic;
			CLK250_B				: in std_logic;
			CLK250_L				: in std_logic;
			CLK250_R				: in std_logic;
			CLK250_T				: in std_logic;

			ATXCLK_R				: out std_logic;
			ATXCLK_L				: out std_logic;
			CPLD_CLK				: out std_logic;

			SYSCLK_LOCKED		: out std_logic;
			SYSCLK_50			: out std_logic;
			SYSCLK_250			: out std_logic;
			SYSCLK_CPU			: out std_logic;
			SYSCLK_PER			: out std_logic;

			GCLK					: out std_logic;
			GCLK_DIV4			: out std_logic;
			GCLK_RST				: out std_logic;

			GCLK_SRC				: out std_logic_vector(1 downto 0);

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_CLK				: in std_logic;
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

end gtpclkrst_per_pkg;
