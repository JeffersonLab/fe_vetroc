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
		CLK					: in std_logic;

		SYNC					: out std_logic;
		TRIG					: out std_logic;
		BUSY					: in std_logic;
		TOKENIN				: out std_logic;
		TOKENOUT				: in std_logic;

		SCALER_LATCH		: out std_logic;
		SCALER_RESET		: out std_logic;
	
		-- I/O ports (fixed)
		FPGAIN				: in std_logic_vector(8 downto 1);
		TOKENFI				: in std_logic;
		SYNCFI				: in std_logic;
		TRIG1F				: in std_logic;
		TRIG2F				: in std_logic;
		STATA_IN				: in std_logic;
		STATB_IN				: in std_logic;

		FPGAOUT				: out std_logic_vector(8 downto 1);
		TOKENFO				: out std_logic;
		TRIGFO				: out std_logic;
		SDLINKF				: out std_logic;
		STATA_OUT			: out std_logic;
		BUSY_OUT				: out std_logic;
		
		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_CLK				: in std_logic;
		BUS_RESET			: in std_logic;
		BUS_RESET_SOFT		: in std_logic;
		BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR				: in std_logic;
		BUS_RD				: in std_logic;
		BUS_ACK				: out std_logic
	);
end sd_per;

architecture synthesis of sd_per is
	component sd_iobuf is
		port(
			CLK					: in std_logic;

			-- Sync Mux inputs
			FPGAIN_SYNC			: out std_logic_vector(8 downto 1);
			TOKENFI_SYNC		: out std_logic;
			SYNCFI_SYNC			: out std_logic;
			TRIG1F_SYNC			: out std_logic;
			TRIG2F_SYNC			: out std_logic;
			STATA_IN_SYNC		: out std_logic;
			STATB_IN_SYNC		: out std_logic;

			-- Async Mux inputs
			FPGAIN_ASYNC		: out std_logic_vector(8 downto 1);
			TOKENFI_ASYNC		: out std_logic;
			SYNCFI_ASYNC		: out std_logic;
			TRIG1F_ASYNC		: out std_logic;
			TRIG2F_ASYNC		: out std_logic;
			STATA_IN_ASYNC		: out std_logic;
			STATB_IN_ASYNC		: out std_logic;

			-- Mux outputs
			FPGAOUT_MUX			: in std_logic_vector(8 downto 1);
			TOKENFO_MUX			: in std_logic;
			TRIGFO_MUX			: in std_logic;
			SDLINKF_MUX			: in std_logic;
			STATA_OUT_MUX		: in std_logic;
			BUSY_OUT_MUX		: in std_logic;

			-- SD Input Pins
			FPGAIN				: in std_logic_vector(8 downto 1);
			TOKENFI				: in std_logic;
			SYNCFI				: in std_logic;
			TRIG1F				: in std_logic;
			TRIG2F				: in std_logic;
			STATA_IN				: in std_logic;
			STATB_IN				: in std_logic;

			-- SD Output Pins
			FPGAOUT				: out std_logic_vector(8 downto 1);
			TOKENFO				: out std_logic;
			TRIGFO				: out std_logic;
			SDLINKF				: out std_logic;
			STATA_OUT			: out std_logic;
			BUSY_OUT				: out std_logic
		);
	end component;

	component sd_mux is
		port(
			CLK					: in std_logic;

			FPGAIN_SYNC			: in std_logic_vector(8 downto 1);
			TOKENFI_SYNC		: in std_logic;
			SYNCFI_SYNC			: in std_logic;
			TRIG1F_SYNC			: in std_logic;
			TRIG2F_SYNC			: in std_logic;
			STATA_IN_SYNC		: in std_logic;
			STATB_IN_SYNC		: in std_logic;

			FPGAIN_ASYNC		: in std_logic_vector(8 downto 1);
			TOKENFI_ASYNC		: in std_logic;
			SYNCFI_ASYNC		: in std_logic;
			TRIG1F_ASYNC		: in std_logic;
			TRIG2F_ASYNC		: in std_logic;
			STATA_IN_ASYNC		: in std_logic;
			STATB_IN_ASYNC		: in std_logic;

			PULSER_OUTPUT		: in std_logic;
			BUSY					: in std_logic;
		
			FPGAOUT_MUX			: out std_logic_vector(8 downto 1);
			TOKENFO_MUX			: out std_logic;
			TRIGFO_MUX			: out std_logic;
			SDLINKF_MUX			: out std_logic;
			STATA_OUT_MUX		: out std_logic;
			BUSY_OUT_MUX		: out std_logic;

			SYNC					: out std_logic;
			TRIG					: out std_logic;
			
			FPGAOUT_SRC			: in slv5a(8 downto 1);
			TOKENFO_SRC			: in std_logic_vector(4 downto 0);
			TRIGFO_SRC			: in std_logic_vector(4 downto 0);
			SDLINKF_SRC			: in std_logic_vector(4 downto 0);
			STATA_OUT_SRC		: in std_logic_vector(4 downto 0);
			BUSY_OUT_SRC		: in std_logic_vector(4 downto 0);
			TRIG_SRC				: in std_logic_vector(4 downto 0);
			SYNC_SRC				: in std_logic_vector(4 downto 0)
		);
	end component;

	component sd_scalers is
		port(
			CLK					: in std_logic;

			-- Input signal scalers
			BUSY					: in std_logic;
			TRIG					: in std_logic;
			SYNC					: in std_logic;

			FPGAIN_SYNC			: in std_logic_vector(8 downto 1);
			TOKENFI_SYNC		: in std_logic;
			SYNCFI_SYNC			: in std_logic;
			TRIG1F_SYNC			: in std_logic;
			TRIG2F_SYNC			: in std_logic;
			STATA_IN_SYNC		: in std_logic;
			STATB_IN_SYNC		: in std_logic;
			
			-- Output signal scalers
			FPGAOUT_MUX			: in std_logic_vector(8 downto 1);
			TOKENFO_MUX			: in std_logic;
			TRIGFO_MUX			: in std_logic;
			SDLINKF_MUX			: in std_logic;
			STATA_OUT_MUX		: in std_logic;
			BUSY_OUT_MUX		: in std_logic;

			-- Scaler control
			SCALER_LATCH		: in std_logic;
			SCALER_RESET		: in std_logic;

			-- Scaler registers
			SCALER_GCLK_125	: out std_logic_vector(31 downto 0);
			SCALER_SYNC			: out std_logic_vector(31 downto 0);
			SCALER_TRIG			: out std_logic_vector(31 downto 0);
			SCALER_BUSYCYCLES	: out std_logic_vector(31 downto 0);
			SCALER_FPGAIN		: out slv32a(8 downto 1);
			SCALER_TOKENFI		: out std_logic_vector(31 downto 0);
			SCALER_SYNCFI		: out std_logic_vector(31 downto 0);
			SCALER_TRIG1F		: out std_logic_vector(31 downto 0);
			SCALER_TRIG2F		: out std_logic_vector(31 downto 0);
			SCALER_STATA_IN	: out std_logic_vector(31 downto 0);
			SCALER_STATB_IN	: out std_logic_vector(31 downto 0);
			SCALER_FPGAOUT		: out slv32a(8 downto 1);
			SCALER_TOKENFO		: out std_logic_vector(31 downto 0);
			SCALER_TRIGFO		: out std_logic_vector(31 downto 0);
			SCALER_SDLINKF		: out std_logic_vector(31 downto 0);
			SCALER_STATA_OUT	: out std_logic_vector(31 downto 0);
			SCALER_BUSY_OUT	: out std_logic_vector(31 downto 0)
		);
	end component;

	signal PI							: pbus_if_i;
	signal PO							: pbus_if_o;

	signal SCALER_LATCH_REG			: std_logic_vector(31 downto 0) := x"00000000";

	signal FPGAOUT_SRC_REG			: slv32a(8 downto 1) := (others=>x"00000000");
	signal TOKENFO_SRC_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal TRIGFO_SRC_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal SDLINKF_SRC_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal STATA_OUT_SRC_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal BUSY_OUT_SRC_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal TRIG_SRC_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal SYNC_SRC_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_PERIOD_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_LOW_CYCLES_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_NCYCLES_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_START_DMY_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_STATUS_REG		: std_logic_vector(31 downto 0) := x"00000000";

	signal FPGAIN_SYNC				: std_logic_vector(8 downto 1);
	signal TOKENFI_SYNC				: std_logic;
	signal SYNCFI_SYNC				: std_logic;
	signal TRIG1F_SYNC				: std_logic;
	signal TRIG2F_SYNC				: std_logic;
	signal STATA_IN_SYNC				: std_logic;
	signal STATB_IN_SYNC				: std_logic;

	signal FPGAIN_ASYNC				: std_logic_vector(8 downto 1);
	signal TOKENFI_ASYNC				: std_logic;
	signal SYNCFI_ASYNC				: std_logic;
	signal TRIG1F_ASYNC				: std_logic;
	signal TRIG2F_ASYNC				: std_logic;
	signal STATA_IN_ASYNC			: std_logic;
	signal STATB_IN_ASYNC			: std_logic;

	signal FPGAOUT_MUX				: std_logic_vector(8 downto 1);
	signal TOKENFO_MUX				: std_logic;
	signal TRIGFO_MUX					: std_logic;
	signal SDLINKF_MUX				: std_logic;
	signal STATA_OUT_MUX				: std_logic;
	signal BUSY_OUT_MUX				: std_logic;

	signal SCALER_LATCH_i			: std_logic;
	signal SCALER_RESET_i			: std_logic;
	signal SCALER_GCLK_125			: std_logic_vector(31 downto 0);
	signal SCALER_SYNC				: std_logic_vector(31 downto 0);
	signal SCALER_TRIG				: std_logic_vector(31 downto 0);
	signal SCALER_BUSYCYCLES		: std_logic_vector(31 downto 0);
	signal SCALER_FPGAIN				: slv32a(8 downto 1);
	signal SCALER_TOKENFI			: std_logic_vector(31 downto 0);
	signal SCALER_SYNCFI				: std_logic_vector(31 downto 0);
	signal SCALER_TRIG1F				: std_logic_vector(31 downto 0);
	signal SCALER_TRIG2F				: std_logic_vector(31 downto 0);
	signal SCALER_STATA_IN			: std_logic_vector(31 downto 0);
	signal SCALER_STATB_IN			: std_logic_vector(31 downto 0);
	signal SCALER_FPGAOUT			: slv32a(8 downto 1);
	signal SCALER_TOKENFO			: std_logic_vector(31 downto 0);
	signal SCALER_TRIGFO				: std_logic_vector(31 downto 0);
	signal SCALER_SDLINKF			: std_logic_vector(31 downto 0);
	signal SCALER_STATA_OUT			: std_logic_vector(31 downto 0);
	signal SCALER_BUSY_OUT			: std_logic_vector(31 downto 0);

	signal FPGAOUT_SRC				: slv5a(8 downto 1);
	signal TOKENFO_SRC				: std_logic_vector(4 downto 0);
	signal TRIGFO_SRC					: std_logic_vector(4 downto 0);
	signal SDLINKF_SRC				: std_logic_vector(4 downto 0);
	signal STATA_OUT_SRC				: std_logic_vector(4 downto 0);
	signal BUSY_OUT_SRC				: std_logic_vector(4 downto 0);
	signal TRIG_SRC					: std_logic_vector(4 downto 0);
	signal SYNC_SRC					: std_logic_vector(4 downto 0);

	signal PULSER_PERIOD				: std_logic_vector(31 downto 0);
	signal PULSER_LOW_CYCLES		: std_logic_vector(31 downto 0);
	signal PULSER_NCYCLES			: std_logic_vector(31 downto 0);
	signal PULSER_START				: std_logic;
	signal PULSER_DONE				: std_logic;
	signal PULSER_OUTPUT				: std_logic;

	signal SYNC_i						: std_logic;
	signal TRIG_i						: std_logic;
