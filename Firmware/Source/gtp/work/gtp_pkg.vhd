library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

package gtp_pkg is
	constant GXBVXS_GEN							: std_logic_vector(15 downto 0) := x"FFFF";

	-- Peripheral system IDs	
	constant PER_ID_GTPCFG						: integer := 0;
	constant PER_ID_GTPCLKRST					: integer := 1;
	constant PER_ID_SD							: integer := 2;
--	constant PER_ID_GTPLA						: integer := 3;
	constant PER_ID_GXBCFG_L					: integer := 3;
	constant PER_ID_GXBCFG_R					: integer := 4;
	constant PER_ID_GXBVXS0						: integer := 5;
	constant PER_ID_GXBVXS1						: integer := 6;
	constant PER_ID_GXBVXS2						: integer := 7;
	constant PER_ID_GXBVXS3						: integer := 8;
	constant PER_ID_GXBVXS4						: integer := 9;
	constant PER_ID_GXBVXS5						: integer := 10;
	constant PER_ID_GXBVXS6						: integer := 11;
	constant PER_ID_GXBVXS7						: integer := 12;
	constant PER_ID_GXBVXS8						: integer := 13;
	constant PER_ID_GXBVXS9						: integer := 14;
	constant PER_ID_GXBVXS10					: integer := 15;
	constant PER_ID_GXBVXS11					: integer := 16;
	constant PER_ID_GXBVXS12					: integer := 17;
	constant PER_ID_GXBVXS13					: integer := 18;
	constant PER_ID_GXBVXS14					: integer := 19;
	constant PER_ID_GXBVXS15					: integer := 20;
	constant PER_ID_TRIGGER						: integer := 21;
	constant PER_ID_QSFP							: integer := 22;
	constant PER_ID_TIGTP						: integer := 23;

	-- Peripheral system address mappings
	-- BASE_ADDR, BASE_MASK, USER_MASK
	constant PER_ADDR_INFO_CFG	: PER_ADDR_INFO_ARRAY := (
		(x"0000", x"FF00", x"00FF"),	-- PER_ID_GTPCFG
		(x"0100", x"FF00", x"00FF"),	-- PER_ID_GTPCLKRST
		(x"0200", x"FE00", x"01FF"),	-- PER_ID_SD
--		(x"0400", x"FF00", x"00FF"),	-- PER_ID_GTPLA
		(x"0500", x"FF00", x"00FF"),	-- PER_ID_GXBCFG_L
		(x"0600", x"FF00", x"00FF"),	-- PER_ID_GXBCFG_R
		(x"1000", x"FF00", x"00FF"),	-- PER_ID_GXBVXS0
		(x"1100", x"FF00", x"00FF"),	-- PER_ID_GXBVXS1
 		(x"1200", x"FF00", x"00FF"),	-- PER_ID_GXBVXS2
 		(x"1300", x"FF00", x"00FF"),	-- PER_ID_GXBVXS3
 		(x"1400", x"FF00", x"00FF"),	-- PER_ID_GXBVXS4
 		(x"1500", x"FF00", x"00FF"),	-- PER_ID_GXBVXS5
 		(x"1600", x"FF00", x"00FF"),	-- PER_ID_GXBVXS6
 		(x"1700", x"FF00", x"00FF"),	-- PER_ID_GXBVXS7
 		(x"1800", x"FF00", x"00FF"),	-- PER_ID_GXBVXS8
 		(x"1900", x"FF00", x"00FF"),	-- PER_ID_GXBVXS9
 		(x"1A00", x"FF00", x"00FF"),	-- PER_ID_GXBVXS10
 		(x"1B00", x"FF00", x"00FF"),	-- PER_ID_GXBVXS11
 		(x"1C00", x"FF00", x"00FF"),	-- PER_ID_GXBVXS12
 		(x"1D00", x"FF00", x"00FF"),	-- PER_ID_GXBVXS13
 		(x"1E00", x"FF00", x"00FF"),	-- PER_ID_GXBVXS14
 		(x"1F00", x"FF00", x"00FF"),	-- PER_ID_GXBVXS15
		(x"2000", x"FC00", x"03FF"),	-- PER_ID_TRIGGER
		(x"2400", x"FF00", x"00FF"),	-- PER_ID_QSFP
		(x"2500", x"FF00", x"00FF")	-- PER_ID_TIGTP
	);

	component gtp_wrapper is
		generic(
			GTX_QUICKSIM			: boolean := false
		);
		port(
			-- Trigger Interface
			GLOBAL_CLK		: in std_logic;
			SYNC				: in std_logic;
			TRIG				: in std_logic;

			-- VME Bus Interface
			VMEBUS_DS_N		: in std_logic_vector(1 downto 0);
			VMEBUS_AS_N		: in std_logic;
			VMEBUS_W_N		: in std_logic;
			VMEBUS_AM		: in std_logic_vector(5 downto 0);
			VMEBUS_D			: inout std_logic_vector(31 downto 0);
			VMEBUS_A			: inout std_logic_vector(31 downto 0);
			VMEBUS_BERR_N	: inout std_logic;
			VMEBUS_DTACK_N	: inout std_logic;
			
			-- GTP Signals
			PP1_RX			: in std_logic_vector(0 to 1);
			PP1_TX			: out std_logic_vector(0 to 1);
			PP2_RX			: in std_logic_vector(0 to 1);
			PP2_TX			: out std_logic_vector(0 to 1);
			PP3_RX			: in std_logic_vector(0 to 1);
			PP3_TX			: out std_logic_vector(0 to 1);
			PP4_RX			: in std_logic_vector(0 to 1);
			PP4_TX			: out std_logic_vector(0 to 1);
			PP5_RX			: in std_logic_vector(0 to 1);
			PP5_TX			: out std_logic_vector(0 to 1);
			PP6_RX			: in std_logic_vector(0 to 1);
			PP6_TX			: out std_logic_vector(0 to 1);
			PP7_RX			: in std_logic_vector(0 to 1);
			PP7_TX			: out std_logic_vector(0 to 1);
			PP8_RX			: in std_logic_vector(0 to 1);
			PP8_TX			: out std_logic_vector(0 to 1);
			PP9_RX			: in std_logic_vector(0 to 1);
			PP9_TX			: out std_logic_vector(0 to 1);
			PP10_RX			: in std_logic_vector(0 to 1);
			PP10_TX			: out std_logic_vector(0 to 1);
			PP11_RX			: in std_logic_vector(0 to 1);
			PP11_TX			: out std_logic_vector(0 to 1);
			PP12_RX			: in std_logic_vector(0 to 1);
			PP12_TX			: out std_logic_vector(0 to 1);
			PP13_RX			: in std_logic_vector(0 to 1);
			PP13_TX			: out std_logic_vector(0 to 1);
			PP14_RX			: in std_logic_vector(0 to 1);
			PP14_TX			: out std_logic_vector(0 to 1);
			PP15_RX			: in std_logic_vector(0 to 1);
			PP15_TX			: out std_logic_vector(0 to 1);
			PP16_RX			: in std_logic_vector(0 to 1);
			PP16_TX			: out std_logic_vector(0 to 1);

			--Fiber Transceiver
			FIBER_RX			: in std_logic_vector(0 to 3);
			FIBER_TX			: out std_logic_vector(0 to 3)
		);
	end component;

end gtp_pkg;
