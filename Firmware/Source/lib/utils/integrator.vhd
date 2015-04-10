library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;

entity integrator is
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
end integrator;

architecture synthesis of integrator is
	signal DIN_DLY			: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	signal DIN_RDY_DLY	: std_logic := '0';
	signal DOUT_i			: std_logic_vector(D_WIDTH+P_WIDTH-1 downto 0) := (others=>'0');
	signal DOUT_RDY_i		: std_logic := '0';
	signal DELAYRAM_I		: std_logic_vector(D_WIDTH downto 0) := (others=>'0');
	signal DELAYRAM_O		: std_logic_vector(D_WIDTH downto 0) := (others=>'0');
	signal DIN_Q0			: std_logic_vector(D_WIDTH downto 0) := (others=>'0');
	signal DIN_Q1			: std_logic_vector(D_WIDTH downto 0) := (others=>'0');
	signal DIN_REF			: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	signal DIN_RDY_REF	: std_logic := '0';
begin

	--...would like to make this method adjustable while in operation (i.e. maintain latency & product correct integral after change)...
	--   need to detect parameter change and zero integral and delay ram
	DOUT <= DOUT_i;
	DOUT_RDY <= DOUT_RDY_i;

	-- DIN_RDY must stay low for D_WIDTH cycles to clear integrator contents initially
	DELAYRAM_I <= '1' & DIN when DIN_RDY = '1' else (others=>'0');

	delay_ram_inst: delay_ram
		generic map(
			D_WIDTH	=> D_WIDTH+1,
			A_WIDTH	=> P_WIDTH
		)
		port map(
			CLK		=> CLK,
			DELAY		=> WIDTH,
			DIN		=> DELAYRAM_I,
			DOUT		=> DELAYRAM_O
		);

	process(CLK)
	begin
		if rising_edge(CLK) then
			DIN_RDY_DLY <= DELAYRAM_O(D_WIDTH);
			DIN_DLY <= DELAYRAM_O(D_WIDTH-1 downto 0);

			-- Compensate for delay_ram minimum insertion delay
			DIN_Q0 <= DIN_RDY & DIN;
			DIN_Q1 <= DIN_Q0;
			DIN_REF <= DIN_Q1(D_WIDTH-1 downto 0);
			DIN_RDY_REF <= DIN_Q1(D_WIDTH);

			if (DIN_RDY_REF = '1') and (DIN_RDY_DLY = '0') then
				DOUT_i <= DOUT_i + DIN_REF;
				DOUT_RDY_i <= '1';
			elsif (DIN_RDY_REF = '1') and (DIN_RDY_DLY = '1') then
				DOUT_i <= DOUT_i + DIN_REF - DIN_DLY;
				DOUT_RDY_i <= '1';
			else
				DOUT_i <= (others=>'0');
				DOUT_RDY_i <= '0';
			end if;
		end if;
	end process;

end synthesis;
