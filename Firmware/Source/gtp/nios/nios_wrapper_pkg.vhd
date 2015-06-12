library ieee;
use ieee.std_logic_1164.all;

package nios_wrapper_pkg is

	component nios_wrapper is
		port(
			-- Clock inputs
			CLK250_T					: in std_logic;

			SYSCLK_LOCKED			: in std_logic;
			SYSCLK_250				: in std_logic;
			SYSCLK_CPU				: in std_logic;
			SYSCLK_PER				: in std_logic;

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
-- 			OCT_RDN1					: IN STD_LOGIC;
-- 			OCT_RUP1  				: IN STD_LOGIC;
			
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
			
			BUS_CLK					: out std_logic;
			BUS_RESET				: out std_logic;
			BUS_DIN					: out std_logic_vector(31 downto 0);
			BUS_DOUT					: in std_logic_vector(31 downto 0);
			BUS_WR					: out std_logic;
			BUS_RD					: out std_logic;
			BUS_ACK					: in std_logic;
			BUS_ADDR					: out std_logic_vector(15 downto 0);
			BUS_IRQ					: in std_logic
		);
	end component;

end package;
