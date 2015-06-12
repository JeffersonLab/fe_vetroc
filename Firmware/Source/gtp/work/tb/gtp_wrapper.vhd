library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity gtp_wrapper is
	generic(
		GTX_QUICKSIM			: boolean := false
	);
	port(
		-- Trigger Interface
		GLOBAL_CLK		: in std_logic;
		SYNC				: in std_logic;
		TRIG				: in std_logic;

		-- VME Bus Interface
		VMEBUS_DS_N		: in std_logic_vector(1 downto 0);
		VMEBUS_AS_N		: in std_logic;
		VMEBUS_W_N		: in std_logic;
		VMEBUS_AM		: in std_logic_vector(5 downto 0);
		VMEBUS_D			: inout std_logic_vector(31 downto 0);
		VMEBUS_A			: inout std_logic_vector(31 downto 0);
		VMEBUS_BERR_N	: inout std_logic;
		VMEBUS_DTACK_N	: inout std_logic;
		
		-- GTP Signals
		PP1_RX			: in std_logic_vector(0 to 1);
		PP1_TX			: out std_logic_vector(0 to 1);
		PP2_RX			: in std_logic_vector(0 to 1);
		PP2_TX			: out std_logic_vector(0 to 1);
		PP3_RX			: in std_logic_vector(0 to 1);
		PP3_TX			: out std_logic_vector(0 to 1);
		PP4_RX			: in std_logic_vector(0 to 1);
		PP4_TX			: out std_logic_vector(0 to 1);
		PP5_RX			: in std_logic_vector(0 to 1);
		PP5_TX			: out std_logic_vector(0 to 1);
		PP6_RX			: in std_logic_vector(0 to 1);
		PP6_TX			: out std_logic_vector(0 to 1);
		PP7_RX			: in std_logic_vector(0 to 1);
		PP7_TX			: out std_logic_vector(0 to 1);
		PP8_RX			: in std_logic_vector(0 to 1);
		PP8_TX			: out std_logic_vector(0 to 1);
		PP9_RX			: in std_logic_vector(0 to 1);
		PP9_TX			: out std_logic_vector(0 to 1);
		PP10_RX			: in std_logic_vector(0 to 1);
		PP10_TX			: out std_logic_vector(0 to 1);
		PP11_RX			: in std_logic_vector(0 to 1);
		PP11_TX			: out std_logic_vector(0 to 1);
		PP12_RX			: in std_logic_vector(0 to 1);
		PP12_TX			: out std_logic_vector(0 to 1);
		PP13_RX			: in std_logic_vector(0 to 1);
		PP13_TX			: out std_logic_vector(0 to 1);
		PP14_RX			: in std_logic_vector(0 to 1);
		PP14_TX			: out std_logic_vector(0 to 1);
		PP15_RX			: in std_logic_vector(0 to 1);
		PP15_TX			: out std_logic_vector(0 to 1);
		PP16_RX			: in std_logic_vector(0 to 1);
		PP16_TX			: out std_logic_vector(0 to 1);

		--Fiber Transceiver
		FIBER_RX			: in std_logic_vector(0 to 3);
		FIBER_TX			: out std_logic_vector(0 to 3)
	);
end gtp_wrapper;

