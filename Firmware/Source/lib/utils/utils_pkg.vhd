library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

package utils_pkg is

	type inta is array(integer range <>) of integer;

	type slv2d is array(integer range <>, integer range <>) of std_logic;

	type slv2a is array(integer range <>) of std_logic_vector(1 downto 0);
	type slv3a is array(integer range <>) of std_logic_vector(2 downto 0);
	type slv4a is array(integer range <>) of std_logic_vector(3 downto 0);
	type slv5a is array(integer range <>) of std_logic_vector(4 downto 0);
	type slv6a is array(integer range <>) of std_logic_vector(5 downto 0);
	type slv7a is array(integer range <>) of std_logic_vector(6 downto 0);
	type slv9a is array(integer range <>) of std_logic_vector(8 downto 0);
	type slv10a is array(integer range <>) of std_logic_vector(9 downto 0);
	type slv11a is array(integer range <>) of std_logic_vector(10 downto 0);
	type slv12a is array(integer range <>) of std_logic_vector(11 downto 0);
	type slv13a is array(integer range <>) of std_logic_vector(12 downto 0);
	type slv14a is array(integer range <>) of std_logic_vector(13 downto 0);
	type slv16a is array(integer range <>) of std_logic_vector(15 downto 0);
	type slv21a is array(integer range <>) of std_logic_vector(20 downto 0);
	type slv22a is array(integer range <>) of std_logic_vector(21 downto 0);
	type slv23a is array(integer range <>) of std_logic_vector(22 downto 0);
	type slv25a is array(integer range <>) of std_logic_vector(24 downto 0);
	type slv32a is array(integer range <>) of std_logic_vector(31 downto 0);
	type slv33a is array(integer range <>) of std_logic_vector(32 downto 0);
	type slv36a is array(integer range <>) of std_logic_vector(35 downto 0);
	type slv45a is array(integer range <>) of std_logic_vector(44 downto 0);
	type slv64a is array(integer range <>) of std_logic_vector(63 downto 0);
	type slv68a is array(integer range <>) of std_logic_vector(67 downto 0);
	type slv96a is array(integer range <>) of std_logic_vector(95 downto 0);
	type slv128a is array(integer range <>) of std_logic_vector(127 downto 0);

	type slvr2a is array(natural range <>) of std_logic_vector(0 to 1);
	type slvr4a is array(natural range <>) of std_logic_vector(0 to 3);

	component xDataRxBuf is
		generic(
			DELAY				: integer := 0;
			SIGNAL_PATTERN	: string := "CLOCK";
			USE_REG			: boolean := false;
			IS_CLK			: boolean := false
		);
		port(
			CLK				: in std_logic;
			
			-- Differential Inputs
			DATA_P			: in std_logic;
			DATA_N			: in std_logic;

			-- Output
			DATA				: out std_logic
		);
	end component;

	component sum_mon is
		port(
			CLK					: in std_logic;

			SUM_MON_THR			: in std_logic_vector(31 downto 0);
			SUM_MON_NSA			: in std_logic_vector(7 downto 0);
			SUM_MON_NSB			: in std_logic_vector(7 downto 0);

			SUM					: in std_logic_vector(31 downto 0);
			SUM_VALID			: in std_logic;

			SUM_HIST_ENABLE	: in std_logic;
			SUM_HIST_DATA		: out std_logic_vector(31 downto 0);
			SUM_HIST_RD			: in std_logic
		);
	end component;

	component pipeline_reg is
		generic(
			WIDTH			: integer := 8;
			DELAY			: integer := 1
		);
		port(
			CLK		: in std_logic;
			ENABLE	: in std_logic;

			REG_IN	: in std_logic_vector(WIDTH-1 downto 0);
			REG_OUT	: out std_logic_vector(WIDTH-1 downto 0)
		);
	end component;
	
	component delay_ram is
		generic(
			D_WIDTH		: integer := 32;
			A_WIDTH		: integer := 10
		);
		port(
			CLK		: in std_logic;
			DELAY		: in std_logic_vector(A_WIDTH-1 downto 0);
			DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
			DOUT		: out std_logic_vector(D_WIDTH-1 downto 0)
		);
	end component;

	component PulseStretcher is
		generic(
			LEN			: integer := 8;
			UPDATING		: boolean := false;
			EDGE_DET		: boolean := false
		);
		port(
			CLK			: in std_logic;
			
			PULSE_IN		: in std_logic;
			PULSE_OUT	: out std_logic;
			PULSE_WIDTH	: in std_logic_vector(LEN-1 downto 0)
		);
	end component;

	component counter is
		generic(
			LEN	: integer := 32
		);
		port(
			CLK	: in std_logic;
			RST	: in std_logic;
			EN		: in std_logic;
			INC	: in std_logic;
			CNT	: out std_logic_vector(LEN-1 downto 0)
		);
	end component;

	component Pulser is
		port(
			CLK			: in std_logic;
			
			PERIOD		: in std_logic_vector(31 downto 0);
			LOW_CYCLES	: in std_logic_vector(31 downto 0);
			
			NPULSES		: in std_logic_vector(31 downto 0);
			START			: in std_logic;
			DONE			: out std_logic;
			
			OUTPUT		: out std_logic
		);
	end component;

	component Scaler is
		generic(
			LEN		: integer := 32;
			EDGE_DET	: boolean := true;
			BUFFERED	: boolean := true
		);
		port(
			CLK		: in std_logic;
			GATE		: in std_logic;
			LATCH		: in std_logic;
			RESET		: in std_logic;
			INPUT		: in std_logic;
			SCALER	: out std_logic_vector(LEN-1 downto 0)
		);
	end component;

	component ibufds_path is
		generic(
			DIFF_INVERT	: boolean := false;
			SYNC_STAGES	: integer := 2
		);
		port(
			CLK			: in std_logic;
			IN_P			: in std_logic;
			IN_N			: in std_logic;
			OUT_ASYNC	: out std_logic;
			OUT_SYNC		: out std_logic
		);
	end component;

	component ibuf_path is
		generic(
			SYNC_STAGES	: integer := 2;
			INVERT		: boolean := false
		);
		port(
			CLK			: in std_logic;
			I				: in std_logic;
			OUT_ASYNC	: out std_logic;
			OUT_SYNC		: out std_logic
		);
	end component;

	component obufds_path is
		generic(
			DIFF_INVERT	: boolean := false
		);
		port(
			I		: in std_logic;
			O_P	: out std_logic;
			O_N	: out std_logic
		);
	end component;

	component LEDPulser is
		generic(
			LEN			: integer := 16;
			INVERT		: boolean := false;
			MIN_OFF_EN	: boolean := false;
			CONTINUOUS	: boolean := false
		);
		port(
			CLK			: in std_logic;
			INPUT			: in std_logic;
			OUTPUT		: out std_logic
		);
	end component;

	component log32b_10b is
		port(
			CLK			: in std_logic;
			
			VAL_IN_EN	: in std_logic;
			VAL_IN		: in std_logic_vector(31 downto 0);
			VAL_OUT_EN	: out std_logic;
			VAL_OUT		: out std_logic_vector(9 downto 0)
		);
	end component;

	component mp_ram_2w1r is
		generic(
			D_WIDTH		: integer := 1;
			A_WIDTH		: integer := 10;
			DOUT_REG		: boolean := false;
			WR0_REG		: boolean := false;
			WR1_REG		: boolean := false
		);
		port(
			WR0_CLK	: in std_logic;
			WR0		: in std_logic;
			WR_ADDR0	: in std_logic_vector(A_WIDTH-1 downto 0);
			DIN0		: in std_logic_vector(D_WIDTH-1 downto 0);

			WR1_CLK	: in std_logic;
			WR1		: in std_logic;
			WR_ADDR1	: in std_logic_vector(A_WIDTH-1 downto 0);
			DIN1		: in std_logic_vector(D_WIDTH-1 downto 0);

			RD_CLK	: in std_logic;
			RD			: in std_logic;
			RD_ADDR	: in std_logic_vector(A_WIDTH-1 downto 0);
			DOUT		: out std_logic_vector(D_WIDTH-1 downto 0)
		);
	end component;

	component sdp_ram is
		generic(
			D_WIDTH		: integer := 32;
			A_WIDTH		: integer := 10;
			DOUT_REG		: boolean := false
		);
		port(
			WR_CLK	: in std_logic;
			WR			: in std_logic;
			WR_ADDR	: in std_logic_vector(A_WIDTH-1 downto 0);
			DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
			
			RD_CLK	: in std_logic;
			RD			: in std_logic;
			RD_ADDR	: in std_logic_vector(A_WIDTH-1 downto 0);
			DOUT		: out std_logic_vector(D_WIDTH-1 downto 0)
		);
	end component;

	component tdp_ram is
		generic(
			D_WIDTH		: integer := 32;
			A_WIDTH		: integer := 10;
			DOUTA_REG	: boolean := false;
			DOUTB_REG	: boolean := false
		);
		port(
			CLKA		: in std_logic;
			WRA		: in std_logic;
			RDA		: in std_logic;
			ADDRA		: in std_logic_vector(A_WIDTH-1 downto 0);
			DINA		: in std_logic_vector(D_WIDTH-1 downto 0);
			DOUTA		: out std_logic_vector(D_WIDTH-1 downto 0);
			
			CLKB		: in std_logic;
			WRB		: in std_logic;
			RDB		: in std_logic;
			ADDRB		: in std_logic_vector(A_WIDTH-1 downto 0);
			DINB		: in std_logic_vector(D_WIDTH-1 downto 0);
			DOUTB		: out std_logic_vector(D_WIDTH-1 downto 0)
		);
	end component;

	component ucrc_par is
		generic(
			POLYNOMIAL : std_logic_vector;
			INIT_VALUE : std_logic_vector;
			DATA_WIDTH : integer range 2 to 256;
			SYNC_RESET : integer range 0 to 1
		);  -- use sync./async reset
		port(
			clk_i   : in  std_logic;          -- clock
			rst_i   : in  std_logic;          -- init CRC
			clken_i : in  std_logic;          -- clock enable
			data_i  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- data input
			match_o : out std_logic;          -- CRC match flag
			crc_o   : out std_logic_vector(POLYNOMIAL'length - 1 downto 0)
		);  -- CRC output
	end component;

	component serdeslanecrc_rx is
		port(
			CLK					: in std_logic;
			CRC_RST				: in std_logic;
			RX_D_I				: in std_logic_vector(15 downto 0);
			RX_D_SRC_RDY_N_I	: in std_logic;
			
			RX_D_O				: out std_logic_vector(15 downto 0);
			RX_D_SRC_RDY_N_O	: out std_logic;
			CRC_PASS				: out std_logic
		);
	end component;

	component serdeslanecrc_tx is
		port(
			CLK					: in std_logic;
			TX_D_I				: in std_logic_vector(15 downto 0);
			TX_SRC_RDY_N_I		: in std_logic;
			
			TX_D_O				: out std_logic_vector(15 downto 0);
			TX_SRC_RDY_N_O		: out std_logic
		);
	end component;

	component SpiInterface is
		port(
			CLK			: in std_logic;
			
			WR_DATA		: in std_logic_vector(7 downto 0);
			RD_DATA		: out std_logic_vector(7 downto 0);
			NCS_SET		: in std_logic;
			NCS_CLEAR	: in std_logic;
			START			: in std_logic;
			DONE			: out std_logic;
			
			SPI_CLK		: out std_logic;
			SPI_MISO		: in std_logic;
			SPI_MOSI		: out std_logic;
			SPI_NCS		: out std_logic
		);
	end component;

	component hist is
		generic(
			BIN_DEPTH		: integer := 32;
			BIN_WIDTH		: integer := 10
		);
		port(
			CLK				: in std_logic;
			
			ENABLE			: in std_logic;
			BIN_DATA			: out std_logic_vector(BIN_DEPTH-1 downto 0);
			BIN_RD			: in std_logic;

			GATE				: in std_logic;
			BIN				: in std_logic_vector(BIN_WIDTH-1 downto 0)
		);
	end component;

	component integrator is
		generic(
			D_WIDTH		: integer := 32;
			P_WIDTH		: integer := 16
		);
		port(
			CLK		: in std_logic;
			WIDTH		: in std_logic_vector(P_WIDTH-1 downto 0);
			DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
			DIN_RDY	: in std_logic;
			DOUT		: out std_logic_vector(D_WIDTH+P_WIDTH-1 downto 0);
			DOUT_RDY	: out std_logic
		);
	end component;

	component pipelinedelay is
		generic(
			LEN		: integer := 0
		);
		port(
			CLK		: in std_logic;
			SIN		: in std_logic;
			SOUT		: out std_logic
		);
	end component;

	component fixedlatencybit is
		port(
				CLK			: in std_logic;
				SYNC			: in std_logic;
				
				LATENCY		: in std_logic_vector(11 downto 0);

				BIT_IN_EN	: in std_logic;
				BIT_IN		: in std_logic;

				BIT_OUT		: out std_logic;
				BIT_OUT_ERR	: out std_logic
		);
	end component;

	component indexer is
		generic(
			-- Max number of elements buffer can hold=2**A_WIDTH_BUF
			A_WIDTH_BUF		: integer := 9;
			-- Time variable width. Maximum run time=2**T_WIDTH*4ns before rollover
			D_WIDTH			: integer := 16;
			T_WIDTH			: integer := 16;
			N_WIDTH			: integer := 6
		);
		port(
			-- WR_CLK domain
			WR_CLK			: in std_logic;
			WR_CLK_2X		: in std_logic;
			WR					: in std_logic;
			DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
			TIN				: in std_logic_Vector(T_WIDTH-1 downto 0);
			-- Note: RESET must be asserted before using to ensure erase pointer is set in proper position
			RESET				: in std_logic;
			
			-- RD_CLK domain
			RD_CLK			: in std_logic;

			RD_ADDR			: in std_logic_vector(A_WIDTH_BUF-1 downto 0);
			DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
			TOUT				: out std_logic_vector(T_WIDTH-1 downto 0);

			RD_ADDR_IDX		: in std_logic_vector(T_WIDTH-1 downto 0);
			ADDR_IDX			: out std_logic_vector(A_WIDTH_BUF-1 downto 0);
			LEN_IDX			: out std_logic_vector(N_WIDTH-1 downto 0);
			VALID_IDX		: out std_logic
		);
	end component;

	component scfifo_std is
		generic(
			D_WIDTH	: integer := 32;
			A_WIDTH		: integer := 10;
			RD_PROTECT	: boolean := true;
			WR_PROTECT	: boolean := true
		);
		port(
			CLK		: in std_logic;
			RST		: in std_logic;

			DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
			WR			: in std_logic;
			FULL		: out std_logic;

			DOUT		: out std_logic_vector(D_WIDTH-1 downto 0);
			RD			: in std_logic;
			EMPTY		: out std_logic
		);
	end component;

	component scfifo_generic is
		generic(
			D_WIDTH	: integer := 32;
			A_WIDTH	: integer := 10;
			DOUT_REG	: boolean := false;
			FWFT			: boolean := false;
			RD_PROTECT	: boolean := true;
			WR_PROTECT	: boolean := true
		);
		port(
			CLK		: in std_logic;
			RST		: in std_logic;

			DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
			WR			: in std_logic;
			FULL		: out std_logic;

			DOUT		: out std_logic_vector(D_WIDTH-1 downto 0);
			RD			: in std_logic;
			EMPTY		: out std_logic
		);
	end component;

	function slv_sat(v : std_logic_vector; len : integer) return std_logic_vector;
	function slv_ones(len : integer) return std_logic_vector;
	function slv_zeros(len : integer) return std_logic_vector;

end utils_pkg;

package body utils_pkg is

	function slv_sat(v : std_logic_vector; len : integer) return std_logic_vector is
		variable result		: std_logic_vector(len-1 downto 0);
	begin
		if v'length = len then
			result := v;
		end if;

		if v'length > len then
			if v(v'length-1 downto len) /= conv_std_logic_vector(0, v'length-len) then
				result := (others=>'1');
			else
				result := v(len-1 downto 0);
			end if;
		end if;

		if v'length < len then
			result(len-1 downto v'length) := (others=>'0');
			result(v'length-1 downto 0) := v;
		end if;

		return result;
	end function;

	function slv_ones(len : integer) return std_logic_vector is
		variable result	: std_logic_vector(len-1 downto 0) := (others=>'1');
	begin
		return result;
	end slv_ones;

	function slv_zeros(len : integer) return std_logic_vector is
		variable result	: std_logic_vector(len-1 downto 0) := (others=>'0');
	begin
		return result;
	end slv_zeros;

end utils_pkg;
