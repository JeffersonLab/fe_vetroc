LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity FD is
	generic(
		INIT	: std_logic := '0'
	);
	port(
		Q		: out std_logic;
		C		: in std_logic;
		D		: in std_logic
	);
end FD;

ARCHITECTURE fd_arch OF FD IS
	SIGNAL Q_I	: std_logic := INIT;
BEGIN

	Q <= Q_I;

	PROCESS(C)
	BEGIN
		IF rising_edge(C) THEN
			Q_I <= D;
		END IF;
	END PROCESS;
	
END fd_arch;