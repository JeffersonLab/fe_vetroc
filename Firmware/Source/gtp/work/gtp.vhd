library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

use work.tigtp_per_pkg.all;
use work.gtpclkrst_per_pkg.all;
use work.gtpcfg_per_pkg.all;
use work.gxbconfig_per_pkg.all;
use work.gxbvxs_per_pkg.all;
use work.gxbqsfp_per_pkg.all;
use work.sd_per_pkg.all;
use work.trigger_per_pkg.all;

use work.nios_wrapper_pkg.all;
use work.perbus_pkg.all;
use work.gtp_pkg.all;

library utils;
use utils.utils_pkg.all;

entity gtp is
	generic(
		SIM_GTXRESET_SPEEDUP		: integer := 0;
		GTX_QUICKSIM				: boolean := false
	);
	port(
		CLK25_B					: IN STD_LOGIC;
		CLK25_R					: IN STD_LOGIC;
		CLK250_B					: IN STD_LOGIC;
		CLK250_L					: IN STD_LOGIC;
		CLK250_R					: IN STD_LOGIC;
		CLK250_T					: IN STD_LOGIC;
		CPLD_CLK					: OUT STD_LOGIC;
		
		--Payload 1-16, Channel 3&4
		PAYLOAD_RX2				: IN STD_LOGIC_VECTOR(0 TO 15);
		PAYLOAD_RX3				: IN STD_LOGIC_VECTOR(0 TO 15);
		PAYLOAD_TX2				: OUT STD_LOGIC_VECTOR(0 TO 15);
		PAYLOAD_TX3				: OUT STD_LOGIC_VECTOR(0 TO 15);
		
		--Fiber Transceiver
		FIBER_RX					: IN STD_LOGIC_VECTOR(0 TO 3);
		FIBER_TX					: OUT STD_LOGIC_VECTOR(0 TO 3);
		
		--Backplane Ethernet
		ENET_RX					: IN STD_LOGIC;
		ENET_TX					: OUT STD_LOGIC;
		ENET_TXn					: OUT STD_LOGIC;
		
		--Front Panel Ethernet Phy
		RGMII_TXD				: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		RGMII_TXC				: OUT STD_LOGIC;
		RGMII_TX_CTL			: OUT STD_LOGIC;
		
		RGMII_RXD				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		RGMII_RXC				: IN STD_LOGIC;
		RGMII_RX_CTL			: IN STD_LOGIC;
--need to setup timing constraints/delays on phy interface		
		ENET_PHY_RESET_N		: OUT STD_LOGIC;
		ENET_PHY_MDC			: OUT STD_LOGIC;
		ENET_PHY_MDIO			: INOUT STD_LOGIC;
		ENET_PHY_INT_N			: IN STD_LOGIC;
		
		--DDR2 Device 0
		MEM0_WE_N				: OUT STD_LOGIC;
		MEM0_RAS_N				: OUT STD_LOGIC;
		MEM0_CAS_N				: OUT STD_LOGIC;
		MEM0_DQ					: INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		MEM0_CS_N				: OUT STD_LOGIC;
		MEM0_CKE					: OUT STD_LOGIC;
		MEM0_ODT					: OUT STD_LOGIC;
		MEM0_CK_N				: OUT STD_LOGIC;
		MEM0_CK					: OUT STD_LOGIC;
		MEM0_BA					: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		MEM0_A					: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		MEM0_DQS_P				: INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		MEM0_DQS_N				: INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		MEM0_UDM					: OUT STD_LOGIC;
		MEM0_LDM_RDQS_P		: OUT STD_LOGIC;
	--	MEM0_NC_RDQS_N			: OUT STD_LOGIC;										--RDQS not supported
		OCT_RDN0					: IN STD_LOGIC;
		OCT_RUP0  				: IN STD_LOGIC;
		
		--DDR2 Device 1
		MEM1_WE_N				: OUT STD_LOGIC;
		MEM1_RAS_N				: OUT STD_LOGIC;
		MEM1_CAS_N				: OUT STD_LOGIC;
		MEM1_DQ					: INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		MEM1_CS_N				: OUT STD_LOGIC;
		MEM1_CKE					: OUT STD_LOGIC;
		MEM1_ODT					: OUT STD_LOGIC;
		MEM1_CK_N				: OUT STD_LOGIC;
		MEM1_CK					: OUT STD_LOGIC;
		MEM1_BA					: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		MEM1_A					: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		MEM1_DQS_P				: INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		MEM1_DQS_N				: INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		MEM1_UDM					: OUT STD_LOGIC;
		MEM1_LDM_RDQS_P		: OUT STD_LOGIC;
	--	MEM1_NC_RDQS_N			: OUT STD_LOGIC;										--RDQS not supported
	--	OCT_RDN1					: IN STD_LOGIC;
	--	OCT_RUP1  				: IN STD_LOGIC;
		
		--CONFIGURATION FLASH
		CONFIG_CLK				: OUT STD_LOGIC;
		CONFIG_NRST				: OUT STD_LOGIC;
		CONFIG_ADDR				: OUT STD_LOGIC_VECTOR(26 DOWNTO 1);
		CONFIG_DATA				: INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		CONFIG_NADV				: OUT STD_LOGIC;
		CONFIG_NCE				: OUT STD_LOGIC;
		CONFIG_NOE				: OUT STD_LOGIC;
		CONFIG_NWE				: OUT STD_LOGIC;
		CONFIG_WAIT				: IN STD_LOGIC;
		
		--NIOS II CODE FLASH
		CODE_CLK					: OUT STD_LOGIC;
		CODE_NRST				: OUT STD_LOGIC;
		CODE_ADDR				: OUT STD_LOGIC_VECTOR(26 DOWNTO 1);
		CODE_DATA				: INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		CODE_NADV				: OUT STD_LOGIC;
		CODE_NCE					: OUT STD_LOGIC;
		CODE_NOE					: OUT STD_LOGIC;
		CODE_NWE					: OUT STD_LOGIC;
		CODE_WAIT				: IN STD_LOGIC;
		
		--Configuration Inteface to CPLD
		FLASH_IMAGE				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		FLASH_ACCESS_REQUEST	: OUT STD_LOGIC;
		FLASH_ACCESS_GRANTED	: IN STD_LOGIC;
		FLASH_nRECONFIG		: OUT STD_LOGIC;
		
		--CPLD to FPGA General Purpose Interface
		CPLD_FPGA_GPIO			: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		
		--CONFIGURATION PINS - NOT USED BY LOGIC
	--	DATA						: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	--	INIT_DONE				: OUT STD_LOGIC;
	--	CRC_ERROR				: OUT STD_LOGIC;
		
		--Busy and Linkup signals to SSP Modules
		PP_BUSY					: OUT STD_LOGIC_VECTOR(16 DOWNTO 1);
		PP_LINKUP				: OUT STD_LOGIC_VECTOR(16 DOWNTO 1);
		BUSY_DIR					: OUT STD_LOGIC;
		LINKUP_DIR				: OUT STD_LOGIC;
		
		--Payload Port 17 I2C
		PP17_SCL					: IN STD_LOGIC;
		PP17_SDA					: INOUT STD_LOGIC;
		PP17_SDA_OE				: OUT STD_LOGIC;
		
		--Trigger Interface I2C
		TI_SCL					: in std_logic;
		TI_SDA					: inout std_logic;
		TI_SDA_OE				: out std_logic;
		
		--Trigger Out, LVDS
		TRIG_OUT					: out std_logic_vector(31 downto 0);
		
		--SD Control
		SD_SYNC					: in std_logic;
		SD_TRIG					: in std_logic_vector(2 downto 1);
		
		--TI Control
		TI_GTP_RX				: in std_logic;
		TI_GTP_TX				: out std_logic;
		TI_BUSY					: out std_logic;
		
		--Front Panel LEDs
		LED_AMBER				: out std_logic;
		LED_RED					: out std_logic;

		FP_OUT					: out std_logic_vector(3 downto 0);
		FP_IN						: in std_logic_vector(3 downto 0)
	);
