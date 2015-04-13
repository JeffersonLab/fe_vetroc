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
			CLK					: in std_logic;

			SYNC					: out std_logic;
			TRIG					: out std_logic;
			BUSY					: in std_logic;
			TOKENIN				: out std_logic;
			TOKENOUT				: in std_logic;

			SCALER_LATCH		: out std_logic;
			SCALER_RESET		: out std_logic;
		
			-- I/O ports (fixed)
			FPGAIN				: in std_logic_vector(8 downto 1);
			TOKENFI				: in std_logic;
			SYNCFI				: in std_logic;
			TRIG1F				: in std_logic;
			TRIG2F				: in std_logic;
			STATA_IN				: in std_logic;
			STATB_IN				: in std_logic;

			FPGAOUT				: out std_logic_vector(8 downto 1);
			TOKENFO				: out std_logic;
			TRIGFO				: out std_logic;
			SDLINKF				: out std_logic;
			STATA_OUT			: out std_logic;
			BUSY_OUT				: out std_logic;
			
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

end sd_per_pkg;
