library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;

entity gtpclkrst_per is
	generic(
		ADDR_INFO		: PER_ADDR_INFO
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		CLK25_B			: in std_logic;
		CLK25_R			: in std_logic;
		CLK250_B			: in std_logic;
		CLK250_L			: in std_logic;
		CLK250_R			: in std_logic;
		CLK250_T			: in std_logic;

		ATXCLK_R			: out std_logic;
		ATXCLK_L			: out std_logic;
		CPLD_CLK			: out std_logic;

		SYSCLK_LOCKED	: out std_logic;
		SYSCLK_50		: out std_logic;
		SYSCLK_250		: out std_logic;
		SYSCLK_CPU		: out std_logic;
		SYSCLK_PER		: out std_logic;

		GCLK				: out std_logic;
		GCLK_DIV4		: out std_logic;
		GCLK_RST			: out std_logic;

		GCLK_SRC			: out std_logic_vector(1 downto 0);

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_CLK			: in std_logic;
		BUS_RESET		: in std_logic;
		BUS_RESET_SOFT	: in std_logic;
		BUS_DIN			: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT			: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR			: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR			: in std_logic;
		BUS_RD			: in std_logic;
		BUS_ACK			: out std_logic
	);
end gtpclkrst_per;

architecture synthesis of gtpclkrst_per is
	component atx_pll is
		port(
			inclk0		: in std_logic := '0';
			areset		: in std_logic;
			c0				: out std_logic;
			locked		: out std_logic
		);
	end component;

	component sysclkpll is
		port(
			areset	: in std_logic := '0';
			inclk0	: in std_logic := '0';
			c0			: out std_logic;
			c1			: out std_logic;
			c2			: out std_logic;
			c3			: out std_logic;
			locked	: out std_logic 
		);
	end component;

	component pll_250_b is
		port(
			inclk0		: in std_logic := '0';
			areset		: in std_logic;
			c0				: out std_logic;
			c1				: out std_logic;
			locked		: out std_logic 
		);
	end component;


	signal CLK_CTRL_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal CLK_STATUS_REG		: std_logic_vector(31 downto 0) := x"00000000";

	signal PI						: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO						: pbus_if_o := (x"00000000", '0');
	
	signal GCLK_i					: std_logic;
	signal GCLK_RST_SREG			: std_logic_vector(7 downto 0);
	signal GCLKPLLRESET			: std_logic;
	signal GCLKPLL_LOCKED		: std_logic;
	signal ATXCLK_L_LOCKED		: std_logic;
	signal ATXCLK_R_LOCKED		: std_logic;
begin

	CPLD_CLK <= '0';

	----------------------------------------------------------------------------
	-- Transceiver transmit reference clocks
	----------------------------------------------------------------------------
	-- Note: CLK250_R is actually on the left side of FPGA
	--       CLK250_L is actually on the right side of FPGA
	pll_atx_l: atx_pll
		port map(
			inclk0		=> CLK250_R,
			areset		=> GCLKPLLRESET,
			c0				=> ATXCLK_L,
			locked		=> ATXCLK_L_LOCKED
		);
	
	pll_atx_r: atx_pll
		port map(
			inclk0		=> CLK250_L,
			areset		=> GCLKPLLRESET,
			c0				=> ATXCLK_R,
			locked		=> ATXCLK_R_LOCKED
		);

	----------------------------------------------------------------------------
	-- Local Clock Generation
	----------------------------------------------------------------------------

	sysclkpll_inst: sysclkpll
		port map(
			areset	=> '0',
			inclk0	=> CLK25_B,
			c0			=> SYSCLK_250,
			c1			=> SYSCLK_50,
			c2			=> SYSCLK_CPU,
			c3			=> SYSCLK_PER,
			locked	=> SYSCLK_LOCKED
		);

	----------------------------------------------------------------------------
	-- Global Clock Generation
	----------------------------------------------------------------------------

	pll250b: pll_250_b
		port map(
			inclk0	=> CLK250_B,
			areset	=> GCLKPLLRESET,
			c0			=> GCLK_i,
			c1			=> GCLK_DIV4,
			locked	=> GCLKPLL_LOCKED
		);

	GCLK <= GCLK_i;
	GCLK_RST <= GCLK_RST_SREG(GCLK_RST_SREG'left);

	process(GCLK_i, GCLKPLL_LOCKED)
	begin
		if GCLKPLL_LOCKED = '0' then
			GCLK_RST_SREG <= (others=>'1');
		elsif rising_edge(GCLK_i) then
			GCLK_RST_SREG <= GCLK_RST_SREG(GCLK_RST_SREG'length-2 downto 0) & '0';
		end if;
	end process;


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

	-----------------------------------
	-- Register CLK_CTRL Mapping
	-----------------------------------	
	GCLK_SRC <= CLK_CTRL_REG(1 downto 0);
	GCLKPLLRESET <= CLK_CTRL_REG(31);

	-----------------------------------
	-- Register CLK_STATUS Mapping
	-----------------------------------
	CLK_STATUS_REG(0) <= GCLKPLL_LOCKED;
	CLK_STATUS_REG(1) <= ATXCLK_L_LOCKED;
	CLK_STATUS_REG(2) <= ATXCLK_R_LOCKED;
	CLK_STATUS_REG(31 downto 3) <= (others=>'0');

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';
			
			rw_reg(	REG => CLK_CTRL_REG		,PI=>PI,PO=>PO, A => x"0000", RW => x"80000003", I => x"80000000");
			ro_reg(	REG => CLK_STATUS_REG	,PI=>PI,PO=>PO, A => x"0004", RO => x"00000007");
		end if;
	end process;

end synthesis;
