library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity sd_iobuf is
	port(
		CLK					: in std_logic;

		BUSY					: in std_logic;
	
		-- Sync Mux inputs
		TRIG1_SYNC			: out std_logic;
		TRIG2_SYNC			: out std_logic;
		SYNC_SYNC			: out std_logic;
		FP_IN_SYNC			: out std_logic_vector(3 downto 0);
		
		-- Async Mux inputs
		TRIG1_ASYNC			: out std_logic;
		TRIG2_ASYNC			: out std_logic;
		SYNC_ASYNC			: out std_logic;
		FP_IN_ASYNC			: out std_logic_vector(3 downto 0);

		-- Mux outputs
		FP_OUT_MUX			: in std_logic_vector(3 downto 0);

		-- SD Input Pins
		FP_IN					: in std_logic_vector(3 downto 0);
		SD_SYNC				: in std_logic;
		SD_TRIG1				: in std_logic;
		SD_TRIG2				: in std_logic;

		-- SD Output Pins		
		TI_BUSY				: out std_logic;
		FP_OUT				: out std_logic_vector(3 downto 0)
	);
end sd_iobuf;

architecture Synthesis of sd_iobuf is
begin

	sd_sync_ibuf: ibuf_path
		generic map(
			SYNC_STAGES	=> 2
		)
		port map(
			CLK			=> CLK,
			I				=> SD_SYNC,
			OUT_ASYNC	=> SYNC_ASYNC,
			OUT_SYNC		=> SYNC_SYNC
		);

	trig1_ibuf: ibuf_path
		generic map(
			SYNC_STAGES	=> 2
		)
		port map(
			CLK			=> CLK,
			I				=> SD_TRIG1,
			OUT_ASYNC	=> TRIG1_ASYNC,
			OUT_SYNC		=> TRIG1_SYNC
		);

	trig2_ibuf: ibuf_path
		generic map(
			SYNC_STAGES	=> 2
		)
		port map(
			CLK			=> CLK,
			I				=> SD_TRIG2,
			OUT_ASYNC	=> TRIG2_ASYNC,
			OUT_SYNC		=> TRIG2_SYNC
		);

	fp_in_ibuf_gen: for I in 0 to 3 generate
		fp_in_ibuf: ibuf_path
			generic map(
				SYNC_STAGES	=> 2
			)
			port map(
				CLK			=> CLK,
				I				=> FP_IN(I),
				OUT_ASYNC	=> FP_IN_ASYNC(I),
				OUT_SYNC		=> FP_IN_SYNC(I)
			);
	end generate;

	-- Single-ended Output Buffers
	FP_OUT <= FP_OUT_MUX;
	TI_BUSY <= BUSY;

end Synthesis;
