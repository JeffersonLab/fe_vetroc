library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity eventbuilder_per is
	generic(
		ADDR_INFO				: PER_ADDR_INFO;
		TRIG_FIFO_BUSY_THR	: integer := 2;
		EVT_FIFO_ARRAY_NUM	: integer
	);
	port(
		-- User ports --------------------------------------

		------------------------------
		-- CLK domain signals
		------------------------------
		CLK						: in std_logic;
		TRIG						: in std_logic;
		SYNC						: in std_logic;
		BUSY						: out std_logic;

		------------------------------
		-- BUS_CLK domain signals
		------------------------------

		-- Trigger unit interface
		TRIG_FIFO_WR			: out std_logic;
		TRIG_FIFO_START		: out std_logic_vector(9 downto 0);
		TRIG_FIFO_STOP			: out std_logic_vector(9 downto 0);

		-- Event builder interface
		EVT_FIFO_DOUT_ARRAY	: in slv33a(EVT_FIFO_ARRAY_NUM-1 downto 0);
		EVT_FIFO_RD_ARRAY		: out std_logic_vector(EVT_FIFO_ARRAY_NUM-1 downto 0);
		EVT_FIFO_EMPTY_ARRAY	: in std_logic_vector(EVT_FIFO_ARRAY_NUM-1 downto 0);

		-- Bus interface ports -----------------------------
		BUS_CLK					: in std_logic;
		BUS_RESET				: in std_logic;
		BUS_RESET_SOFT			: in std_logic;
		BUS_DIN					: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT					: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR					: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR					: in std_logic;
		BUS_RD					: in std_logic;
		BUS_ACK					: out std_logic
	);
end eventbuilder_per;

architecture Synthesis of eventbuilder_per is
	component triggerunit is
		generic(
			TRIG_FIFO_BUSY_THR	: integer := 2
		);
		port(
			BUSY						: out std_logic;
			
			-- CLK domain signals
			CLK						: in std_logic;
			TRIG						: in std_logic;
			SYNC						: in std_logic;

			-- BUS_CLK domain signals
			BUS_CLK					: in std_logic;
			RESET_SOFT				: in std_logic;

			LOOKBACK					: in std_logic_vector(9 downto 0);
			WINDOW_WIDTH			: in std_logic_vector(9 downto 0);
			TRIG_DELAY				: in std_logic_vector(9 downto 0);

			TRIG_FIFO_RD_EB		: in std_logic;
			TRIG_FIFO_DOUT_EB		: out std_logic_vector(47 downto 0);
			TRIG_FIFO_EMPTY_EB	: out std_logic;

			TRIG_FIFO_WR_CH		: out std_logic;
			TRIG_FIFO_START_CH	: out std_logic_vector(9 downto 0);
			TRIG_FIFO_STOP_CH		: out std_logic_vector(9 downto 0)
		);
	end component;

	component evtbuilderfull is
		port(
			CLK						: in std_logic;
			RESET						: in std_logic;

			TRIG_FIFO_RD			: out std_logic;
			TRIG_FIFO_DATA			: in std_logic_vector(47 downto 0);
			TRIG_FIFO_EMPTY		: in std_logic;
			
			DEVICEID					: in std_logic_vector(4 downto 0);
			BLOCK_SIZE				: in std_logic_vector(7 downto 0);
			
			USER_FIFO_DATA			: out std_logic_vector(35 downto 0);
			USER_FIFO_EMPTY		: out std_logic;
			USER_FIFO_RDREQ		: in std_logic;
		
			BLD_DATA					: in std_logic_vector(31 downto 0);
			BLD_EVTEND				: in std_logic;
			BLD_EMPTY				: in std_logic;
			BLD_READ					: out std_logic;
			
			USER_FIFO_WORD_CNT	: out std_logic_vector(31 downto 0); 
			USER_FIFO_EVENT_CNT	: out std_logic_vector(31 downto 0)
		);
	end component;

	component evtbuilderstage is
		generic(
			GRP_NUM			: integer := 4
		);
		port(
			CLK_WR			: in std_logic;
			CLK_RD			: in std_logic;
			
			RESET				: in std_logic;
			
			GRP_BLD_DATA	: in slv33a(GRP_NUM-1 downto 0);
			GRP_BLD_EMPTY	: in std_logic_vector(GRP_NUM-1 downto 0);
			GRP_BLD_READ	: out std_logic_vector(GRP_NUM-1 downto 0);

			BLD_DATA			: out std_logic_vector(32 downto 0);
			BLD_EMPTY		: out std_logic;
			BLD_READ			: in std_logic
		);
	end component;

	signal PI							: pbus_if_i;
	signal PO							: pbus_if_o;

	-- Registers
	signal LOOKBACK_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal WINDOW_WIDTH_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal BLOCK_CFG_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal DEVICEID_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal READOUT_CFG_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal READOUT_STATUS_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal FIFO_BLOCK_CNT_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal FIFO_WORD_CNT_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal FIFO_EVENT_CNT_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal TRIG_DELAY_REG			: std_logic_vector(31 downto 0) := x"00000000";

	-- Register bits
	signal LOOKBACK					: std_logic_vector(9 downto 0);
	signal WINDOW_WIDTH				: std_logic_vector(9 downto 0);
	signal TRIG_DELAY					: std_logic_vector(9 downto 0);
	signal BLOCK_SIZE					: std_logic_vector(7 downto 0);
	signal DEVICEID					: std_logic_vector(4 downto 0);
	signal USER_FIFO_WORD_CNT		: std_logic_vector(31 downto 0);
	signal USER_FIFO_EVENT_CNT		: std_logic_vector(31 downto 0);
	signal EVT_WORD_INT_LEVEL		: std_logic_vector(15 downto 0);
	signal EVT_NUM_INT_LEVEL		: std_logic_vector(14 downto 0);

	-- to channel event builders
	signal BLD_DATA					: std_logic_vector(32 downto 0);
	signal BLD_EMPTY					: std_logic;
	signal BLD_READ					: std_logic;

	signal USER_FIFO_DATA			: std_logic_vector(35 downto 0);
	signal USER_FIFO_EMPTY			: std_logic;
	signal USER_FIFO_RDREQ			: std_logic;

	signal TRIG_FIFO_RD_EB			: std_logic;
	signal TRIG_FIFO_DOUT_EB		: std_logic_vector(47 downto 0);
	signal TRIG_FIFO_EMPTY_EB		: std_logic;
