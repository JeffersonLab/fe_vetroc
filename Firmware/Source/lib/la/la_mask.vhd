library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity la_mask is
	generic(
		D_WIDTH			: integer := 32
	);
	port(
		CLK				: in std_logic;

		EN					: in std_logic_vector(D_WIDTH-1 downto 0);
		VAL				: in std_logic_vector(D_WIDTH-1 downto 0);
		DIN				: in std_logic_vector(D_WIDTH-1 downto 0);

		TRG				: out std_logic
	);
end la_mask;

architecture synthesis of la_mask is
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (EN and DIN) = (EN and VAL) then
				TRG <= '1';
			else
				TRG <= '0';
			end if;
		end if;
	end process;

end synthesis;
