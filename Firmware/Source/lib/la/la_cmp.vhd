library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.la_pkg.all;

entity la_cmp is
	generic(
		D_WIDTH			: integer := 32
	);
	port(
		CLK				: in std_logic;

		MODE				: in std_logic_vector(2 downto 0);
		THR				: in std_logic_vector(D_WIDTH-1 downto 0);
		DIN				: in std_logic_vector(D_WIDTH-1 downto 0);

		TRG				: out std_logic
	);
end la_cmp;

architecture synthesis of la_cmp is
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			TRG <= '0';

			case MODE is
				when LA_CMP_MODE_LT =>
					if DIN < THR then
						TRG <= '1';
					end if;
				when LA_CMP_MODE_GT =>
					if DIN > THR then
						TRG <= '1';
					end if;
				when LA_CMD_MODE_EQ =>
					if DIN = THR then
						TRG <= '1';
					end if;
				when LA_CMD_MODE_NE =>
					if DIN /= THR then
						TRG <= '1';
					end if;
				when LA_CMD_MODE_DC =>
					TRG <= '1';
				when others =>
					null;
			end case;
		end if;
	end process;

end synthesis;
