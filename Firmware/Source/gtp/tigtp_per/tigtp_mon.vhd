library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

library la;
use la.la_pkg.all;

entity tigtp_mon is
	port(
		CLK				: in std_logic;

		TX_CMD			: in std_logic_vector(1 downto 0);
		TX_DATA			: in std_logic_vector(7 downto 0);
		RX_CMD			: in std_logic_vector(1 downto 0);
		RX_DATA			: in std_logic_vector(7 downto 0);
		SYNC_EVT			: in std_logic;
		SYNC_EVT_RST	: in std_logic;
		SEND_ACK			: in std_logic;
		SEND_BL_REQ		: in std_logic;

		LA_MASK_EN0		: in std_logic_vector(21 downto 0);
		LA_MASK_VAL0	: in std_logic_vector(21 downto 0);
		LA_ENABLE		: in std_logic;
		LA_READY			: out std_logic;
		LA_DO				: out slv32a(0 downto 0);
		LA_RDEN			: in std_logic_vector(0 downto 0)
	);
end tigtp_mon;

architecture synthesis of tigtp_mon is
	constant LA_RAM_NUM		: integer := 1;

	signal LA_RDADDR_LD		: std_logic_vector(LA_RAM_NUM-1 downto 0);
	signal LA_READY_i			: std_logic;
	signal LA_WREN				: std_logic_vector(LA_RAM_NUM-1 downto 0);
	signal LA_DI				: std_logic_vector(32*LA_RAM_NUM-1 downto 0) := (others=>'0');
	signal TRG					: std_logic_vector(0 downto 0);
	signal TRIGGER				: std_logic;
begin

	LA_READY <= LA_READY_i;

	process(CLK)
	begin
		if rising_edge(CLK) then
			for I in 0 to LA_RAM_NUM-1 loop
				LA_WREN(I) <= not LA_READY_i;
				LA_RDADDR_LD(I) <= LA_ENABLE;
			end loop;

			TRIGGER <= and_reduce(TRG);
		end if;
	end process;

	-- Analyzer State Machine
	la_sm_inst: la_sm
		port map(
			CLK			=> CLK,
			TRIGGER		=> TRIGGER,
			LA_ENABLE	=> LA_ENABLE,
			LA_READY		=> LA_READY_i
		);

	-- Analyzer Inputs Signal Mapping & Deskewing
	process(CLK)
	begin
		if rising_edge(CLK) then
			LA_DI(1 downto 0) <= TX_CMD;
			LA_DI(9 downto 2) <= TX_DATA;
			LA_DI(11 downto 10) <= RX_CMD;
			LA_DI(19 downto 12) <= RX_DATA;
			LA_DI(20) <= SYNC_EVT;
			LA_DI(21) <= SYNC_EVT_RST;
			LA_DI(22) <= SEND_ACK;
			LA_DI(23) <= SEND_BL_REQ;
		end if;
	end process;

	-- Analyzer Buffer
	la_ram_gen: for I in 0 to LA_RAM_NUM-1 generate
		la_ram_inst: la_ram
			port map(
				CLK			=> CLK,
				WREN			=> LA_WREN(I),
				DI				=> LA_DI(I*32+31 downto I*32),
				RDADDR_LD	=> LA_RDADDR_LD(I),
				RDEN			=> LA_RDEN(I),
				DO				=> LA_DO(I)
			);
	end generate;

	-- Analyzer Trigger Comparators
	la_mask_inst0: la_mask generic map(D_WIDTH => 22)	port map(CLK => CLK, EN => LA_MASK_EN0, VAL => LA_MASK_VAL0, DIN => LA_DI(21 downto 0), TRG => TRG(0));

end synthesis;
