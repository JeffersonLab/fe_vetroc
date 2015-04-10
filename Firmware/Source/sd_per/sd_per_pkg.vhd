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

			TRIG					: out std_logic;
			SYNC					: out std_logic;
			BUSY					: in std_logic;
			MAROC_ADC_START	: out std_logic;
			MAROC_OUT_OR		: in std_logic;

			SCALER_LATCH		: out std_logic;
			SCALER_RESET		: out std_logic;

			-- MAROC I/O
			OR_1_0				: in std_logic;
			OR_1_1				: in std_logic;
			OR_2_0				: in std_logic;
			OR_2_1				: in std_logic;
			OR_3_0				: in std_logic;
			OR_3_1				: in std_logic;
		
			-- Test port I/O
			INPUT_1				: in std_logic;
			INPUT_2				: in std_logic;
			INPUT_3				: in std_logic;
			OUTPUT_1				: out std_logic;
			OUTPUT_2				: out std_logic;
			OUTPUT_3				: out std_logic;
			
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

end sd_per_pkg;
