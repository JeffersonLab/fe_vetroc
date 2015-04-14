library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.perbus_pkg.all;

entity clkrst_per is
	generic(
		ADDR_INFO				: PER_ADDR_INFO
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		CLK125F_P				: in std_logic;
		CLK125F_N				: in std_logic;
		
		CLKPRGC					: in std_logic;

		PCLKLOAD					: out std_logic;
		PCLKOUT1					: out std_logic;
		PCLKOUT2					: out std_logic;
		PCLKSIN1					: out std_logic;
		PCLKSIN2					: out std_logic;
		PCSWCFG					: out std_logic;

		-- Generated Clocks
		SYSCLK_50_RESET		: out std_logic;
		SYSCLK_50				: out std_logic;
		SYSCLK_125				: out std_logic;

		GCLK_125_RESET			: out std_logic;
		GCLK_125					: out std_logic;
		GCLK_250					: out std_logic;
		GCLK_500					: out std_logic;

		-- Flash Memory
		PMEMCE_N					: out std_logic;
		PMEMD0					: inout std_logic;
		PMEMD1					: inout std_logic;
		PMEMD2					: inout std_logic;
		PMEMD3					: inout std_logic;

		BUS_RESET_SOFT_OUT	: out std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_CLK					: in std_logic;
		BUS_RESET				: in std_logic;
		BUS_RESET_SOFT			: in std_logic;
		BUS_DIN					: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT					: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR					: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR					: in std_logic;
		BUS_RD					: in std_logic;
		BUS_ACK					: out std_logic
	);
end clkrst_per;

architecture synthesis of clkrst_per is
	component sysclkpll is
		port(
			CLK_33MHZ			: in std_logic;
			
			SYSCLK_50_RESET	: out std_logic;
			SYSCLK_50			: out std_logic;
			SYSCLK_125			: out std_logic
		);
	end component;

	component gclkpll is
		port(
			GCLK_125_REF_RST	: in std_logic;
			CLK125F_P			: in std_logic;
			CLK125F_N			: in std_logic;
			
			GCLK_125_RESET		: out std_logic;
			GCLK_125				: out std_logic;
			GCLK_250				: out std_logic;
			GCLK_500				: out std_logic;

			GCLK_PLLLOCKED		: out std_logic
		);
	end component;

	component clksel is
		port(
			CLK				: in std_logic;

			CLKSRC_RELOAD	: in std_logic;
			CLKSRC_GTPA		: in std_logic_vector(1 downto 0);
			CLKSRC_GTPB		: in std_logic_vector(1 downto 0);
			CLKSRC_FPGA		: in std_logic_vector(1 downto 0);
			CLKSRC_TD		: in std_logic_vector(1 downto 0);

			CLK_SOUT			: out std_logic_vector(1 downto 0);
			CLK_SIN			: out std_logic_vector(1 downto 0);
			CLK_LOAD			: out std_logic;
			CLK_CONF			: out std_logic
		);
	end component;

	component spiflash is
		port(
			CLK				: in std_logic;

			WR_DATA			: in std_logic_vector(7 downto 0);
			RD_DATA			: out std_logic_vector(7 downto 0);
			NCS_SET			: in std_logic;
			NCS_CLEAR		: in std_logic;
			START				: in std_logic;
			DONE				: out std_logic;

			CONFIGROM_D		: out std_logic;
			CONFIGROM_Q		: in std_logic;
			CONFIGROM_S_N	: out std_logic
		);
	end component;

	signal CLK_CTRL_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal CLK_STATUS_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal SPI_FLASH_CTRL_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal SPI_FLASH_STATUS_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal SOFT_RESET_REG			: std_logic_vector(31 downto 0) := x"00000000";

	signal PI							: pbus_if_i;
	signal PO							: pbus_if_o;

	signal WR_DATA						: std_logic_vector(7 downto 0);
	signal RD_DATA						: std_logic_vector(7 downto 0);
	signal NCS_SET						: std_logic;
	signal NCS_CLEAR					: std_logic;
	signal START						: std_logic;
	signal DONE							: std_logic;

	signal CLKSRC_GTPA				: std_logic_vector(1 downto 0);
	signal CLKSRC_GTPB				: std_logic_vector(1 downto 0);
	signal CLKSRC_FPGA				: std_logic_vector(1 downto 0);
	signal CLKSRC_TD					: std_logic_vector(1 downto 0);
	signal CLKSRC_RELOAD				: std_logic;
	signal GCLK_125_REF_RST			: std_logic;
	signal GCLK_PLLLOCKED			: std_logic;