architecture testbench of gtp_wrapper is

	component gtp is
		generic(
			SIM_GTXRESET_SPEEDUP	: integer := 0;
			GTX_QUICKSIM			: boolean := false
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
			TI_SCL					: IN STD_LOGIC;
			TI_SDA					: INOUT STD_LOGIC;
			TI_SDA_OE				: OUT STD_LOGIC;
			
			--Trigger Out, LVDS
			TRIG_OUT					: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--SD Control
			SD_SYNC					: IN STD_LOGIC;
			SD_TRIG					: IN STD_LOGIC_VECTOR(2 DOWNTO 1);
			
			--TI Control
			TI_GTP_RX				: IN STD_LOGIC;
			TI_GTP_TX				: OUT STD_LOGIC;
			TI_BUSY					: OUT STD_LOGIC;
			
			--Front Panel LEDs
			LED_AMBER				: OUT STD_LOGIC;
			LED_RED					: OUT STD_LOGIC;
			
			FP_OUT					: out std_logic_vector(3 downto 0);
			FP_IN						: in std_logic_vector(3 downto 0)
		);
	end component;

	signal CLK25_B						: STD_LOGIC := '0';
	signal CLK25_R						: STD_LOGIC := '0';
	signal CLK250_B					: STD_LOGIC := '0';
	signal CLK250_L					: STD_LOGIC := '0';
	signal CLK250_R					: STD_LOGIC := '0';
	signal CLK250_T					: STD_LOGIC := '0';
	signal CPLD_CLK					: STD_LOGIC := '0';
	signal PAYLOAD_RX2				: STD_LOGIC_VECTOR(0 TO 15) := (others=>'0');
	signal PAYLOAD_RX3				: STD_LOGIC_VECTOR(0 TO 15) := (others=>'0');
	signal PAYLOAD_TX2				: STD_LOGIC_VECTOR(0 TO 15) := (others=>'0');
	signal PAYLOAD_TX3				: STD_LOGIC_VECTOR(0 TO 15) := (others=>'0');
	signal ENET_RX						: STD_LOGIC := '0';
	signal ENET_TX						: STD_LOGIC := '0';
	signal ENET_TXn					: STD_LOGIC := '0';
	signal RGMII_TXD					: STD_LOGIC_VECTOR(3 DOWNTO 0) := (others=>'0');
	signal RGMII_TXC					: STD_LOGIC := '0';
	signal RGMII_TX_CTL				: STD_LOGIC := '0';
	signal RGMII_RXD					: STD_LOGIC_VECTOR(3 DOWNTO 0) := (others=>'0');
	signal RGMII_RXC					: STD_LOGIC := '0';
	signal RGMII_RX_CTL				: STD_LOGIC := '0';
	signal ENET_PHY_RESET_N			: STD_LOGIC := '0';
	signal ENET_PHY_MDC				: STD_LOGIC := '0';
	signal ENET_PHY_MDIO				: STD_LOGIC := '0';
	signal ENET_PHY_INT_N			: STD_LOGIC := '0';
	signal MEM0_WE_N					: STD_LOGIC := '0';
	signal MEM0_RAS_N					: STD_LOGIC := '0';
	signal MEM0_CAS_N					: STD_LOGIC := '0';
	signal MEM0_DQ						: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
	signal MEM0_CS_N					: STD_LOGIC := '0';
	signal MEM0_CKE					: STD_LOGIC := '0';
	signal MEM0_ODT					: STD_LOGIC := '0';
	signal MEM0_CK_N					: STD_LOGIC := '0';
	signal MEM0_CK						: STD_LOGIC := '0';
	signal MEM0_BA						: STD_LOGIC_VECTOR(2 DOWNTO 0) := (others=>'0');
	signal MEM0_A						: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
	signal MEM0_DQS_P					: STD_LOGIC_VECTOR(1 DOWNTO 0) := (others=>'0');
	signal MEM0_DQS_N					: STD_LOGIC_VECTOR(1 DOWNTO 0) := (others=>'0');
	signal MEM0_UDM					: STD_LOGIC := '0';
	signal MEM0_LDM_RDQS_P			: STD_LOGIC := '0';
