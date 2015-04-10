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
		OR_1_0_SYNC			: in std_logic;
		OR_1_1_SYNC			: in std_logic;
		OR_2_0_SYNC			: in std_logic;
		OR_2_1_SYNC			: in std_logic;
		OR_3_0_SYNC			: in std_logic;
		OR_3_1_SYNC			: in std_logic;
		INPUT_1_SYNC		: in std_logic;
		INPUT_2_SYNC		: in std_logic;
		INPUT_3_SYNC		: in std_logic;
		
		-- Output signal scalers
		OUTPUT_1_MUX		: in std_logic;
		OUTPUT_2_MUX		: in std_logic;
		OUTPUT_3_MUX		: in std_logic;

		-- Scaler control
		SCALER_LATCH		: in std_logic;
		SCALER_RESET		: in std_logic;

		-- Scaler registers
		SCALER_GCLK_125	: out std_logic_vector(31 downto 0);
		SCALER_SYNC			: out std_logic_vector(31 downto 0);
		SCALER_TRIG			: out std_logic_vector(31 downto 0);
		SCALER_BUSY			: out std_logic_vector(31 downto 0);
		SCALER_BUSYCYCLES	: out std_logic_vector(31 downto 0);
		SCALER_OR_1_0		: out std_logic_vector(31 downto 0);
		SCALER_OR_1_1		: out std_logic_vector(31 downto 0);
		SCALER_OR_2_0		: out std_logic_vector(31 downto 0);
		SCALER_OR_2_1		: out std_logic_vector(31 downto 0);
		SCALER_OR_3_0		: out std_logic_vector(31 downto 0);
		SCALER_OR_3_1		: out std_logic_vector(31 downto 0);
		SCALER_INPUT_1		: out std_logic_vector(31 downto 0);
		SCALER_INPUT_2		: out std_logic_vector(31 downto 0);
		SCALER_INPUT_3		: out std_logic_vector(31 downto 0);
		SCALER_OUTPUT_1	: out std_logic_vector(31 downto 0);
		SCALER_OUTPUT_2	: out std_logic_vector(31 downto 0);
		SCALER_OUTPUT_3	: out std_logic_vector(31 downto 0)
	);
end sd_scalers;

architecture Synthesis of sd_scalers is
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

	Scaler_Busy_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => BUSY, SCALER => SCALER_BUSY);

	Scaler_BusyCycles_inst: Scaler
		generic map(LEN => 32, EDGE_DET => false, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => BUSY, SCALER => SCALER_BUSYCYCLES);

	Scaler_Or1_0_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OR_1_0_SYNC, SCALER => SCALER_OR_1_0);

	Scaler_Or1_1_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OR_1_1_SYNC, SCALER => SCALER_OR_1_1);

	Scaler_Or2_0_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OR_2_0_SYNC, SCALER => SCALER_OR_2_0);

	Scaler_Or2_1_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OR_2_1_SYNC, SCALER => SCALER_OR_2_1);

	Scaler_Or3_0_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OR_3_0_SYNC, SCALER => SCALER_OR_3_0);

	Scaler_Or3_1_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OR_3_1_SYNC, SCALER => SCALER_OR_3_1);

	Scaler_Input_1_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => INPUT_1_SYNC, SCALER => SCALER_INPUT_1);

	Scaler_Input_2_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => INPUT_2_SYNC, SCALER => SCALER_INPUT_2);

	Scaler_Input_3_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => INPUT_3_SYNC, SCALER => SCALER_INPUT_3);

	Scaler_Output_1_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OUTPUT_1_MUX, SCALER => SCALER_OUTPUT_1);

	Scaler_Output_2_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OUTPUT_2_MUX, SCALER => SCALER_OUTPUT_2);

	Scaler_Output_3_inst: Scaler
		generic map(LEN => 32, EDGE_DET => true, BUFFERED => false)
		port map(CLK => CLK, GATE => '1', LATCH => SCALER_LATCH, RESET => SCALER_RESET, INPUT => OUTPUT_3_MUX, SCALER => SCALER_OUTPUT_3);

end Synthesis;
