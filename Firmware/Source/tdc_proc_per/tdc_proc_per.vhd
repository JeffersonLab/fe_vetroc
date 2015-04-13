library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;
use work.eventbuilder_per_pkg.all;

entity tdc_proc_per is
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

		SYNC					: in std_logic;

		-- TDC Inputs, Trigger Outputs
		HIT					: in std_logic_vector(15 downto 0);
		HIT_TRIG				: out std_logic_vector(15 downto 0);

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
end tdc_proc_per;

architecture synthesis of tdc_proc_per is
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
			HIT_TRIG_WIDTH		: in std_logic_vector(7 downto 0);

			------------------------------
			-- GCLK domain signals
			------------------------------
			GCLK_125				: in std_logic;
			GCLK_250				: in std_logic;
			GCLK_500				: in std_logic;
			RESET_SOFT			: in std_logic;
			SYNC					: in std_logic;
			
			HIT					: in std_logic_vector(15 downto 0);
			HIT_TRIG				: out std_logic_vector(15 downto 0);
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
	signal ENABLE_N_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal HIT_TRIG_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal TDC_SCALER					: slv32a(15 downto 0) := (others=>x"00000000");

	-- Register bits
	signal ENABLE_N					: std_logic_vector(15 downto 0);
	signal HIT_TRIG_WIDTH			: std_logic_vector(7 downto 0);
begin

	tdc_channel_group_inst: tdc_channel_group
		generic map(
			CHANNEL_START		=> CHANNEL_START,
			INVERTED				=> false
		)
		port map(
			SCALER_LATCH		=> SCALER_LATCH,
			SCALER_RESET		=> SCALER_RESET,
			TDC_SCALER			=> TDC_SCALER,
			ENABLE_N				=> ENABLE_N,
			HIT_TRIG_WIDTH		=> HIT_TRIG_WIDTH,
			GCLK_125				=> GCLK_125,
			GCLK_250				=> GCLK_250,
			GCLK_500				=> GCLK_500,
			RESET_SOFT			=> PI.RESET_SOFT,
			SYNC					=> SYNC,
			HIT					=> HIT,
			HIT_TRIG				=> HIT_TRIG,
			HIT_ASYNC			=> open,
			BUS_CLK				=> BUS_CLK,
			TRIG_FIFO_WR		=> TRIG_FIFO_WR,
			TRIG_FIFO_START	=> TRIG_FIFO_START,
			TRIG_FIFO_STOP		=> TRIG_FIFO_STOP,
			EVT_FIFO_DOUT		=> EVT_FIFO_DOUT,
			EVT_FIFO_RD			=> EVT_FIFO_RD,
			EVT_FIFO_EMPTY		=> EVT_FIFO_EMPTY
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

	--ENABLE_N_REG
	ENABLE_N <= ENABLE_N_REG(15 downto 0);
	
	--HIT_TRIG_REG
	HIT_TRIG_WIDTH <= HIT_TRIG_REG(7 downto 0);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';

			rw_reg(		REG => ENABLE_N_REG			,PI=>PI,PO=>PO, A => x"0000", RW => x"0000FFFF");
			rw_reg(		REG => HIT_TRIG_REG			,PI=>PI,PO=>PO, A => x"0004", RW => x"000000FF");

			ro_reg(		REG => TDC_SCALER(0)			,PI=>PI,PO=>PO, A => x"0080", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(1)			,PI=>PI,PO=>PO, A => x"0084", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(2)			,PI=>PI,PO=>PO, A => x"0088", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(3)			,PI=>PI,PO=>PO, A => x"008C", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(4)			,PI=>PI,PO=>PO, A => x"0090", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(5)			,PI=>PI,PO=>PO, A => x"0094", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(6)			,PI=>PI,PO=>PO, A => x"0098", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(7)			,PI=>PI,PO=>PO, A => x"009C", RO => x"FFFFFFFF");

			ro_reg(		REG => TDC_SCALER(8)			,PI=>PI,PO=>PO, A => x"00A0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(9)			,PI=>PI,PO=>PO, A => x"00A4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(10)		,PI=>PI,PO=>PO, A => x"00A8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(11)		,PI=>PI,PO=>PO, A => x"00AC", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(12)		,PI=>PI,PO=>PO, A => x"00B0", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(13)		,PI=>PI,PO=>PO, A => x"00B4", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(14)		,PI=>PI,PO=>PO, A => x"00B8", RO => x"FFFFFFFF");
			ro_reg(		REG => TDC_SCALER(15)		,PI=>PI,PO=>PO, A => x"00BC", RO => x"FFFFFFFF");
		end if;
	end process;

end synthesis;
