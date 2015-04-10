library ieee;
use ieee.std_logic_1164.all;

entity log32b_10b is
	port(
		CLK			: in std_logic;
		
		VAL_IN_EN	: in std_logic;
		VAL_IN		: in std_logic_vector(31 downto 0);
		VAL_OUT_EN	: out std_logic;
		VAL_OUT		: out std_logic_vector(9 downto 0)
	);
end log32b_10b;

architecture Synthesis of log32b_10b is
	signal I_PART		: std_logic_vector(4 downto 0);
	signal F_PART		: std_logic_vector(4 downto 0);
	signal F_PART_LUT	: std_logic_vector(5 downto 0);
begin

	F_PART_LUT <= VAL_IN(30 downto 25)			when VAL_IN(31) = '1' else
	              VAL_IN(29 downto 24)			when VAL_IN(30) = '1' else
	              VAL_IN(28 downto 23)			when VAL_IN(29) = '1' else
	              VAL_IN(27 downto 22)			when VAL_IN(28) = '1' else
	              VAL_IN(26 downto 21)			when VAL_IN(27) = '1' else
	              VAL_IN(25 downto 20)			when VAL_IN(26) = '1' else
	              VAL_IN(24 downto 19)			when VAL_IN(25) = '1' else
	              VAL_IN(23 downto 18)			when VAL_IN(24) = '1' else
	              VAL_IN(22 downto 17)			when VAL_IN(23) = '1' else
	              VAL_IN(21 downto 16)			when VAL_IN(22) = '1' else
	              VAL_IN(20 downto 15)			when VAL_IN(21) = '1' else
	              VAL_IN(19 downto 14)			when VAL_IN(20) = '1' else
	              VAL_IN(18 downto 13)			when VAL_IN(19) = '1' else
	              VAL_IN(17 downto 12)			when VAL_IN(18) = '1' else
	              VAL_IN(16 downto 11)			when VAL_IN(17) = '1' else
	              VAL_IN(15 downto 10)			when VAL_IN(16) = '1' else
	              VAL_IN(14 downto 9)			when VAL_IN(15) = '1' else
	              VAL_IN(13 downto 8)			when VAL_IN(14) = '1' else
	              VAL_IN(12 downto 7)			when VAL_IN(13) = '1' else
	              VAL_IN(11 downto 6)			when VAL_IN(12) = '1' else
	              VAL_IN(10 downto 5)			when VAL_IN(11) = '1' else
	              VAL_IN(9 downto 4)			   when VAL_IN(10) = '1' else
	              VAL_IN(8 downto 3)			   when VAL_IN(9) = '1' else
	              VAL_IN(7 downto 2)				when VAL_IN(8) = '1' else
	              VAL_IN(6 downto 1)				when VAL_IN(7) = '1' else
	              VAL_IN(5 downto 0)				when VAL_IN(6) = '1' else
	              VAL_IN(4 downto 0)&"0"		when VAL_IN(5) = '1' else
	              VAL_IN(3 downto 0)&"00"		when VAL_IN(4) = '1' else
	              VAL_IN(2 downto 0)&"000"		when VAL_IN(3) = '1' else
	              VAL_IN(1 downto 0)&"0000"	when VAL_IN(2) = '1' else
	              VAL_IN(0 downto 0)&"00000"	when VAL_IN(1) = '1' else
			      "000000";
	
	F_PART <= "00000" when F_PART_LUT = "000000" else
              "00000" when F_PART_LUT = "000001" else
              "00001" when F_PART_LUT = "000010" else
              "00010" when F_PART_LUT = "000011" else
              "00010" when F_PART_LUT = "000100" else
              "00011" when F_PART_LUT = "000101" else
              "00100" when F_PART_LUT = "000110" else
              "00100" when F_PART_LUT = "000111" else
              "00101" when F_PART_LUT = "001000" else
              "00110" when F_PART_LUT = "001001" else
              "00110" when F_PART_LUT = "001010" else
              "00111" when F_PART_LUT = "001011" else
              "00111" when F_PART_LUT = "001100" else
              "01000" when F_PART_LUT = "001101" else
              "01001" when F_PART_LUT = "001110" else
              "01001" when F_PART_LUT = "001111" else
              "01010" when F_PART_LUT = "010000" else
              "01010" when F_PART_LUT = "010001" else
              "01011" when F_PART_LUT = "010010" else
              "01100" when F_PART_LUT = "010011" else
              "01100" when F_PART_LUT = "010100" else
              "01101" when F_PART_LUT = "010101" else
              "01101" when F_PART_LUT = "010110" else
              "01110" when F_PART_LUT = "010111" else
              "01110" when F_PART_LUT = "011000" else
              "01111" when F_PART_LUT = "011001" else
              "01111" when F_PART_LUT = "011010" else
              "10000" when F_PART_LUT = "011011" else
              "10000" when F_PART_LUT = "011100" else
              "10001" when F_PART_LUT = "011101" else
              "10001" when F_PART_LUT = "011110" else
              "10010" when F_PART_LUT = "011111" else
              "10010" when F_PART_LUT = "100000" else
              "10011" when F_PART_LUT = "100001" else
              "10011" when F_PART_LUT = "100010" else
              "10100" when F_PART_LUT = "100011" else
              "10100" when F_PART_LUT = "100100" else
              "10101" when F_PART_LUT = "100101" else
              "10101" when F_PART_LUT = "100110" else
              "10101" when F_PART_LUT = "100111" else
              "10110" when F_PART_LUT = "101000" else
              "10110" when F_PART_LUT = "101001" else
              "10111" when F_PART_LUT = "101010" else
              "10111" when F_PART_LUT = "101011" else
              "11000" when F_PART_LUT = "101100" else
              "11000" when F_PART_LUT = "101101" else
              "11001" when F_PART_LUT = "101110" else
              "11001" when F_PART_LUT = "101111" else
              "11001" when F_PART_LUT = "110000" else
              "11010" when F_PART_LUT = "110001" else
              "11010" when F_PART_LUT = "110010" else
              "11011" when F_PART_LUT = "110011" else
              "11011" when F_PART_LUT = "110100" else
              "11011" when F_PART_LUT = "110101" else
              "11100" when F_PART_LUT = "110110" else
              "11100" when F_PART_LUT = "110111" else
              "11101" when F_PART_LUT = "111000" else
              "11101" when F_PART_LUT = "111001" else
              "11101" when F_PART_LUT = "111010" else
              "11110" when F_PART_LUT = "111011" else
              "11110" when F_PART_LUT = "111100" else
              "11110" when F_PART_LUT = "111101" else
              "11111" when F_PART_LUT = "111110" else
              "11111";

	I_PART <= "11111" when VAL_IN(31) = '1' else
	          "11110" when VAL_IN(30) = '1' else
	          "11101" when VAL_IN(29) = '1' else
	          "11100" when VAL_IN(28) = '1' else
	          "11011" when VAL_IN(27) = '1' else
	          "11010" when VAL_IN(26) = '1' else
	          "11001" when VAL_IN(25) = '1' else
	          "11000" when VAL_IN(24) = '1' else
	          "10111" when VAL_IN(23) = '1' else
	          "10110" when VAL_IN(22) = '1' else
	          "10101" when VAL_IN(21) = '1' else
	          "10100" when VAL_IN(20) = '1' else
	          "10011" when VAL_IN(19) = '1' else
	          "10010" when VAL_IN(18) = '1' else
	          "10001" when VAL_IN(17) = '1' else
	          "10000" when VAL_IN(16) = '1' else
	          "01111" when VAL_IN(15) = '1' else
	          "01110" when VAL_IN(14) = '1' else
	          "01101" when VAL_IN(13) = '1' else
	          "01100" when VAL_IN(12) = '1' else
	          "01011" when VAL_IN(11) = '1' else
	          "01010" when VAL_IN(10) = '1' else
	          "01001" when VAL_IN(9) = '1' else
	          "01000" when VAL_IN(8) = '1' else
	          "00111" when VAL_IN(7) = '1' else
	          "00110" when VAL_IN(6) = '1' else
	          "00101" when VAL_IN(5) = '1' else
	          "00100" when VAL_IN(4) = '1' else
	          "00011" when VAL_IN(3) = '1' else
	          "00010" when VAL_IN(2) = '1' else
	          "00001" when VAL_IN(1) = '1' else
			    "00000";

	process(CLK)
	begin
		if rising_edge(CLK) then
			VAL_OUT_EN <= VAL_IN_EN;
			VAL_OUT <= I_PART & F_PART;
		end if;
	end process;

end Synthesis;
