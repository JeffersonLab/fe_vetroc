library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity sramfifo_tb is
end sramfifo_tb;

architecture behavior of sramfifo_tb is
	component SramFifo is
		generic(
			ADDR_WIDTH		: integer := 18
		);
		port(
			CLK				: in std_logic;
			
			RESET			: in std_logic;
			
			FIFO_RD_CLK		: in std_logic;
			FIFO_WR_CLK		: in std_logic;
			FIFO_RD			: in std_logic;
			FIFO_WR			: in std_logic;
			FIFO_DIN		: in std_logic_vector(35 downto 0);
			FIFO_DOUT		: out std_logic_vector(35 downto 0);
			FIFO_EMPTY		: out std_logic;
			FIFO_FULL		: out std_logic;
			
			-- SRAM Phy Signals
			SRAM_CLK_O		: out std_logic;
			SRAM_CLK_I		: in std_logic;
			SRAM_D			: inout std_logic_vector(35 downto 0);
			SRAM_A			: out std_logic_vector(18 downto 0);
			SRAM_RW			: out std_logic;
			SRAM_OE			: out std_logic;
			SRAM_CS			: out std_logic;
			SRAM_ADV		: out std_logic
		);
	end component;
	
	constant ADDR_WIDTH		: integer := 8;
	
	type mem_array_type is array(natural range <>) of std_logic_vector(35 downto 0);
	
	signal ZBT_MEMORY_ARRAY	: mem_array_type(0 to 2**ADDR_WIDTH-1);

	signal CLK				: std_logic;	
	signal RESET			: std_logic;
	signal FIFO_RD_CLK		: std_logic;
	signal FIFO_WR_CLK		: std_logic;
	signal FIFO_RD			: std_logic;
	signal FIFO_WR			: std_logic;
	signal FIFO_DIN			: std_logic_vector(35 downto 0);
	signal FIFO_DOUT		: std_logic_vector(35 downto 0);
	signal FIFO_EMPTY		: std_logic;
	signal FIFO_FULL		: std_logic;
	signal SRAM_CLK_O		: std_logic;
	signal SRAM_CLK_I		: std_logic;
	signal SRAM_D			: std_logic_vector(35 downto 0);
	signal SRAM_A			: std_logic_vector(18 downto 0);
	signal SRAM_RW			: std_logic;
	signal SRAM_OE			: std_logic;
	signal SRAM_CS			: std_logic;
	signal SRAM_ADV			: std_logic;
	
	signal SRAM_RW_Q0		: std_logic;
	signal SRAM_RW_Q1		: std_logic;
	signal SRAM_A_Q0		: std_logic_vector(18 downto 0);
	signal SRAM_A_Q1		: std_logic_vector(18 downto 0);
	signal SRAM_D_O			: std_logic_vector(35 downto 0);
	signal FIFO_WR_CNT		: std_logic_vector(35 downto 0) := x"000000000";
begin

	SramFifo_uut: SramFifo
		generic map(
			ADDR_WIDTH		=> ADDR_WIDTH
		)
		port map(
			CLK				=> CLK,
			RESET			=> RESET,
			FIFO_RD_CLK		=> FIFO_RD_CLK,
			FIFO_WR_CLK		=> FIFO_WR_CLK,
			FIFO_RD			=> FIFO_RD,
			FIFO_WR			=> FIFO_WR,
			FIFO_DIN		=> FIFO_DIN,
			FIFO_DOUT		=> FIFO_DOUT,
			FIFO_EMPTY		=> FIFO_EMPTY,
			FIFO_FULL		=> FIFO_FULL,
			SRAM_CLK_O		=> SRAM_CLK_O,
			SRAM_CLK_I		=> SRAM_CLK_I,
			SRAM_D			=> SRAM_D,
			SRAM_A			=> SRAM_A,
			SRAM_RW			=> SRAM_RW,
			SRAM_OE			=> SRAM_OE,
			SRAM_CS			=> SRAM_CS,
			SRAM_ADV		=> SRAM_ADV
		);

	FIFO_RD_CLK <= CLK;
	FIFO_WR_CLK <= CLK;

	SRAM_CLK_I <= transport SRAM_CLK_O after 3 ns;

	process
	begin
		CLK <= '0';
		wait for 4 ns;
		CLK <= '1';
		wait for 4 ns;
	end process;
	
	process
	begin
		RESET <= '1';
		wait for 100 ns;
		RESET <= '0';
		wait;
	end process;
	
	process(SRAM_CLK_I)
	begin
		if rising_edge(SRAM_CLK_I) then
			SRAM_A_Q0 <= SRAM_A;
			SRAM_A_Q1 <= SRAM_A_Q0;
			SRAM_RW_Q0 <= SRAM_RW;
			SRAM_RW_Q1 <= SRAM_RW_Q0;
			if (SRAM_RW_Q1 = '0') then
				ZBT_MEMORY_ARRAY(conv_integer(SRAM_A_Q1)) <= SRAM_D;
			end if;
		end if;
	end process;
	
	SRAM_D_O <= ZBT_MEMORY_ARRAY(conv_integer(SRAM_A_Q1));
	
	SRAM_D <= SRAM_D_O when SRAM_OE = '0' else (others=>'Z');
	SRAM_D <= (others=>'H');
	
	FIFO_WR <= not FIFO_FULL;
	FIFO_RD <= not FIFO_EMPTY;

	process(FIFO_WR_CLK)
	begin
		if rising_edge(FIFO_WR_CLK) then
			if FIFO_WR = '1' then
				FIFO_WR_CNT <= FIFO_WR_CNT + 1;
			end if;
		end if;
	end process;

	FIFO_DIN <= FIFO_WR_CNT;	

end;
