library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity nios_wrapper is
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
-- 		OCT_RDN1					: IN STD_LOGIC;
-- 		OCT_RUP1  				: IN STD_LOGIC;
		
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
end nios_wrapper;

architecture Synthesis of nios_wrapper is

	component sopc_system is
		port(
			clk_in_reset_reset_n          : in    std_logic                     := 'X';             -- reset_n
			clk_in_clk                    : in    std_logic                     := 'X';             -- clk
			ddr2_status_local_init_done   : out   std_logic;                                        -- local_init_done
			ddr2_status_local_cal_success : out   std_logic;                                        -- local_cal_success
			ddr2_status_local_cal_fail    : out   std_logic;                                        -- local_cal_fail
			ddr2_mem_mem_a                : out   std_logic_vector(12 downto 0);                    -- mem_a
			ddr2_mem_mem_ba               : out   std_logic_vector(2 downto 0);                     -- mem_ba
			ddr2_mem_mem_ck               : out   std_logic_vector(0 downto 0);                     -- mem_ck
			ddr2_mem_mem_ck_n             : out   std_logic_vector(0 downto 0);                     -- mem_ck_n
			ddr2_mem_mem_cke              : out   std_logic_vector(0 downto 0);                     -- mem_cke
			ddr2_mem_mem_cs_n             : out   std_logic_vector(0 downto 0);                     -- mem_cs_n
			ddr2_mem_mem_dm               : out   std_logic_vector(1 downto 0);                     -- mem_dm
			ddr2_mem_mem_ras_n            : out   std_logic_vector(0 downto 0);                     -- mem_ras_n
			ddr2_mem_mem_cas_n            : out   std_logic_vector(0 downto 0);                     -- mem_cas_n
			ddr2_mem_mem_we_n             : out   std_logic_vector(0 downto 0);                     -- mem_we_n
			ddr2_mem_mem_dq               : inout std_logic_vector(15 downto 0) := (others => 'X'); -- mem_dq
			ddr2_mem_mem_dqs              : inout std_logic_vector(1 downto 0)  := (others => 'X'); -- mem_dqs
			ddr2_mem_mem_dqs_n            : inout std_logic_vector(1 downto 0)  := (others => 'X'); -- mem_dqs_n
			ddr2_mem_mem_odt              : out   std_logic_vector(0 downto 0);                     -- mem_odt
			cfi_tcm_address_out           : out   std_logic_vector(26 downto 0);                    -- tcm_address_out
			cfi_tcm_outputenable_n_out    : out   std_logic_vector(0 downto 0);                     -- tcm_outputenable_n_out
			cfi_tcm_reset_n_out           : out   std_logic_vector(0 downto 0);                     -- tcm_reset_n_out
			cfi_tcm_write_n_out           : out   std_logic_vector(0 downto 0);                     -- tcm_write_n_out
			cfi_tcm_data_out              : inout std_logic_vector(15 downto 0) := (others => 'X'); -- tcm_data_out
			cfi_tcm_chipselect_n_out      : out   std_logic_vector(0 downto 0);                     -- tcm_chipselect_n_out
			ddr2_oct_rdn                  : in    std_logic                     := 'X';             -- rdn
			ddr2_oct_rup                  : in    std_logic                     := 'X';             -- rup
			gtpbus_CLK                    : out   std_logic;                                        -- CLK
			gtpbus_RESET                  : out   std_logic;                                        -- RESET
			gtpbus_DIN                    : out   std_logic_vector(31 downto 0);                    -- DIN
			gtpbus_DOUT                   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- DOUT
			gtpbus_WR                     : out   std_logic;                                        -- WR
			gtpbus_RD                     : out   std_logic;                                        -- RD
			gtpbus_ACK                    : in    std_logic                     := 'X';             -- ACK
			gtpbus_ADDR                   : out   std_logic_vector(15 downto 0);                    -- ADDR
			gtpbus_IRQ                    : in    std_logic                     := 'X';             -- IRQ
			tse_mdio_mdc                  : out   std_logic;                                        -- mdc
			tse_mdio_mdio_in              : in    std_logic                     := 'X';             -- mdio_in
			tse_mdio_mdio_out             : out   std_logic;                                        -- mdio_out
			tse_mdio_mdio_oen             : out   std_logic;                                        -- mdio_oen
			tse_rgmii_rgmii_in            : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rgmii_in
			tse_rgmii_rgmii_out           : out   std_logic_vector(3 downto 0);                     -- rgmii_out
			tse_rgmii_rx_control          : in    std_logic                     := 'X';             -- rx_control
			tse_rgmii_tx_control          : out   std_logic;                                        -- tx_control
			tse_status_set_10             : in    std_logic                     := 'X';             -- set_10
			tse_status_set_1000           : in    std_logic                     := 'X';             -- set_1000
			tse_status_eth_mode           : out   std_logic;                                        -- eth_mode
			tse_status_ena_10             : out   std_logic;                                        -- ena_10
			tse_txclk_clk                 : in    std_logic                     := 'X';             -- clk
			tse_rxclk_clk                 : in    std_logic                     := 'X';             -- clk
			cfi_fpga_tcm_address_out        : out   std_logic_vector(26 downto 0);                    -- tcm_address_out
			cfi_fpga_tcm_outputenable_n_out : out   std_logic_vector(0 downto 0);                     -- tcm_outputenable_n_out
			cfi_fpga_tcm_reset_n_out        : out   std_logic_vector(0 downto 0);                     -- tcm_reset_n_out
			cfi_fpga_tcm_write_n_out        : out   std_logic_vector(0 downto 0);                     -- tcm_write_n_out
			cfi_fpga_tcm_data_out           : inout std_logic_vector(15 downto 0) := (others => 'X'); -- tcm_data_out
			cfi_fpga_tcm_chipselect_n_out   : out   std_logic_vector(0 downto 0);                     -- tcm_chipselect_n_out
			tse_misc_xon_gen                : in    std_logic                     := 'X';             -- xon_gen
			tse_misc_xoff_gen               : in    std_logic                     := 'X';             -- xoff_gen
			tse_misc_magic_wakeup           : out   std_logic;                                        -- magic_wakeup
			tse_misc_magic_sleep_n          : in    std_logic                     := 'X';             -- magic_sleep_n
			tse_misc_ff_tx_crc_fwd          : in    std_logic                     := 'X';             -- ff_tx_crc_fwd
			tse_misc_ff_tx_septy            : out   std_logic;                                        -- ff_tx_septy
			tse_misc_tx_ff_uflow            : out   std_logic;                                        -- tx_ff_uflow
			tse_misc_ff_tx_a_full           : out   std_logic;                                        -- ff_tx_a_full
			tse_misc_ff_tx_a_empty          : out   std_logic;                                        -- ff_tx_a_empty
			tse_misc_rx_err_stat            : out   std_logic_vector(17 downto 0);                    -- rx_err_stat
			tse_misc_rx_frm_type            : out   std_logic_vector(3 downto 0);                     -- rx_frm_type
			tse_misc_ff_rx_dsav             : out   std_logic;                                        -- ff_rx_dsav
			tse_misc_ff_rx_a_full           : out   std_logic;                                        -- ff_rx_a_full
			tse_misc_ff_rx_a_empty          : out   std_logic                                         -- ff_rx_a_empty
		);
	end component;

	component ephyclkctrl is
		port(
			inclk		: in std_logic;
			outclk	: out std_logic 
		);
	end component;

	signal CODE_ADDR_A0							: std_logic;
	signal CONFIG_ADDR_A0						: std_logic;

	signal tx_clk_to_the_tse_mac				: std_logic;
	signal ena_10_from_the_tse_mac			: std_logic;
	signal eth_mode_from_the_tse_mac			: std_logic;

	signal user_led_export						: std_logic_vector(7 downto 0);
	signal user_dipsw_export					: std_logic_vector(7 downto 0);
	signal user_pb_export						: std_logic_vector(3 downto 0);

	signal uart_ext_rxd							: std_logic;
	signal uart_ext_txd							: std_logic;
	
	signal mdio_out_from_the_tse_mac			: std_logic;
	signal mdio_oen_from_the_tse_mac			: std_logic;
	signal mdio_in_to_the_tse_mac				: std_logic;

 	signal reset_n_sreg							: std_logic_vector(7 downto 0) := (others=>'0');
 	signal reset_n									: std_logic;

	signal BUS_RESET_i							: std_logic;

	signal SYSCLK_250_CNT						: std_logic_vector(6 downto 0) := (others=>'0');
	signal SYSCLK_250_CNT_LIMIT				: std_logic_vector(6 downto 0) := (others=>'0');
	signal SYSCLK_250_CNT_DONE					: std_logic;
	signal ETH_CLK									: std_logic := '0';
