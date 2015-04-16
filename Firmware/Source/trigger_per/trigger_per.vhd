library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity trigger_per is
--	generic(
--		ADDR_INFO				: PER_ADDR_INFO
--	);
	port(
		-- User ports --------------------------------------
		CLK					: in std_logic;
		SYNC					: in std_logic;

		HIT_TRIG				: in std_logic_vector(127 downto 0);

		GT_TX_D				: out std_logic_vector(31 downto 0);
		GT_TX_SRC_RDY_N	: out std_logic

		-- Bus interface ports -----------------------------
-- 			BUS_CLK				: in std_logic;
-- 			BUS_RESET			: in std_logic;
-- 			BUS_RESET_SOFT		: in std_logic;
-- 			BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
-- 			BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
-- 			BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
-- 			BUS_WR				: in std_logic;
-- 			BUS_RD				: in std_logic;
-- 			BUS_ACK				: out std_logic
	);
end trigger_per;

architecture synthesis of trigger_per is
	signal SYNC_Q			: std_logic;
	signal HIT_TRIG_Q		: std_logic_vector(127 downto 0);
	signal WORD_CNT		: std_logic_vector(1 downto 0);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			SYNC_Q <= SYNC;
			GT_TX_SRC_RDY_N <= SYNC_Q;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SYNC_Q = '1' then
				WORD_CNT <= "00";
			else
				WORD_CNT <= WORD_CNT + 1;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if WORD_CNT = "11" then
				HIT_TRIG_Q <= HIT_TRIG;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if WORD_CNT = "00" then
				GT_TX_D <= HIT_TRIG_Q(31 downto 0);
			elsif WORD_CNT = "01" then
				GT_TX_D <= HIT_TRIG_Q(63 downto 32);
			elsif WORD_CNT = "10" then
				GT_TX_D <= HIT_TRIG_Q(95 downto 64);
			else
				GT_TX_D <= HIT_TRIG_Q(127 downto 96);
			end if;
		end if;
	end process;

end synthesis;
