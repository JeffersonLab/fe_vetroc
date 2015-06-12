library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity serdeslatency is
	port(
		CLK				: in std_logic;
		SYNC				: in std_logic;
		RX_SRC_RDY_N	: in std_logic;
		LATENCY			: out std_logic_vector(15 downto 0)
	);
end serdeslatency;

architecture Synthesis of serdeslatency is
	signal SYNC_Q	: std_logic;
	signal CNT		: std_logic_vector(15 downto 0);
	signal CNT_OVF	: std_logic;
	signal CNT_EN	: std_logic;
begin

	LATENCY <= CNT;

	CNT_OVF <= '1' when CNT = conv_std_logic_vector(2**CNT'length-1, CNT'length) else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SYNC = '1' then
				CNT_EN <= '1';
			elsif RX_SRC_RDY_N = '0' then
				CNT_EN <= '0';
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if SYNC = '1' then
				CNT <= (others=>'0');
			elsif (CNT_EN = '1') and (CNT_OVF = '0') then
				CNT <= CNT + 1;
			end if;
		end if;
	end process;

end Synthesis;
