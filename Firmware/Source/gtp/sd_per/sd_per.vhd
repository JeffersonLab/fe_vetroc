library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity sd_per is
	generic(
		ADDR_INFO		: PER_ADDR_INFO
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		CLK				: in std_logic;
		SYSCLK_50		: in std_logic;

		SYNC				: out std_logic;
		TRIG				: out std_logic;
		BUSY				: in std_logic;

		TRIG_BIT_OUT	: in std_logic_vector(31 downto 0);

		SCALER_LATCH	: out std_logic;

		-- SSP I/O ports (muxed)
		FP_OUT			: out std_logic_vector(3 downto 0);
		FP_IN				: in std_logic_vector(3 downto 0);

		-- SSP I/O ports (fixed)
		SD_SYNC			: in std_logic;
		SD_TRIG			: in std_logic_vector(2 downto 1);
		TI_BUSY			: out std_logic;
		PP_BUSY			: out std_logic_vector(16 downto 1);
		PP_LINKUP		: out std_logic_vector(16 downto 1);
		BUSY_DIR			: out std_logic;
		LINKUP_DIR		: out std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_RESET		: in std_logic;
		BUS_RESET_SOFT	: in std_logic;
		BUS_DIN			: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT			: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR			: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR			: in std_logic;
		BUS_RD			: in std_logic;
		BUS_ACK			: out std_logic
	);
end sd_per;

architecture Synthesis of sd_per is
	component sd_iobuf is
		port(
			CLK					: in std_logic;

			BUSY					: in std_logic;
		
			-- Sync Mux inputs
			TRIG1_SYNC			: out std_logic;
			TRIG2_SYNC			: out std_logic;
			SYNC_SYNC			: out std_logic;
			FP_IN_SYNC			: out std_logic_vector(3 downto 0);
			
			-- Async Mux inputs
			TRIG1_ASYNC			: out std_logic;
			TRIG2_ASYNC			: out std_logic;
			SYNC_ASYNC			: out std_logic;
			FP_IN_ASYNC			: out std_logic_vector(3 downto 0);

			-- Mux outputs
			FP_OUT_MUX			: in std_logic_vector(3 downto 0);

			-- SD Input Pins
			FP_IN					: in std_logic_vector(3 downto 0);
			SD_SYNC				: in std_logic;
			SD_TRIG1				: in std_logic;
			SD_TRIG2				: in std_logic;

			-- SD Output Pins		
			TI_BUSY				: out std_logic;
			FP_OUT				: out std_logic_vector(3 downto 0)
		);
	end component;

	component sd_mux is
		port(
			CLK					: in std_logic;

			TRIG1_SYNC			: in std_logic;
			TRIG2_SYNC			: in std_logic;
			SYNC_SYNC			: in std_logic;
			FP_IN_SYNC			: in std_logic_vector(3 downto 0);

			PULSER_OUTPUT		: in std_logic;
			FP_IN_ASYNC			: in std_logic_vector(3 downto 0);
			SYNC_ASYNC			: in std_logic;
			TRIG1_ASYNC			: in std_logic;
			TRIG2_ASYNC			: in std_logic;
			BUSY					: in std_logic;
			TRIG_IN				: in std_logic_vector(31 downto 0);
			
			FP_OUT_MUX			: out std_logic_vector(3 downto 0);

			SYNC					: out std_logic;
			TRIG					: out std_logic;
			
			FP_OUT_SRC			: in slv6a(3 downto 0);
			TRIG_SRC				: in std_logic_vector(5 downto 0);
			SYNC_SRC				: in std_logic_vector(5 downto 0)
		);
	end component;

	component sd_scalers is
		port(
			SYSCLK_50			: in std_logic;
			CLK					: in std_logic;

			-- Input signal scalers
			BUSY					: in std_logic;
			TRIG1_SYNC			: in std_logic;
			TRIG2_SYNC			: in std_logic;
			SYNC_SYNC			: in std_logic;
			FP_IN_SYNC			: in std_logic_vector(3 downto 0);
			
			-- Output signal scalers
			FP_OUT_MUX			: in std_logic_vector(3 downto 0);

			-- Scaler control
			SCALER_LATCH		: in std_logic;

			-- Scaler registers
			SCALER_SYSCLK_50	: out std_logic_vector(31 downto 0);
			SCALER_CLK			: out std_logic_vector(31 downto 0);
			SCALER_SYNC			: out std_logic_vector(31 downto 0);
			SCALER_TRIG1		: out std_logic_vector(31 downto 0);
			SCALER_TRIG2		: out std_logic_vector(31 downto 0);
			SCALER_FP_IN		: out slv32a(3 downto 0);
			SCALER_FP_OUT		: out slv32a(3 downto 0);
			SCALER_BUSY			: out std_logic_vector(31 downto 0);
			SCALER_BUSYCYCLES	: out std_logic_vector(31 downto 0)
		);
	end component;

	signal PI							: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO							: pbus_if_o := (x"00000000", '0');

	signal SCALER_LATCH_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_PERIOD_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_LOW_CYCLES_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_NCYCLES_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_STATUS_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_START_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal TRIG_SRC_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal SYNC_SRC_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal FP_OUT_SRC_REG			: slv32a(3 downto 0) := (others=>x"00000000");

	signal TRIG1_SYNC				: std_logic;
	signal TRIG2_SYNC				: std_logic;
	signal SYNC_SYNC				: std_logic;
	signal FP_IN_SYNC				: std_logic_vector(3 downto 0);

	signal TRIG1_ASYNC			: std_logic;
	signal TRIG2_ASYNC			: std_logic;
	signal SYNC_ASYNC				: std_logic;
	signal FP_IN_ASYNC			: std_logic_vector(3 downto 0);
	
	signal FP_OUT_MUX				: std_logic_vector(3 downto 0);

	signal SCALER_LATCH_i		: std_logic;

	signal SCALER_SYSCLK_50		: std_logic_vector(31 downto 0);
	signal SCALER_CLK				: std_logic_vector(31 downto 0);
	signal SCALER_SYNC			: std_logic_vector(31 downto 0);
	signal SCALER_TRIG1			: std_logic_vector(31 downto 0);
	signal SCALER_TRIG2			: std_logic_vector(31 downto 0);
	signal SCALER_FP_IN			: slv32a(3 downto 0);
	signal SCALER_FP_OUT			: slv32a(3 downto 0);
	signal SCALER_BUSY			: std_logic_vector(31 downto 0);
	signal SCALER_BUSYCYCLES	: std_logic_vector(31 downto 0);

	signal FP_OUT_SRC				: slv6a(3 downto 0);
	signal TRIG_SRC				: std_logic_vector(5 downto 0);
	signal SYNC_SRC				: std_logic_vector(5 downto 0);

	signal PULSER_PERIOD			: std_logic_vector(31 downto 0);
	signal PULSER_LOW_CYCLES	: std_logic_vector(31 downto 0);
	signal PULSER_NCYCLES		: std_logic_vector(31 downto 0);
	signal PULSER_START			: std_logic;
	signal PULSER_DONE			: std_logic;
	signal PULSER_OUTPUT			: std_logic;
