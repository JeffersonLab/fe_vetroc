library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library utils;
use utils.utils_pkg.all;

entity sd_iobuf is
	port(
		CLK					: in std_logic;

		-- Sync Mux inputs
		INPUT_1_SYNC		: out std_logic;
		INPUT_2_SYNC		: out std_logic;
		INPUT_3_SYNC		: out std_logic;
		OR_1_0_SYNC			: out std_logic;
		OR_1_1_SYNC			: out std_logic;
		OR_2_0_SYNC			: out std_logic;
		OR_2_1_SYNC			: out std_logic;
		OR_3_0_SYNC			: out std_logic;
		OR_3_1_SYNC			: out std_logic;

		-- Async Mux inputs
		INPUT_1_ASYNC		: out std_logic;
		INPUT_2_ASYNC		: out std_logic;
		INPUT_3_ASYNC		: out std_logic;
		OR_1_0_ASYNC		: out std_logic;
		OR_1_1_ASYNC		: out std_logic;
		OR_2_0_ASYNC		: out std_logic;
		OR_2_1_ASYNC		: out std_logic;
		OR_3_0_ASYNC		: out std_logic;
		OR_3_1_ASYNC		: out std_logic;

		-- Mux outputs
		OUTPUT_1_MUX		: in std_logic;
		OUTPUT_2_MUX		: in std_logic;
		OUTPUT_3_MUX		: in std_logic;
		
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
		OUTPUT_3				: out std_logic
	);
end sd_iobuf;

architecture Synthesis of sd_iobuf is
begin

	-- Single-ended Input Buffers
	INPUT_1_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => INPUT_1, OUT_ASYNC => INPUT_1_ASYNC, OUT_SYNC => INPUT_1_SYNC);

	INPUT_2_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => INPUT_2, OUT_ASYNC => INPUT_2_ASYNC, OUT_SYNC => INPUT_2_SYNC);

	INPUT_3_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => INPUT_3, OUT_ASYNC => INPUT_3_ASYNC, OUT_SYNC => INPUT_3_SYNC);

	OR_1_0_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => OR_1_0, OUT_ASYNC => OR_1_0_ASYNC, OUT_SYNC => OR_1_0_SYNC);

	OR_1_1_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => OR_1_1, OUT_ASYNC => OR_1_1_ASYNC, OUT_SYNC => OR_1_1_SYNC);

	OR_2_0_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => OR_2_0, OUT_ASYNC => OR_2_0_ASYNC, OUT_SYNC => OR_2_0_SYNC);

	OR_2_1_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => OR_2_1, OUT_ASYNC => OR_2_1_ASYNC, OUT_SYNC => OR_2_1_SYNC);

	OR_3_0_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => OR_3_0, OUT_ASYNC => OR_3_0_ASYNC, OUT_SYNC => OR_3_0_SYNC);

	OR_3_1_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => OR_3_1, OUT_ASYNC => OR_3_1_ASYNC, OUT_SYNC => OR_3_1_SYNC);

	-- Single-ended Output Buffers
	OUTPUT_1 <= OUTPUT_1_MUX;
	OUTPUT_2 <= OUTPUT_2_MUX;
	OUTPUT_3 <= OUTPUT_3_MUX;

end Synthesis;
