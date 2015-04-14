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

		SLOTID					: in std_logic_vector(4 downto 0);
		A32_BASE_ADDR			: out std_logic_vector(8 downto 0);
		A32_BASE_ADDR_EN		: out std_logic;		
		A32M_ADDR_MIN			: out std_logic_vector(8 downto 0);
		A32M_ADDR_MAX			: out std_logic_vector(8 downto 0);
		A32M_ADDR_EN			: out std_logic;
		TOKEN_FIRST				: out std_logic;
		TOKEN_LAST				: out std_logic;
		TOKEN_STATUS			: in std_logic;
		TOKEN_TAKE				: out std_logic;
		USER_INT_ID				: out std_logic_vector(7 downto 0);
		USER_INT_LEVEL			: out std_logic_vector(2 downto 0);
		USER_BERR_EN			: out std_logic;
		USER_INT					: out std_logic;
		USER_FIFO_DATA_1		: out std_logic_vector(35 downto 0);
		USER_FIFO_EMPTY_1		: out std_logic;
		USER_FIFO_RDREQ_1		: in std_logic;
		USER_FIFO_DATA_2		: out std_logic_vector(35 downto 0);
		USER_FIFO_EMPTY_2		: out std_logic;
		USER_FIFO_RDREQ_2		: in std_logic;

		SRAM_REF_CLK			: in std_logic;
		
		-- SRAM Phy Signals
		SRAM_CLK					: out std_logic;
		SRAM_CLK_O				: out std_logic;
		SRAM_CLK_I				: in std_logic;
		SRAM_D					: inout std_logic_vector(17 downto 0);
		SRAM_A					: out std_logic_vector(19 downto 0);
		SRAM_RW					: out std_logic;
		SRAM_NOE					: out std_logic;
		SRAM_CS					: out std_logic;
		SRAM_ADV					: out std_logic;
			
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
	end component;

	component evtbuilderfull is
		port(
			CLK						: in std_logic;
			RESET						: in std_logic;

			TRIG_FIFO_RD			: out std_logic;
			TRIG_FIFO_DATA			: in std_logic_vector(47 downto 0);
			TRIG_FIFO_EMPTY		: in std_logic;
			
			SLOTID					: in std_logic_vector(4 downto 0);
			BLOCK_SIZE				: in std_logic_vector(7 downto 0);
			
			USER_FIFO_DATA_1		: out std_logic_vector(35 downto 0);
			USER_FIFO_EMPTY_1		: out std_logic;
			USER_FIFO_RDREQ_1		: in std_logic;
			USER_FIFO_DATA_2		: out std_logic_vector(35 downto 0);
			USER_FIFO_EMPTY_2		: out std_logic;
			USER_FIFO_RDREQ_2		: in std_logic;
		
			BLD_DATA					: in std_logic_vector(31 downto 0);
			BLD_EVTEND				: in std_logic;
			BLD_EMPTY				: in std_logic;
			BLD_READ					: out std_logic;
			
			USER_INT					: out std_logic;
			USER_INT_ACKED			: in std_logic;
			USER_INT_ENABLED		: in std_logic;
			USER_FIFO_WORD_CNT	: out std_logic_vector(31 downto 0); 
			USER_FIFO_EVENT_CNT	: out std_logic_vector(31 downto 0);
			USER_FIFO_BLOCK_CNT	: out std_logic_vector(31 downto 0);
			EVT_WORD_INT_LEVEL	: in std_logic_vector(15 downto 0); 
			EVT_NUM_INT_LEVEL		: in std_logic_vector(14 downto 0);
			
			SRAM_REF_CLK			: in std_logic;
			
			-- SRAM Debug Interface
			SRAM_DBG_WR				: in std_logic;
			SRAM_DBG_RD				: in std_logic;
			SRAM_DBG_ADDR			: in std_logic_vector(19 downto 0);
			SRAM_DBG_DIN			: in std_logic_vector(17 downto 0);
			SRAM_DBG_DOUT			: out std_logic_vector(17 downto 0);
			
			-- SRAM Phy Signals
			SRAM_CLK					: out std_logic;
			SRAM_CLK_O				: out std_logic;
			SRAM_CLK_I				: in std_logic;
			SRAM_D					: inout std_logic_vector(17 downto 0);
			SRAM_A					: out std_logic_vector(19 downto 0);
			SRAM_RW					: out std_logic;
			SRAM_NOE					: out std_logic;
			SRAM_CS					: out std_logic;
			SRAM_ADV					: out std_logic
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
	signal TRIG_FIFO_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LOOKBACK_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal WINDOW_WIDTH_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal BLOCK_CFG_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal ADR32_REG					: std_logic_vector(31 downto 0) := x"00000000";
	signal ADR32M_REG					: std_logic_vector(31 downto 0) := x"00000000";
	signal USER_INT_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal READOUT_CFG_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal READOUT_STATUS_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal FIFO_BLOCK_CNT_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal FIFO_WORD_CNT_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal FIFO_EVENT_CNT_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal SRAM_DIN_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal SRAM_DOUT_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal SRAM_CTRL_REG				: std_logic_vector(31 downto 0) := x"00000000";
	
	-- Register bits
	signal TRIG_FIFO_BUSY_THR		: std_logic_vector(7 downto 0);
	signal LOOKBACK					: std_logic_vector(9 downto 0);
	signal WINDOW_WIDTH				: std_logic_vector(9 downto 0);
	signal BLOCK_SIZE					: std_logic_vector(7 downto 0);
	signal USER_INT_ENABLED			: std_logic;
	signal USER_INT_ACKED			: std_logic;
	signal USER_FIFO_WORD_CNT		: std_logic_vector(31 downto 0);
	signal USER_FIFO_EVENT_CNT		: std_logic_vector(31 downto 0);
	signal USER_FIFO_BLOCK_CNT		: std_logic_vector(31 downto 0);
	signal EVT_WORD_INT_LEVEL		: std_logic_vector(15 downto 0);
	signal EVT_NUM_INT_LEVEL		: std_logic_vector(14 downto 0);
	signal SRAM_DBG_WR				: std_logic;
	signal SRAM_DBG_RD				: std_logic;
	signal SRAM_DBG_ADDR				: std_logic_vector(19 downto 0);
	signal SRAM_DBG_DIN				: std_logic_vector(17 downto 0);
	signal SRAM_DBG_DOUT				: std_logic_vector(17 downto 0);

	-- to channel event builders
	signal BLD_DATA					: std_logic_vector(32 downto 0);
	signal BLD_EMPTY					: std_logic;
	signal BLD_READ					: std_logic;

	signal TRIG_FIFO_RD_EB			: std_logic;
	signal TRIG_FIFO_DOUT_EB		: std_logic_vector(47 downto 0);
	signal TRIG_FIFO_EMPTY_EB		: std_logic;
begin

	triggerunit_inst: triggerunit
		port map(
			BUSY						=> BUSY,
			CLK						=> CLK,
			TRIG						=> TRIG,
			SYNC						=> SYNC,
			BUS_CLK					=> BUS_CLK,
			RESET_SOFT				=> PI.RESET_SOFT,
			TRIG_FIFO_BUSY_THR	=> TRIG_FIFO_BUSY_THR,
			LOOKBACK					=> LOOKBACK,
			WINDOW_WIDTH			=> WINDOW_WIDTH,
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
			SLOTID					=> SLOTID,
			BLOCK_SIZE				=> BLOCK_SIZE,
			USER_FIFO_DATA_1		=> USER_FIFO_DATA_1,
			USER_FIFO_EMPTY_1		=> USER_FIFO_EMPTY_1,
			USER_FIFO_RDREQ_1		=> USER_FIFO_RDREQ_1,
			USER_FIFO_DATA_2		=> USER_FIFO_DATA_2,
			USER_FIFO_EMPTY_2		=> USER_FIFO_EMPTY_2,
			USER_FIFO_RDREQ_2		=> USER_FIFO_RDREQ_2,
			BLD_DATA					=> BLD_DATA(31 downto 0),
			BLD_EVTEND				=> BLD_DATA(32),
			BLD_EMPTY				=> BLD_EMPTY,
			BLD_READ					=> BLD_READ,
			USER_INT					=> USER_INT,
			USER_INT_ACKED			=> USER_INT_ACKED,
			USER_INT_ENABLED		=> USER_INT_ENABLED,
			USER_FIFO_WORD_CNT	=> USER_FIFO_WORD_CNT,
			USER_FIFO_EVENT_CNT	=> USER_FIFO_EVENT_CNT,
			USER_FIFO_BLOCK_CNT	=> USER_FIFO_BLOCK_CNT,
			EVT_WORD_INT_LEVEL	=> EVT_WORD_INT_LEVEL,
			EVT_NUM_INT_LEVEL		=> EVT_NUM_INT_LEVEL,
			SRAM_REF_CLK			=> SRAM_REF_CLK,
			SRAM_DBG_WR				=> SRAM_DBG_WR,
			SRAM_DBG_RD				=> SRAM_DBG_RD,
			SRAM_DBG_ADDR			=> SRAM_DBG_ADDR,
			SRAM_DBG_DIN			=> SRAM_DBG_DIN,
			SRAM_DBG_DOUT			=> SRAM_DBG_DOUT,
			SRAM_CLK					=> SRAM_CLK,
			SRAM_CLK_O				=> SRAM_CLK_O,
			SRAM_CLK_I				=> SRAM_CLK_I,
			SRAM_D					=> SRAM_D,
			SRAM_A					=> SRAM_A,
			SRAM_RW					=> SRAM_RW,
			SRAM_NOE					=> SRAM_NOE,
			SRAM_CS					=> SRAM_CS,
			SRAM_ADV					=> SRAM_ADV
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

	-- FIFO_BLOCK_CNT_REG
	FIFO_BLOCK_CNT_REG <= USER_FIFO_BLOCK_CNT;

	-- FIFO_WORD_CNT_REG
	FIFO_WORD_CNT_REG <= USER_FIFO_WORD_CNT;

	-- FIFO_EVENT_CNT_REG
	FIFO_EVENT_CNT_REG <= USER_FIFO_EVENT_CNT;

	--TRIG_FIFO_REG
	TRIG_FIFO_BUSY_THR <= TRIG_FIFO_REG(7 downto 0);

	--LOOKBACK_REG
	LOOKBACK <= LOOKBACK_REG(9 downto 0);

	--WINDOW_WIDTH_REG
	WINDOW_WIDTH <= WINDOW_WIDTH_REG(9 downto 0);

	--BLOCK_CFG_REG
	BLOCK_SIZE <= BLOCK_CFG_REG(7 downto 0);

	--ADR32_REG
	A32_BASE_ADDR <= ADR32_REG(15 downto 7);
	A32_BASE_ADDR_EN <= ADR32_REG(0);

	--USER_INT_REG
	USER_INT_ID <= USER_INT_REG(7 downto 0);
	USER_INT_LEVEL <= USER_INT_REG(10 downto 8);
	USER_INT_ENABLED <= USER_INT_REG(11);
	USER_INT_ACKED <= USER_INT_REG(31);

	--READOUT_CFG_REG
	USER_BERR_EN <= READOUT_CFG_REG(0);
	EVT_WORD_INT_LEVEL <= READOUT_CFG_REG(31 downto 16);
	EVT_NUM_INT_LEVEL <= READOUT_CFG_REG(15 downto 1);

	--ADR32M_REG
	A32M_ADDR_MIN <= ADR32M_REG(8 downto 0);
	A32M_ADDR_MAX <= ADR32M_REG(24 downto 16);
	A32M_ADDR_EN <= ADR32M_REG(25);
	TOKEN_FIRST <= ADR32M_REG(26);
	TOKEN_LAST <= ADR32M_REG(27);
	TOKEN_TAKE <= ADR32M_REG(28);

	--READOUT_STATUS_REG
	READOUT_STATUS_REG(0) <= TOKEN_STATUS;

	--SRAM_DIN_REG
	SRAM_DBG_DIN <= SRAM_DIN_REG(17 downto 0);
	
	--SRAM_DOUT_REG
	SRAM_DIN_REG(17 downto 0) <= SRAM_DBG_DOUT;
	
	--SRAM_CTRL_REG
	SRAM_DBG_ADDR <= SRAM_CTRL_REG(19 downto 0);
	SRAM_DBG_WR <= SRAM_CTRL_REG(31);
	SRAM_DBG_RD <= SRAM_CTRL_REG(30);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';

			rw_reg(		REG => LOOKBACK_REG			,PI=>PI,PO=>PO, A => x"0000", RW => x"000003FF");
			rw_reg(		REG => WINDOW_WIDTH_REG		,PI=>PI,PO=>PO, A => x"0004", RW => x"000003FF");
			rw_reg(		REG => BLOCK_CFG_REG			,PI=>PI,PO=>PO, A => x"0008", RW => x"000000FF");
			rw_reg(		REG => ADR32_REG				,PI=>PI,PO=>PO, A => x"000C", RW => x"0000FF81");
			rw_reg(		REG => ADR32M_REG				,PI=>PI,PO=>PO, A => x"0010", RW => x"FFFFFFFF");
			rw_reg(		REG => USER_INT_REG			,PI=>PI,PO=>PO, A => x"0014", RW => x"80000FFF", R => x"80000000");
			rw_reg(		REG => READOUT_CFG_REG		,PI=>PI,PO=>PO, A => x"0018", RW => x"FFFFFFFF");
			ro_reg(		REG => READOUT_STATUS_REG	,PI=>PI,PO=>PO, A => x"001C", RO => x"00000001");
			ro_reg(		REG => FIFO_BLOCK_CNT_REG	,PI=>PI,PO=>PO, A => x"0020", RO => x"FFFFFFFF");
			ro_reg(		REG => FIFO_WORD_CNT_REG	,PI=>PI,PO=>PO, A => x"0024", RO => x"FFFFFFFF");
			ro_reg(		REG => FIFO_EVENT_CNT_REG	,PI=>PI,PO=>PO, A => x"0028", RO => x"FFFFFFFF");
			rw_reg(		REG => TRIG_FIFO_REG			,PI=>PI,PO=>PO, A => x"002C", RW => x"000000FF", I => x"00000002");			
			ro_reg(		REG => SRAM_DIN_REG			,PI=>PI,PO=>PO, A => x"0030", RO => x"0003FFFF");
			wo_reg(		REG => SRAM_DOUT_REG			,PI=>PI,PO=>PO, A => x"0034", WO => x"0003FFFF");
			rw_reg(		REG => SRAM_CTRL_REG			,PI=>PI,PO=>PO, A => x"0038", RW => x"C00FFFFF", R => x"C0000000");
		end if;
	end process;

end Synthesis;
