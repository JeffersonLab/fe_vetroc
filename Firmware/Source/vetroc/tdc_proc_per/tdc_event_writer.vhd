library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library utils;
use utils.utils_pkg.all;

entity tdc_event_writer is
	generic(
		TRIG_FIFO_TAG			: std_logic_vector(3 downto 0)
	);
	port(
		------------------------------
		-- CLK domain signals
		------------------------------
		CLK					: in std_logic;
		RESET_SOFT			: in std_logic;

		IDX_RD				: out std_logic;
		IDX_EMPTY			: in std_logic;
		IDX_ADDR				: in std_logic_vector(9 downto 0);
		IDX_LEN				: in std_logic_vector(5 downto 0);
		IDX_START			: in std_logic_vector(9 downto 0);
		IDX_END				: in std_logic;

		RD_ADDR_BUF			: out std_logic_vector(9 downto 0);
		DOUT_BUF				: in std_logic_vector(11 downto 0);
		TOUT_BUF				: in std_logic_vector(9 downto 0);

		------------------------------
		-- BUS_CLK domain signals
		------------------------------
		BUS_CLK				: in std_logic;

		EVT_FIFO_DOUT		: out std_logic_vector(32 downto 0);
		EVT_FIFO_RD			: in std_logic;
		EVT_FIFO_EMPTY		: out std_logic
	);
end tdc_event_writer;

architecture synthesis of tdc_event_writer is
	component xfifo_33b512d_fwft_async is
		port(
			RD_EN					: in std_logic := 'X'; 
			RST					: in std_logic := 'X'; 
			EMPTY					: out std_logic; 
			WR_EN					: in std_logic := 'X'; 
			RD_CLK				: in std_logic := 'X'; 
			FULL					: out std_logic; 
			WR_CLK				: in std_logic := 'X'; 
			PROG_FULL			: out std_logic; 
			DOUT					: out std_logic_vector(32 downto 0); 
			DIN					: in std_logic_vector(32 downto 0); 
			PROG_FULL_THRESH	: in std_logic_vector(8 downto 0) 
		);
	end component;

	signal IDX_RD_i			: std_logic := '0';
	signal RD_ADDR_BUF_i		: std_logic_vector(9 downto 0) := (others=>'0');
	signal TIMER_CNT_DONE	: std_logic := '0';
	signal TIMER_CNT_RST		: std_logic := '0';
	signal TIMER_CNT			: unsigned(5 downto 0) := (others=>'0');
	signal WR_VALID			: std_logic_vector(2 downto 0) := (others=>'0');
	signal T_START				: slv10a(2 downto 0) := (others=>(others=>'0'));
	signal WRITE_END			: std_logic_vector(2 downto 0) := (others=>'0');
	signal WR					: std_logic := '0';
	signal DIN					: std_logic_vector(32 downto 0);
	signal FULL					: std_logic := '0';
begin

	IDX_RD <= IDX_RD_i;
	RD_ADDR_BUF <= RD_ADDR_BUF_i;

	IDX_RD_i <= ((IDX_END and not IDX_EMPTY) or TIMER_CNT_RST) and not FULL;

	TIMER_CNT_RST <= '1' when (IDX_EMPTY = '0') and (TIMER_CNT_DONE = '1') and (IDX_END = '0') else '0';

	TIMER_CNT_DONE <= '1' when TIMER_CNT = 0 else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if FULL = '0' then
				T_START <= T_START(T_START'length-2 downto 0) & IDX_START;
				WR_VALID <= WR_VALID(WR_VALID'length-2 downto 0) & (TIMER_CNT_RST or not TIMER_CNT_DONE);
				WRITE_END <= WRITE_END(WRITE_END'length-2 downto 0) & (IDX_END and IDX_RD_i);

				if TIMER_CNT_RST = '1' then
					TIMER_CNT <= unsigned(IDX_LEN);
					RD_ADDR_BUF_i <= IDX_ADDR;
				elsif TIMER_CNT_DONE = '0' then
					TIMER_CNT <= TIMER_CNT - 1;
					RD_ADDR_BUF_i <= std_logic_vector(unsigned(RD_ADDR_BUF_i) + 1);
				end if;

				WR <= WR_VALID(WR_VALID'length-1) or WRITE_END(WRITE_END'length-1);
				DIN(31 downto 0) <= "1" & TRIG_FIFO_TAG & DOUT_BUF(11) & "00" & DOUT_BUF(10 downto 3) & "000" & std_logic_vector(unsigned(TOUT_BUF)-unsigned(T_START(T_START'length-1))) & DOUT_BUF(2 downto 0);
				DIN(32) <= WRITE_END(WRITE_END'length-1);
			end if;
		end if;
	end process;

	-- Event builder interface FIFO
	xfifo_33b512d_fwft_async_inst: xfifo_33b512d_fwft_async
		port map(
			RD_EN						=> EVT_FIFO_RD,
			RST						=> RESET_SOFT,
			EMPTY						=> EVT_FIFO_EMPTY,
			WR_EN						=> WR,
			RD_CLK					=> BUS_CLK,
			FULL						=> open,
			WR_CLK					=> CLK,
			PROG_FULL				=> FULL,
			DOUT						=> EVT_FIFO_DOUT,
			DIN						=> DIN,
			PROG_FULL_THRESH		=> "111111111"
		);

end synthesis;
