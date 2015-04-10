library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;

entity delay_ram is
	generic(
		D_WIDTH		: integer := 32;
		A_WIDTH		: integer := 10
	);
	port(
		CLK		: in std_logic;
		DELAY		: in std_logic_vector(A_WIDTH-1 downto 0);
		DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
		DOUT		: out std_logic_vector(D_WIDTH-1 downto 0)
	);
end delay_ram;

architecture synthesis of delay_ram is
	signal WR_ADDR		: std_logic_vector(A_WIDTH-1 downto 0) := (others=>'0');
	signal RD_ADDR		: std_logic_vector(A_WIDTH-1 downto 0) := (others=>'0');
begin

	sdp_ram_inst: sdp_ram
		generic map(
			D_WIDTH		=> D_WIDTH,
			A_WIDTH		=> A_WIDTH,
			DOUT_REG		=> true
		)
		port map(
			WR_CLK	=> CLK,
			WR			=> '1',
			WR_ADDR	=> WR_ADDR,
			DIN		=> DIN,
			RD_CLK	=> CLK,
			RD			=> '1',
			RD_ADDR	=> RD_ADDR,
			DOUT		=> DOUT
		);

	-- offset WR_ADDR so delay = 0,1,2,3,... step equally. this limits maximum delay.
	process(CLK)
	begin
		if rising_edge(CLK) then
			RD_ADDR <= RD_ADDR + 1;
			WR_ADDR <= RD_ADDR + 2 + DELAY;
		end if;
	end process;

end synthesis;
