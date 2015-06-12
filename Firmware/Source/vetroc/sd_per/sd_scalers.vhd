library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library utils;
use utils.utils_pkg.all;

entity sd_scalers is
	port(
		CLK					: in std_logic;

		-- Input signal scalers
		BUSY					: in std_logic;
		TRIG					: in std_logic;
		SYNC					: in std_logic;

		FPGAIN_SYNC			: in std_logic_vector(8 downto 1);
		TOKENFI_SYNC		: in std_logic;
		SYNCFI_SYNC			: in std_logic;
		TRIG1F_SYNC			: in std_logic;
		TRIG2F_SYNC			: in std_logic;
		STATA_IN_SYNC		: in std_logic;
		STATB_IN_SYNC		: in std_logic;
		
		-- Output signal scalers
		FPGAOUT_MUX			: in std_logic_vector(8 downto 1);
		TOKENFO_MUX			: in std_logic;
		TRIGFO_MUX			: in std_logic;
		SDLINKF_MUX			: in std_logic;
		STATA_OUT_MUX		: in std_logic;
		BUSY_OUT_MUX		: in std_logic;

		-- Scaler control
		SCALER_LATCH		: in std_logic;
		SCALER_RESET		: in std_logic;

		-- Scaler registers
		SCALER_GCLK_125	: out std_logic_vector(31 downto 0);
		SCALER_SYNC			: out std_logic_vector(31 downto 0);
		SCALER_TRIG			: out std_logic_vector(31 downto 0);
		SCALER_BUSYCYCLES	: out std_logic_vector(31 downto 0);
		SCALER_FPGAIN		: out slv32a(8 downto 1);
		SCALER_TOKENFI		: out std_logic_vector(31 downto 0);
		SCALER_SYNCFI		: out std_logic_vector(31 downto 0);
		SCALER_TRIG1F		: out std_logic_vector(31 downto 0);
		SCALER_TRIG2F		: out std_logic_vector(31 downto 0);
		SCALER_STATA_IN	: out std_logic_vector(31 downto 0);
		SCALER_STATB_IN	: out std_logic_vector(31 downto 0);
		SCALER_FPGAOUT		: out slv32a(8 downto 1);
		SCALER_TOKENFO		: out std_logic_vector(31 downto 0);
		SCALER_TRIGFO		: out std_logic_vector(31 downto 0);
		SCALER_SDLINKF		: out std_logic_vector(31 downto 0);
		SCALER_STATA_OUT	: out std_logic_vector(31 downto 0);
		SCALER_BUSY_OUT	: out std_logic_vector(31 downto 0)
	);
end sd_scalers;

architecture synthesis of sd_scalers is
begin

	Scaler_CLK125_inst: Scaler
		generic map(LEN => 32, EDGE_DET => false, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => '1', SCALER => SCALER_GCLK_125);

	Scaler_Sync_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => SYNC, SCALER => SCALER_SYNC);

	Scaler_Trig_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => TRIG, SCALER => SCALER_TRIG);

	Scaler_BusyCycles_inst: Scaler
		generic map(LEN => 32, EDGE_DET => false, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => BUSY, SCALER => SCALER_BUSYCYCLES);

	FPGAINOUT_Scaler_gen: for I in 1 to 8 generate
		Scaler_FPGAIN_inst: Scaler
			generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
			port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => FPGAIN_SYNC(I), SCALER => SCALER_FPGAIN(I));

		Scaler_FPGAOUT_inst: Scaler
			generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
			port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => FPGAOUT_MUX(I), SCALER => SCALER_FPGAOUT(I));
	end generate;

	Scaler_TOKENFI_SYNC_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => TOKENFI_SYNC, SCALER => SCALER_TOKENFI);

	Scaler_SYNCFI_SYNC_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => SYNCFI_SYNC , SCALER => SCALER_SYNCFI);

	Scaler_TRIG1F_SYNC_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => TRIG1F_SYNC, SCALER => SCALER_TRIG1F);

	Scaler_TRIG2F_SYNC_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => TRIG2F_SYNC, SCALER => SCALER_TRIG2F);

	Scaler_STATA_IN_SYNC_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => STATA_IN_SYNC, SCALER => SCALER_STATA_IN);

	Scaler_STATB_IN_SYNC_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => STATB_IN_SYNC, SCALER => SCALER_STATB_IN);

	Scaler_TOKENFO_MUX_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => TOKENFO_MUX, SCALER => SCALER_TOKENFO);

	Scaler_TRIGFO_MUX_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => TRIGFO_MUX, SCALER => SCALER_TRIGFO);

	Scaler_SDLINKF_MUX_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => SDLINKF_MUX, SCALER => SCALER_SDLINKF);

	Scaler_STATA_OUT_MUX_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => STATA_OUT_MUX, SCALER => SCALER_STATA_OUT);

	Scaler_BUSY_OUT_MUX_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => BUSY_OUT_MUX, SCALER => SCALER_BUSY_OUT);

end synthesis;
