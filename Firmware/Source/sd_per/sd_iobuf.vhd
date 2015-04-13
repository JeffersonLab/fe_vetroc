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
		FPGAIN_SYNC			: out std_logic_vector(8 downto 1);
		TOKENFI_SYNC		: out std_logic;
		SYNCFI_SYNC			: out std_logic;
		TRIG1F_SYNC			: out std_logic;
		TRIG2F_SYNC			: out std_logic;
		STATA_IN_SYNC		: out std_logic;
		STATB_IN_SYNC		: out std_logic;

		-- Async Mux inputs
		FPGAIN_ASYNC		: out std_logic_vector(8 downto 1);
		TOKENFI_ASYNC		: out std_logic;
		SYNCFI_ASYNC		: out std_logic;
		TRIG1F_ASYNC		: out std_logic;
		TRIG2F_ASYNC		: out std_logic;
		STATA_IN_ASYNC		: out std_logic;
		STATB_IN_ASYNC		: out std_logic;

		-- Mux outputs
		FPGAOUT_MUX			: in std_logic_vector(8 downto 1);
		TOKENFO_MUX			: in std_logic;
		TRIGFO_MUX			: in std_logic;
		SDLINKF_MUX			: in std_logic;
		STATA_OUT_MUX		: in std_logic;
		BUSY_OUT_MUX		: in std_logic;

		-- SD Input Pins
		FPGAIN				: in std_logic_vector(8 downto 1);
		TOKENFI				: in std_logic;
		SYNCFI				: in std_logic;
		TRIG1F				: in std_logic;
		TRIG2F				: in std_logic;
		STATA_IN				: in std_logic;
		STATB_IN				: in std_logic;

		-- SD Output Pins
		FPGAOUT				: out std_logic_vector(8 downto 1);
		TOKENFO				: out std_logic;
		TRIGFO				: out std_logic;
		SDLINKF				: out std_logic;
		STATA_OUT			: out std_logic;
		BUSY_OUT				: out std_logic
	);
end sd_iobuf;

architecture synthesis of sd_iobuf is
begin

	-- Single-ended Input Buffers
	FPGAIN_ibuf_path_gen: for I in FPGAIN'range generate
		FPGAIN_ibuf_path: ibuf_path
			generic map(SYNC_STAGES	=> 2)
			port map(CLK => CLK, I => FPGAIN(I), OUT_ASYNC => FPGAIN_ASYNC(I), OUT_SYNC => FPGAIN_SYNC(I));
	end generate;

	TOKENFI_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => TOKENFI, OUT_ASYNC => TOKENFI_ASYNC, OUT_SYNC => TOKENFI_SYNC);

	SYNCFI_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => SYNCFI, OUT_ASYNC => SYNCFI_ASYNC, OUT_SYNC => SYNCFI_SYNC);

	TRIG1F_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => TRIG1F, OUT_ASYNC => TRIG1F_ASYNC, OUT_SYNC => TRIG1F_SYNC);

	TRIG2F_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => TRIG2F, OUT_ASYNC => TRIG2F_ASYNC, OUT_SYNC => TRIG2F_SYNC);

	STATA_IN_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => STATA_IN, OUT_ASYNC => STATA_IN_ASYNC, OUT_SYNC => STATA_IN_SYNC);

	STATB_IN_ibuf_path: ibuf_path
		generic map(SYNC_STAGES	=> 2)
		port map(CLK => CLK, I => STATB_IN, OUT_ASYNC => STATB_IN_ASYNC, OUT_SYNC => STATB_IN_SYNC);

	-- Single-ended Output Buffers
	FPGAOUT <= FPGAOUT_MUX;
	TOKENFO <= TOKENFO_MUX;
	TRIGFO <= TRIGFO_MUX;
	SDLINKF <= SDLINKF_MUX;
	STATA_OUT <= STATA_OUT_MUX;
	BUSY_OUT <= BUSY_OUT_MUX;

end synthesis;