begin

	TRIG <= TRIG_i;
	SYNC <= SYNC_i;

	SCALER_LATCH <= SCALER_LATCH_i;
	SCALER_RESET <= SCALER_RESET_i;

	sd_iobuf_inst: sd_iobuf
		port map(
			CLK					=> CLK,
			FPGAIN_SYNC			=> FPGAIN_SYNC,
			TOKENFI_SYNC		=> TOKENFI_SYNC,
			SYNCFI_SYNC			=> SYNCFI_SYNC,
			TRIG1F_SYNC			=> TRIG1F_SYNC,
			TRIG2F_SYNC			=> TRIG2F_SYNC,
			STATA_IN_SYNC		=> STATA_IN_SYNC,
			STATB_IN_SYNC		=> STATB_IN_SYNC,
			FPGAIN_ASYNC		=> FPGAIN_ASYNC,
			TOKENFI_ASYNC		=> TOKENFI_ASYNC,
			SYNCFI_ASYNC		=> SYNCFI_ASYNC,
			TRIG1F_ASYNC		=> TRIG1F_ASYNC,
			TRIG2F_ASYNC		=> TRIG2F_ASYNC,
			STATA_IN_ASYNC		=> STATA_IN_ASYNC,
			STATB_IN_ASYNC		=> STATB_IN_ASYNC,
			FPGAOUT_MUX			=> FPGAOUT_MUX,
			TOKENFO_MUX			=> TOKENFO_MUX,
			TRIGFO_MUX			=> TRIGFO_MUX,
			SDLINKF_MUX			=> SDLINKF_MUX,
			STATA_OUT_MUX		=> STATA_OUT_MUX,
			BUSY_OUT_MUX		=> BUSY_OUT_MUX,
			FPGAIN				=> FPGAIN,
			TOKENFI				=> TOKENFI,
			SYNCFI				=> SYNCFI,
			TRIG1F				=> TRIG1F,
			TRIG2F				=> TRIG2F,
			STATA_IN				=> STATA_IN,
			STATB_IN				=> STATB_IN,
			FPGAOUT				=> FPGAOUT,
			TOKENFO				=> TOKENFO,
			TRIGFO				=> TRIGFO,
			SDLINKF				=> SDLINKF,
			STATA_OUT			=> STATA_OUT,
			BUSY_OUT				=> BUSY_OUT
		);

	sd_scalers_inst: sd_scalers
		port map(
			CLK					=> CLK,
			BUSY					=> BUSY,
			TRIG					=> TRIG_i,
			SYNC					=> SYNC_i,
			FPGAIN_SYNC			=> FPGAIN_SYNC,
			TOKENFI_SYNC		=> TOKENFI_SYNC,
			SYNCFI_SYNC			=> SYNCFI_SYNC,
			TRIG1F_SYNC			=> TRIG1F_SYNC,
			TRIG2F_SYNC			=> TRIG2F_SYNC,
			STATA_IN_SYNC		=> STATA_IN_SYNC,
			STATB_IN_SYNC		=> STATB_IN_SYNC,
			FPGAOUT_MUX			=> FPGAOUT_MUX,
			TOKENFO_MUX			=> TOKENFO_MUX,
			TRIGFO_MUX			=> TRIGFO_MUX,
			SDLINKF_MUX			=> SDLINKF_MUX,
			STATA_OUT_MUX		=> STATA_OUT_MUX,
			BUSY_OUT_MUX		=> BUSY_OUT_MUX,
			SCALER_LATCH		=> SCALER_LATCH_i,
			SCALER_RESET		=> SCALER_RESET_i,
			SCALER_GCLK_125	=> SCALER_GCLK_125,
			SCALER_SYNC			=> SCALER_SYNC,
			SCALER_TRIG			=> SCALER_TRIG,
			SCALER_BUSYCYCLES	=> SCALER_BUSYCYCLES,
			SCALER_FPGAIN		=> SCALER_FPGAIN,
			SCALER_TOKENFI		=> SCALER_TOKENFI,
			SCALER_SYNCFI		=> SCALER_SYNCFI,
			SCALER_TRIG1F		=> SCALER_TRIG1F,
			SCALER_TRIG2F		=> SCALER_TRIG2F,
			SCALER_STATA_IN	=> SCALER_STATA_IN,
			SCALER_STATB_IN	=> SCALER_STATB_IN,
			SCALER_FPGAOUT		=> SCALER_FPGAOUT,
			SCALER_TOKENFO		=> SCALER_TOKENFO,
			SCALER_TRIGFO		=> SCALER_TRIGFO,
			SCALER_SDLINKF		=> SCALER_SDLINKF,
			SCALER_STATA_OUT	=> SCALER_STATA_OUT,
			SCALER_BUSY_OUT	=> SCALER_BUSY_OUT
		);

	sd_mux_inst: sd_mux
		port map(
			CLK					=> CLK,
			FPGAIN_SYNC			=> FPGAIN_SYNC,
			TOKENFI_SYNC		=> TOKENFI_SYNC,
			SYNCFI_SYNC			=> SYNCFI_SYNC,
			TRIG1F_SYNC			=> TRIG1F_SYNC,
			TRIG2F_SYNC			=> TRIG2F_SYNC,
			STATA_IN_SYNC		=> STATA_IN_SYNC,
			STATB_IN_SYNC		=> STATB_IN_SYNC,
			FPGAIN_ASYNC		=> FPGAIN_ASYNC,
			TOKENFI_ASYNC		=> TOKENFI_ASYNC,
			SYNCFI_ASYNC		=> SYNCFI_ASYNC,
			TRIG1F_ASYNC		=> TRIG1F_ASYNC,
			TRIG2F_ASYNC		=> TRIG2F_ASYNC,
			STATA_IN_ASYNC		=> STATA_IN_ASYNC,
			STATB_IN_ASYNC		=> STATB_IN_ASYNC,
			PULSER_OUTPUT		=> PULSER_OUTPUT,
			BUSY					=> BUSY,
			FPGAOUT_MUX			=> FPGAOUT_MUX,
			TOKENFO_MUX			=> TOKENFO_MUX,
			TRIGFO_MUX			=> TRIGFO_MUX,
			SDLINKF_MUX			=> SDLINKF_MUX,
			STATA_OUT_MUX		=> STATA_OUT_MUX,
			BUSY_OUT_MUX		=> BUSY_OUT_MUX,
			SYNC					=> SYNC_i,
			TRIG					=> TRIG_i,
			FPGAOUT_SRC			=> FPGAOUT_SRC,
			TOKENFO_SRC			=> TOKENFO_SRC,
			TRIGFO_SRC			=> TRIGFO_SRC,
			SDLINKF_SRC			=> SDLINKF_SRC,
			STATA_OUT_SRC		=> STATA_OUT_SRC,
			BUSY_OUT_SRC		=> BUSY_OUT_SRC,
			TRIG_SRC				=> TRIG_SRC,
			SYNC_SRC				=> SYNC_SRC
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

	-----------------------------------
	-- Register PULSER_* Mapping
	-----------------------------------	
	PULSER_PERIOD <= PULSER_PERIOD_REG;
	PULSER_LOW_CYCLES <= PULSER_LOW_CYCLES_REG;
	PULSER_NCYCLES <= PULSER_NCYCLES_REG;
	PULSER_STATUS_REG <= x"0000000" & "000" & PULSER_DONE;

	-----------------------------------
	-- Register *_SRC Mapping
	-----------------------------------
	FPGAOUT_SRC_gen: for I in FPGAOUT_SRC'range generate
		FPGAOUT_SRC(I) <= FPGAOUT_SRC_REG(I)(4 downto 0);
	end generate;
	TOKENFO_SRC <= TOKENFO_SRC_REG(4 downto 0);
	TRIGFO_SRC <= TRIGFO_SRC_REG(4 downto 0);
	SDLINKF_SRC <= SDLINKF_SRC_REG(4 downto 0);
	STATA_OUT_SRC <= STATA_OUT_SRC_REG(4 downto 0);
	BUSY_OUT_SRC <= BUSY_OUT_SRC_REG(4 downto 0);
	TRIG_SRC <= TRIG_SRC_REG(4 downto 0);
	SYNC_SRC <= SYNC_SRC_REG(4 downto 0);

	-----------------------------------
	-- Register SCALER_LATCH_REG Mapping
	-----------------------------------	
	SCALER_LATCH_i <= SCALER_LATCH_REG(0);
	SCALER_RESET_i <= SCALER_LATCH_REG(1);

	process(CLK)
	begin
		if rising_edge(CLK) then
			PO.ACK <= '0';

			rw_reg(		REG => FPGAOUT_SRC_REG(1)		,PI=>PI,PO=>PO, A => x"0008", RW => x"0000001F");
			rw_reg(		REG => FPGAOUT_SRC_REG(2)		,PI=>PI,PO=>PO, A => x"000C", RW => x"0000001F");
			rw_reg(		REG => FPGAOUT_SRC_REG(3)		,PI=>PI,PO=>PO, A => x"0010", RW => x"0000001F");
			rw_reg(		REG => FPGAOUT_SRC_REG(4)		,PI=>PI,PO=>PO, A => x"0014", RW => x"0000001F");
			rw_reg(		REG => FPGAOUT_SRC_REG(5)		,PI=>PI,PO=>PO, A => x"0018", RW => x"0000001F");
			rw_reg(		REG => FPGAOUT_SRC_REG(6)		,PI=>PI,PO=>PO, A => x"001C", RW => x"0000001F");
			rw_reg(		REG => FPGAOUT_SRC_REG(7)		,PI=>PI,PO=>PO, A => x"0020", RW => x"0000001F");
			rw_reg(		REG => FPGAOUT_SRC_REG(8)		,PI=>PI,PO=>PO, A => x"0024", RW => x"0000001F");
			rw_reg(		REG => TOKENFO_SRC_REG			,PI=>PI,PO=>PO, A => x"0028", RW => x"0000001F");
			rw_reg(		REG => TRIGFO_SRC_REG			,PI=>PI,PO=>PO, A => x"002C", RW => x"0000001F");
			rw_reg(		REG => SDLINKF_SRC_REG			,PI=>PI,PO=>PO, A => x"0030", RW => x"0000001F");
			rw_reg(		REG => STATA_OUT_SRC_REG		,PI=>PI,PO=>PO, A => x"0034", RW => x"0000001F");
			rw_reg(		REG => BUSY_OUT_SRC_REG			,PI=>PI,PO=>PO, A => x"0038", RW => x"0000001F");
			rw_reg(		REG => TRIG_SRC_REG				,PI=>PI,PO=>PO, A => x"003C", RW => x"0000001F");
			rw_reg(		REG => SYNC_SRC_REG				,PI=>PI,PO=>PO, A => x"0040", RW => x"0000001F");

			rw_reg(		REG => PULSER_PERIOD_REG		,PI=>PI,PO=>PO, A => x"0080", RW => x"FFFFFFFF");
			rw_reg(		REG => PULSER_LOW_CYCLES_REG	,PI=>PI,PO=>PO, A => x"0084", RW => x"FFFFFFFF");
			rw_reg(		REG => PULSER_NCYCLES_REG		,PI=>PI,PO=>PO, A => x"0088", RW => x"FFFFFFFF");
			rw_reg_ack(	REG => PULSER_START_DMY_REG	,PI=>PI,PO=>PO, A => x"008C", ACK => PULSER_START);
			ro_reg(		REG => PULSER_STATUS_REG		,PI=>PI,PO=>PO, A => x"0090", RO => x"00000001");

			rw_reg(		REG => SCALER_LATCH_REG			,PI=>PI,PO=>PO, A => x"0100", RW => x"00000003");
			ro_reg(		REG => SCALER_GCLK_125			,PI=>PI,PO=>PO, A => x"0108", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_SYNC				,PI=>PI,PO=>PO, A => x"010C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TRIG				,PI=>PI,PO=>PO, A => x"0110", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_BUSYCYCLES		,PI=>PI,PO=>PO, A => x"0114", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(1)			,PI=>PI,PO=>PO, A => x"0118", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(2)			,PI=>PI,PO=>PO, A => x"011C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(3)			,PI=>PI,PO=>PO, A => x"0120", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(4)			,PI=>PI,PO=>PO, A => x"0124", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(5)			,PI=>PI,PO=>PO, A => x"0128", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(6)			,PI=>PI,PO=>PO, A => x"012C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(7)			,PI=>PI,PO=>PO, A => x"0130", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAIN(8)			,PI=>PI,PO=>PO, A => x"0134", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TOKENFI			,PI=>PI,PO=>PO, A => x"0138", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_SYNCFI				,PI=>PI,PO=>PO, A => x"013C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TRIG1F				,PI=>PI,PO=>PO, A => x"0140", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TRIG2F				,PI=>PI,PO=>PO, A => x"0144", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_STATA_IN			,PI=>PI,PO=>PO, A => x"0148", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_STATB_IN			,PI=>PI,PO=>PO, A => x"014C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(1)		,PI=>PI,PO=>PO, A => x"0150", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(2)		,PI=>PI,PO=>PO, A => x"0154", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(3)		,PI=>PI,PO=>PO, A => x"0158", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(4)		,PI=>PI,PO=>PO, A => x"015C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(5)		,PI=>PI,PO=>PO, A => x"0160", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(6)		,PI=>PI,PO=>PO, A => x"0164", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(7)		,PI=>PI,PO=>PO, A => x"0168", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_FPGAOUT(8)		,PI=>PI,PO=>PO, A => x"016C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TOKENFO			,PI=>PI,PO=>PO, A => x"0170", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TRIGFO				,PI=>PI,PO=>PO, A => x"0174", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_SDLINKF			,PI=>PI,PO=>PO, A => x"0178", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_STATA_OUT			,PI=>PI,PO=>PO, A => x"017C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_BUSY_OUT			,PI=>PI,PO=>PO, A => x"0180", RO => x"FFFFFFFF");
		end if;
	end process;

end Synthesis;
