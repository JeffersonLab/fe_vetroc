library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic(
		LEN	: integer := 32
	);
	port(
		CLK	: in std_logic;
		RST	: in std_logic;
		EN		: in std_logic;
		INC	: in std_logic;
		CNT	: out std_logic_vector(LEN-1 downto 0)
	);
end counter;

architecture synthesis of counter is
	signal RST_Q		: std_logic_vector(1 downto 0) := (others=>'0');
	signal EN_Q			: std_logic_vector(1 downto 0) := (others=>'0');
	signal INC_Q		: std_logic_vector(1 downto 0) := (others=>'0');
	signal CNT_I		: std_logic_vector(LEN-1 downto 0) := (others=>'0');
	signal CNT_I_OVF	: std_logic := '0';
	signal CNT_I_INC	: std_logic := '0';
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			RST_Q <= RST_Q(RST_Q'left-1 downto 0) & RST;
			EN_Q <= EN_Q(EN_Q'left-1 downto 0) & EN;
			INC_Q <= INC_Q(INC_Q'left-1 downto 0) & INC;
		end if;
	end process;

	CNT <= CNT_I;
	CNT_I_INC <= EN_Q(EN_Q'left) and INC_Q(INC_Q'left);
	CNT_I_OVF <= '1' when CNT_I = conv_std_logic_vector(2**CNT_I'length-1, CNT_I'length) else '0';

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST_Q(RST_Q'left) = '1' then
				CNT_I <= (others=>'0');
			elsif (CNT_I_INC = '1') and (CNT_I_OVF = '0') then
				CNT_I <= CNT_I + 1;
			end if; 
		end if;
	end process;

end synthesis;