--	signal MEM0_NC_RDQS_N			: STD_LOGIC := '0';										--RDQS not supported
	signal OCT_RDN0					: STD_LOGIC := '0';
	signal OCT_RUP0  					: STD_LOGIC := '0';
	signal MEM1_WE_N					: STD_LOGIC := '0';
	signal MEM1_RAS_N					: STD_LOGIC := '0';
	signal MEM1_CAS_N					: STD_LOGIC := '0';
	signal MEM1_DQ						: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
	signal MEM1_CS_N					: STD_LOGIC := '0';
	signal MEM1_CKE					: STD_LOGIC := '0';
	signal MEM1_ODT					: STD_LOGIC := '0';
	signal MEM1_CK_N					: STD_LOGIC := '0';
	signal MEM1_CK						: STD_LOGIC := '0';
	signal MEM1_BA						: STD_LOGIC_VECTOR(2 DOWNTO 0) := (others=>'0');
	signal MEM1_A						: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
	signal MEM1_DQS_P					: STD_LOGIC_VECTOR(1 DOWNTO 0) := (others=>'0');
	signal MEM1_DQS_N					: STD_LOGIC_VECTOR(1 DOWNTO 0) := (others=>'0');
	signal MEM1_UDM					: STD_LOGIC := '0';
	signal MEM1_LDM_RDQS_P			: STD_LOGIC := '0';
--	signal MEM1_NC_RDQS_N			: STD_LOGIC := '0';										--RDQS not supported
--	signal OCT_RDN1					: STD_LOGIC := '0';
--	signal OCT_RUP1  					: STD_LOGIC := '0';
	signal CONFIG_CLK					: STD_LOGIC := '0';
	signal CONFIG_NRST				: STD_LOGIC := '0';
	signal CONFIG_ADDR				: STD_LOGIC_VECTOR(26 DOWNTO 1) := (others=>'0');
	signal CONFIG_DATA				: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
	signal CONFIG_NADV				: STD_LOGIC := '0';
	signal CONFIG_NCE					: STD_LOGIC := '0';
	signal CONFIG_NOE					: STD_LOGIC := '0';
	signal CONFIG_NWE					: STD_LOGIC := '0';
	signal CONFIG_WAIT				: STD_LOGIC := '0';
	signal CODE_CLK					: STD_LOGIC := '0';
	signal CODE_NRST					: STD_LOGIC := '0';
	signal CODE_ADDR					: STD_LOGIC_VECTOR(26 DOWNTO 1) := (others=>'0');
	signal CODE_DATA					: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
	signal CODE_NADV					: STD_LOGIC := '0';
	signal CODE_NCE					: STD_LOGIC := '0';
	signal CODE_NOE					: STD_LOGIC := '0';
	signal CODE_NWE					: STD_LOGIC := '0';
	signal CODE_WAIT					: STD_LOGIC := '0';
	signal FLASH_IMAGE				: STD_LOGIC_VECTOR(2 DOWNTO 0) := (others=>'0');
	signal FLASH_ACCESS_REQUEST	: STD_LOGIC := '0';
	signal FLASH_ACCESS_GRANTED	: STD_LOGIC := '0';
	signal FLASH_nRECONFIG			: STD_LOGIC := '0';
	signal CPLD_FPGA_GPIO			: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
