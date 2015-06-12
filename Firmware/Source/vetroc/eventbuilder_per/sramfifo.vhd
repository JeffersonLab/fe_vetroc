library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sramfifo is
	port(
		CLK				: in std_logic;
		
		RESET				: in std_logic;
		
		FIFO_RD_CLK		: in std_logic;
		FIFO_WR_CLK		: in std_logic;
		FIFO_RD			: in std_logic;
		FIFO_WR			: in std_logic;
		FIFO_DIN			: in std_logic_vector(35 downto 0);
		FIFO_DOUT		: out std_logic_vector(35 downto 0);
		FIFO_EMPTY		: out std_logic;
		FIFO_FULL		: out std_logic;
		
		SRAM_DBG_WR		: in std_logic;
		SRAM_DBG_RD		: in std_logic;
		SRAM_DBG_ADDR	: in std_logic_vector(19 downto 0);
		SRAM_DBG_DIN	: in std_logic_vector(17 downto 0);
		SRAM_DBG_DOUT	: out std_logic_vector(17 downto 0);
		
		-- SRAM Phy Signals
		SRAM_CLK			: out std_logic;
		SRAM_CLK_O		: out std_logic;
		SRAM_CLK_I		: in std_logic;
		SRAM_D			: inout std_logic_vector(17 downto 0);
		SRAM_A			: out std_logic_vector(19 downto 0);
		SRAM_RW			: out std_logic;
		SRAM_NOE			: out std_logic;
		SRAM_CS			: out std_logic;
		SRAM_ADV			: out std_logic
	);
end sramfifo;

architecture Synthesis of SramFifo is
	component sramcntrl is
		port(
			-- SRAM clock source
			CLK				: in std_logic;
			RESET				: in std_logic;
			
			-- SRAM Phy Signals
			SRAM_CLK			: out std_logic;
			SRAM_CLK_O		: out std_logic;
			SRAM_CLK_I		: in std_logic;
			SRAM_D			: inout std_logic_vector(17 downto 0);
			SRAM_A			: out std_logic_vector(19 downto 0);
			SRAM_RW			: out std_logic;
			SRAM_NOE			: out std_logic;
			SRAM_CS			: out std_logic;
			SRAM_ADV			: out std_logic;		
			
			-- SRAM User Signals
			USER_CLK			: out std_logic;
			USER_WRITE		: in std_logic;
			USER_ADDR		: in std_logic_vector(19 downto 0);
			USER_RD_DATA	: out std_logic_vector(17 downto 0);
			USER_WR_DATA	: in std_logic_vector(17 downto 0)
		);
	end component;
	
	component sramfifo_wr_if is
		port( 
			rst			: in std_logic;
			wr_clk		: in std_logic;
			rd_clk		: in std_logic;
			din			: in std_logic_vector ( 35 downto 0 );
			wr_en			: in std_logic;
			rd_en			: in std_logic;
			dout			: out std_logic_vector ( 17 downto 0 );
			full			: out std_logic;
			empty			: out std_logic;
			prog_full	: out std_logic
		);
	end component;

	component sramfifo_rd_if is
		port(
			rst			: in std_logic;
			wr_clk		: in std_logic;
			rd_clk		: in std_logic;
			din			: in std_logic_vector(17 downto 0);
			wr_en			: in std_logic;
			rd_en			: in std_logic;
			dout			: out std_logic_vector(35 downto 0);
			full			: out std_logic;
			empty			: out std_logic;
			prog_full	: out std_logic
		);
	end component;
	
	signal USER_CLK			: std_logic;
	signal USER_WRITE			: std_logic := '0';
	signal USER_ADDR			: std_logic_vector(19 downto 0) := (others=>'0');
	signal USER_RD_DATA		: std_logic_vector(17 downto 0);
	signal USER_WR_DATA		: std_logic_vector(17 downto 0);
	signal RD_POS				: std_logic_vector(19 downto 0);
	signal WR_POS				: std_logic_vector(19 downto 0);
	signal FULL					: std_logic;
	signal EMPTY				: std_logic;
	signal int_fifo_din		: std_logic_vector(17 downto 0);
	signal int_fifo_wr		: std_logic;
	signal int_fifo_full		: std_logic;
	signal int_fifo_rd		: std_logic;
	signal int_fifo_dout		: std_logic_vector(17 downto 0);
	signal int_fifo_dout_q0	: std_logic_vector(17 downto 0);
	signal int_fifo_dout_q1	: std_logic_vector(17 downto 0);
	signal int_fifo_dout_q2	: std_logic_vector(17 downto 0);
	signal int_fifo_empty	: std_logic;
	signal do_wr_fifo			: std_logic;
	signal do_rd_fifo			: std_logic;
	signal do_rd_fifo_q0		: std_logic;
	signal do_rd_fifo_q1		: std_logic;
	signal do_rd_fifo_q2		: std_logic;
	signal do_rd_fifo_q3		: std_logic;
	signal do_rd_fifo_q4		: std_logic;
	signal SRAM_DBG_RD_q0	: std_logic;
	signal SRAM_DBG_RD_q1	: std_logic;
	signal SRAM_DBG_RD_q2	: std_logic;
	signal SRAM_DBG_RD_q3	: std_logic;
	signal SRAM_DBG_RD_q4	: std_logic;
	signal wr_fifo_rdy		: std_logic;
	signal rd_fifo_rdy		: std_logic;
	
	signal SRAM_DBG_WR_UP	: std_logic;
	signal SRAM_DBG_RD_UP	: std_logic;
	signal SRAM_DBG_WR_Q		: std_logic_vector(2 downto 0);
	signal SRAM_DBG_RD_Q		: std_logic_vector(2 downto 0);
