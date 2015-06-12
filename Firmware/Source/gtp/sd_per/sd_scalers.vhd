library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity sd_scalers is
	port(
		SYSCLK_50			: in std_logic;
		CLK					: in std_logic;

		-- Input signal scalers
		BUSY					: in std_logic;
		TRIG1_SYNC			: in std_logic;
		TRIG2_SYNC			: in std_logic;
		SYNC_SYNC			: in std_logic;
		FP_IN_SYNC			: in std_logic_vector(3 downto 0);
		
		-- Output signal scalers
		FP_OUT_MUX			: in std_logic_vector(3 downto 0);

		-- Scaler control
		SCALER_LATCH		: in std_logic;

		-- Scaler registers
		SCALER_SYSCLK_50	: out std_logic_vector(31 downto 0);
		SCALER_CLK			: out std_logic_vector(31 downto 0);
		SCALER_SYNC			: out std_logic_vector(31 downto 0);
		SCALER_TRIG1		: out std_logic_vector(31 downto 0);
		SCALER_TRIG2		: out std_logic_vector(31 downto 0);
		SCALER_FP_IN		: out slv32a(3 downto 0);
		SCALER_FP_OUT		: out slv32a(3 downto 0);
		SCALER_BUSY			: out std_logic_vector(31 downto 0);
		SCALER_BUSYCYCLES	: out std_logic_vector(31 downto 0)
	);
end sd_scalers;

architecture Synthesis of sd_scalers is
begin

	Scaler_CLK50_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => SYSCLK_50, SCALER => SCALER_SYSCLK_50);

	Scaler_CLK_inst: Scaler
		generic map(LEN => 32, EDGE_DET => false, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => '1', SCALER => SCALER_CLK);

	Scaler_Sync_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => SYNC_SYNC, SCALER => SCALER_SYNC);

	Scaler_Trig1_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => TRIG1_SYNC, SCALER => SCALER_TRIG1);

	Scaler_Trig2_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => TRIG2_SYNC, SCALER => SCALER_TRIG2);

	Scaler_FP_IN_gen: for I in 0 to 3 generate
		Scaler_FP_IN_inst: Scaler
			generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
			port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => FP_IN_SYNC(I), SCALER => SCALER_FP_IN(I));
	end generate;

	Scaler_FP_OUT_gen: for I in 0 to 3 generate
		Scaler_FP_OUT_inst: Scaler
			generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
			port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => FP_OUT_MUX(I), SCALER => SCALER_FP_OUT(I));
	end generate;

	Scaler_Busy_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => BUSY, SCALER => SCALER_BUSY);

	Scaler_BusyCycles_inst: Scaler
		generic map(LEN => 32, EDGE_DET => false, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, INPUT => BUSY, SCALER => SCALER_BUSYCYCLES);

end Synthesis;