begin

	BUS_RESET <= BUS_RESET_i;

	reset_n <= reset_n_sreg(0);
	
	process(CLK250_T)
	begin
		if rising_edge(CLK250_T) then
			reset_n_sreg <= SYSCLK_LOCKED & reset_n_sreg(reset_n_sreg'length-1 downto 1);
		end if;
	end process;

	sopc_system_inst: sopc_system
		port map(
			clk_in_reset_reset_n					=> reset_n,
			clk_in_clk								=> CLK250_T,
			ddr2_status_local_init_done		=> open,
			ddr2_status_local_cal_success		=> open,
			ddr2_status_local_cal_fail			=> open,
			ddr2_mem_mem_a							=> MEM0_A(12 downto 0),
			ddr2_mem_mem_ba						=> MEM0_BA,
			ddr2_mem_mem_ck(0)					=> MEM0_CK,
			ddr2_mem_mem_ck_n(0)					=> MEM0_CK_N,
			ddr2_mem_mem_cke(0)					=> MEM0_CKE,
			ddr2_mem_mem_cs_n(0)					=> MEM0_CS_N,
			ddr2_mem_mem_dm(0)					=> MEM0_LDM_RDQS_P,
			ddr2_mem_mem_dm(1)					=> MEM0_UDM,
			ddr2_mem_mem_ras_n(0)				=> MEM0_RAS_N,
			ddr2_mem_mem_cas_n(0)				=> MEM0_CAS_N,
			ddr2_mem_mem_we_n(0)					=> MEM0_WE_N,
			ddr2_mem_mem_dq						=> MEM0_DQ,
			ddr2_mem_mem_dqs						=> MEM0_DQS_P,
			ddr2_mem_mem_dqs_n					=> MEM0_DQS_N,
			ddr2_mem_mem_odt(0)					=> MEM0_ODT,
 			cfi_tcm_address_out(26 downto 1)	=> CODE_ADDR(26 downto 1),
 			cfi_tcm_address_out(0)				=> CODE_ADDR_A0,
 			cfi_tcm_outputenable_n_out(0)		=> CODE_NOE,
 			cfi_tcm_reset_n_out(0)				=> CODE_NRST,
 			cfi_tcm_write_n_out(0)				=> CODE_NWE,
 			cfi_tcm_data_out						=> CODE_DATA,
 			cfi_tcm_chipselect_n_out(0)		=> CODE_NCE,
			ddr2_oct_rdn							=> OCT_RDN0,
			ddr2_oct_rup							=> OCT_RUP0,
			gtpbus_CLK								=> BUS_CLK,
			gtpbus_RESET							=> BUS_RESET_i,
			gtpbus_DIN								=> BUS_DIN,
			gtpbus_DOUT								=> BUS_DOUT,
			gtpbus_WR								=> BUS_WR,
			gtpbus_RD								=> BUS_RD,
			gtpbus_ACK								=> BUS_ACK,
			gtpbus_ADDR								=> BUS_ADDR,
			gtpbus_IRQ								=> BUS_IRQ,
			tse_mdio_mdc							=> ENET_PHY_MDC,
			tse_mdio_mdio_in						=> mdio_in_to_the_tse_mac,
			tse_mdio_mdio_out						=> mdio_out_from_the_tse_mac,
			tse_mdio_mdio_oen						=> mdio_oen_from_the_tse_mac,
			tse_rgmii_rgmii_in					=> RGMII_RXD,
			tse_rgmii_rgmii_out					=> RGMII_TXD,
			tse_rgmii_rx_control					=> RGMII_RX_CTL,
			tse_rgmii_tx_control					=> RGMII_TX_CTL,
			tse_status_set_10						=> '0',
			tse_status_set_1000					=> '0',
			tse_status_eth_mode					=> eth_mode_from_the_tse_mac,
			tse_status_ena_10						=> ena_10_from_the_tse_mac,
			tse_txclk_clk							=> tx_clk_to_the_tse_mac,
			tse_rxclk_clk							=> RGMII_RXC,
			cfi_fpga_tcm_address_out(26 downto 1)	=> CONFIG_ADDR(26 downto 1),
			cfi_fpga_tcm_address_out(0)				=> CONFIG_ADDR_A0,
			cfi_fpga_tcm_outputenable_n_out(0)		=> CONFIG_NOE,
			cfi_fpga_tcm_reset_n_out(0)				=> CONFIG_NRST,
			cfi_fpga_tcm_write_n_out(0)				=> CONFIG_NWE,
			cfi_fpga_tcm_data_out						=> CONFIG_DATA,
			cfi_fpga_tcm_chipselect_n_out(0)			=> CONFIG_NCE,
			tse_misc_xon_gen						=> '0',
			tse_misc_xoff_gen						=> '0',
			tse_misc_magic_wakeup				=> open,
			tse_misc_magic_sleep_n				=> '1',
			tse_misc_ff_tx_crc_fwd				=> '0',
			tse_misc_ff_tx_septy					=> open,
			tse_misc_tx_ff_uflow					=> open,
			tse_misc_ff_tx_a_full				=> open,
			tse_misc_ff_tx_a_empty				=> open,
			tse_misc_rx_err_stat					=> open,
			tse_misc_rx_frm_type					=> open,
			tse_misc_ff_rx_dsav					=> open,
			tse_misc_ff_rx_a_full				=> open,
			tse_misc_ff_rx_a_empty				=> open
		);

	------------------------
	-- Ethernet Phy I/O
	------------------------

	SYSCLK_250_CNT_DONE <= '1' when SYSCLK_250_CNT >= SYSCLK_250_CNT_LIMIT else '0';

	process(SYSCLK_250)
	begin
		if rising_edge(SYSCLK_250) then
			if SYSCLK_250_CNT_DONE = '1' then
				SYSCLK_250_CNT <= (others=>'0');
			else
				SYSCLK_250_CNT <= SYSCLK_250_CNT + 1;
			end if;
		end if;
	end process;

	process(SYSCLK_250)
	begin
		if rising_edge(SYSCLK_250) then
			if eth_mode_from_the_tse_mac = '1' then
				SYSCLK_250_CNT_LIMIT <= conv_std_logic_vector(0, SYSCLK_250_CNT_LIMIT'length);
			elsif ena_10_from_the_tse_mac = '0' then
				SYSCLK_250_CNT_LIMIT <= conv_std_logic_vector(4, SYSCLK_250_CNT_LIMIT'length);
			else
				SYSCLK_250_CNT_LIMIT <= conv_std_logic_vector(49, SYSCLK_250_CNT_LIMIT'length);
			end if;
		end if;
	end process;

	process(SYSCLK_250)
	begin
		if rising_edge(SYSCLK_250) then
			if SYSCLK_250_CNT_DONE = '1' then
				ETH_CLK <= not ETH_CLK;
			end if;
		end if;
	end process;

	tx_clk_to_the_tse_mac <= ETH_CLK;

	altddio_out_inst: altddio_out
		generic map(
			extend_oe_disable			=> "off",
			intended_device_family	=> "stratix iv",
			invert_output				=> "off",
			lpm_hint						=> "unused",
			lpm_type						=> "altddio_out",
			oe_reg						=> "unregistered",
			power_up_high				=> "off",
			width							=> 1
		)
		port map(
			datain_h(0)	=> '1',
			datain_l(0)	=> '0',
			outclock		=> tx_clk_to_the_tse_mac,
			dataout(0)	=> RGMII_TXC
		);

	ENET_PHY_RESET_N <= not BUS_RESET_i;

	ENET_PHY_MDIO <= mdio_out_from_the_tse_mac when mdio_oen_from_the_tse_mac = '0' else 'Z';
	mdio_in_to_the_tse_mac <= ENET_PHY_MDIO;

	------------------------
	-- Unused SDRAM I/O
	------------------------
	MEM0_A(15 downto 13) <= "000";

	MEM1_WE_N <= '1';
	MEM1_RAS_N <= '1';
	MEM1_CAS_N <= '1';
	MEM1_DQ <= (others=>'Z');
	MEM1_CS_N <= '1';
	MEM1_CKE <= '0';
	MEM1_ODT <= '0';
	MEM1_CK_N <= '1';
	MEM1_CK <= '0';
	MEM1_BA <= "000";
	MEM1_A <= x"0000";
	MEM1_DQS_P <= (others=>'Z');
	MEM1_DQS_N <= (others=>'Z');
	MEM1_UDM <= '0';
	MEM1_LDM_RDQS_P <= '0';

	------------------------
	--CONFIGURATION FLASH
	------------------------
	CONFIG_CLK <= '0';
	CONFIG_NADV <= '0';
	--CONFIG_WAIT				: IN STD_LOGIC;

	------------------------
	--NIOS II CODE FLASH
	------------------------
	CODE_CLK <= '0';
	CODE_NADV <= '0';
	--CODE_WAIT				: IN STD_LOGIC;

	------------------------
	--Configuration Inteface to CPLD
	------------------------
	FLASH_IMAGE <= "000";
	FLASH_ACCESS_REQUEST <= '0';
	--FLASH_ACCESS_GRANTED	: IN STD_LOGIC;
	FLASH_nRECONFIG <= '1';

end Synthesis;