begin

	triggerunit_inst: triggerunit
		generic map(
			TRIG_FIFO_BUSY_THR	=> TRIG_FIFO_BUSY_THR
		)
		port map(
			BUSY						=> BUSY,
			CLK						=> CLK,
			TRIG						=> TRIG,
			SYNC						=> SYNC,
			BUS_CLK					=> BUS_CLK,
			RESET_SOFT				=> PI.RESET_SOFT,
			LOOKBACK					=> LOOKBACK,
			WINDOW_WIDTH			=> WINDOW_WIDTH,
			TRIG_DELAY				=> TRIG_DELAY,
			TRIG_FIFO_RD_EB		=> TRIG_FIFO_RD_EB,
			TRIG_FIFO_DOUT_EB		=> TRIG_FIFO_DOUT_EB,
			TRIG_FIFO_EMPTY_EB	=> TRIG_FIFO_EMPTY_EB,
			TRIG_FIFO_WR_CH		=> TRIG_FIFO_WR,
			TRIG_FIFO_START_CH	=> TRIG_FIFO_START,
			TRIG_FIFO_STOP_CH		=> TRIG_FIFO_STOP
		);

	evtbuilderfull_inst: evtbuilderfull
		port map(
			CLK						=> BUS_CLK,
			RESET						=> BUS_RESET_SOFT,
			TRIG_FIFO_RD			=> TRIG_FIFO_RD_EB,
			TRIG_FIFO_DATA			=> TRIG_FIFO_DOUT_EB,
			TRIG_FIFO_EMPTY		=> TRIG_FIFO_EMPTY_EB,
			DEVICEID					=> DEVICEID,
			BLOCK_SIZE				=> BLOCK_SIZE,
			USER_FIFO_DATA			=> USER_FIFO_DATA,
			USER_FIFO_EMPTY		=> USER_FIFO_EMPTY,
			USER_FIFO_RDREQ		=> USER_FIFO_RDREQ,
			BLD_DATA					=> BLD_DATA(31 downto 0),
			BLD_EVTEND				=> BLD_DATA(32),
			BLD_EMPTY				=> BLD_EMPTY,
			BLD_READ					=> BLD_READ,
			USER_FIFO_WORD_CNT	=> USER_FIFO_WORD_CNT,
			USER_FIFO_EVENT_CNT	=> USER_FIFO_EVENT_CNT
		);

	evtbuilderstage_inst: evtbuilderstage
		generic map(
			GRP_NUM			=> EVT_FIFO_ARRAY_NUM
		)
		port map(
			CLK_WR			=> BUS_CLK,
			CLK_RD			=> BUS_CLK,
			RESET				=> BUS_RESET_SOFT,			
 			GRP_BLD_DATA	=> EVT_FIFO_DOUT_ARRAY,
 			GRP_BLD_EMPTY	=> EVT_FIFO_EMPTY_ARRAY,
	 		GRP_BLD_READ	=> EVT_FIFO_RD_ARRAY,
			BLD_DATA			=> BLD_DATA,
			BLD_EMPTY		=> BLD_EMPTY,
			BLD_READ			=> BLD_READ
		);

	-----------------------------------
	-- Registers
	-----------------------------------	

	PerBusCtrl_CLK_inst: PerBusCtrl
		generic map(
			ADDR_INFO		=> ADDR_INFO
		)
		port map(
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT,
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK,
			PER_CLK			=> BUS_CLK,
			PER_RESET		=> PI.RESET,
			PER_RESET_SOFT	=> PI.RESET_SOFT,
			PER_DIN			=> PI.DIN,
			PER_ADDR			=> PI.ADDR,
			PER_WR			=> PI.WR,
			PER_RD			=> PI.RD,
			PER_MATCH		=> PI.MATCH,
			PER_DOUT			=> PO.DOUT,
			PER_ACK			=> PO.ACK
		);

