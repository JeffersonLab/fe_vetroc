library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

entity sfifo_tb is
end sfifo_tb;

architecture testbench of sfifo_tb is
	constant D_WIDTH	: integer := 32;
	constant A_WIDTH	: integer := 4;

	signal CLK			: std_logic;
	signal RST			: std_logic;
	signal DIN			: std_logic_vector(D_WIDTH-1 downto 0);
	signal WR			: std_logic;
	signal FULL			: std_logic;
	signal DOUT			: std_logic_vector(D_WIDTH-1 downto 0);
	signal RD			: std_logic;
	signal EMPTY		: std_logic;

begin

	scfifo_generic_inst: scfifo_generic
		generic map(
			D_WIDTH	=> D_WIDTH,
			A_WIDTH	=> A_WIDTH,
			DOUT_REG	=> true,
			MODE		=> "STD"
		)
		port map(
			CLK		=> CLK,
			RST		=> RST,
			DIN		=> DIN,
			WR			=> WR,
			FULL		=> FULL,
			DOUT		=> DOUT,
			RD			=> RD,
			EMPTY		=> EMPTY
		);

	process
	begin
		CLK <= '0';
		wait for 5 ns;
		CLK <= '1';
		wait for 5 ns;
	end process;

	process
	begin
		RST <= '1';
		wait for 100 ns;
		wait until rising_edge(CLK);
		RST <= '0';
		wait;
	end process;

	process
	begin
		WR <= '0';
		DIN <= x"00000000";
		wait until rising_edge(CLK) and RST = '0';

		WR <= '1';
		DIN <= x"00000001";
		wait until rising_edge(CLK);

		WR <= '1';
		DIN <= x"00000002";
		wait until rising_edge(CLK);

		WR <= '1';
		DIN <= x"00000003";
		wait until rising_edge(CLK);

		WR <= '1';
		DIN <= x"00000004";
		wait until rising_edge(CLK);

		WR <= '0';
		DIN <= x"00000000";
		wait;
	end process;

	RD <= not EMPTY;

-- 	process
-- 	begin
-- 		RD <= '0';
-- 		wait until rising_edge(CLK) and RST = '0';
-- 
-- 		wait until rising_edge(CLK);
-- 		wait until rising_edge(CLK);
-- 		wait until rising_edge(CLK);
-- 
-- 		while true loop
-- 			if EMPTY = '0' then
-- 				RD <= '1';
-- 			else
-- 				RD <= '0';
-- 			end if;
-- 			wait until rising_edge(CLK);
-- 		end loop;
-- 	end process;

end testbench;
