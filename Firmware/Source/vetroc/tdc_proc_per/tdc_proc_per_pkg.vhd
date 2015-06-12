library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.perbus_pkg.all;

package tdc_proc_per_pkg is

	component tdc_proc_per is
		generic(
			ADDR_INFO			: PER_ADDR_INFO;
			CHANNEL_START		: integer := 0
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			SCALER_LATCH		: in std_logic;
			SCALER_RESET		: in std_logic;

			GCLK_125				: in std_logic;
			GCLK_250				: in std_logic;
			GCLK_500				: in std_logic;

			SYNC					: in std_logic;

			-- TDC Inputs, Trigger Outputs
			HIT					: in std_logic_vector(15 downto 0);
			HIT_TRIG				: out std_logic_vector(15 downto 0);

			------------------------------
			-- BUS_CLK domain signals
			------------------------------
			BUS_CLK				: in std_logic;

			-- Trigger unit interface
			TRIG_FIFO_WR		: in std_logic;
			TRIG_FIFO_START	: in std_logic_vector(9 downto 0);
			TRIG_FIFO_STOP		: in std_logic_vector(9 downto 0);

			-- Event builder interface
			EVT_FIFO_DOUT		: out std_logic_vector(32 downto 0);
			EVT_FIFO_RD			: in std_logic;
			EVT_FIFO_EMPTY		: out std_logic;

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

end tdc_proc_per_pkg;
