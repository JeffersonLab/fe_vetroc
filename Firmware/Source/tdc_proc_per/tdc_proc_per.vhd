library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;
use work.eventbuilder_per_pkg.all;

entity maroc_proc_per is
	generic(
		ADDR_INFO			: PER_ADDR_INFO;
		CHANNEL_START		: integer := 0
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		SCALER_LATCH		: in std_logic;
		SCALER_RESET		: in std_logic;

		GCLK_125				: in std_logic;
		GCLK_250				: in std_logic;
		GCLK_500				: in std_logic;
		GCLK_500_180		: in std_logic;

		SYNC					: in std_logic;

		-- MAROC3 Discriminator Outputs
		MAROC_OUT			: in std_logic_vector(63 downto 0);

		MAROC_OUT_OR		: out std_logic;

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
		EVT_FIFO_EMPTY		: out std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_RESET			: in std_logic;
		BUS_RESET_SOFT		: in std_logic;
		BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR				: in std_logic;
		BUS_RD				: in std_logic;
		BUS_ACK				: out std_logic
	);
end maroc_proc_per;

architecture synthesis of maroc_proc_per is
	component tdc_channel_group is
		generic(
			CHANNEL_START		: integer := 0;
			INVERTED				: boolean := true
		);
		port(
			SCALER_LATCH		: in std_logic;
			SCALER_RESET		: in std_logic;
			TDC_SCALER			: out slv32a(15 downto 0);
			ENABLE_N				: in std_logic_vector(15 downto 0);

			------------------------------
			-- GCLK domain signals
			------------------------------
			GCLK_125				: in std_logic;
			GCLK_250				: in std_logic;
			GCLK_500				: in std_logic;
			GCLK_500_180		: in std_logic;
			RESET_SOFT			: in std_logic;
			SYNC					: in std_logic;
			
			HIT					: in std_logic_vector(15 downto 0);

			HIT_ASYNC			: out std_logic_vector(15 downto 0);

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

	signal PI							: pbus_if_i;
	signal PO							: pbus_if_o;

	-- Registers
	signal ENABLE0_N_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal ENABLE1_N_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal ENABLE2_N_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal ENABLE3_N_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal HIT_OR_MASK0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal HIT_OR_MASK1_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal TDC_SCALER					: slv32a(63 downto 0) := (others=>x"00000000");

	-- Register bits
	signal ENABLE_N					: slv16a(3 downto 0);
	signal HIT_OR_MASK				: std_logic_vector(63 downto 0);

	signal HIT_ASYNC					: std_logic_vector(63 downto 0);
 	signal GRP_EVT_FIFO_DOUT		: slv33a(3 downto 0);
 	signal GRP_EVT_FIFO_EMPTY		: std_logic_vector(3 downto 0);
 	signal GRP_EVT_FIFO_RD			: std_logic_vector(3 downto 0);
	signal SYNC_ARRAY					: std_logic_vector(3 downto 0);
begin

	MAROC_OUT_OR <= or_reduce(HIT_ASYNC and HIT_OR_MASK);

	process(GCLK_125)
	begin
		if rising_edge(GCLK_125) then
			SYNC_ARRAY <= (others=>SYNC);
		end if;
	end process;

	tdc_channel_group_gen: for I in 0 to 3 generate
		tdc_channel_group_inst: tdc_channel_group
			generic map(
				CHANNEL_START		=> CHANNEL_START+16*I,
				INVERTED				=> false
			)
			port map(
				SCALER_LATCH		=> SCALER_LATCH,
				SCALER_RESET		=> SCALER_RESET,
				TDC_SCALER			=> TDC_SCALER(16*I+15 downto 16*I),
				ENABLE_N				=> ENABLE_N(I),
				GCLK_125				=> GCLK_125,
				GCLK_250				=> GCLK_250,
				GCLK_500				=> GCLK_500,
				GCLK_500_180		=> GCLK_500_180,
				RESET_SOFT			=> PI.RESET_SOFT,
				SYNC					=> SYNC_ARRAY(I),
				HIT					=> MAROC_OUT(16*I+15 downto 16*I),
				HIT_ASYNC			=> HIT_ASYNC(16*I+15 downto 16*I),
				BUS_CLK				=> BUS_CLK,
				TRIG_FIFO_WR		=> TRIG_FIFO_WR,
				TRIG_FIFO_START	=> TRIG_FIFO_START,
				TRIG_FIFO_STOP		=> TRIG_FIFO_STOP,
				EVT_FIFO_DOUT		=> GRP_EVT_FIFO_DOUT(I),
				EVT_FIFO_RD			=> GRP_EVT_FIFO_RD(I),
				EVT_FIFO_EMPTY		=> GRP_EVT_FIFO_EMPTY(I)
			);
	end generate;

	evtbuilderstage_inst: evtbuilderstage
		generic map(
			GRP_NUM			=> 4
		)
		port map(
			CLK_WR			=> BUS_CLK,
			CLK_RD			=> BUS_CLK,
			RESET				=> PI.RESET_SOFT,
			GRP_BLD_DATA	=> GRP_EVT_FIFO_DOUT,
			GRP_BLD_EMPTY	=> GRP_EVT_FIFO_EMPTY,
			GRP_BLD_READ	=> GRP_EVT_FIFO_RD,
			BLD_DATA			=> EVT_FIFO_DOUT,
			BLD_EMPTY		=> EVT_FIFO_EMPTY,
			BLD_READ			=> EVT_FIFO_RD
		);

	-----------------------------------
	-- Registers
	-----------------------------------	
	PerBusCtrl_inst: PerBusCtrl
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

	--ENABLE0_N_REG
	ENABLE_N(0) <= ENABLE0_N_REG(15 downto 0);

	--ENABLE1_N_REG
	ENABLE_N(1) <= ENABLE1_N_REG(15 downto 0);

	--ENABLE2_N_REG
	ENABLE_N(2) <= ENABLE2_N_REG(15 downto 0);

	--ENABLE3_N_REG
	ENABLE_N(3) <= ENABLE3_N_REG(15 downto 0);

	--HIT_OR_MASK0_REG
	HIT_OR_MASK(31 downto 0) <= HIT_OR_MASK0_REG;

	--HIT_OR_MASK1_REG
	HIT_OR_MASK(63 downto 32) <= HIT_OR_MASK1_REG;

	process(BUS_CLK)
		variable A		: std_logic_vector(15 downto 0);
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';

			rw_reg(		REG => ENABLE0_N_REG			,PI=>PI,PO=>PO, A => x"0000", RW => x"0000FFFF");
			rw_reg(		REG => ENABLE1_N_REG			,PI=>PI,PO=>PO, A => x"0004", RW => x"0000FFFF");
			rw_reg(		REG => ENABLE2_N_REG			,PI=>PI,PO=>PO, A => x"0008", RW => x"0000FFFF");
			rw_reg(		REG => ENABLE3_N_REG			,PI=>PI,PO=>PO, A => x"000C", RW => x"0000FFFF");

			rw_reg(		REG => HIT_OR_MASK0_REG		,PI=>PI,PO=>PO, A => x"0010", RW => x"FFFFFFFF");
			rw_reg(		REG => HIT_OR_MASK1_REG		,PI=>PI,PO=>PO, A => x"0014", RW => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(0)			,PI=>PI,PO=>PO, A => x"0100", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(1)			,PI=>PI,PO=>PO, A => x"0104", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(2)			,PI=>PI,PO=>PO, A => x"0108", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(3)			,PI=>PI,PO=>PO, A => x"010C", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(4)			,PI=>PI,PO=>PO, A => x"0110", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(5)			,PI=>PI,PO=>PO, A => x"0114", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(6)			,PI=>PI,PO=>PO, A => x"0118", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(7)			,PI=>PI,PO=>PO, A => x"011C", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(8)			,PI=>PI,PO=>PO, A => x"0120", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(9)			,PI=>PI,PO=>PO, A => x"0124", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(10)		,PI=>PI,PO=>PO, A => x"0128", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(11)		,PI=>PI,PO=>PO, A => x"012C", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(12)		,PI=>PI,PO=>PO, A => x"0130", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(13)		,PI=>PI,PO=>PO, A => x"0134", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(14)		,PI=>PI,PO=>PO, A => x"0138", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(15)		,PI=>PI,PO=>PO, A => x"013C", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(16)		,PI=>PI,PO=>PO, A => x"0140", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(17)		,PI=>PI,PO=>PO, A => x"0144", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(18)		,PI=>PI,PO=>PO, A => x"0148", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(19)		,PI=>PI,PO=>PO, A => x"014C", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(20)		,PI=>PI,PO=>PO, A => x"0150", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(21)		,PI=>PI,PO=>PO, A => x"0154", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(22)		,PI=>PI,PO=>PO, A => x"0158", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(23)		,PI=>PI,PO=>PO, A => x"015C", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(24)		,PI=>PI,PO=>PO, A => x"0160", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(25)		,PI=>PI,PO=>PO, A => x"0164", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(26)		,PI=>PI,PO=>PO, A => x"0168", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(27)		,PI=>PI,PO=>PO, A => x"016C", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(28)		,PI=>PI,PO=>PO, A => x"0170", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(29)		,PI=>PI,PO=>PO, A => x"0174", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(30)		,PI=>PI,PO=>PO, A => x"0178", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(31)		,PI=>PI,PO=>PO, A => x"017C", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(32)		,PI=>PI,PO=>PO, A => x"0180", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(33)		,PI=>PI,PO=>PO, A => x"0184", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(34)		,PI=>PI,PO=>PO, A => x"0188", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(35)		,PI=>PI,PO=>PO, A => x"018C", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(36)		,PI=>PI,PO=>PO, A => x"0190", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(37)		,PI=>PI,PO=>PO, A => x"0194", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(38)		,PI=>PI,PO=>PO, A => x"0198", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(39)		,PI=>PI,PO=>PO, A => x"019C", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(40)		,PI=>PI,PO=>PO, A => x"01A0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(41)		,PI=>PI,PO=>PO, A => x"01A4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(42)		,PI=>PI,PO=>PO, A => x"01A8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(43)		,PI=>PI,PO=>PO, A => x"01AC", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(44)		,PI=>PI,PO=>PO, A => x"01B0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(45)		,PI=>PI,PO=>PO, A => x"01B4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(46)		,PI=>PI,PO=>PO, A => x"01B8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(47)		,PI=>PI,PO=>PO, A => x"01BC", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(48)		,PI=>PI,PO=>PO, A => x"01C0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(49)		,PI=>PI,PO=>PO, A => x"01C4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(50)		,PI=>PI,PO=>PO, A => x"01C8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(51)		,PI=>PI,PO=>PO, A => x"01CC", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(52)		,PI=>PI,PO=>PO, A => x"01D0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(53)		,PI=>PI,PO=>PO, A => x"01D4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(54)		,PI=>PI,PO=>PO, A => x"01D8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(55)		,PI=>PI,PO=>PO, A => x"01DC", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(56)		,PI=>PI,PO=>PO, A => x"01E0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(57)		,PI=>PI,PO=>PO, A => x"01E4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(58)		,PI=>PI,PO=>PO, A => x"01E8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(59)		,PI=>PI,PO=>PO, A => x"01EC", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(60)		,PI=>PI,PO=>PO, A => x"01F0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(61)		,PI=>PI,PO=>PO, A => x"01F4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(62)		,PI=>PI,PO=>PO, A => x"01F8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(63)		,PI=>PI,PO=>PO, A => x"01FC", RO => x"FFFFFFFF");
		end if;
	end process;

end synthesis;
