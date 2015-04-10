library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity evtbuilderstage is
	generic(
		GRP_NUM			: integer := 4
	);
	port(
		CLK_WR			: in std_logic;
		CLK_RD			: in std_logic;
		
		RESET				: in std_logic;
 		
 		GRP_BLD_DATA	: in slv33a(GRP_NUM-1 downto 0);
 		GRP_BLD_EMPTY	: in std_logic_vector(GRP_NUM-1 downto 0);
 		GRP_BLD_READ	: out std_logic_vector(GRP_NUM-1 downto 0);

		BLD_DATA			: out std_logic_vector(32 downto 0);
		BLD_EMPTY		: out std_logic;
		BLD_READ			: in std_logic
	);
end evtbuilderstage;

architecture synthesis of evtbuilderstage is
	component xfifo_33b512d_fwft_async is
		port(
			RD_EN					: in std_logic;
			RST					: in std_logic;
			EMPTY					: out std_logic;
			WR_EN					: in std_logic;
			RD_CLK				: in std_logic;
			FULL					: out std_logic;
			WR_CLK				: in std_logic;
			PROG_FULL			: out std_logic;
			DOUT					: out std_logic_vector(32 downto 0);
			DIN					: in std_logic_vector(32 downto 0);
			PROG_FULL_THRESH	: in std_logic_vector(8 downto 0)
		);
	end component;

	signal FIFO_WR		: std_logic;
	signal FIFO_DIN	: std_logic_vector(32 downto 0);
	signal FIFO_FULL	: std_logic;
begin

	-- Writes full event from each input FIFO -> output before processing next
	process(GRP_BLD_EMPTY, GRP_BLD_DATA, FIFO_FULL)
	begin
		FIFO_WR <= '0';
		FIFO_DIN <= (others=>'1');
		GRP_BLD_READ <= (others=>'0');
		for I in 0 to GRP_NUM-1 loop
			if (GRP_BLD_EMPTY(I) = '1') or (FIFO_FULL = '1') then
				exit;
			end if;
			if GRP_BLD_DATA(I)(32) = '0' then
				FIFO_DIN <= '0' & GRP_BLD_DATA(I)(31 downto 0);
				FIFO_WR <= '1';
				GRP_BLD_READ(I) <= '1';
				exit;
			elsif I = GRP_NUM-1 then
				FIFO_WR <= '1';
				GRP_BLD_READ <= (others=>'1');
			end if;
		end loop;
	end process;

	xfifo_33b512d_fwft_async_inst: xfifo_33b512d_fwft_async
		port map(
			RD_EN					=> BLD_READ,
			RST					=> RESET,
			EMPTY					=> BLD_EMPTY,
			WR_EN					=> FIFO_WR,
			RD_CLK				=> CLK_RD,
			FULL					=> FIFO_FULL,
			WR_CLK				=> CLK_WR,
			PROG_FULL			=> open,
			DOUT					=> BLD_DATA,
			DIN					=> FIFO_DIN,
			PROG_FULL_THRESH	=> (others=>'1')
		);

end synthesis;