begin

	SRAM_DBG_WR_UP <= SRAM_DBG_WR_Q(1) and not SRAM_DBG_WR_Q(2);
	SRAM_DBG_RD_UP <= SRAM_DBG_RD_Q(1) and not SRAM_DBG_RD_Q(2);
	
	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			SRAM_DBG_WR_Q <= SRAM_DBG_WR_Q(1 downto 0) & SRAM_DBG_WR; 
			SRAM_DBG_RD_Q <= SRAM_DBG_RD_Q(1 downto 0) & SRAM_DBG_RD; 
		end if;
	end process;

	sramcntrl_inst: sramcntrl
		port map(
			CLK				=> CLK,
			RESET				=> RESET,
			SRAM_CLK			=> SRAM_CLK,
			SRAM_CLK_O		=> SRAM_CLK_O,
			SRAM_CLK_I		=> SRAM_CLK_I,
			SRAM_D			=> SRAM_D,
			SRAM_A			=> SRAM_A,
			SRAM_RW			=> SRAM_RW,
			SRAM_NOE			=> SRAM_NOE,
			SRAM_CS			=> SRAM_CS,
			SRAM_ADV			=> SRAM_ADV,
			USER_CLK			=> USER_CLK,
			USER_WRITE		=> USER_WRITE,
			USER_ADDR		=> USER_ADDR,
			USER_RD_DATA	=> USER_RD_DATA,
			USER_WR_DATA	=> USER_WR_DATA
		);
		
	sramfifo_wr_if_inst: sramfifo_wr_if
		port map(
			rst			=> RESET,
			wr_clk		=> FIFO_WR_CLK,
			rd_clk		=> USER_CLK,
			din			=> FIFO_DIN,
			wr_en			=> FIFO_WR,
			rd_en			=> int_fifo_rd,
			dout			=> int_fifo_dout,
			full			=> open,
			empty			=> int_fifo_empty,
			prog_full	=> FIFO_FULL
		);

	sramfifo_rd_if_inst: sramfifo_rd_if
		port map(
			rst			=> RESET,
			wr_clk		=> USER_CLK,
			rd_clk		=> FIFO_RD_CLK,
			din			=> int_fifo_din,
			wr_en			=> int_fifo_wr,
			rd_en			=> FIFO_RD,
			dout			=> FIFO_DOUT,
			full			=> open,
			empty			=> FIFO_EMPTY,
			prog_full	=> int_fifo_full 
		);
	
	USER_WR_DATA <= int_fifo_dout_q2;
	
	int_fifo_rd <= DO_WR_FIFO;

	WR_FIFO_RDY <= '1' when (FULL = '0') and (int_fifo_empty = '0') else '0';
	RD_FIFO_RDY <= '1' when (EMPTY = '0') and (int_fifo_full = '0') else '0';
	
	DO_RD_FIFO <= '1' when (RD_FIFO_RDY = '1') else '0';
	DO_WR_FIFO <= '1' when (RD_FIFO_RDY = '0') and (WR_FIFO_RDY = '1') else '0';

	FULL <= '1' when WR_POS + 1 = RD_POS else '0';
	EMPTY <= '1' when RD_POS = WR_POS else '0';
	
	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if SRAM_DBG_RD_q4 = '1' then
				SRAM_DBG_DOUT <= USER_RD_DATA;
			end if;
		end if;
	end process;
	
	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if (SRAM_DBG_WR_UP = '1') or (SRAM_DBG_RD_UP = '1') then
				USER_ADDR <= SRAM_DBG_ADDR;
			elsif DO_WR_FIFO = '1' then
				USER_ADDR <= WR_POS;
			else
				USER_ADDR <= RD_POS;
			end if;
		end if;
	end process;

	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			USER_WRITE <= DO_WR_FIFO or SRAM_DBG_WR_UP;
			
			if SRAM_DBG_WR_UP = '1' then
				int_fifo_dout_q0 <= SRAM_DBG_DIN; 			
			else
				int_fifo_dout_q0 <= int_fifo_dout;
			end if;
			
			int_fifo_dout_q1 <= int_fifo_dout_q0;
			int_fifo_dout_q2 <= int_fifo_dout_q1;
			DO_RD_FIFO_q0 <= DO_RD_FIFO;
			DO_RD_FIFO_q1 <= DO_RD_FIFO_q0;
			DO_RD_FIFO_q2 <= DO_RD_FIFO_q1;
			DO_RD_FIFO_q3 <= DO_RD_FIFO_q2;
			DO_RD_FIFO_q4 <= DO_RD_FIFO_q3;
			int_fifo_wr <= DO_RD_FIFO_q4;
			int_fifo_din <= USER_RD_DATA;
			SRAM_DBG_RD_q0 <= SRAM_DBG_RD_UP;
			SRAM_DBG_RD_q1 <= SRAM_DBG_RD_q0;
			SRAM_DBG_RD_q2 <= SRAM_DBG_RD_q1;
			SRAM_DBG_RD_q3 <= SRAM_DBG_RD_q2;
			SRAM_DBG_RD_q4 <= SRAM_DBG_RD_q3;
		end if;
	end process;

	process(RESET, USER_CLK)
	begin
		if RESET = '1' then
			RD_POS <= (others=>'0');
		elsif rising_edge(USER_CLK) then
			if DO_RD_FIFO = '1' then
				RD_POS <= RD_POS + 1;
			end if;
		end if;
	end process;
	
	process(RESET, USER_CLK)
	begin
		if RESET = '1' then
			WR_POS <= (others=>'0');
		elsif rising_edge(USER_CLK) then
			if DO_WR_FIFO = '1' then
				WR_POS <= WR_POS + 1;
			end if;
		end if;
	end process;

end synthesis;
