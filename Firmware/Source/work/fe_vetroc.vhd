library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

use work.fe_vetroc_pkg.all;
use work.vme_mst_pkg.all;
use work.clkrst_per_pkg.all;
use work.perbus_pkg.all;
use work.tdc_proc_per_pkg.all;
use work.sd_per_pkg.all;
use work.eventbuilder_per_pkg.all;

entity fe_vetroc is
	port(
		-- VME BUS Interface
		A_CLKAB		: out std_logic;
		A_CLKBA		: out std_logic;
		A_DIR			: out std_logic;
		A_LE			: out std_logic;
		A_OE_N		: out std_logic;
		A				: inout std_logic_vector(31 downto 0);
		AM				: in std_logic_vector(5 downto 0);
	
		D_CLKAB		: out std_logic;
		D_CLKBA		: out std_logic;
		D_DIR			: out std_logic;
		D_LE			: out std_logic;
		D_OE_N		: out std_logic;
		D				: inout std_logic_vector(31 downto 0);

		SYSRESET_N	: in std_logic;
		SYSRST_EN	: out std_logic;
		SYSFAIL_EN	: out std_logic;
		SYSFAIL_N	: in std_logic;
		BUSY_EN		: out std_logic;
		BUSY_N		: in std_logic;
		BUSRQ_EN		: out std_logic;
		RETRY_N		: in std_logic;
		RETRY_OE		: out std_logic;
		WRITE_EN		: out std_logic;
		WRITE_N		: in std_logic;

		AS_EN			: out std_logic;
		AS_N			: in std_logic;
		BERR_EN		: out std_logic;
		BERR_N		: in std_logic;
		BG3IN_N		: in std_logic;
		BG3OUT_EN	: out std_logic;
		DS0_EN		: out std_logic;
		DS0_N			: in std_logic;
		DS1_EN		: out std_logic;
		DS1_N			: in std_logic;
		DTACK_EN		: out std_logic;
		DTACK_FPGA	: out std_logic;
		DTACK_N		: in std_logic;
		GA_N			: in std_logic_vector(4 downto 0);
		GAP_N			: in std_logic;
		IACK_EN		: out std_logic;
		IACK_I_N		: in std_logic;
		IACK_N		: in std_logic;
		IACK_O_EN	: out std_logic;
		
		IRQ_N			: out std_logic_vector(7 downto 1);
		IRQOE_N		: out std_logic;

		-- VME P2 Expansion
		VMERA			: in std_logic_vector(28 downto 1);
		VMERC			: in std_logic_vector(28 downto 1);
		VMERD			: in std_logic_vector(8 downto 1);
		VMERZ			: in std_logic_vector(16 downto 1);

		-- Front Panel Inteface
		FPAIN			: in std_logic_vector(32 downto 1);
		FPBIN			: in std_logic_vector(32 downto 1);
		FPCIN			: in std_logic_vector(32 downto 1);
		FPDIN			: in std_logic_vector(32 downto 1);

		FP6ID			: in std_logic_vector(2 downto 0);
		FP6OE			: out std_logic;
		FP6SEL		: out std_logic;
		FP7ID			: in std_logic_vector(2 downto 0);
		FP7OE			: out std_logic;
		FP7SEL		: out std_logic;

		FPGAIN		: in std_logic_vector(8 downto 1);
		FPGAOUT		: out std_logic_vector(8 downto 1);
		
		LEDA			: out std_logic_vector(8 downto 1);

		-- SRAM
		MEMA			: out std_logic_vector(19 downto 0);
		MEMCE2		: out std_logic;
		MEMCLK		: out std_logic;
		MEMD			: inout std_logic_vector(17 downto 0);
		MEMLDB		: out std_logic;
		MEMRWB		: out std_logic;
		CLKLOOP_O	: out std_logic;
		CLKLOOP_I	: in std_logic;


		-- Flash Memory
		PMEMCE_N		: out std_logic;
		PMEMD0		: inout std_logic;
		PMEMD1		: inout std_logic;
		PMEMD2		: inout std_logic;
		PMEMD3		: inout std_logic;

		-- VXS Interface
		TOKENFI		: in std_logic;
		TOKENFO		: out std_logic;
		SYNCFI		: in std_logic;
		TRIG1F		: in std_logic;
		TRIG2F		: in std_logic;
		TRIGFO		: out std_logic;
		SDLINKF		: out std_logic;
		STATA_IN		: in std_logic;
		STATA_OUT	: out std_logic;
		STATB_IN		: in std_logic;
		BUSY_OUT		: out std_logic;
		
		CLKREFA_P	: in std_logic;
		CLKREFA_N	: in std_logic;
		
		CTPRX_P		: in std_logic_vector(1 to 4);
		CTPRX_N		: in std_logic_vector(1 to 4);
		CTPTX_P		: out std_logic_vector(1 to 4);
		CTPTX_N		: out std_logic_vector(1 to 4);

		-- Clocks & Config
		CLK125F_P	: in std_logic;	-- Note: labeled CLK250F_P on schematic
		CLK125F_N	: in std_logic;	-- Note: labeled CLK250F_N on schematic
		
		CLKPRGC		: in std_logic;

		PCLKLOAD		: out std_logic;
		PCLKOUT1		: out std_logic;
		PCLKOUT2		: out std_logic;
		PCLKSIN1		: out std_logic;
		PCLKSIN2		: out std_logic;
		PCSWCFG		: out std_logic;

		-- Dip switches
		SWA			: in std_logic_vector(23 downto 19);
		SWM1			: in std_logic;
		CLKSELX1		: in std_logic;
		CLKSELX2		: in std_logic

 		-- Fiber Transeivers
-- 		FIBERICK		: inout std_logic;
-- 		FIBERICKB	: inout std_logic;
-- 		FIBERIDATA	: inout std_logic;
-- 		FIBERIDATAB	: inout std_logic;
-- 		FIBERRST		: out std_logic;
-- 		FIBERRSTB	: out std_logic;
-- 		MODINTA		: in std_logic;
-- 		MODINTB		: in std_logic;
-- 		MODPRSTA		: in std_logic;
-- 		MODPRSTB		: in std_logic;
-- 		TIAMSEL		: out std_logic;
-- 		TIBMSEL		: out std_logic;
-- 		
-- 		SYNCODEI_P	: in std_logic;
-- 		SYNCODEI_N	: in std_logic;
-- 		
-- 		SYNCODEO_P	: in std_logic;
-- 		SYNCODEO_N	: in std_logic

		-- Connects to nothing
--		MEMOE#
--		MEMWE#
--		
	);
