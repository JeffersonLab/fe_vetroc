library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library utils;
use utils.utils_pkg.all;

entity tdc_index_finder is
	port(
		------------------------------
		-- BUS_CLK domain signals
		------------------------------
		BUS_CLK				: in std_logic;

		-- Trigger unit interface
		TRIG_FIFO_WR		: in std_logic;
		TRIG_FIFO_START	: in std_logic_vector(9 downto 0);
		TRIG_FIFO_STOP		: in std_logic_vector(9 downto 0);

		------------------------------
		-- CLK domain signals
		------------------------------
		CLK					: in std_logic;
		RESET_SOFT			: in std_logic;

 		RD_ADDR_IDX			: out std_logic_vector(9 downto 0);
		ADDR_IDX				: in std_logic_vector(9 downto 0);
		LEN_IDX				: in std_logic_vector(5 downto 0);
		VALID_IDX			: in std_logic;

		IDX_RD				: in std_logic;
		IDX_EMPTY			: out std_logic;
		IDX_ADDR				: out std_logic_vector(9 downto 0);
		IDX_LEN				: out std_logic_vector(5 downto 0);
		IDX_START			: out std_logic_vector(9 downto 0);
		IDX_END				: out std_logic
	);
end tdc_index_finder;

architecture synthesis of tdc_index_finder is
	component xfifo_20b256d_fwft_async is
		port(
			RD_EN					: in std_logic;
			RST					: in std_logic;
			EMPTY					: out std_logic;
			WR_EN					: in std_logic;
			RD_CLK				: in std_logic;
			FULL					: out std_logic;
			WR_CLK				: in std_logic;
			PROG_FULL			: out std_logic;
			DOUT					: out std_logic_vector(19 downto 0);
			DIN					: in std_logic_vector(19 downto 0);
			PROG_FULL_THRESH	: in std_logic_vector(7 downto 0)
		);
	end component;

	signal TRIG_FIFO_START_DOUT	: std_logic_vector(9 downto 0) := (others=>'0');
	signal TRIG_FIFO_STOP_DOUT		: std_logic_vector(9 downto 0) := (others=>'0');
	signal TRIG_FIFO_RD				: std_logic := '0';
	signal TRIG_FIFO_EMPTY			: std_logic := '0';
	signal RD_ADDR_IDX_i				: std_logic_vector(9 downto 0) := (others=>'0');
	signal TIMER_CNT_DONE			: std_logic := '0';
	signal TIMER_CNT_RST				: std_logic := '0';
	signal TIMER_CNT					: unsigned(9 downto 0) := (others=>'0');
	signal CHECK_VALID				: std_logic_vector(2 downto 0) := (others=>'0');
	signal T_START						: slv10a(2 downto 0) := (others=>(others=>'0'));
	signal DIN							: std_logic_vector(26 downto 0) := (others=>'0');
	signal WR							: std_logic := '0';
	signal FULL							: std_logic := '0';
	signal WRITE_END					: std_logic_vector(2 downto 0) := (others=>'0');
	signal NEED_TO_WRITE_END		: std_logic := '0';
begin

	TRIG_FIFO_RD <= TIMER_CNT_RST and not FULL;

	RD_ADDR_IDX <= RD_ADDR_IDX_i;

	TIMER_CNT_DONE <= '1' when TIMER_CNT = to_unsigned(0, TIMER_CNT'length) else '0';

	TIMER_CNT_RST <= '1' when (TRIG_FIFO_EMPTY = '0') and (TIMER_CNT_DONE = '1') and (NEED_TO_WRITE_END = '0') else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if FULL = '0' then
				T_START <= T_START(T_START'length-2 downto 0) & TRIG_FIFO_START_DOUT;
				CHECK_VALID <= CHECK_VALID(CHECK_VALID'length-2 downto 0) & (TIMER_CNT_RST or not TIMER_CNT_DONE);
				WRITE_END <= WRITE_END(WRITE_END'length-2 downto 0) & (TIMER_CNT_DONE and NEED_TO_WRITE_END);

				if TIMER_CNT_RST = '1' then
					NEED_TO_WRITE_END <= '1';
					TIMER_CNT <= unsigned(TRIG_FIFO_STOP_DOUT) - unsigned(TRIG_FIFO_START_DOUT);
					RD_ADDR_IDX_i <= TRIG_FIFO_START_DOUT;
				elsif TIMER_CNT_DONE = '0' then
					TIMER_CNT <= TIMER_CNT - 1;
					RD_ADDR_IDX_i <= std_logic_vector(unsigned(RD_ADDR_IDX_i) + 1);
				elsif NEED_TO_WRITE_END = '1' then
					NEED_TO_WRITE_END <= '0';
				end if;

				WR <= (CHECK_VALID(CHECK_VALID'length-1) and VALID_IDX) or WRITE_END(WRITE_END'length-1);
				DIN(9 downto 0) <= ADDR_IDX;
				DIN(15 downto 10) <= LEN_IDX;
				DIN(25 downto 16) <= T_START(T_START'length-1);
				DIN(26) <= WRITE_END(WRITE_END'length-1);
			end if;
		end if;
	end process;

 	scfifo_generic_inst_trigunit: scfifo_generic
 		generic map(
 			D_WIDTH					=> 27,
 			A_WIDTH					=> 4,
 			DOUT_REG					=> true,
 			FWFT						=> true
 		)
 		port map(
 			CLK						=> CLK,
 			RST						=> RESET_SOFT,
 			DIN						=> DIN,
 			WR							=> WR,
 			FULL						=> FULL,
 			DOUT(9 downto 0)		=> IDX_ADDR,
 			DOUT(15 downto 10)	=> IDX_LEN,
			DOUT(25 downto 16)	=> IDX_START,
 			DOUT(26)					=> IDX_END,
 			RD							=> IDX_RD,
 			EMPTY						=> IDX_EMPTY
 		);

	-- Trigger unit interface FIFO
	xfifo_20b256d_fwft_async_inst: xfifo_20b256d_fwft_async
		port map(
			RD_EN						=> TRIG_FIFO_RD,
			RST						=> RESET_SOFT,
			EMPTY						=> TRIG_FIFO_EMPTY,
			WR_EN						=> TRIG_FIFO_WR,
			RD_CLK					=> CLK,
			FULL						=> open,
			WR_CLK					=> BUS_CLK,
			PROG_FULL				=> open,
			DOUT(9 downto 0)		=> TRIG_FIFO_START_DOUT,
			DOUT(19 downto 10)	=> TRIG_FIFO_STOP_DOUT,
			DIN(9 downto 0)		=> TRIG_FIFO_START,
			DIN(19 downto 10)		=> TRIG_FIFO_STOP,
			PROG_FULL_THRESH		=> (others=>'1')
		);

end synthesis;