--	signal DATA							: STD_LOGIC_VECTOR(7 DOWNTO 0) := (others=>'0');
--	signal INIT_DONE					: STD_LOGIC := '0';
--	signal CRC_ERROR					: STD_LOGIC := '0';
	signal PP_BUSY						: STD_LOGIC_VECTOR(16 DOWNTO 1) := (others=>'0');
	signal PP_LINKUP					: STD_LOGIC_VECTOR(16 DOWNTO 1) := (others=>'0');
	signal BUSY_DIR					: STD_LOGIC := '0';
	signal LINKUP_DIR					: STD_LOGIC := '0';
	signal PP17_SCL					: STD_LOGIC := '0';
	signal PP17_SDA					: STD_LOGIC := '0';
	signal PP17_SDA_OE				: STD_LOGIC := '0';
	signal TI_SCL						: STD_LOGIC := '0';
	signal TI_SDA						: STD_LOGIC := '0';
	signal TI_SDA_OE					: STD_LOGIC := '0';
	signal TRIG_OUT					: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others=>'0');
	signal SD_SYNC						: STD_LOGIC := '0';
	signal SD_TRIG						: STD_LOGIC_VECTOR(2 DOWNTO 1) := (others=>'0');
	signal TI_GTP_RX					: STD_LOGIC := '0';
	signal TI_GTP_TX					: STD_LOGIC := '0';
	signal TI_BUSY						: STD_LOGIC := '0';
	signal LED_AMBER					: STD_LOGIC := '0';
	signal LED_RED						: STD_LOGIC := '0';
	signal FP_OUT						: std_logic_vector(3 downto 0);
	signal FP_IN						: std_logic_vector(3 downto 0);

	-- Signal Spy Mirrors
	signal BUS_RESET					: std_logic;
	signal BUS_DIN						: std_logic_vector(31 downto 0);
	signal BUS_DOUT					: std_logic_vector(31 downto 0);
	signal BUS_WR						: std_logic;
	signal BUS_RD						: std_logic;
	signal BUS_ACK						: std_logic;
	signal BUS_ADDR					: std_logic_vector(15 downto 0);
