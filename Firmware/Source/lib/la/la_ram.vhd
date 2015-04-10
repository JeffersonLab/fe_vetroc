library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity la_ram is
	generic(
		D_WIDTH		: integer := 32
	);
	port(
		CLK			: in std_logic;

		WREN			: in std_logic;
		DI				: in std_logic_vector(D_WIDTH-1 downto 0);

		RDADDR_LD	: in std_logic;
		RDEN			: in std_logic;
		DO				: out std_logic_vector(D_WIDTH-1 downto 0)
	);
end la_ram;

architecture synthesis of la_ram is
	signal WRADDR		: std_logic_vector(8 downto 0) := (others=>'0');
	signal RDADDR		: std_logic_vector(8 downto 0) := (others=>'0');
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if WREN = '1' then
				WRADDR <= WRADDR + 1;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RDADDR_LD = '1' then
				RDADDR <= WRADDR;
			elsif RDEN = '1' then
				RDADDR <= RDADDR + 1;
			end if;
		end if;
	end process;

	sdp_ram_inst: sdp_ram
		generic map(
			D_WIDTH	=> D_WIDTH,
			A_WIDTH	=> 9,
			DOUT_REG	=> true
		)
		port map(
			WR_CLK	=> CLK,
			WR			=> WREN,
			WR_ADDR	=> WRADDR,
			DIN		=> DI,
			RD_CLK	=> CLK,
			RD			=> '1',
			RD_ADDR	=> RDADDR,
			DOUT		=> DO
		);

end Synthesis;
