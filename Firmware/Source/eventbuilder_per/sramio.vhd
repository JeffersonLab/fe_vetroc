library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SramIo is
	port(
		CLK			: in std_logic;
		
		SRAM_D		: inout std_logic_vector(35 downto 0);
		SRAM_A		: out std_logic_vector(18 downto 0);
		SRAM_RW		: out std_logic;
		SRAM_NOE		: out std_logic;
		SRAM_CS		: out std_logic;
		SRAM_ADV		: out std_logic;
		
		D_I			: out std_logic_vector(35 downto 0);
		D_O			: in std_logic_vector(35 downto 0);
		D_T			: in std_logic;
		A				: in std_logic_vector(18 downto 0);
		RNW			: in std_logic
	);
end SramIo;

architecture Synthesis of SramIo is
	signal D_O_Q	: std_logic_vector(35 downto 0);
	signal D_T_Q0	: std_logic_vector(35 downto 0);
	signal D_T_Q1	: std_logic_vector(35 downto 0);
	signal D_T_Q2	: std_logic_vector(35 downto 0);
	
	attribute iob					: string;
	attribute iob of SRAM_RW	: signal is "TRUE";
	attribute iob of SRAM_A		: signal is "TRUE";
	attribute iob of D_I			: signal is "TRUE";
	attribute iob of D_O_Q		: signal is "TRUE";
	attribute iob of D_T_Q2		: signal is "TRUE";
begin

	SRAM_ADV <= '0';
	SRAM_CS <= '1';
	SRAM_NOE <= '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			SRAM_RW <= RNW;
			SRAM_A <= A;
			D_I <= transport SRAM_D after 100 ps;
			D_O_Q <= D_O;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			D_T_Q0 <= (others=>D_T);
			D_T_Q1 <= D_T_Q0;
			D_T_Q2 <= D_T_Q1;
		end if;
	end process;

	
	DIO_gen: for I in 0 to 35 generate
		SRAM_D(I) <= D_O_Q(I) when D_T_Q2(I) = '0' else 'Z';		
	end generate;

end Synthesis;