begin

	PP_BUSY <= (others=>'0');
	PP_LINKUP <= (others=>'0');
	BUSY_DIR <= '0';
	LINKUP_DIR <= '0';

	SCALER_LATCH <= SCALER_LATCH_i;

	sd_iobuf_inst: sd_iobuf
		port map(
			CLK					=> CLK,
			BUSY					=> BUSY,
			TRIG1_SYNC			=> TRIG1_SYNC,
			TRIG2_SYNC			=> TRIG2_SYNC,
			SYNC_SYNC			=> SYNC_SYNC,
			FP_IN_SYNC			=> FP_IN_SYNC,
			TRIG1_ASYNC			=> TRIG1_ASYNC,
			TRIG2_ASYNC			=> TRIG2_ASYNC,
			SYNC_ASYNC			=> SYNC_ASYNC,
			FP_IN_ASYNC			=> FP_IN_ASYNC,
			FP_OUT_MUX			=> FP_OUT_MUX,
			FP_IN					=> FP_IN,
			SD_SYNC				=> SD_SYNC,
			SD_TRIG1				=> SD_TRIG(1),
			SD_TRIG2				=> SD_TRIG(2),
			TI_BUSY				=> TI_BUSY,
			FP_OUT				=> FP_OUT
		);

	sd_scalers_inst: sd_scalers
		port map(
			SYSCLK_50			=> SYSCLK_50,
			CLK					=> CLK,
			BUSY					=> BUSY,
			TRIG1_SYNC			=> TRIG1_SYNC,
			TRIG2_SYNC			=> TRIG2_SYNC,
			SYNC_SYNC			=> SYNC_SYNC,
			FP_IN_SYNC			=> FP_IN_SYNC,
			FP_OUT_MUX			=> FP_OUT_MUX,
			SCALER_LATCH		=> SCALER_LATCH_i,
			SCALER_SYSCLK_50	=> SCALER_SYSCLK_50,
			SCALER_CLK			=> SCALER_CLK,
			SCALER_SYNC			=> SCALER_SYNC,
			SCALER_TRIG1		=> SCALER_TRIG1,
			SCALER_TRIG2		=> SCALER_TRIG2,
			SCALER_FP_IN		=> SCALER_FP_IN,
			SCALER_FP_OUT		=> SCALER_FP_OUT,
			SCALER_BUSY			=> SCALER_BUSY,
			SCALER_BUSYCYCLES	=> SCALER_BUSYCYCLES
		);

	sd_mux_inst: sd_mux
		port map(
			CLK				=> CLK,
			TRIG1_SYNC		=> TRIG1_SYNC,
			TRIG2_SYNC		=> TRIG2_SYNC,
			SYNC_SYNC		=> SYNC_SYNC,
			FP_IN_SYNC		=> FP_IN_SYNC,
			PULSER_OUTPUT	=> PULSER_OUTPUT,
			FP_IN_ASYNC		=> FP_IN_ASYNC,
			SYNC_ASYNC		=> SYNC_ASYNC,
			TRIG1_ASYNC		=> TRIG1_ASYNC,
			TRIG2_ASYNC		=> TRIG2_ASYNC,
			BUSY				=> BUSY,
			TRIG_IN			=> TRIG_BIT_OUT,
			FP_OUT_MUX		=> FP_OUT_MUX,
			SYNC				=> SYNC,
			TRIG				=> TRIG,
			FP_OUT_SRC		=> FP_OUT_SRC,
			TRIG_SRC			=> TRIG_SRC,
			SYNC_SRC			=> SYNC_SRC
		);

	Pulser_inst: Pulser
		port map(
			CLK			=> CLK,
			PERIOD		=> PULSER_PERIOD,
			LOW_CYCLES	=> PULSER_LOW_CYCLES,
			NPULSES		=> PULSER_NCYCLES,
			START			=> PULSER_START,
			DONE			=> PULSER_DONE,
			OUTPUT		=> PULSER_OUTPUT
		);

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
			PER_CLK			=> CLK,
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

	-- Registers
	process(CLK)
	begin
		if rising_edge(CLK) then
			PO.ACK <= '0';

			rw_reg(		REG => SCALER_LATCH_REG			,PI=>PI,PO=>PO, A => x"0000", RW => x"00000001");

			ro_reg(		REG => SCALER_SYSCLK_50			,PI=>PI,PO=>PO, A => x"0004", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_CLK					,PI=>PI,PO=>PO, A => x"0008", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_SYNC				,PI=>PI,PO=>PO, A => x"000C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TRIG1				,PI=>PI,PO=>PO, A => x"0010", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TRIG2				,PI=>PI,PO=>PO, A => x"0014", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_BUSY				,PI=>PI,PO=>PO, A => x"0018", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_BUSYCYCLES		,PI=>PI,PO=>PO, A => x"001C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_IN(0)			,PI=>PI,PO=>PO, A => x"0020", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_IN(1)			,PI=>PI,PO=>PO, A => x"0024", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_IN(2)			,PI=>PI,PO=>PO, A => x"0028", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_IN(3)			,PI=>PI,PO=>PO, A => x"002C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_OUT(0)			,PI=>PI,PO=>PO, A => x"0030", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_OUT(1)			,PI=>PI,PO=>PO, A => x"0034", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_OUT(2)			,PI=>PI,PO=>PO, A => x"0038", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FP_OUT(3)			,PI=>PI,PO=>PO, A => x"003C", RO => x"FFFFFFFF");

			rw_reg(		REG => PULSER_PERIOD_REG		,PI=>PI,PO=>PO, A => x"0100", RW => x"FFFFFFFF");
			rw_reg(		REG => PULSER_LOW_CYCLES_REG	,PI=>PI,PO=>PO, A => x"0104", RW => x"FFFFFFFF");
			rw_reg(		REG => PULSER_NCYCLES_REG		,PI=>PI,PO=>PO, A => x"0108", RW => x"FFFFFFFF");
			ro_reg(		REG => PULSER_STATUS_REG		,PI=>PI,PO=>PO, A => x"010C", RO => x"00000001");
			rw_reg_ack(	REG => PULSER_START_REG			,PI=>PI,PO=>PO, A => x"0110", ACK => PULSER_START);

			rw_reg(		REG => TRIG_SRC_REG				,PI=>PI,PO=>PO, A => x"0120", RW => x"0000003F");
			rw_reg(		REG => SYNC_SRC_REG				,PI=>PI,PO=>PO, A => x"0124", RW => x"0000003F");

			rw_reg(		REG => FP_OUT_SRC_REG(0)		,PI=>PI,PO=>PO, A => x"0128", RW => x"0000003F");
			rw_reg(		REG => FP_OUT_SRC_REG(1)		,PI=>PI,PO=>PO, A => x"012C", RW => x"0000003F");
			rw_reg(		REG => FP_OUT_SRC_REG(2)		,PI=>PI,PO=>PO, A => x"0130", RW => x"0000003F");
			rw_reg(		REG => FP_OUT_SRC_REG(3)		,PI=>PI,PO=>PO, A => x"0134", RW => x"0000003F");
		end if;
	end process;

	SCALER_LATCH_i <= SCALER_LATCH_REG(0);

	PULSER_PERIOD <= PULSER_PERIOD_REG;
	PULSER_LOW_CYCLES <= PULSER_LOW_CYCLES_REG;
	PULSER_NCYCLES <= PULSER_NCYCLES_REG;
	PULSER_STATUS_REG <= x"0000000" & "000" & PULSER_DONE;

	TRIG_SRC <= TRIG_SRC_REG(5 downto 0);

	SYNC_SRC <= SYNC_SRC_REG(5 downto 0);

	FP_OUT_SRC(0) <= FP_OUT_SRC_REG(0)(5 downto 0);
	FP_OUT_SRC(1) <= FP_OUT_SRC_REG(1)(5 downto 0);
	FP_OUT_SRC(2) <= FP_OUT_SRC_REG(2)(5 downto 0);
	FP_OUT_SRC(3) <= FP_OUT_SRC_REG(3)(5 downto 0);

end Synthesis;
