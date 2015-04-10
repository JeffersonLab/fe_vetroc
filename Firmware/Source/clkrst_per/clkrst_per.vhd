library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.perbus_pkg.all;

entity richclkrst_per is
	generic(
		ADDR_INFO			: PER_ADDR_INFO
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		-- CLK_33MHZ is local always running 33MHz clock
		CLK_33MHZ			: in std_logic;
		
		-- SYSCLK_# derived from CLK_30MHZ local oscillator
		-- SYSCLK_RESET synchronous to SYSCLK_#
		SYSCLK_50_RESET	: out std_logic;
		SYSCLK_50			: out std_logic;

		SYSCLK_200_RESET	: out std_logic;
		SYSCLK_200			: out std_logic;

		GCLK_125_REF_RST	: in std_logic;
		GCLK_125_REF		: in std_logic;
		GCLK_125_RESET		: out std_logic;
		GCLK_125				: out std_logic;
		GCLK_250				: out std_logic;
		GCLK_500				: out std_logic;
		GCLK_500_180		: out std_logic;

		CONFIGROM_D			: out std_logic;
		CONFIGROM_Q			: in std_logic;
		CONFIGROM_S_N		: out std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_CLK				: in std_logic;
		BUS_RESET			: in std_logic;
		BUS_RESET_SOFT		: out std_logic;
		BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR				: in std_logic;
		BUS_RD				: in std_logic;
		BUS_ACK				: out std_logic
	);
end richclkrst_per;

architecture synthesis of richclkrst_per is
	component sysclkpll is
		port(
			CLK_33MHZ			: in std_logic;
			
			SYSCLK_50_RESET	: out std_logic;
			SYSCLK_50			: out std_logic;

			SYSCLK_200_RESET	: out std_logic;
			SYSCLK_200			: out std_logic
		);
	end component;

	component gclkpll is
		port(
			GCLK_125_REF_RST	: in std_logic;
			GCLK_125_REF		: in std_logic;
			
			GCLK_125_RESET		: out std_logic;
			GCLK_125				: out std_logic;
			GCLK_250				: out std_logic;
			GCLK_500				: out std_logic;
			GCLK_500_180		: out std_logic
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

	signal CLK_CTRL_REG				: std_logic_vector(31 downto 0);
	signal CLK_DUMMY_REG				: std_logic_vector(31 downto 0);
	signal SPI_FLASH_CTRL_REG		: std_logic_vector(31 downto 0);
	signal SPI_FLASH_STATUS_REG	: std_logic_vector(31 downto 0);

	signal PI							: pbus_if_i;
	signal PO							: pbus_if_o;

	signal BUS_RESET_SOFT_i			: std_logic;

	signal WR_DATA						: std_logic_vector(7 downto 0);
	signal RD_DATA						: std_logic_vector(7 downto 0);
	signal NCS_SET						: std_logic;
	signal NCS_CLEAR					: std_logic;
	signal START						: std_logic;
	signal DONE							: std_logic;
begin

	BUS_RESET_SOFT <= BUS_RESET_SOFT_i;

	sysclkpll_inst: sysclkpll
		port map(
			CLK_33MHZ			=> CLK_33MHZ,
			SYSCLK_50_RESET	=> SYSCLK_50_RESET,
			SYSCLK_50			=> SYSCLK_50,
			SYSCLK_200_RESET	=> SYSCLK_200_RESET,
			SYSCLK_200			=> SYSCLK_200
		);

	gclkpll_inst: gclkpll
		port map(
			GCLK_125_REF_RST	=> GCLK_125_REF_RST,
			GCLK_125_REF		=> GCLK_125_REF,
			GCLK_125_RESET		=> GCLK_125_RESET,
			GCLK_125				=> GCLK_125,
			GCLK_250				=> GCLK_250,
			GCLK_500				=> GCLK_500,
			GCLK_500_180		=> GCLK_500_180
		);

	rich_spiflash_inst: rich_spiflash
		port map(
			CLK				=> BUS_CLK,
			WR_DATA			=> WR_DATA,
			RD_DATA			=> RD_DATA,
			NCS_SET			=> NCS_SET,
			NCS_CLEAR		=> NCS_CLEAR,
			START				=> START,
			DONE				=> DONE,
			CONFIGROM_D		=> CONFIGROM_D,
			CONFIGROM_Q		=> CONFIGROM_Q,
			CONFIGROM_S_N	=> CONFIGROM_S_N
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
			BUS_RESET_SOFT	=> BUS_RESET_SOFT_i,
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

	--CLK_CTRL
	BUS_RESET_SOFT_i <= CLK_CTRL_REG(0);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';
			
			rw_reg(	REG => CLK_CTRL_REG				,PI=>PI,PO=>PO, A => x"0000", RW => x"00000001", I => x"00000001");
			rw_reg(	REG => CLK_DUMMY_REG				,PI=>PI,PO=>PO, A => x"0004", RW => x"FFFFFFFF", I => x"A55A1234");

			rw_reg(	REG => SPI_FLASH_CTRL_REG		,PI=>PI,PO=>PO, A => x"0008", RW => x"000007FF", I => x"00000100", R => x"00000700");
			ro_reg(	REG => SPI_FLASH_STATUS_REG	,PI=>PI,PO=>PO, A => x"000C", RO => x"000008FF");
		end if;
	end process;

end synthesis;
