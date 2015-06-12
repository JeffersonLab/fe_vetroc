LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity FDR is
	generic(
		INIT	: std_logic := '0'
	);
	port(
		Q		: out std_logic;
		C		: in std_logic;
		D		: in std_logic;
		R		: in std_logic
	);
end FDR;


ARCHITECTURE fdr_arch OF FDR IS
  signal Q_I    : std_logic := INIT;
BEGIN

  Q <= Q_I;

	PROCESS(C)
	BEGIN
		IF rising_edge(C) THEN
			IF R = '1' THEN
				Q_I <= '0';
			ELSE
				Q_I <= D;
			END IF;
		END IF;
	END PROCESS;
	
END fdr_arch;