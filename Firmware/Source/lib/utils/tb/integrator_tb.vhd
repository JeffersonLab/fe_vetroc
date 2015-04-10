library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;

entity integrator_tb is
	generic(
		D_WIDTH		: integer := 32;
		P_WIDTH		: integer := 4
	);
end integrator_tb;

architecture testbench of integrator_tb is
	component integrator is
		generic(
			D_WIDTH		: integer := 32;
			P_WIDTH		: integer := 16
		);
		port(
			CLK		: in std_logic;
			WIDTH		: in std_logic_vector(P_WIDTH-1 downto 0);
			DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
			DIN_RDY	: in std_logic;
			DOUT		: out std_logic_vector(D_WIDTH+P_WIDTH-1 downto 0);
			DOUT_RDY	: out std_logic
		);
	end component;

	constant CLK_PERIOD	: time := 5 ns;

	signal CLK			: std_logic;
	signal WIDTH		: std_logic_vector(P_WIDTH-1 downto 0);
	signal DIN			: std_logic_vector(D_WIDTH-1 downto 0);
	signal DIN_RDY		: std_logic;
	signal DOUT			: std_logic_vector(D_WIDTH+P_WIDTH-1 downto 0);
	signal DOUT_RDY	: std_logic;
begin

	integrator_inst: integrator
		generic map(
			D_WIDTH		=> D_WIDTH,
			P_WIDTH		=> P_WIDTH
		)
		port map(
			CLK			=> CLK,
			WIDTH			=> WIDTH,
			DIN			=> DIN,
			DIN_RDY		=> DIN_RDY,
			DOUT			=> DOUT,
			DOUT_RDY		=> DOUT_RDY
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
		for W in 0 to 2**P_WIDTH-1 loop
			WIDTH <= conv_std_logic_vector(W, WIDTH'length);
			DIN <= conv_std_logic_vector(0, DIN'length);
			DIN_RDY <= '0';

			wait for 2**(P_WIDTH+1) * CLK_PERIOD;
			wait until rising_edge(CLK);

			for I in 0 to 2**P_WIDTH-1 loop
				DIN_RDY <= '1';
				DIN <= conv_std_logic_vector(I, DIN'length);
				wait until rising_edge(CLK);
			end loop;

			DIN <= conv_std_logic_vector(0, DIN'length);
			DIN_RDY <= '0';
			wait for 2**(P_WIDTH+1) * CLK_PERIOD;
			wait until rising_edge(CLK);
		end loop;
		
		wait;
	end process;

end testbench;
