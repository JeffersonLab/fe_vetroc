library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library utils;
use utils.utils_pkg.all;

use work.eventbuilder_per_pkg.all;

entity tdc_data_eb is
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
end tdc_data_eb;

architecture synthesis of tdc_data_eb is
	component tdc_event_writer is
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
	end component;

	component tdc_index_finder is
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
	end component;

	signal RD_ADDR_BUF			: std_logic_vector(9 downto 0);
	signal DOUT_BUF				: std_logic_vector(11 downto 0);
	signal TOUT_BUF				: std_logic_vector(9 downto 0);
 	signal RD_ADDR_IDX			: std_logic_vector(9 downto 0);
	signal ADDR_IDX				: std_logic_vector(9 downto 0);
	signal LEN_IDX					: std_logic_vector(5 downto 0);
	signal VALID_IDX				: std_logic;
	signal IDX_RD					: std_logic;
	signal IDX_EMPTY				: std_logic;
	signal IDX_ADDR				: std_logic_vector(9 downto 0);
	signal IDX_LEN					: std_logic_vector(5 downto 0);
	signal IDX_START				: std_logic_vector(9 downto 0);
	signal IDX_END					: std_logic;
	signal EN_Q						: std_logic;
	signal T_Q						: std_logic_vector(9 downto 0);
	signal D_Q						: std_logic_vector(11 downto 0);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			EN_Q <= EN;
			T_Q <= T;
			D_Q <= D;
		end if;
	end process;


	tdc_finder_inst: tdc_index_finder
		port map(
			BUS_CLK				=> BUS_CLK,
			TRIG_FIFO_WR		=> TRIG_FIFO_WR,
			TRIG_FIFO_START	=> TRIG_FIFO_START,
			TRIG_FIFO_STOP		=> TRIG_FIFO_STOP,
			CLK					=> CLK,
			RESET_SOFT			=> RESET_SOFT,
			RD_ADDR_IDX			=> RD_ADDR_IDX,
			ADDR_IDX				=> ADDR_IDX,
			LEN_IDX				=> LEN_IDX,
			VALID_IDX			=> VALID_IDX,
			IDX_RD				=> IDX_RD,
			IDX_EMPTY			=> IDX_EMPTY,
			IDX_ADDR				=> IDX_ADDR,
			IDX_LEN				=> IDX_LEN,
			IDX_START			=> IDX_START,
			IDX_END				=> IDX_END
		);

	tdc_event_writer_inst: tdc_event_writer
		generic map(
			TRIG_FIFO_TAG		=> TRIG_FIFO_TAG
		)
		port map(
			CLK					=> CLK,
			RESET_SOFT			=> RESET_SOFT,
			IDX_RD				=> IDX_RD,
			IDX_EMPTY			=> IDX_EMPTY,
			IDX_ADDR				=> IDX_ADDR,
			IDX_LEN				=> IDX_LEN,
			IDX_START			=> IDX_START,
			IDX_END				=> IDX_END,
			RD_ADDR_BUF			=> RD_ADDR_BUF,
			DOUT_BUF				=> DOUT_BUF,
			TOUT_BUF				=> TOUT_BUF,
			BUS_CLK				=> BUS_CLK,
			EVT_FIFO_DOUT		=> EVT_FIFO_DOUT,
			EVT_FIFO_RD			=> EVT_FIFO_RD,
			EVT_FIFO_EMPTY		=> EVT_FIFO_EMPTY
		);

	indexer_inst: indexer
		generic map(
			A_WIDTH_BUF				=> 10,
			D_WIDTH					=> 12,
			T_WIDTH					=> 10,
			N_WIDTH					=> 6
		)
		port map(
			WR_CLK					=> CLK,
			WR_CLK_2X				=> CLK_2X,
			WR							=> EN_Q,
			DIN						=> D_Q,
			TIN						=> T_Q,
			RESET						=> SYNC,
			RD_CLK					=> CLK,
			RD_ADDR					=> RD_ADDR_BUF,
			DOUT						=> DOUT_BUF,
			TOUT						=> TOUT_BUF,
			RD_ADDR_IDX				=> RD_ADDR_IDX,
			ADDR_IDX					=> ADDR_IDX,
			LEN_IDX					=> LEN_IDX,
			VALID_IDX				=> VALID_IDX
		);

end synthesis;
