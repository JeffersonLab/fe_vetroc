library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

library utils;
use utils.utils_pkg.all;

entity tdc_channel_group is
	generic(
		CHANNEL_START		: integer := 0;
		INVERTED				: boolean := true
	);
	port(
		SCALER_LATCH			: in std_logic;
		SCALER_RESET			: in std_logic;
		TDC_SCALER				: out slv32a(15 downto 0);
		ENABLE_N					: in std_logic_vector(15 downto 0);

		------------------------------
		-- GCLK domain signals
		------------------------------
		GCLK_125					: in std_logic;
		GCLK_250					: in std_logic;
		GCLK_500					: in std_logic;
		GCLK_500_180			: in std_logic;
		RESET_SOFT				: in std_logic;
		SYNC						: in std_logic;
		
		HIT						: in std_logic_vector(15 downto 0);

		HIT_ASYNC				: out std_logic_vector(15 downto 0);

		------------------------------
		-- BUS_CLK domain signals
		------------------------------
		BUS_CLK					: in std_logic;

		-- Trigger unit interface
		TRIG_FIFO_WR			: in std_logic;
		TRIG_FIFO_START		: in std_logic_vector(9 downto 0);
		TRIG_FIFO_STOP			: in std_logic_vector(9 downto 0);

		-- Event builder interface
		EVT_FIFO_DOUT			: out std_logic_vector(32 downto 0);
		EVT_FIFO_RD				: in std_logic;
		EVT_FIFO_EMPTY			: out std_logic
	);
end tdc_channel_group;

architecture synthesis of tdc_channel_group is
	component tdc_input is
		generic(
			INVERTED				: boolean := true
		);
		port(
			GCLK_125				: in std_logic;
			GCLK_500				: in std_logic;
			GCLK_500_180		: in std_logic;

			ENABLE_N				: in std_logic;
			
			HIT					: in std_logic;

			HIT_ASYNC			: out std_logic;

			TDC_HIT				: out std_logic;
			TDC_EDGE				: out std_logic;
			TDC_HIT_OFFSET		: out std_logic_vector(2 downto 0);
			
			SCALER_LATCH		: in std_logic;
			SCALER_RESET		: in std_logic;
			TDC_SCALER			: out std_logic_vector(31 downto 0)
		);
	end component;

	component tdc_channel_fifo_sort is
		generic(
			AWIDTH	: integer
		);
		port(
			CLK		: in std_logic;

			WR_0		: in std_logic;
			DIN_0		: in std_logic_vector(21 downto 0);
			FULL_0	: out std_logic;

			WR_1		: in std_logic;
			DIN_1		: in std_logic_vector(21 downto 0);
			FULL_1	: out std_logic;

			WR			: out std_logic;
			DIN		: out std_logic_vector(21 downto 0);
			FULL		: in std_logic
		);
	end component;

	component tdc_data_eb is
		generic(
			TRIG_FIFO_TAG			: std_logic_vector(3 downto 0)
		);
		port(
			------------------------------
			-- CLK domain signals
			------------------------------
			CLK					: in std_logic;
			CLK_2X				: in std_logic;
			SYNC					: in std_logic;
			RESET_SOFT			: in std_logic;

			EN						: in std_logic;
			T						: in std_logic_vector(9 downto 0);
			D						: in std_logic_vector(11 downto 0);

			------------------------------
			-- BUS_CLK domain signals
			------------------------------
			BUS_CLK				: in std_logic;

			-- Trigger unit interface
			TRIG_FIFO_WR		: in std_logic;
			TRIG_FIFO_START	: in std_logic_vector(9 downto 0);
			TRIG_FIFO_STOP		: in std_logic_vector(9 downto 0);

			-- Event builder interface
			EVT_FIFO_DOUT		: out std_logic_vector(32 downto 0);
			EVT_FIFO_RD			: in std_logic;
			EVT_FIFO_EMPTY		: out std_logic
		);
	end component;

	constant TDC_HIT_TAG		: std_logic_vector(3 downto 0) := "1000";

	signal DIN					: slv22a(30 downto 0);
	signal WR					: std_logic_vector(30 downto 0);
	signal FULL					: std_logic_vector(30 downto 0) := (others=>'0');
	signal GTIME				: std_logic_vector(9 downto 0) := (others=>'0');
	signal TDC_HIT				: std_logic_vector(15 downto 0);
	signal TDC_EDGE			: std_logic_vector(15 downto 0);
	signal TDC_HIT_OFFSET	: slv3a(15 downto 0);
begin

	process(GCLK_125)
	begin
		if rising_edge(GCLK_125) then
			if SYNC = '1' then
				GTIME <= (others=>'0');
			else
				GTIME <= GTIME + 1;
			end if;
		end if;
	end process;

	tdc_channels_gen: for I in 0 to 15 generate
		DIN(I) <= TDC_EDGE(I) & conv_std_logic_vector(CHANNEL_START+I, 8) & GTIME & TDC_HIT_OFFSET(I);
		WR(I) <= TDC_HIT(I);

		tdc_input_inst: tdc_input
			generic map(
				INVERTED				=> INVERTED
			)
			port map(
				GCLK_125				=> GCLK_125,
				GCLK_500				=> GCLK_500,
				GCLK_500_180		=> GCLK_500_180,
				ENABLE_N				=> ENABLE_N(I),
				HIT					=> HIT(I),
				HIT_ASYNC			=> HIT_ASYNC(I),
				TDC_HIT				=> TDC_HIT(I),
				TDC_EDGE				=> TDC_EDGE(I),
				TDC_HIT_OFFSET		=> TDC_HIT_OFFSET(I),
				SCALER_LATCH		=> SCALER_LATCH,
				SCALER_RESET		=> SCALER_RESET,
				TDC_SCALER			=> TDC_SCALER(I)
			);
	end generate;

	tdc_sort_gen: for I in 0 to 14 generate
		tdc_channel_fifo_sort_inst: tdc_channel_fifo_sort
			generic map(
				AWIDTH => 4
			)
			port map(
				CLK		=> GCLK_125,
				WR_0		=> WR(2*I+0),
				DIN_0		=> DIN(2*I+0),
				FULL_0	=> FULL(2*I+0),
				WR_1		=> WR(2*I+1),
				DIN_1		=> DIN(2*I+1),
				FULL_1	=> FULL(2*I+1),
				WR			=> WR(16+I),
				DIN		=> DIN(16+I),
				FULL		=> FULL(16+I)
			);
	end generate;

	tdc_data_eb_inst: tdc_data_eb
		generic map(
			TRIG_FIFO_TAG		=> TDC_HIT_TAG
		)
		port map(
			CLK					=> GCLK_125,
			CLK_2X				=> GCLK_250,
			SYNC					=> SYNC,
			RESET_SOFT			=> RESET_SOFT,
			EN						=> WR(30),
			T						=> DIN(30)(12 downto 3),
			D(2 downto 0)		=> DIN(30)(2 downto 0),
			D(11 downto 3)		=> DIN(30)(21 downto 13),
			BUS_CLK				=> BUS_CLK,
			TRIG_FIFO_WR		=> TRIG_FIFO_WR,
			TRIG_FIFO_START	=> TRIG_FIFO_START,
			TRIG_FIFO_STOP		=> TRIG_FIFO_STOP,
			EVT_FIFO_DOUT		=> EVT_FIFO_DOUT,
			EVT_FIFO_RD			=> EVT_FIFO_RD,
			EVT_FIFO_EMPTY		=> EVT_FIFO_EMPTY
		);

end synthesis;
