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

		TRIG					: out std_logic;
		SYNC					: out std_logic;
		BUSY					: in std_logic;
		MAROC_ADC_START	: out std_logic;
		MAROC_OUT_OR		: in std_logic;

		SCALER_LATCH		: out std_logic;
		SCALER_RESET		: out std_logic;

		-- MAROC I/O
		OR_1_0				: in std_logic;
		OR_1_1				: in std_logic;
		OR_2_0				: in std_logic;
		OR_2_1				: in std_logic;
		OR_3_0				: in std_logic;
		OR_3_1				: in std_logic;
	
		-- Test port I/O
		INPUT_1				: in std_logic;
		INPUT_2				: in std_logic;
		INPUT_3				: in std_logic;
		OUTPUT_1				: out std_logic;
		OUTPUT_2				: out std_logic;
		OUTPUT_3				: out std_logic;
		
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
end sd_per;

architecture Synthesis of sd_per is
	component sd_iobuf is
		port(
			CLK					: in std_logic;

			-- Sync Mux inputs
			INPUT_1_SYNC		: out std_logic;
			INPUT_2_SYNC		: out std_logic;
			INPUT_3_SYNC		: out std_logic;
			OR_1_0_SYNC			: out std_logic;
			OR_1_1_SYNC			: out std_logic;
			OR_2_0_SYNC			: out std_logic;
			OR_2_1_SYNC			: out std_logic;
			OR_3_0_SYNC			: out std_logic;
			OR_3_1_SYNC			: out std_logic;

			-- Async Mux inputs
			INPUT_1_ASYNC		: out std_logic;
			INPUT_2_ASYNC		: out std_logic;
			INPUT_3_ASYNC		: out std_logic;
			OR_1_0_ASYNC		: out std_logic;
			OR_1_1_ASYNC		: out std_logic;
			OR_2_0_ASYNC		: out std_logic;
			OR_2_1_ASYNC		: out std_logic;
			OR_3_0_ASYNC		: out std_logic;
			OR_3_1_ASYNC		: out std_logic;

			-- Mux outputs
			OUTPUT_1_MUX		: in std_logic;
			OUTPUT_2_MUX		: in std_logic;
			OUTPUT_3_MUX		: in std_logic;
			
			-- MAROC I/O
			OR_1_0				: in std_logic;
			OR_1_1				: in std_logic;
			OR_2_0				: in std_logic;
			OR_2_1				: in std_logic;
			OR_3_0				: in std_logic;
			OR_3_1				: in std_logic;
		
			-- Test port I/O
			INPUT_1				: in std_logic;
			INPUT_2				: in std_logic;
			INPUT_3				: in std_logic;
			OUTPUT_1				: out std_logic;
			OUTPUT_2				: out std_logic;
			OUTPUT_3				: out std_logic
		);
	end component;

	component sd_mux is
		port(
			CLK					: in std_logic;

			INPUT_1_SYNC		: in std_logic;
			INPUT_2_SYNC		: in std_logic;
			INPUT_3_SYNC		: in std_logic;
			OR_1_0_SYNC			: in std_logic;
			OR_1_1_SYNC			: in std_logic;
			OR_2_0_SYNC			: in std_logic;
			OR_2_1_SYNC			: in std_logic;
			OR_3_0_SYNC			: in std_logic;
			OR_3_1_SYNC			: in std_logic;

			PULSER_OUTPUT		: in std_logic;
			INPUT_1_ASYNC		: in std_logic;
			INPUT_2_ASYNC		: in std_logic;
			INPUT_3_ASYNC		: in std_logic;
			OR_1_0_ASYNC		: in std_logic;
			OR_1_1_ASYNC		: in std_logic;
			OR_2_0_ASYNC		: in std_logic;
			OR_2_1_ASYNC		: in std_logic;
			OR_3_0_ASYNC		: in std_logic;
			OR_3_1_ASYNC		: in std_logic;
			BUSY					: in std_logic;
			MAROC_OUT_OR		: in std_logic;
			
			OUTPUT_1_MUX		: out std_logic;
			OUTPUT_2_MUX		: out std_logic;
			OUTPUT_3_MUX		: out std_logic;

			SYNC					: out std_logic;
			TRIG					: out std_logic;
			ADC_START			: out std_logic;
			
			OUTPUT_1_SRC		: in std_logic_vector(4 downto 0);
			OUTPUT_2_SRC		: in std_logic_vector(4 downto 0);
			OUTPUT_3_SRC		: in std_logic_vector(4 downto 0);
			ADC_START_SRC		: in std_logic_vector(4 downto 0);
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
			OR_1_0_SYNC			: in std_logic;
			OR_1_1_SYNC			: in std_logic;
			OR_2_0_SYNC			: in std_logic;
			OR_2_1_SYNC			: in std_logic;
			OR_3_0_SYNC			: in std_logic;
			OR_3_1_SYNC			: in std_logic;
			INPUT_1_SYNC		: in std_logic;
			INPUT_2_SYNC		: in std_logic;
			INPUT_3_SYNC		: in std_logic;
			
			-- Output signal scalers
			OUTPUT_1_MUX		: in std_logic;
			OUTPUT_2_MUX		: in std_logic;
			OUTPUT_3_MUX		: in std_logic;

			-- Scaler control
			SCALER_LATCH		: in std_logic;
			SCALER_RESET		: in std_logic;

			-- Scaler registers
			SCALER_GCLK_125	: out std_logic_vector(31 downto 0);
			SCALER_SYNC			: out std_logic_vector(31 downto 0);
			SCALER_TRIG			: out std_logic_vector(31 downto 0);
			SCALER_BUSY			: out std_logic_vector(31 downto 0);
			SCALER_BUSYCYCLES	: out std_logic_vector(31 downto 0);
			SCALER_OR_1_0		: out std_logic_vector(31 downto 0);
			SCALER_OR_1_1		: out std_logic_vector(31 downto 0);
			SCALER_OR_2_0		: out std_logic_vector(31 downto 0);
			SCALER_OR_2_1		: out std_logic_vector(31 downto 0);
			SCALER_OR_3_0		: out std_logic_vector(31 downto 0);
			SCALER_OR_3_1		: out std_logic_vector(31 downto 0);
			SCALER_INPUT_1		: out std_logic_vector(31 downto 0);
			SCALER_INPUT_2		: out std_logic_vector(31 downto 0);
			SCALER_INPUT_3		: out std_logic_vector(31 downto 0);
			SCALER_OUTPUT_1	: out std_logic_vector(31 downto 0);
			SCALER_OUTPUT_2	: out std_logic_vector(31 downto 0);
			SCALER_OUTPUT_3	: out std_logic_vector(31 downto 0)
		);
	end component;

	signal PI							: pbus_if_i;
	signal PO							: pbus_if_o;

	signal SCALER_LATCH_REG			: std_logic_vector(31 downto 0) := x"00000000";

	signal OUTPUT_1_SRC_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal OUTPUT_2_SRC_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal OUTPUT_3_SRC_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal ADC_START_SRC_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal TRIG_SRC_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal SYNC_SRC_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_PERIOD_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_LOW_CYCLES_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_NCYCLES_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_START_DMY_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal PULSER_STATUS_REG		: std_logic_vector(31 downto 0) := x"00000000";

	signal INPUT_1_SYNC				: std_logic;
	signal INPUT_2_SYNC				: std_logic;
	signal INPUT_3_SYNC				: std_logic;
	signal OR_1_0_SYNC				: std_logic;
	signal OR_1_1_SYNC				: std_logic;
	signal OR_2_0_SYNC				: std_logic;
	signal OR_2_1_SYNC				: std_logic;
	signal OR_3_0_SYNC				: std_logic;
	signal OR_3_1_SYNC				: std_logic;

	signal INPUT_1_ASYNC				: std_logic;
	signal INPUT_2_ASYNC				: std_logic;
	signal INPUT_3_ASYNC				: std_logic;
	signal OR_1_0_ASYNC				: std_logic;
	signal OR_1_1_ASYNC				: std_logic;
	signal OR_2_0_ASYNC				: std_logic;
	signal OR_2_1_ASYNC				: std_logic;
	signal OR_3_0_ASYNC				: std_logic;
	signal OR_3_1_ASYNC				: std_logic;
	
	signal OUTPUT_1_MUX				: std_logic;
	signal OUTPUT_2_MUX				: std_logic;
	signal OUTPUT_3_MUX				: std_logic;

	signal SCALER_LATCH_i			: std_logic;
	signal SCALER_RESET_i			: std_logic;
	signal SCALER_GCLK_125			: std_logic_vector(31 downto 0);
	signal SCALER_SYNC				: std_logic_vector(31 downto 0);
	signal SCALER_TRIG				: std_logic_vector(31 downto 0);
	signal SCALER_BUSY				: std_logic_vector(31 downto 0);
	signal SCALER_BUSYCYCLES		: std_logic_vector(31 downto 0);
	signal SCALER_OR_1_0				: std_logic_vector(31 downto 0);
	signal SCALER_OR_1_1				: std_logic_vector(31 downto 0);
	signal SCALER_OR_2_0				: std_logic_vector(31 downto 0);
	signal SCALER_OR_2_1				: std_logic_vector(31 downto 0);
	signal SCALER_OR_3_0				: std_logic_vector(31 downto 0);
	signal SCALER_OR_3_1				: std_logic_vector(31 downto 0);
	signal SCALER_INPUT_1			: std_logic_vector(31 downto 0);
	signal SCALER_INPUT_2			: std_logic_vector(31 downto 0);
	signal SCALER_INPUT_3			: std_logic_vector(31 downto 0);
	signal SCALER_OUTPUT_1			: std_logic_vector(31 downto 0);
	signal SCALER_OUTPUT_2			: std_logic_vector(31 downto 0);
	signal SCALER_OUTPUT_3			: std_logic_vector(31 downto 0);

	signal OUTPUT_1_SRC				: std_logic_vector(4 downto 0);
	signal OUTPUT_2_SRC				: std_logic_vector(4 downto 0);
	signal OUTPUT_3_SRC				: std_logic_vector(4 downto 0);
	signal ADC_START_SRC				: std_logic_vector(4 downto 0);
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
			INPUT_1_SYNC		=> INPUT_1_SYNC,
			INPUT_2_SYNC		=> INPUT_2_SYNC,
			INPUT_3_SYNC		=> INPUT_3_SYNC,
			OR_1_0_SYNC			=> OR_1_0_SYNC,
			OR_1_1_SYNC			=> OR_1_1_SYNC,
			OR_2_0_SYNC			=> OR_2_0_SYNC,
			OR_2_1_SYNC			=> OR_2_1_SYNC,
			OR_3_0_SYNC			=> OR_3_0_SYNC,
			OR_3_1_SYNC			=> OR_3_1_SYNC,
			INPUT_1_ASYNC		=> INPUT_1_ASYNC,
			INPUT_2_ASYNC		=> INPUT_2_ASYNC,
			INPUT_3_ASYNC		=> INPUT_3_ASYNC,
			OR_1_0_ASYNC		=> OR_1_0_ASYNC,
			OR_1_1_ASYNC		=> OR_1_1_ASYNC,
			OR_2_0_ASYNC		=> OR_2_0_ASYNC,
			OR_2_1_ASYNC		=> OR_2_1_ASYNC,
			OR_3_0_ASYNC		=> OR_3_0_ASYNC,
			OR_3_1_ASYNC		=> OR_3_1_ASYNC,
			OUTPUT_1_MUX		=> OUTPUT_1_MUX,
			OUTPUT_2_MUX		=> OUTPUT_2_MUX,
			OUTPUT_3_MUX		=> OUTPUT_3_MUX,
			OR_1_0				=> OR_1_0,
			OR_1_1				=> OR_1_1,
			OR_2_0				=> OR_2_0,
			OR_2_1				=> OR_2_1,
			OR_3_0				=> OR_3_0,
			OR_3_1				=> OR_3_1,
			INPUT_1				=> INPUT_1,
			INPUT_2				=> INPUT_2,
			INPUT_3				=> INPUT_3,
			OUTPUT_1				=> OUTPUT_1,
			OUTPUT_2				=> OUTPUT_2,
			OUTPUT_3				=> OUTPUT_3
		);

	sd_scalers_inst: sd_scalers
		port map(
			CLK					=> CLK,
			BUSY					=> BUSY,
			TRIG					=> TRIG_i,
			SYNC					=> SYNC_i,
			SCALER_LATCH		=> SCALER_LATCH_i,
			SCALER_RESET		=> SCALER_RESET_i,
			SCALER_GCLK_250	=> SCALER_GCLK_250,
			SCALER_SYNC			=> SCALER_SYNC,
			SCALER_TRIG			=> SCALER_TRIG,
			SCALER_BUSYCYCLES	=> SCALER_BUSYCYCLES
		);

	sd_mux_inst: sd_mux
		port map(
			CLK					=> CLK,
			PULSER_OUTPUT		=> PULSER_OUTPUT,
			BUSY					=> BUSY,
			SYNC					=> SYNC_i,
			TRIG					=> TRIG_i,
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

			rw_reg(		REG => TRIG_SRC_REG				,PI=>PI,PO=>PO, A => x"003C", RW => x"0000001F");
			rw_reg(		REG => SYNC_SRC_REG				,PI=>PI,PO=>PO, A => x"0040", RW => x"0000001F");

			rw_reg(		REG => PULSER_PERIOD_REG		,PI=>PI,PO=>PO, A => x"0080", RW => x"FFFFFFFF");
			rw_reg(		REG => PULSER_LOW_CYCLES_REG	,PI=>PI,PO=>PO, A => x"0084", RW => x"FFFFFFFF");
			rw_reg(		REG => PULSER_NCYCLES_REG		,PI=>PI,PO=>PO, A => x"0088", RW => x"FFFFFFFF");
			rw_reg_ack(	REG => PULSER_START_DMY_REG	,PI=>PI,PO=>PO, A => x"008C", ACK => PULSER_START);
			ro_reg(		REG => PULSER_STATUS_REG		,PI=>PI,PO=>PO, A => x"0090", RO => x"00000001");

			rw_reg(		REG => SCALER_LATCH_REG			,PI=>PI,PO=>PO, A => x"0100", RW => x"00000003");
			ro_reg(		REG => SCALER_GCLK_250			,PI=>PI,PO=>PO, A => x"0108", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_SYNC				,PI=>PI,PO=>PO, A => x"010C", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_TRIG				,PI=>PI,PO=>PO, A => x"0110", RO => x"FFFFFFFF");
			ro_reg(		REG => SCALER_BUSYCYCLES		,PI=>PI,PO=>PO, A => x"0148", RO => x"FFFFFFFF");
		end if;
	end process;

end Synthesis;
