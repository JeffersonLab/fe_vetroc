library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

package eventbuilder_per_pkg is

	constant FIFO_TAG_BLKHDR				: std_logic_vector(3 downto 0) := "0100";
	constant FIFO_TAG_BLKTLR				: std_logic_vector(3 downto 0) := "1000";
	constant FIFO_TAG_EVTHDR				: std_logic_vector(3 downto 0) := "0001";
	constant FIFO_TAG_OTHER					: std_logic_vector(3 downto 0) := "0000";
	
	constant DATA_TYPE_BLKHDR				: std_logic_vector(3 downto 0) := "0000";
	constant DATA_TYPE_BLKTLR				: std_logic_vector(3 downto 0) := "0001";
	constant DATA_TYPE_EVTHDR				: std_logic_vector(3 downto 0) := "0010";
	constant DATA_TYPE_TRGTIME				: std_logic_vector(3 downto 0) := "0011";
	constant DATA_TYPE_CLUSTER				: std_logic_vector(3 downto 0) := "0100";
	constant DATA_TYPE_DNV					: std_logic_vector(3 downto 0) := "1110";
	constant DATA_TYPE_FILLER				: std_logic_vector(3 downto 0) := "1111";

	component eventbuilder_per is
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

			-- BUS_CLK domain signals
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
	end component;

	component gen_timestamp_index_finder is
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

	component gen_timestamp_data_eb is
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

			-- Fiber input from GTP
			EN						: in std_logic;
			T						: in std_logic_vector(9 downto 0);
			D						: in std_logic_vector(10 downto 0);

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

end eventbuilder_per_pkg;
