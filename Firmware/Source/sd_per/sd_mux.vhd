library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library utils;
use utils.utils_pkg.all;

entity sd_mux is
	port(
		CLK					: in std_logic;

		INPUT_1_SYNC		: in std_logic;
		INPUT_2_SYNC		: in std_logic;
		INPUT_3_SYNC		: in std_logic;
		OR_1_0_SYNC			: in std_logic;
		OR_1_1_SYNC			: in std_logic;
		OR_2_0_SYNC			: in std_logic;
		OR_2_1_SYNC			: in std_logic;
		OR_3_0_SYNC			: in std_logic;
		OR_3_1_SYNC			: in std_logic;

		PULSER_OUTPUT		: in std_logic;
		INPUT_1_ASYNC		: in std_logic;
		INPUT_2_ASYNC		: in std_logic;
		INPUT_3_ASYNC		: in std_logic;
		OR_1_0_ASYNC		: in std_logic;
		OR_1_1_ASYNC		: in std_logic;
		OR_2_0_ASYNC		: in std_logic;
		OR_2_1_ASYNC		: in std_logic;
		OR_3_0_ASYNC		: in std_logic;
		OR_3_1_ASYNC		: in std_logic;
		BUSY					: in std_logic;
		MAROC_OUT_OR		: in std_logic;
		
		OUTPUT_1_MUX		: out std_logic;
		OUTPUT_2_MUX		: out std_logic;
		OUTPUT_3_MUX		: out std_logic;

		SYNC					: out std_logic;
		TRIG					: out std_logic;
		ADC_START			: out std_logic;
		
		OUTPUT_1_SRC		: in std_logic_vector(4 downto 0);
		OUTPUT_2_SRC		: in std_logic_vector(4 downto 0);
		OUTPUT_3_SRC		: in std_logic_vector(4 downto 0);
		ADC_START_SRC		: in std_logic_vector(4 downto 0);
		TRIG_SRC				: in std_logic_vector(4 downto 0);
		SYNC_SRC				: in std_logic_vector(4 downto 0)
	);
end sd_mux;

architecture Synthesis of sd_mux is
	signal MUX_SRC				: std_logic_vector(31 downto 0);
	signal MUX_SRC_SYNC		: std_logic_vector(31 downto 0);
begin

	-- Async Signal multiplexing
	MUX_SRC(0) <= '0';
	MUX_SRC(1) <= '1';
	MUX_SRC(2) <= MAROC_OUT_OR;
	MUX_SRC(3) <= '0';
	MUX_SRC(4) <= '0';
	MUX_SRC(5) <= INPUT_1_ASYNC;
	MUX_SRC(6) <= INPUT_2_ASYNC;
	MUX_SRC(7) <= INPUT_3_ASYNC;
	MUX_SRC(8) <= '0';
	MUX_SRC(9) <= '0';
	MUX_SRC(10) <= OR_1_0_ASYNC;
	MUX_SRC(11) <= OR_1_1_ASYNC;
	MUX_SRC(12) <= OR_2_0_ASYNC;
	MUX_SRC(13) <= OR_2_1_ASYNC;
	MUX_SRC(14) <= OR_3_0_ASYNC;
	MUX_SRC(15) <= OR_3_1_ASYNC;
	MUX_SRC(16) <= '0';
	MUX_SRC(17) <= '0';
	MUX_SRC(18) <= PULSER_OUTPUT;
	MUX_SRC(19) <= BUSY;
	MUX_SRC(31 downto 20) <= (others=>'0');

	ADC_START <= MUX_SRC(conv_integer(ADC_START_SRC));
	OUTPUT_1_MUX <= MUX_SRC(conv_integer(OUTPUT_1_SRC));
	OUTPUT_2_MUX <= MUX_SRC(conv_integer(OUTPUT_2_SRC));
	OUTPUT_3_MUX <= MUX_SRC(conv_integer(OUTPUT_3_SRC));

	-- Sync Signal multiplexing
	process(CLK)
	begin
		if rising_edge(CLK) then
			MUX_SRC_SYNC(0) <= '0';
			MUX_SRC_SYNC(1) <= '1';
			MUX_SRC_SYNC(2) <= MAROC_OUT_OR;
			MUX_SRC_SYNC(3) <= '0';
			MUX_SRC_SYNC(4) <= '0';
			MUX_SRC_SYNC(5) <= INPUT_1_ASYNC;
			MUX_SRC_SYNC(6) <= INPUT_2_ASYNC;
			MUX_SRC_SYNC(7) <= INPUT_3_ASYNC;
			MUX_SRC_SYNC(8) <= '0';
			MUX_SRC_SYNC(9) <= '0';
			MUX_SRC_SYNC(10) <= OR_1_0_ASYNC;
			MUX_SRC_SYNC(11) <= OR_1_1_ASYNC;
			MUX_SRC_SYNC(12) <= OR_2_0_ASYNC;
			MUX_SRC_SYNC(13) <= OR_2_1_ASYNC;
			MUX_SRC_SYNC(14) <= OR_3_0_ASYNC;
			MUX_SRC_SYNC(15) <= OR_3_1_ASYNC;
			MUX_SRC_SYNC(16) <= '0';
			MUX_SRC_SYNC(17) <= '0';
			MUX_SRC_SYNC(18) <= PULSER_OUTPUT;
			MUX_SRC_SYNC(19) <= BUSY;
			MUX_SRC_SYNC(31 downto 20) <= (others=>'0');

			SYNC <= MUX_SRC_SYNC(conv_integer(SYNC_SRC));
			TRIG <= MUX_SRC_SYNC(conv_integer(TRIG_SRC));
		end if;
	end process;

end Synthesis;