-- Register bits

	-- FIFO_WORD_CNT_REG
	FIFO_WORD_CNT_REG <= USER_FIFO_WORD_CNT;

	-- FIFO_EVENT_CNT_REG
	FIFO_EVENT_CNT_REG <= USER_FIFO_EVENT_CNT;

	--LOOKBACK_REG
	LOOKBACK <= LOOKBACK_REG(9 downto 0);

	--WINDOW_WIDTH_REG
	WINDOW_WIDTH <= WINDOW_WIDTH_REG(9 downto 0);

	--BLOCK_CFG_REG
	BLOCK_SIZE <= BLOCK_CFG_REG(7 downto 0);

	--DEVICEID_REG
	DEVICEID <= DEVICEID_REG(4 downto 0);

	--TRIG_DELAY_REG
	TRIG_DELAY <= TRIG_DELAY_REG(9 downto 0);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';

			rw_reg(		REG => LOOKBACK_REG			,PI=>PI,PO=>PO, A => x"0000", RW => x"000003FF");
			rw_reg(		REG => WINDOW_WIDTH_REG		,PI=>PI,PO=>PO, A => x"0004", RW => x"000003FF");
			rw_reg(		REG => BLOCK_CFG_REG			,PI=>PI,PO=>PO, A => x"0008", RW => x"000000FF");
			rw_reg(		REG => DEVICEID_REG			,PI=>PI,PO=>PO, A => x"0010", RW => x"0000001F");
			rw_reg(		REG => TRIG_DELAY_REG		,PI=>PI,PO=>PO, A => x"0014", RW => x"000003FF");
			ro_reg(		REG => FIFO_WORD_CNT_REG	,PI=>PI,PO=>PO, A => x"0024", RO => x"FFFFFFFF");
			ro_reg(		REG => FIFO_EVENT_CNT_REG	,PI=>PI,PO=>PO, A => x"0028", RO => x"FFFFFFFF");
			ro_reg_ack(	REG => USER_FIFO_DATA(31 downto 0)	,PI=>PI,PO=>PO, A => x"0080", RO => x"FFFFFFFF", ACK => USER_FIFO_RDREQ);
		end if;
	end process;

end Synthesis;