begin

	sysclkpll_inst: sysclkpll
		port map(
			CLK_33MHZ			=> CLKPRGC,
			SYSCLK_50_RESET	=> SYSCLK_50_RESET,
			SYSCLK_50			=> SYSCLK_50,
			SYSCLK_125			=> SYSCLK_125
		);

	gclkpll_inst: gclkpll
		port map(
			GCLK_125_REF_RST	=> GCLK_125_REF_RST,
			CLK125F_P			=> CLK125F_P,
			CLK125F_N			=> CLK125F_N,
			GCLK_125_RESET		=> GCLK_125_RESET,
			GCLK_125				=> GCLK_125,
			GCLK_250				=> GCLK_250,
			GCLK_500				=> GCLK_500
		);

	clksel_inst: clksel
		port map(
			CLK				=> BUS_CLK,
			CLKSRC_RELOAD	=> CLKSRC_RELOAD,
			CLKSRC_GTPA		=> CLKSRC_GTPA,
			CLKSRC_GTPB		=> CLKSRC_GTPB,
			CLKSRC_FPGA		=> CLKSRC_FPGA,
			CLKSRC_TD		=> CLKSRC_TD,
			CLK_SOUT(0)		=> PCLKOUT1,
			CLK_SOUT(1)		=> PCLKOUT2,
			CLK_SIN(0)		=> PCLKSIN1,
			CLK_SIN(1)		=> PCLKSIN2,
			CLK_LOAD			=> PCLKLOAD,
			CLK_CONF			=> PCSWCFG
		);

	spiflash_inst: spiflash
		port map(
			CLK				=> BUS_CLK,
			WR_DATA			=> WR_DATA,
			RD_DATA			=> RD_DATA,
			NCS_SET			=> NCS_SET,
			NCS_CLEAR		=> NCS_CLEAR,
			START				=> START,
			DONE				=> DONE,
			CONFIGROM_D		=> PMEMD0,
			CONFIGROM_Q		=> PMEMD1,
			CONFIGROM_S_N	=> PMEMCE_N
		);

	PMEMD0 <= 'Z';
	PMEMD2 <= '1';
	PMEMD3 <= '1';

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

	--SPI_FLASH_CTRL_REG
	WR_DATA <= SPI_FLASH_CTRL_REG(7 downto 0);
	NCS_SET <= SPI_FLASH_CTRL_REG(8);
	NCS_CLEAR <= SPI_FLASH_CTRL_REG(9);
	START <= SPI_FLASH_CTRL_REG(10);

	--SPI_FLASH_STATUS_REG
	SPI_FLASH_STATUS_REG(7 downto 0) <= RD_DATA;
	SPI_FLASH_STATUS_REG(10 downto 8) <= (others=>'0');
	SPI_FLASH_STATUS_REG(11) <= DONE;
	SPI_FLASH_STATUS_REG(31 downto 12) <= (others=>'0');

	--CLK_CTRL_REG
	CLKSRC_GTPA <= CLK_CTRL_REG(23 downto 22);
	CLKSRC_GTPB <= CLK_CTRL_REG(25 downto 24);
	CLKSRC_FPGA <= CLK_CTRL_REG(27 downto 26);
	CLKSRC_TD <= CLK_CTRL_REG(29 downto 28);
	GCLK_125_REF_RST <= CLK_CTRL_REG(31);

	--CLK_STATUS_REG
	CLK_STATUS_REG(16 downto 0) <= (others=>'0');
	CLK_STATUS_REG(17) <= GCLK_PLLLOCKED;
	CLK_STATUS_REG(31 downto 18) <= (others=>'0');

	--SOFT_RESET_REG
	BUS_RESET_SOFT_OUT <= SOFT_RESET_REG(0);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';

			rw_reg_ack(	REG => CLK_CTRL_REG				,PI=>PI,PO=>PO, A => x"0000", RW => x"BFC00000", I => x"80000000", ACK => CLKSRC_RELOAD);
			ro_reg(		REG => CLK_STATUS_REG			,PI=>PI,PO=>PO, A => x"0004", RO => x"00020000");
			rw_reg(		REG => SPI_FLASH_CTRL_REG		,PI=>PI,PO=>PO, A => x"0008", RW => x"000007FF", I => x"00000100", R => x"00000700");
			ro_reg(		REG => SPI_FLASH_STATUS_REG	,PI=>PI,PO=>PO, A => x"000C", RO => x"000008FF");
			rw_reg(		REG => SOFT_RESET_REG			,PI=>PI,PO=>PO, A => x"0010", RW => x"00000001", I => x"00000001");
		end if;
	end process;

end synthesis;