begin
	------------------------------------------
	-- GTP Components
	------------------------------------------

	gtp_inst: gtp
		generic map(
			SIM_GTXRESET_SPEEDUP	=> 1,
			GTX_QUICKSIM			=> GTX_QUICKSIM
		)
		port map(
			CLK25_B					=> CLK25_B,
			CLK25_R					=> CLK25_R,
			CLK250_B					=> CLK250_B,
			CLK250_L					=> CLK250_L,
			CLK250_R					=> CLK250_R,
			CLK250_T					=> CLK250_T,
			CPLD_CLK					=> CPLD_CLK,
			PAYLOAD_RX2				=> PAYLOAD_RX2,
			PAYLOAD_RX3				=> PAYLOAD_RX3,
			PAYLOAD_TX2				=> PAYLOAD_TX2,
			PAYLOAD_TX3				=> PAYLOAD_TX3,
			FIBER_RX					=> FIBER_RX,
			FIBER_TX					=> FIBER_TX,
			ENET_RX					=> ENET_RX,
			ENET_TX					=> ENET_TX,
			ENET_TXn					=> ENET_TXn,
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
		--	MEM0_NC_RDQS_N			=> MEM0_NC_RDQS_N,
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
		--	MEM1_NC_RDQS_N			=> MEM1_NC_RDQS_N,
		--	OCT_RDN1					=> OCT_RDN1,
		--	OCT_RUP1  				=> OCT_RUP1,
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
			CPLD_FPGA_GPIO			=> CPLD_FPGA_GPIO,
		--	DATA						=> DATA,
		--	INIT_DONE				=> INIT_DONE,
		--	CRC_ERROR				=> CRC_ERROR,
			PP_BUSY					=> PP_BUSY,
			PP_LINKUP				=> PP_LINKUP,
			BUSY_DIR					=> BUSY_DIR,
			LINKUP_DIR				=> LINKUP_DIR,
			PP17_SCL					=> PP17_SCL,
			PP17_SDA					=> PP17_SDA,
			PP17_SDA_OE				=> PP17_SDA_OE,
			TI_SCL					=> TI_SCL,
			TI_SDA					=> TI_SDA,
			TI_SDA_OE				=> TI_SDA_OE,
			TRIG_OUT					=> TRIG_OUT,
			SD_SYNC					=> SD_SYNC,
			SD_TRIG					=> SD_TRIG,
			TI_GTP_RX				=> TI_GTP_RX,
			TI_GTP_TX				=> TI_GTP_TX,
			TI_BUSY					=> TI_BUSY,
			LED_AMBER				=> LED_AMBER,
			LED_RED					=> LED_RED,
			FP_OUT					=> FP_OUT,
			FP_IN						=> FP_IN
		);

	TI_SCL <= '1';
	TI_SDA <= '1';

	------------------------------------------
	-- Global
	------------------------------------------

	CLK250_B <= GLOBAL_CLK;
	CLK250_L <= GLOBAL_CLK;
	CLK250_R <= GLOBAL_CLK;
	CLK250_T <= GLOBAL_CLK;

	SD_SYNC <= SYNC;
	SD_TRIG(1) <= TRIG;
	SD_TRIG(2) <= '0';

	FP_IN <= (others=>'0');

	process
	begin
		CLK25_B <= '0';
		CLK25_R <= '0';
		wait for 20.001 ns;
		CLK25_B <= '1';
		CLK25_R <= '1';
		wait for 20.001 ns;
	end process;

	PAYLOAD_RX2(0) <= PP1_RX(0);		PAYLOAD_RX3(0) <= PP1_RX(1);
	PAYLOAD_RX2(1) <= PP2_RX(0);		PAYLOAD_RX3(1) <= PP2_RX(1);
	PAYLOAD_RX2(2) <= PP3_RX(0);		PAYLOAD_RX3(2) <= PP3_RX(1);
	PAYLOAD_RX2(3) <= PP4_RX(0);		PAYLOAD_RX3(3) <= PP4_RX(1);
	PAYLOAD_RX2(4) <= PP5_RX(0);		PAYLOAD_RX3(4) <= PP5_RX(1);
	PAYLOAD_RX2(5) <= PP6_RX(0);		PAYLOAD_RX3(5) <= PP6_RX(1);
	PAYLOAD_RX2(6) <= PP7_RX(0);		PAYLOAD_RX3(6) <= PP7_RX(1);
	PAYLOAD_RX2(7) <= PP8_RX(0);		PAYLOAD_RX3(7) <= PP8_RX(1);
	PAYLOAD_RX2(8) <= PP9_RX(0);		PAYLOAD_RX3(8) <= PP9_RX(1);
	PAYLOAD_RX2(9) <= PP10_RX(0);		PAYLOAD_RX3(9) <= PP10_RX(1);
	PAYLOAD_RX2(10) <= PP11_RX(0);	PAYLOAD_RX3(10) <= PP11_RX(1);
	PAYLOAD_RX2(11) <= PP12_RX(0);	PAYLOAD_RX3(11) <= PP12_RX(1);
	PAYLOAD_RX2(12) <= PP13_RX(0);	PAYLOAD_RX3(12) <= PP13_RX(1);
	PAYLOAD_RX2(13) <= PP14_RX(0);	PAYLOAD_RX3(13) <= PP14_RX(1);
	PAYLOAD_RX2(14) <= PP15_RX(0);	PAYLOAD_RX3(14) <= PP15_RX(1);
	PAYLOAD_RX2(15) <= PP16_RX(0);	PAYLOAD_RX3(15) <= PP16_RX(1);

	PP1_TX(0) <= PAYLOAD_TX2(0);		PP1_TX(1) <= PAYLOAD_TX3(0);
	PP2_TX(0) <= PAYLOAD_TX2(1);		PP2_TX(1) <= PAYLOAD_TX3(1);
	PP3_TX(0) <= PAYLOAD_TX2(2);		PP3_TX(1) <= PAYLOAD_TX3(2);
	PP4_TX(0) <= PAYLOAD_TX2(3);		PP4_TX(1) <= PAYLOAD_TX3(3);
	PP5_TX(0) <= PAYLOAD_TX2(4);		PP5_TX(1) <= PAYLOAD_TX3(4);
	PP6_TX(0) <= PAYLOAD_TX2(5);		PP6_TX(1) <= PAYLOAD_TX3(5);
	PP7_TX(0) <= PAYLOAD_TX2(6);		PP7_TX(1) <= PAYLOAD_TX3(6);
	PP8_TX(0) <= PAYLOAD_TX2(7);		PP8_TX(1) <= PAYLOAD_TX3(7);
	PP9_TX(0) <= PAYLOAD_TX2(8);		PP9_TX(1) <= PAYLOAD_TX3(8);
	PP10_TX(0) <= PAYLOAD_TX2(9);		PP10_TX(1) <= PAYLOAD_TX3(9);
	PP11_TX(0) <= PAYLOAD_TX2(10);	PP11_TX(1) <= PAYLOAD_TX3(10);
	PP12_TX(0) <= PAYLOAD_TX2(11);	PP12_TX(1) <= PAYLOAD_TX3(11);
	PP13_TX(0) <= PAYLOAD_TX2(12);	PP13_TX(1) <= PAYLOAD_TX3(12);
	PP14_TX(0) <= PAYLOAD_TX2(13);	PP14_TX(1) <= PAYLOAD_TX3(13);
	PP15_TX(0) <= PAYLOAD_TX2(14);	PP15_TX(1) <= PAYLOAD_TX3(14);
	PP16_TX(0) <= PAYLOAD_TX2(15);	PP16_TX(1) <= PAYLOAD_TX3(15);

 	process
 	begin
		-- monitored in tb
 		init_signal_spy("gtp_inst/nios_wrapper_inst/BUS_DOUT","BUS_DOUT", 1);
 		init_signal_spy("gtp_inst/nios_wrapper_inst/BUS_ACK","BUS_ACK", 1);

		init_signal_driver("BUS_RESET", "gtp_inst/nios_wrapper_inst/BUS_RESET_i");
		init_signal_driver("BUS_DIN", "gtp_inst/nios_wrapper_inst/BUS_DIN");
		init_signal_driver("BUS_WR", "gtp_inst/nios_wrapper_inst/BUS_WR");
		init_signal_driver("BUS_RD", "gtp_inst/nios_wrapper_inst/BUS_RD");
		init_signal_driver("BUS_ADDR", "gtp_inst/nios_wrapper_inst/BUS_ADDR");

 		wait;
 	end process;

	process
		procedure WriteReg(
				addr : in std_logic_vector(15 downto 0);
				data : in std_logic_vector(31 downto 0)
			) is
		begin
			BUS_ADDR <= addr;
			BUS_DIN <= data;
			wait for 40 ns;
			BUS_WR <= '1';
			wait for 40 ns;
			BUS_WR <= '0';
		end WriteReg;

		procedure ReadReg(
				addr : in std_logic_vector(15 downto 0);
				signal data : out std_logic_vector(31 downto 0)
			) is
		begin
			BUS_ADDR <= addr;
			wait for 40 ns;
			BUS_RD <= '1';
			wait for 40 ns;
			data <= BUS_DOUT;
			wait for 10 ns;
			BUS_RD <= '0';
		end ReadReg;
	begin
		BUS_RESET <= '1';
		BUS_DIN <= (others=>'0');
		BUS_WR <= '0';
		BUS_RD <= '0';
		BUS_ADDR <= (others=>'0');

		VMEBUS_D <= (others=>'H');
		VMEBUS_A <= (others=>'H');
		VMEBUS_BERR_N <= 'H';
		VMEBUS_DTACK_N <= 'H';

		wait for 1 us;
		BUS_RESET <= '0';

		while true loop
			wait until falling_edge(VMEBUS_AS_N);

			if VMEBUS_A(31 downto 16) = x"0000" then
				if VMEBUS_W_N = '1' then
					ReadReg(VMEBUS_A(15 downto 0), VMEBUS_D);
				else
					WriteReg(VMEBUS_A(15 downto 0), VMEBUS_D);
				end if;
				VMEBUS_DTACK_N <= '0';
			end if;

			wait until to_X01(VMEBUS_AS_N) = '1';
			VMEBUS_D <= (others=>'H');
			VMEBUS_DTACK_N <= 'H';
		end loop;

	end process;

end testbench;