end gtp;

architecture synthesis of gtp is
	-- Peripheral bus interconnect signals
	signal BUS_CLK						: std_logic := '0';
	signal BUS_RESET					: std_logic := '0';
	signal BUS_RESET_SOFT			: std_logic := '0';
	signal BUS_DIN						: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	signal BUS_ADDR					: std_logic_vector(A_WIDTH-1 downto 0) := (others=>'0');
	signal BUS_WR						: std_logic := '0';
	signal BUS_RD						: std_logic := '0';
	signal BUS_ACK						: std_logic := '0';
	signal BUS_IRQ						: std_logic := '0';

	signal BUS_ACK_ARRAY				: std_logic_vector(PER_ADDR_INFO_CFG'range) := (others=>'0');
	signal BUS_DOUT					: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	signal BUS_DOUT_ARRAY			: slv32a(PER_ADDR_INFO_CFG'range) := (others=>x"00000000");

	signal ATXCLK_R					: std_logic;
	signal ATXCLK_L					: std_logic;
	signal SYSCLK_LOCKED				: std_logic;
	signal SYSCLK_50					: std_logic;
	signal SYSCLK_250					: std_logic;
	signal SYSCLK_CPU					: std_logic;
	signal SYSCLK_PER					: std_logic;
	signal GCLK							: std_logic;
	signal GCLK_DIV4					: std_logic;
	signal GCLK_RST					: std_logic;

	signal TIGTP_PLL_RESET			: std_logic;

	signal SCALER_LATCH				: std_logic;

	signal RX_D							: slv32a(15 downto 0) := (others=>x"00000000");
	signal RX_SRC_RDY_N				: std_logic_vector(15 downto 0) := (others=>'0');
	signal FIB_TX_D					: std_logic_vector(63 downto 0);
	signal FIB_TX_SRC_RDY_N			: std_logic;
	
	signal BUSY							: std_logic;
	signal SYNC							: std_logic;
	signal TRIG							: std_logic;

	signal ATXCLK						: std_logic_vector(15 downto 0);
	signal CAL_BLK_POWERDOWN		: std_logic_vector(15 downto 0);
	signal CAL_BLK_POWERDOWN_L		: std_logic;
	signal CAL_BLK_POWERDOWN_R		: std_logic;
	signal CAL_BLK_BUSY				: std_logic_vector(15 downto 0);
	signal CAL_BLK_BUSY_L			: std_logic;
	signal CAL_BLK_BUSY_R			: std_logic;
	signal RECONFIG_TOGXB_L			: std_logic_vector(3 downto 0);
	signal RECONFIG_TOGXB_R			: std_logic_vector(3 downto 0);
	signal RECONFIG_FROMGXB_L		: std_logic_vector(611 downto 0);
	signal RECONFIG_FROMGXB_R		: std_logic_vector(611 downto 0);
	signal RECONFIG_TOGXB_ARRAY	: slv4a(15 downto 0);
	signal RECONFIG_FROMGXB_ARRAY	: slv68a(15 downto 0);

	signal TRIG_BIT_OUT				: std_logic_vector(31 downto 0);
begin

--	PP17_SCL					: IN STD_LOGIC;
	PP17_SDA <= 'Z';
	PP17_SDA_OE <= '0';

	TRIG_OUT <= (others=>'0');

	BUS_RESET_SOFT <= '0';

	BUSY <= '0';

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
	-- TI ROC interface peripheral
	-----------------------------------------------------
	tigtp_per_inst: tigtp_per
		generic map(
			ADDR_INFO			=> PER_ADDR_INFO_CFG(PER_ID_TIGTP)
		)
		port map(
			CLK_REF				=> GCLK,
			TI_GTP_TX			=> TI_GTP_TX,
			TI_GTP_RX			=> TI_GTP_RX,
			BUS_CLK				=> BUS_CLK,
			BUS_RESET			=> BUS_RESET,
			BUS_RESET_SOFT		=> BUS_RESET_SOFT,
			BUS_DIN				=> BUS_DIN,
			BUS_DOUT				=> BUS_DOUT_ARRAY(PER_ID_TIGTP),
			BUS_ADDR				=> BUS_ADDR,
			BUS_WR				=> BUS_WR,
			BUS_RD				=> BUS_RD,
			BUS_ACK				=> BUS_ACK_ARRAY(PER_ID_TIGTP),
			BUS_IRQ				=> BUS_IRQ
		);

	-----------------------------------------------------
	-- System/Global clock/reset peripheral
	-----------------------------------------------------
	gtpcfg_per_inst: gtpcfg_per
		generic map(
			ADDR_INFO		=> PER_ADDR_INFO_CFG(PER_ID_GTPCFG)
		)
		port map(
			CPLD_FPGA_GPIO	=> CPLD_FPGA_GPIO(15 downto 2),
			LED_AMBER		=> LED_AMBER,
			LED_RED			=> LED_RED,
			TI_SCL			=> TI_SCL,
			TI_SDA			=> TI_SDA,
			TI_SDA_OE		=> TI_SDA_OE,
			BUS_CLK			=> SYSCLK_50,
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT_ARRAY(PER_ID_GTPCFG),
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK_ARRAY(PER_ID_GTPCFG)
		);

	-----------------------------------------------------
	-- System/Global clock/reset peripheral
	-----------------------------------------------------
	gtpclkrst_per_inst: gtpclkrst_per
		generic map(
			ADDR_INFO			=> PER_ADDR_INFO_CFG(PER_ID_GTPCLKRST)
		)
		port map(
			CLK25_B				=> CLK25_B,
			CLK25_R				=> CLK25_R,
			CLK250_B				=> CLK250_B,
			CLK250_L				=> CLK250_L,
			CLK250_R				=> CLK250_R,
			CLK250_T				=> CLK250_T,
			ATXCLK_R				=> ATXCLK_R,
			ATXCLK_L				=> ATXCLK_L,
			CPLD_CLK				=> CPLD_CLK,
			SYSCLK_LOCKED		=> SYSCLK_LOCKED,
			SYSCLK_50			=> SYSCLK_50,
			SYSCLK_250			=> SYSCLK_250,
			SYSCLK_CPU			=> SYSCLK_CPU,
			SYSCLK_PER			=> SYSCLK_PER,
			GCLK					=> GCLK,
			GCLK_DIV4			=> GCLK_DIV4,
			GCLK_RST				=> GCLK_RST,
			GCLK_SRC				=> CPLD_FPGA_GPIO(1 DOWNTO 0),
			BUS_CLK				=> SYSCLK_50,
			BUS_RESET			=> BUS_RESET,
			BUS_RESET_SOFT		=> BUS_RESET_SOFT,
			BUS_DIN				=> BUS_DIN,
			BUS_DOUT				=> BUS_DOUT_ARRAY(PER_ID_GTPCLKRST),
			BUS_ADDR				=> BUS_ADDR,
			BUS_WR				=> BUS_WR,
			BUS_RD				=> BUS_RD,
			BUS_ACK				=> BUS_ACK_ARRAY(PER_ID_GTPCLKRST)
		);

	-----------------------------------------------------
	-- SD Peripheral
	-----------------------------------------------------
	sd_per_inst: sd_per
		generic map(
			ADDR_INFO		=> PER_ADDR_INFO_CFG(PER_ID_SD)
		)
		port map(
			CLK				=> GCLK,
			SYSCLK_50		=> SYSCLK_50,
			SYNC				=> SYNC,
			TRIG				=> TRIG,
			BUSY				=> BUSY,
			TRIG_BIT_OUT	=> TRIG_BIT_OUT,
			SCALER_LATCH	=> SCALER_LATCH,
			FP_OUT			=> FP_OUT,
			FP_IN				=> FP_IN,
			SD_SYNC			=> SD_SYNC,
			SD_TRIG			=> SD_TRIG,
			TI_BUSY			=> TI_BUSY,
			PP_BUSY			=> PP_BUSY,
			PP_LINKUP		=> PP_LINKUP,
			BUSY_DIR			=> BUSY_DIR,
			LINKUP_DIR		=> LINKUP_DIR,
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT_ARRAY(PER_ID_SD),
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK_ARRAY(PER_ID_SD)
		);

-- 	-----------------------------------------------------
-- 	-- Logic Analyzer Peripheral
-- 	-----------------------------------------------------
-- 	gtpla_per_inst: gtpla_per
-- 		generic map(
-- 			ADDR_INFO		=> PER_ADDR_INFO_CFG(PER_ID_GTPLA)
-- 		)
-- 		port map(
-- 			CLK				=> GCLK,
-- 			TRIG_STREAM		=> TRIG_STREAM_FANOUT(TRIG_STREAM_FANOUT'length-1),
-- 			TRIG_OUT_SCOPE	=> TRIG_OUT_SCOPE,
-- 			BUS_RESET		=> BUS_RESET,
--				BUS_RESET_SOFT	=> BUS_RESET_SOFT,
-- 			BUS_DIN			=> BUS_DIN,
-- 			BUS_DOUT			=> BUS_DOUT_ARRAY(PER_ID_GTPLA),
-- 			BUS_ADDR			=> BUS_ADDR,
-- 			BUS_WR			=> BUS_WR,
-- 			BUS_RD			=> BUS_RD,
-- 			BUS_ACK			=> BUS_ACK_ARRAY(PER_ID_GTPLA)
-- 		);

	-----------------------------------------------------
	-- GXB Serdes Reconfig Peripheral (Odd Payloads)
	-----------------------------------------------------
	gxbconfig_per_inst_l: gxbconfig_per
		generic map(
			ADDR_INFO			=> PER_ADDR_INFO_CFG(PER_ID_GXBCFG_L)
		)
		port map(
			SYSCLK_50			=> SYSCLK_50,
			CAL_BLK_POWERDOWN	=> CAL_BLK_POWERDOWN_L,
			CAL_BLK_BUSY		=> CAL_BLK_BUSY_L,
			RECONFIG_TOGXB		=> RECONFIG_TOGXB_L,
			RECONFIG_FROMGXB	=> RECONFIG_FROMGXB_L,
			BUS_RESET			=> BUS_RESET,
			BUS_RESET_SOFT		=> BUS_RESET_SOFT,
			BUS_DIN				=> BUS_DIN,
			BUS_DOUT				=> BUS_DOUT_ARRAY(PER_ID_GXBCFG_L),
			BUS_ADDR				=> BUS_ADDR,
			BUS_WR				=> BUS_WR,
			BUS_RD				=> BUS_RD,
			BUS_ACK				=> BUS_ACK_ARRAY(PER_ID_GXBCFG_L)
		);

	ReconfigPayload_gen_odd: for I in 0 to 7 generate
		CAL_BLK_POWERDOWN(2*I) <= CAL_BLK_POWERDOWN_L;
		CAL_BLK_BUSY(2*I) <= CAL_BLK_BUSY_L;
		RECONFIG_TOGXB_ARRAY(2*I) <= RECONFIG_TOGXB_L;
		RECONFIG_FROMGXB_L(68*I+67 downto 68*I) <= RECONFIG_FROMGXB_ARRAY(2*I);
		ATXCLK(2*I) <= ATXCLK_L;
	end generate;

	-----------------------------------------------------
	-- GXB Serdes Reconfig Peripheral (Even Payloads)
	-----------------------------------------------------
	gxbconfig_per_inst_r: gxbconfig_per
		generic map(
			ADDR_INFO			=> PER_ADDR_INFO_CFG(PER_ID_GXBCFG_R)
		)
		port map(
			SYSCLK_50			=> SYSCLK_50,
			CAL_BLK_POWERDOWN	=> CAL_BLK_POWERDOWN_R,
			CAL_BLK_BUSY		=> CAL_BLK_BUSY_R,
			RECONFIG_TOGXB		=> RECONFIG_TOGXB_R,
			RECONFIG_FROMGXB	=> RECONFIG_FROMGXB_R,
			BUS_RESET			=> BUS_RESET,
			BUS_RESET_SOFT		=> BUS_RESET_SOFT,
			BUS_DIN				=> BUS_DIN,
			BUS_DOUT				=> BUS_DOUT_ARRAY(PER_ID_GXBCFG_R),
			BUS_ADDR				=> BUS_ADDR,
			BUS_WR				=> BUS_WR,
			BUS_RD				=> BUS_RD,
			BUS_ACK				=> BUS_ACK_ARRAY(PER_ID_GXBCFG_R)
		);

	ReconfigPayload_gen_even: for I in 0 to 7 generate
		CAL_BLK_POWERDOWN(2*I+1) <= CAL_BLK_POWERDOWN_R;
		CAL_BLK_BUSY(2*I+1) <= CAL_BLK_BUSY_R;
		RECONFIG_TOGXB_ARRAY(2*I+1) <= RECONFIG_TOGXB_R;
		RECONFIG_FROMGXB_R(68*I+67 downto 68*I) <= RECONFIG_FROMGXB_ARRAY(2*I+1);
		ATXCLK(2*I+1) <= ATXCLK_R;
	end generate;

	-----------------------------------------------------
	-- GXB Serdes VXS peripheral
	-----------------------------------------------------
	gxbvxs_per_gen: for I in 0 to 15 generate
		gxbvxs_gen_true: if GXBVXS_GEN(I) = '1' generate
			gxbvxs_per_inst: gxbvxs_per
				generic map(
					ADDR_INFO				=> PER_ADDR_INFO_CFG(PER_ID_GXBVXS0+I),
					PAYLOAD_INST			=> I+1,
					SIM_GTXRESET_SPEEDUP	=> SIM_GTXRESET_SPEEDUP,
					GTX_QUICKSIM			=> GTX_QUICKSIM
				)
				port map(
					SYSCLK_50			=> SYSCLK_50,
					ATXCLK				=> ATXCLK(I),
					PAYLOAD_RX2			=> PAYLOAD_RX2(I),
					PAYLOAD_RX3			=> PAYLOAD_RX3(I),
					PAYLOAD_TX2			=> PAYLOAD_TX2(I),
					PAYLOAD_TX3			=> PAYLOAD_TX3(I),
					CAL_BLK_POWERDOWN	=> CAL_BLK_POWERDOWN(I),
					CAL_BLK_BUSY		=> CAL_BLK_BUSY(I),
					RECONFIG_FROMGXB	=> RECONFIG_FROMGXB_ARRAY(I),
					RECONFIG_TOGXB		=> RECONFIG_TOGXB_ARRAY(I),
					CLK					=> GCLK,
					SYNC					=> SYNC,
					RX_D					=> RX_D(I),
					RX_SRC_RDY_N		=> RX_SRC_RDY_N(I),
					EXT_TRIGGER			=> '0',
					BUS_RESET			=> BUS_RESET,
					BUS_RESET_SOFT		=> BUS_RESET_SOFT,
					BUS_DIN				=> BUS_DIN,
					BUS_DOUT				=> BUS_DOUT_ARRAY(PER_ID_GXBVXS0+I),
					BUS_ADDR				=> BUS_ADDR,
					BUS_WR				=> BUS_WR,
					BUS_RD				=> BUS_RD,
					BUS_ACK				=> BUS_ACK_ARRAY(PER_ID_GXBVXS0+I)
				);
		end generate;
	end generate;

	-----------------------------------------------------
	-- GXB Serdes QSFP peripheral
	-----------------------------------------------------
	gxbqsfp_per_inst: gxbqsfp_per
		generic map(
			ADDR_INFO					=> PER_ADDR_INFO_CFG(PER_ID_QSFP),
			SIM_GTXRESET_SPEEDUP		=> SIM_GTXRESET_SPEEDUP,
			GTX_QUICKSIM				=> GTX_QUICKSIM
		)
		port map(
			SYSCLK_50				=> SYSCLK_50,
			ATXCLK_L					=> ATXCLK_L,
			ATXCLK_R					=> ATXCLK_R,
			FIBER_RX					=> FIBER_RX,
			FIBER_TX					=> FIBER_TX,
			CAL_BLK_POWERDOWN_L	=> CAL_BLK_POWERDOWN_L,
			CAL_BLK_POWERDOWN_R	=> CAL_BLK_POWERDOWN_R,
			CAL_BLK_BUSY_L			=> CAL_BLK_BUSY_L,
			CAL_BLK_BUSY_R			=> CAL_BLK_BUSY_R,
			RECONFIG_FROMGXB_L	=> RECONFIG_FROMGXB_L(611 downto 544),
			RECONFIG_FROMGXB_R	=> RECONFIG_FROMGXB_R(611 downto 544),
			RECONFIG_TOGXB_L		=> RECONFIG_TOGXB_L,
			RECONFIG_TOGXB_R		=> RECONFIG_TOGXB_R,
			CLK						=> GCLK,
			SYNC						=> SYNC,
			TX_D						=> FIB_TX_D,
			TX_SRC_RDY_N			=> FIB_TX_SRC_RDY_N,
			BUS_RESET				=> BUS_RESET,
			BUS_RESET_SOFT			=> BUS_RESET_SOFT,
			BUS_DIN					=> BUS_DIN,
			BUS_DOUT					=> BUS_DOUT_ARRAY(PER_ID_QSFP),
			BUS_ADDR					=> BUS_ADDR,
			BUS_WR					=> BUS_WR,
			BUS_RD					=> BUS_RD,
			BUS_ACK					=> BUS_ACK_ARRAY(PER_ID_QSFP)
		);

 	-----------------------------------------------------
 	-- Trigger Peripheral
 	-----------------------------------------------------
 	trigger_per_inst: trigger_per
 		generic map(
 			ADDR_INFO				=> PER_ADDR_INFO_CFG(PER_ID_TRIGGER)
 		)
 		port map(
 			CLK						=> GCLK,
			CLK_DIV4					=> GCLK_DIV4,
			SYNC						=> SYNC,
			RX_D						=> RX_D,
			RX_SRC_RDY_N			=> RX_SRC_RDY_N,
			TRIG_BIT_OUT			=> TRIG_BIT_OUT,
 			BUS_RESET				=> BUS_RESET,
			BUS_RESET_SOFT			=> BUS_RESET_SOFT,
 			BUS_DIN					=> BUS_DIN,
 			BUS_DOUT					=> BUS_DOUT_ARRAY(PER_ID_TRIGGER),
 			BUS_ADDR					=> BUS_ADDR,
 			BUS_WR					=> BUS_WR,
 			BUS_RD					=> BUS_RD,
 			BUS_ACK					=> BUS_ACK_ARRAY(PER_ID_TRIGGER)
 		);

	FIB_TX_D <= (others=>'0');
	FIB_TX_SRC_RDY_N <= '1';

	-----------------------------------------------------
	-- Nios II System
	-----------------------------------------------------
	nios_wrapper_inst: nios_wrapper
		port map(
			CLK250_T					=> CLK250_T,
			SYSCLK_LOCKED			=> SYSCLK_LOCKED,
			SYSCLK_250				=> SYSCLK_250,
			SYSCLK_CPU				=> SYSCLK_CPU,
			SYSCLK_PER				=> SYSCLK_PER,
			RGMII_TXD				=> RGMII_TXD,
			RGMII_TXC				=> RGMII_TXC,
			RGMII_TX_CTL			=> RGMII_TX_CTL,
			RGMII_RXD				=> RGMII_RXD,
			RGMII_RXC				=> RGMII_RXC,
			RGMII_RX_CTL			=> RGMII_RX_CTL,
			ENET_PHY_RESET_N		=> ENET_PHY_RESET_N,
			ENET_PHY_MDC			=> ENET_PHY_MDC,
			ENET_PHY_MDIO			=> ENET_PHY_MDIO,
			ENET_PHY_INT_N			=> ENET_PHY_INT_N,
			MEM0_WE_N				=> MEM0_WE_N,
			MEM0_RAS_N				=> MEM0_RAS_N,
			MEM0_CAS_N				=> MEM0_CAS_N,
			MEM0_DQ					=> MEM0_DQ,
			MEM0_CS_N				=> MEM0_CS_N,
			MEM0_CKE					=> MEM0_CKE,
			MEM0_ODT					=> MEM0_ODT,
			MEM0_CK_N				=> MEM0_CK_N,
			MEM0_CK					=> MEM0_CK,
			MEM0_BA					=> MEM0_BA,
			MEM0_A					=> MEM0_A,
			MEM0_DQS_P				=> MEM0_DQS_P,
			MEM0_DQS_N				=> MEM0_DQS_N,
			MEM0_UDM					=> MEM0_UDM,
			MEM0_LDM_RDQS_P		=> MEM0_LDM_RDQS_P,
			OCT_RDN0					=> OCT_RDN0,
			OCT_RUP0  				=> OCT_RUP0,
			MEM1_WE_N				=> MEM1_WE_N,
			MEM1_RAS_N				=> MEM1_RAS_N,
			MEM1_CAS_N				=> MEM1_CAS_N,
			MEM1_DQ					=> MEM1_DQ,
			MEM1_CS_N				=> MEM1_CS_N,
			MEM1_CKE					=> MEM1_CKE,
			MEM1_ODT					=> MEM1_ODT,
			MEM1_CK_N				=> MEM1_CK_N,
			MEM1_CK					=> MEM1_CK,
			MEM1_BA					=> MEM1_BA,
			MEM1_A					=> MEM1_A,
			MEM1_DQS_P				=> MEM1_DQS_P,
			MEM1_DQS_N				=> MEM1_DQS_N,
			MEM1_UDM					=> MEM1_UDM,
			MEM1_LDM_RDQS_P		=> MEM1_LDM_RDQS_P,
-- 			OCT_RDN1					=> OCT_RDN1,
-- 			OCT_RUP1 				=> OCT_RUP1,
			CONFIG_CLK				=> CONFIG_CLK,
			CONFIG_NRST				=> CONFIG_NRST,
			CONFIG_ADDR				=> CONFIG_ADDR,
			CONFIG_DATA				=> CONFIG_DATA,
			CONFIG_NADV				=> CONFIG_NADV,
			CONFIG_NCE				=> CONFIG_NCE,
			CONFIG_NOE				=> CONFIG_NOE,
			CONFIG_NWE				=> CONFIG_NWE,
			CONFIG_WAIT				=> CONFIG_WAIT,
			CODE_CLK					=> CODE_CLK,
			CODE_NRST				=> CODE_NRST,
			CODE_ADDR				=> CODE_ADDR,
			CODE_DATA				=> CODE_DATA,
			CODE_NADV				=> CODE_NADV,
			CODE_NCE					=> CODE_NCE,
			CODE_NOE					=> CODE_NOE,
			CODE_NWE					=> CODE_NWE,
			CODE_WAIT				=> CODE_WAIT,
			FLASH_IMAGE				=> FLASH_IMAGE,
			FLASH_ACCESS_REQUEST	=> FLASH_ACCESS_REQUEST,
			FLASH_ACCESS_GRANTED	=> FLASH_ACCESS_GRANTED,
			FLASH_nRECONFIG		=> FLASH_nRECONFIG,
			BUS_CLK					=> BUS_CLK,
			BUS_RESET				=> BUS_RESET,
			BUS_DIN					=> BUS_DIN,
			BUS_DOUT					=> BUS_DOUT,
			BUS_WR					=> BUS_WR,
			BUS_RD					=> BUS_RD,
			BUS_ACK					=> BUS_ACK,
			BUS_ADDR					=> BUS_ADDR,
			BUS_IRQ					=> BUS_IRQ
		);

end synthesis;
