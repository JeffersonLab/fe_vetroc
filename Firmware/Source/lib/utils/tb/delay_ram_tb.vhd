library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;

entity delay_ram_tb is
	generic(
		D_WIDTH		: integer := 32;
		A_WIDTH		: integer := 8
	);
end delay_ram_tb;

architecture testbench of delay_ram_tb is
	component delay_ram is
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
	end component;

	constant CLK_PERIOD	: time := 5 ns;

	signal CLK			: std_logic;
	signal DELAY		: std_logic_vector(A_WIDTH-1 downto 0);
	signal DIN			: std_logic_vector(D_WIDTH-1 downto 0);
	signal DOUT			: std_logic_vector(D_WIDTH-1 downto 0);
begin

	delay_ram_inst: delay_ram
		generic map(
			D_WIDTH		=> D_WIDTH,
			A_WIDTH		=> A_WIDTH
		)
		port map(
			CLK		=> CLK,
			DELAY		=> DELAY,
			DIN		=> DIN,
			DOUT		=> DOUT
		);

	process
	begin
		CLK <= '1';
		wait for CLK_PERIOD / 2;
		CLK <= '0';
		wait for CLK_PERIOD / 2;
	end process;

	process
	begin
		for D in 0 to 2**DELAY'length-1 loop
			DELAY <= conv_std_logic_vector(D, DELAY'length);
			DIN <= conv_std_logic_vector(0, DIN'length);

			-- flush delay memory
			wait for 2**(A_WIDTH+1) * CLK_PERIOD;
			wait until rising_edge(CLK);

			DIN <= conv_std_logic_vector(D+1, DIN'length);

			for I in 0 to 2**(A_WIDTH+1) loop
				wait for 1 ns;

				if DOUT /= conv_std_logic_vector(0, DOUT'length) then
					if DOUT = conv_std_logic_vector(D+1, DIN'length) then
						report "Delay setting of " & integer'image(D) & " has actual delay = " & integer'image(I) severity note;
					else
						report "Delay setting of " & integer'image(D) & " failed - invalid output seen" severity error;
					end if;

					exit;
				end if;

				wait until rising_edge(CLK);
			end loop;

		end loop;

		wait;
	end process;

end testbench;
