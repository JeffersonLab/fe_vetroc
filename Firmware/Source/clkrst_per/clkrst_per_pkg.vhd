library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

package clkrst_per_pkg is

	component clkrst_per is
		generic(
			ADDR_INFO				: PER_ADDR_INFO
		);
		port(
			----------------------------------------------------
			-- User ports --------------------------------------
			----------------------------------------------------
			CLK125F_P				: in std_logic;
			CLK125F_N				: in std_logic;
			
			CLKPRGC					: in std_logic;

			PCLKLOAD					: out std_logic;
			PCLKOUT1					: out std_logic;
			PCLKOUT2					: out std_logic;
			PCLKSIN1					: out std_logic;
			PCLKSIN2					: out std_logic;
			PCSWCFG					: out std_logic;

			-- Generated Clocks
			SYSCLK_50_RESET		: out std_logic;
			SYSCLK_50				: out std_logic;
			SYSCLK_125				: out std_logic;

			GCLK_125_RESET			: out std_logic;
			GCLK_125					: out std_logic;
			GCLK_250					: out std_logic;
			GCLK_500					: out std_logic;

			-- Flash Memory
			PMEMCE_N					: out std_logic;
			PMEMD0					: inout std_logic;
			PMEMD1					: inout std_logic;
			PMEMD2					: inout std_logic;
			PMEMD3					: inout std_logic;

			BUS_RESET_SOFT_OUT	: out std_logic;

			----------------------------------------------------
			-- Bus interface ports -----------------------------
			----------------------------------------------------
			BUS_CLK					: in std_logic;
			BUS_RESET				: in std_logic;
			BUS_RESET_SOFT			: in std_logic;
			BUS_DIN					: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT					: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR					: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR					: in std_logic;
			BUS_RD					: in std_logic;
			BUS_ACK					: out std_logic
		);
	end component;

end clkrst_per_pkg;
