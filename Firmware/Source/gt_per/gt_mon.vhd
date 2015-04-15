library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

library la;
use la.la_pkg.all;

entity gxbvxs_mon is
	port(
		CLK				: in std_logic;

		TX_SRC_RDY_N	: in std_logic;
		TX_D				: in std_logic_vector(31 downto 0);

		LA_CMP_MODE0	: in std_logic_vector(2 downto 0);
		LA_CMP_THR0		: in std_logic_vector(31 downto 0);
		LA_MASK_EN0		: in std_logic_vector(31 downto 0);
		LA_MASK_VAL0	: in std_logic_vector(31 downto 0);
		LA_MASK_EN1		: in std_logic_vector(2 downto 0);
		LA_MASK_VAL1	: in std_logic_vector(2 downto 0);
		LA_ENABLE		: in std_logic;
		LA_READY			: out std_logic;
		LA_DO				: out slv32a(1 downto 0);
		LA_RDEN			: in std_logic_vector(1 downto 0)
	);
end gxbvxs_mon;

architecture synthesis of gxbvxs_mon is
	constant LA_RAM_NUM		: integer := 2;

	signal LA_RDADDR_LD		: std_logic_vector(LA_RAM_NUM-1 downto 0);
	signal LA_READY_i			: std_logic;
	signal LA_WREN				: std_logic_vector(LA_RAM_NUM-1 downto 0);
	signal LA_DI				: std_logic_vector(32*LA_RAM_NUM-1 downto 0) := (others=>'0');
	signal TRG					: std_logic_vector(2 downto 0);
	signal TRIGGER				: std_logic;

	signal TX_D_FRAME_IDX			: std_logic_vector(1 downto 0);
begin

	LA_READY <= LA_READY_i;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if TX_SRC_RDY_N = '1' then
				TX_D_FRAME_IDX <= (others=>'0');
			else
				TX_D_FRAME_IDX <= TX_D_FRAME_IDX + 1;
			end if;
		end if;
	end process;

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
			LA_DI(31 downto 0) <= TX_D;
			LA_DI(32) <= TX_SRC_RDY_N;
			LA_DI(34 downto 33) <= TX_D_FRAME_IDX;
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
	la_cmp_inst0: la_cmp generic map(D_WIDTH => 32)		port map(CLK => CLK, MODE => LA_CMP_MODE0, THR => LA_CMP_THR0, DIN => LA_DI(31 downto 0), TRG => TRG(0));
	la_mask_inst0: la_mask generic map(D_WIDTH => 32)	port map(CLK => CLK, EN => LA_MASK_EN0, VAL => LA_MASK_VAL0, DIN => LA_DI(31 downto 0), TRG => TRG(1));
	la_mask_inst1: la_mask generic map(D_WIDTH => 3)	port map(CLK => CLK, EN => LA_MASK_EN1, VAL => LA_MASK_VAL1, DIN => LA_DI(34 downto 32), TRG => TRG(2));

end synthesis;
