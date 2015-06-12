library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity triggerunit is
	port(
		BUSY						: out std_logic;
		
		-- CLK domain signals
		CLK						: in std_logic;
		TRIG						: in std_logic;
		SYNC						: in std_logic;

		-- BUS_CLK domain signals
		BUS_CLK					: in std_logic;
		RESET_SOFT				: in std_logic;

		TRIG_FIFO_BUSY_THR	: in std_logic_vector(7 downto 0);
		LOOKBACK					: in std_logic_vector(9 downto 0);
		WINDOW_WIDTH			: in std_logic_vector(9 downto 0);

		TRIG_FIFO_RD_EB		: in std_logic;
		TRIG_FIFO_DOUT_EB		: out std_logic_vector(47 downto 0);
		TRIG_FIFO_EMPTY_EB	: out std_logic;

		TRIG_FIFO_WR_CH		: out std_logic;
		TRIG_FIFO_START_CH	: out std_logic_vector(9 downto 0);
		TRIG_FIFO_STOP_CH		: out std_logic_vector(9 downto 0)
	);
end triggerunit;

architecture synthesis of triggerunit is
	component xfifo_48b256d_fwft_async is
		port(
			RD_EN					: in std_logic;
			RST					: in std_logic;
			EMPTY					: out std_logic;
			WR_EN					: in std_logic;
			RD_CLK				: in std_logic;
			FULL					: out std_logic;
			WR_CLK				: in std_logic;
			PROG_FULL			: out std_logic;
			DOUT					: out std_logic_vector(47 downto 0);
			DIN					: in std_logic_vector(47 downto 0);
			PROG_FULL_THRESH	: in std_logic_vector(7 downto 0)
		);
	end component;

	component xfifo_10b256d_fwft_async is
		port(
			RD_EN					: in std_logic;
			RST					: in std_logic;
			EMPTY					: out std_logic;
			WR_EN					: in std_logic;
			RD_CLK				: in std_logic;
			FULL					: out std_logic;
			WR_CLK				: in std_logic;
			PROG_FULL			: out std_logic;
			DOUT					: out std_logic_vector(9 downto 0);
			DIN					: in std_logic_vector(9 downto 0);
			PROG_FULL_THRESH	: in std_logic_vector(7 downto 0)
		);
	end component;

	signal TIMER				: std_logic_vector(47 downto 0) := (others=>'0');
	signal TRIG_Q				: std_logic_vector(1 downto 0);
	signal SYNC_Q				: std_logic;
	signal FULL_EB				: std_logic;
	signal FULL_CH				: std_logic;
	signal FIFO_DIN			: std_logic_vector(47 downto 0) := (others=>'0');
	signal FIFO_DOUT_CH		: std_logic_vector(9 downto 0) := (others=>'0');
	signal FIFO_FULL_EB		: std_logic;
	signal FIFO_EMPTY_CH		: std_logic;
	signal FIFO_RD_CH			: std_logic;
	signal FIFO_WR				: std_logic;
begin

	BUSY <= FIFO_FULL_EB;

	-- CLK domain signals
	process(CLK)
	begin
		if rising_edge(CLK) then
			if (TRIG_Q(0) = '1') and (TRIG_Q(1) = '0') and (FULL_EB = '0') and (FULL_CH = '0') then
				FIFO_WR <= '1';
				FIFO_DIN <= TIMER;
			else
				FIFO_WR <= '0';
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SYNC_Q = '1' then
				TIMER <= (others=>'0');
			else
				TIMER <= std_logic_vector(unsigned(TIMER) + 1);
			end if;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			SYNC_Q <= SYNC;
			TRIG_Q <= TRIG_Q(0) & TRIG;
		end if;
	end process;

	-- BUS_CLK domain signals
	FIFO_RD_CH <= not FIFO_EMPTY_CH;

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			TRIG_FIFO_WR_CH <= FIFO_RD_CH;
			TRIG_FIFO_START_CH <= std_logic_vector(unsigned(FIFO_DOUT_CH) - unsigned(LOOKBACK));
			TRIG_FIFO_STOP_CH <= std_logic_vector(unsigned(FIFO_DOUT_CH) - unsigned(LOOKBACK) + unsigned(WINDOW_WIDTH));
		end if;
	end process;

	-- CLK <-> BUS_CLK crossing
	xfifo_48b256d_fwft_async_inst_eb: xfifo_48b256d_fwft_async
		port map(
			RD_EN					=> TRIG_FIFO_RD_EB,
			RST					=> RESET_SOFT,
			EMPTY					=> TRIG_FIFO_EMPTY_EB,
			WR_EN					=> FIFO_WR,
			RD_CLK				=> BUS_CLK,
			FULL					=> FULL_EB,
			WR_CLK				=> CLK,
			PROG_FULL			=> FIFO_FULL_EB,
			DOUT					=> TRIG_FIFO_DOUT_EB,
			DIN					=> FIFO_DIN,
			PROG_FULL_THRESH	=> TRIG_FIFO_BUSY_THR
		);

	xfifo_10b256d_fwft_async_inst_ch: xfifo_10b256d_fwft_async
		port map(
			RD_EN					=> FIFO_RD_CH,
			RST					=> RESET_SOFT,
			EMPTY					=> FIFO_EMPTY_CH,
			WR_EN					=> FIFO_WR,
			RD_CLK				=> BUS_CLK,
			FULL					=> FULL_CH,
			WR_CLK				=> CLK,
			PROG_FULL			=> open,
			DOUT					=> FIFO_DOUT_CH,
			DIN					=> FIFO_DIN(9 downto 0),
			PROG_FULL_THRESH	=> (others=>'1')
		);

end synthesis;
