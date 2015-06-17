library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package sd_per_pkg is
	
	component sd_per is
		generic(
			ADDR_INFO		: PER_ADDR_INFO
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			CLK				: in std_logic;
			SYSCLK_50		: in std_logic;

			SYNC				: out std_logic;
			TRIG				: out std_logic;
			BUSY				: in std_logic;

			TRIG_BIT_OUT	: in std_logic_vector(31 downto 0);

			SCALER_LATCH	: out std_logic;
			SCALER_RESET	: out std_logic;

			-- SSP I/O ports (muxed)
			FP_OUT			: out std_logic_vector(3 downto 0);
			FP_IN				: in std_logic_vector(3 downto 0);

			-- SSP I/O ports (fixed)
			SD_SYNC			: in std_logic;
			SD_TRIG			: in std_logic_vector(2 downto 1);
			TI_BUSY			: out std_logic;
			PP_BUSY			: out std_logic_vector(16 downto 1);
			PP_LINKUP		: out std_logic_vector(16 downto 1);
			BUSY_DIR			: out std_logic;
			LINKUP_DIR		: out std_logic;

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
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

end sd_per_pkg;
