library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package gtpcfg_per_pkg is

	constant GTP_TYPE_HALLD			: std_logic_vector(15 downto 0) := x"0001";
	constant GTP_TYPE_HPS			: std_logic_vector(15 downto 0) := x"0002";

	constant BOARD_ID					: std_logic_vector(31 downto 0) := x"47545020";
	constant FIRMWARE_REV			: std_logic_vector(31 downto 0) := GTP_TYPE_HPS & x"0101";

	constant SLAVE_ADR		: std_logic_vector(6 downto 0) := "0000000";	-- TI I2C

	component gtpcfg_per is
		generic(
			ADDR_INFO		: PER_ADDR_INFO
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			CPLD_FPGA_GPIO	: out std_logic_vector(15 downto 2);

			LED_AMBER		: out std_logic;
			LED_RED			: out std_logic;

			TI_SCL			: in std_logic;
			TI_SDA			: inout std_logic;
			TI_SDA_OE		: out std_logic;

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_CLK			: in std_logic;
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

end gtpcfg_per_pkg;