end fe_vetroc;

architecture synthesis of fe_vetroc is
	signal RETRY					: std_logic;
	signal D_OE_N_i				: std_logic_vector(1 downto 0);

	signal SYSCLK_50_RESET		: std_logic;
	signal SYSCLK_50				: std_logic;
	signal GCLK_125_RESET		: std_logic;
	signal GCLK_125				: std_logic;
	signal GCLK_250				: std_logic;
	signal GCLK_500				: std_logic;

	signal TRIG						: std_logic;
	signal SYNC						: std_logic;
	signal BUSY						: std_logic;
	signal SCALER_LATCH			: std_logic;
	signal SCALER_RESET			: std_logic;
	signal SYNC_ARRAY				: std_logic_vector(7 downto 0);

	-- Peripheral bus interconnect signals
	signal BUS_CLK					: std_logic;
	signal BUS_RESET				: std_logic;
	signal BUS_RESET_SOFT		: std_logic;
	signal BUS_DIN					: std_logic_vector(D_WIDTH-1 downto 0);
	signal BUS_DOUT				: std_logic_vector(D_WIDTH-1 downto 0);
	signal BUS_ADDR				: std_logic_vector(A_WIDTH-1 downto 0);
	signal BUS_WR					: std_logic;
	signal BUS_RD					: std_logic;
	signal BUS_ACK					: std_logic;
	signal BUS_ACK_ARRAY			: std_logic_vector(PER_ADDR_INFO_CFG'range) := (others=>'0');
	signal BUS_DOUT_ARRAY		: slv32a(PER_ADDR_INFO_CFG'range) := (others=>(others=>'0'));

	-- eventbuilder_per signals
	signal TOKENIN						: std_logic;
	signal TOKENOUT					: std_logic;
	signal SLOTID						: std_logic_vector(4 downto 0);
	signal A32_BASE_ADDR				: std_logic_vector(8 downto 0);
	signal A32_BASE_ADDR_EN			: std_logic;		
	signal A32M_ADDR_MIN				: std_logic_vector(8 downto 0);
	signal A32M_ADDR_MAX				: std_logic_vector(8 downto 0);
	signal A32M_ADDR_EN				: std_logic;
	signal TOKEN_FIRST				: std_logic;
	signal TOKEN_LAST					: std_logic;
	signal TOKEN_STATUS				: std_logic;
	signal TOKEN_TAKE					: std_logic;
	signal USER_INT_ID				: std_logic_vector(7 downto 0);
	signal USER_INT_LEVEL			: std_logic_vector(2 downto 0);
	signal USER_BERR_EN				: std_logic;
	signal USER_INT					: std_logic;
	signal USER_FIFO_DATA_1			: std_logic_vector(35 downto 0);
	signal USER_FIFO_EMPTY_1		: std_logic;
	signal USER_FIFO_RDREQ_1		: std_logic;
	signal USER_FIFO_DATA_2			: std_logic_vector(35 downto 0);
	signal USER_FIFO_EMPTY_2		: std_logic;
	signal USER_FIFO_RDREQ_2		: std_logic;

	-- event builder & trigger fifo interface count
	constant EVT_FIFO_ARRAY_NUM	: integer := 8;

	signal EVT_FIFO_CLK				: std_logic;
	signal EVT_FIFO_DOUT_ARRAY		: slv33a(EVT_FIFO_ARRAY_NUM-1 downto 0);
	signal EVT_FIFO_RD_ARRAY		: std_logic_vector(EVT_FIFO_ARRAY_NUM-1 downto 0);
	signal EVT_FIFO_EMPTY_ARRAY	: std_logic_vector(EVT_FIFO_ARRAY_NUM-1 downto 0);

	signal TRIG_FIFO_CLK				: std_logic;
	signal TRIG_FIFO_WR				: std_logic;
	signal TRIG_FIFO_START			: std_logic_vector(9 downto 0);
	signal TRIG_FIFO_STOP			: std_logic_vector(9 downto 0);
	
	signal HIT							: std_logic_vector(127 downto 0);
	signal HIT_TRIG					: std_logic_vector(127 downto 0);
begin

	BUS_CLK <= SYSCLK_50;
	BUS_RESET <= SYSCLK_50_RESET;

	process(GCLK_125)
	begin
		if rising_edge(GCLK_125) then
			SYNC_ARRAY <= (others=>SYNC);
		end if;
	end process;

	-----------------------------------------------------
	-- Peripheral Bus Consolidation
	-----------------------------------------------------
	BUS_ACK <= or_reduce(BUS_ACK_ARRAY);

	process(BUS_DOUT_ARRAY, BUS_ACK_ARRAY)
		variable bus_dout_or		: std_logic_vector(D_WIDTH-1 downto 0);
	begin
		bus_dout_or := (others=>'0');
		for I in PER_ADDR_INFO_CFG'range loop
			if BUS_ACK_ARRAY(I) = '1' then
				bus_dout_or := bus_dout_or or BUS_DOUT_ARRAY(I);
			end if;
		end loop;
		BUS_DOUT <= bus_dout_or;
	end process;
	
	-----------------------------------------------------
	-- Bus Master (VME->local bus bridge)
	-----------------------------------------------------
	vme_mst_inst: vme_mst
		port map(
			DTACK_LED					=> open,
			TOKENIN						=> TOKENIN,
			TOKENOUT						=> TOKENOUT,
			SLOTID						=> SLOTID,
			A32_BASE_ADDR				=> A32_BASE_ADDR,
			A32_BASE_ADDR_EN			=> A32_BASE_ADDR_EN,
			A32M_ADDR_MIN				=> A32M_ADDR_MIN,
			A32M_ADDR_MAX				=> A32M_ADDR_MAX,
			A32M_ADDR_EN				=> A32M_ADDR_EN,
			TOKEN_FIRST					=> TOKEN_FIRST,
			TOKEN_LAST					=> TOKEN_LAST,
			TOKEN_STATUS				=> TOKEN_STATUS,
			TOKEN_TAKE					=> TOKEN_TAKE,
			USER_INT_ID					=> USER_INT_ID,
			USER_INT_LEVEL				=> USER_INT_LEVEL,
			USER_BERR_EN				=> USER_BERR_EN,
			USER_INT						=> USER_INT,
			USER_FIFO_DATA_1			=> USER_FIFO_DATA_1,
			USER_FIFO_EMPTY_1			=> USER_FIFO_EMPTY_1,
			USER_FIFO_RDREQ_1			=> USER_FIFO_RDREQ_1,
			USER_FIFO_DATA_2			=> USER_FIFO_DATA_2,
			USER_FIFO_EMPTY_2			=> USER_FIFO_EMPTY_2,
			USER_FIFO_RDREQ_2			=> USER_FIFO_RDREQ_2,
			VME_ADR(23 downto 19)	=> SWA,
			VME_ADR(18 downto 16)	=> "111",
			IACK_O_N						=> open,
			IACK_I_N						=> IACK_I_N,
			IACK_N						=> IACK_N,
			RETRY							=> RETRY,
			RETRY_OE						=> open,
			BERR_I_N						=> BERR_N,
			BERR_O_N						=> BERR_EN,
			DTACK_I_N					=> DTACK_N,
			DTACK_O_N					=> DTACK_FPGA,
			DTACK_OE						=> DTACK_EN,
			W_N							=> WRITE_N,
			AM								=> AM,
			A								=> A,
			A_LE							=> A_LE,
			AS_N							=> AS_N,
			A_OE_N						=> A_OE_N,
			A_DIR							=> A_DIR,
			D								=> D,
			D_LE							=> D_LE,
			DS_N(0)						=> DS0_N,
			DS_N(1)						=> DS1_N,
			D_OE_N						=> D_OE_N_i,
			D_DIR							=> D_DIR,
			IRQ_N							=> IRQ_N,
			GA_N							=> GA_N,
			GAP							=> GAP_N,
			BUS_CLK						=> BUS_CLK,
			BUS_RESET					=> BUS_RESET,
			BUS_DIN						=> BUS_DIN,
			BUS_DOUT						=> BUS_DOUT,
			BUS_ADDR						=> BUS_ADDR,
			BUS_WR						=> BUS_WR,
			BUS_RD						=> BUS_RD,
			BUS_ACK						=> BUS_ACK
		);

	-- Tie unused master VME conrol features
	D_OE_N <= D_OE_N_i(0) and D_OE_N_i(1);
	RETRY_OE <= not RETRY;
	A_CLKAB <= '0';
	A_CLKBA <= '0';
	D_CLKAB <= '0';
	D_CLKBA <= '0';
	WRITE_EN <= '0';
	AS_EN <= '0';
	DS0_EN <= '0';
	DS1_EN <= '0';
	IACK_O_EN <= '1';
	IACK_EN <= '0';
	IRQOE_N <= '0';
	BG3OUT_EN <= '0';
	SYSRST_EN <= '0';
	SYSFAIL_EN <= '0';
	BUSY_EN <= '0';
	BUSRQ_EN <= '0';
	--BG3IN_N		: in std_logic;
	--SYSRESET_N	: in std_logic;
	--SYSFAIL_N	: in std_logic;
	--BUSY_N		: in std_logic;
	--RETRY_N		: in std_logic;

		
	-----------------------------------------------------
	-- Event builder peripheral
	-----------------------------------------------------
	eventbuilder_per_inst: eventbuilder_per
		generic map(
			ADDR_INFO				=> PER_ADDR_INFO_CFG(PER_ID_EVTBUILDER),
			EVT_FIFO_ARRAY_NUM	=> EVT_FIFO_ARRAY_NUM
		)
		port map(
			CLK						=> GCLK_125,
			TRIG						=> TRIG,
			SYNC						=> SYNC,
			BUSY						=> BUSY,
			TRIG_FIFO_WR			=> TRIG_FIFO_WR,
			TRIG_FIFO_START		=> TRIG_FIFO_START,
			TRIG_FIFO_STOP			=> TRIG_FIFO_STOP,
			EVT_FIFO_DOUT_ARRAY	=> EVT_FIFO_DOUT_ARRAY,
			EVT_FIFO_RD_ARRAY		=> EVT_FIFO_RD_ARRAY,
			EVT_FIFO_EMPTY_ARRAY	=> EVT_FIFO_EMPTY_ARRAY,
			SLOTID					=> SLOTID,
			A32_BASE_ADDR			=> A32_BASE_ADDR,
			A32_BASE_ADDR_EN		=> A32_BASE_ADDR_EN,
			A32M_ADDR_MIN			=> A32M_ADDR_MIN,
			A32M_ADDR_MAX			=> A32M_ADDR_MAX,
			A32M_ADDR_EN			=> A32M_ADDR_EN,
			TOKEN_FIRST				=> TOKEN_FIRST,
			TOKEN_LAST				=> TOKEN_LAST,
			TOKEN_STATUS			=> TOKEN_STATUS,
			TOKEN_TAKE				=> TOKEN_TAKE,
			USER_INT_ID				=> USER_INT_ID,
			USER_INT_LEVEL			=> USER_INT_LEVEL,
			USER_BERR_EN			=> USER_BERR_EN,
			USER_INT					=> USER_INT,
			USER_FIFO_DATA_1		=> USER_FIFO_DATA_1,
			USER_FIFO_EMPTY_1		=> USER_FIFO_EMPTY_1,
			USER_FIFO_RDREQ_1		=> USER_FIFO_RDREQ_1,
			USER_FIFO_DATA_2		=> USER_FIFO_DATA_2,
			USER_FIFO_EMPTY_2		=> USER_FIFO_EMPTY_2,
			USER_FIFO_RDREQ_2		=> USER_FIFO_RDREQ_2,
			BUS_CLK					=> BUS_CLK,
			BUS_RESET				=> BUS_RESET,
			BUS_RESET_SOFT			=> BUS_RESET_SOFT,
			BUS_DIN					=> BUS_DIN,
			BUS_DOUT					=> BUS_DOUT_ARRAY(PER_ID_EVTBUILDER),
			BUS_ADDR					=> BUS_ADDR,
			BUS_WR					=> BUS_WR,
			BUS_RD					=> BUS_RD,
			BUS_ACK					=> BUS_ACK_ARRAY(PER_ID_EVTBUILDER)
		);

	-----------------------------------------------------
	-- System/Global clock/reset peripheral
	-----------------------------------------------------
	clkrst_per_inst: clkrst_per
		generic map(
			ADDR_INFO				=> PER_ADDR_INFO_CFG(PER_ID_CLKRST)
		)
		port map(
			CLK125F_P				=> CLK125F_P,
			CLK125F_N				=> CLK125F_N,
			CLKPRGC					=> CLKPRGC,
			PCLKLOAD					=> PCLKLOAD,
			PCLKOUT1					=> PCLKOUT1,
			PCLKOUT2					=> PCLKOUT2,
			PCLKSIN1					=> PCLKSIN1,
			PCLKSIN2					=> PCLKSIN2,
			PCSWCFG					=> PCSWCFG,
			SYSCLK_50_RESET		=> SYSCLK_50_RESET,
			SYSCLK_50				=> SYSCLK_50,
			GCLK_125_RESET			=> GCLK_125_RESET,
			GCLK_125					=> GCLK_125,
			GCLK_250					=> GCLK_250,
			GCLK_500					=> GCLK_500,
			PMEMCE_N					=> PMEMCE_N,
			PMEMD0					=> PMEMD0,
			PMEMD1					=> PMEMD1,
			PMEMD2					=> PMEMD2,
			PMEMD3					=> PMEMD3,
			BUS_RESET_SOFT_OUT	=> BUS_RESET_SOFT,
			BUS_CLK					=> BUS_CLK,
			BUS_RESET				=> BUS_RESET,
			BUS_RESET_SOFT			=> BUS_RESET_SOFT,
			BUS_DIN					=> BUS_DIN,
			BUS_DOUT					=> BUS_DOUT_ARRAY(PER_ID_CLKRST),
			BUS_ADDR					=> BUS_ADDR,
			BUS_WR					=> BUS_WR,
			BUS_RD					=> BUS_RD,
			BUS_ACK					=> BUS_ACK_ARRAY(PER_ID_CLKRST)
		);

	-----------------------------------------------------
	-- TDC Processing
	-----------------------------------------------------
	HIT(31 downto 0) <= FPAIN;
	HIT(63 downto 32) <= FPBIN;
	HIT(95 downto 64) <= FPCIN;
	HIT(127 downto 96) <= FPDIN;
	
	tdc_proc_per_gen: for I in 0 to 7 generate
		tdc_proc_per_inst: tdc_proc_per
			generic map(
				ADDR_INFO			=> PER_ADDR_INFO_CFG(PER_ID_TDCPROC0+I),
				CHANNEL_START		=> 16*I
			)
			port map(
				SCALER_LATCH		=> SCALER_LATCH,
				SCALER_RESET		=> SCALER_RESET,
				GCLK_125				=> GCLK_125,
				GCLK_250				=> GCLK_250,
				GCLK_500				=> GCLK_500,
				SYNC					=> SYNC_ARRAY(I),
				HIT					=> HIT(I*16+15 downto I*16),
				HIT_TRIG				=> HIT_TRIG(I*16+15 downto I*16),
				BUS_CLK				=> BUS_CLK,
				TRIG_FIFO_WR		=> TRIG_FIFO_WR,
				TRIG_FIFO_START	=> TRIG_FIFO_START,
				TRIG_FIFO_STOP		=> TRIG_FIFO_STOP,
				EVT_FIFO_DOUT		=> EVT_FIFO_DOUT_ARRAY(I),
				EVT_FIFO_RD			=> EVT_FIFO_RD_ARRAY(I),
				EVT_FIFO_EMPTY		=> EVT_FIFO_EMPTY_ARRAY(I),
				BUS_RESET			=> BUS_RESET,
				BUS_RESET_SOFT		=> BUS_RESET_SOFT,
				BUS_DIN				=> BUS_DIN,
				BUS_DOUT				=> BUS_DOUT_ARRAY(PER_ID_TDCPROC0+I),
				BUS_ADDR				=> BUS_ADDR,
				BUS_WR				=> BUS_WR,
				BUS_RD				=> BUS_RD,
				BUS_ACK				=> BUS_ACK_ARRAY(PER_ID_TDCPROC0+I)
			);
	end generate;

	-----------------------------------------------------
	-- SD peripheral
	-----------------------------------------------------
	sd_per_inst: sd_per
		generic map(
			ADDR_INFO			=> PER_ADDR_INFO_CFG(PER_ID_SD)
		)
		port map(
			CLK					=> GCLK_125,
			SYNC					=> SYNC,
			TRIG					=> TRIG,
			BUSY					=> BUSY,
			TOKENIN				=> TOKENIN,
			TOKENOUT				=> TOKENOUT,
			SCALER_LATCH		=> SCALER_LATCH,
			SCALER_RESET		=> SCALER_RESET,
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
			BUSY_OUT				=> BUSY_OUT,
			BUS_CLK				=> BUS_CLK,
			BUS_RESET			=> BUS_RESET,
			BUS_RESET_SOFT		=> BUS_RESET_SOFT,
			BUS_DIN				=> BUS_DIN,
			BUS_DOUT				=> BUS_DOUT_ARRAY(PER_ID_SD),
			BUS_ADDR				=> BUS_ADDR,
			BUS_WR				=> BUS_WR,
			BUS_RD				=> BUS_RD,
			BUS_ACK				=> BUS_ACK_ARRAY(PER_ID_SD)
		);

end synthesis;
