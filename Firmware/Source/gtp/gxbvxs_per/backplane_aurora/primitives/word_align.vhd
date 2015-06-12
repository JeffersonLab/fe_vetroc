library ieee;
use ieee.std_logic_1164.all;

entity word_align is
	generic(
		align_pattern1			: std_logic_vector(9 downto 0) := "0101111100";	-- K28.5-
		align_pattern2			: std_logic_vector(9 downto 0) := "1010000011"	-- K28.5+
	);
	port(
		clk						: in std_logic;
		rx_enapatternalign	: in std_logic;
		rx_datain				: in std_logic_vector(19 downto 0);
		rx_dataout				: out std_logic_vector(19 downto 0);
		rx_patterndetect		: out std_logic_vector(1 downto 0);
		rx_syncstatus			: out std_logic_vector(1 downto 0)
	);
end word_align;

architecture synthesis of word_align is
	signal word_buf						: std_logic_vector(39 downto 0);
	signal align_pos						: integer range 0 to 63 := 29;
	signal do_align						: std_logic;
	signal rx_enapatternalign_q		: std_logic := '0';
	signal rx_patterndetect_i			: std_logic_vector(1 downto 0) := "00";
	signal rx_syncstatus_i				: std_logic_vector(1 downto 0) := "00";
	signal rx_enapatternalign_start	: std_logic;
begin

	rx_patterndetect <= rx_patterndetect_i;
	rx_syncstatus <= rx_syncstatus_i;
	rx_enapatternalign_start <= rx_enapatternalign and not rx_enapatternalign_q;

	process(clk)
	begin
		if rising_edge(clk) then
			rx_enapatternalign_q <= rx_enapatternalign;
			word_buf <= rx_datain & word_buf(39 downto 20);

			if rx_enapatternalign_start = '1' then
				do_align <= '1';
				rx_syncstatus_i <= "00";
			end if; 			

			if do_align = '1' then
				for I in 29 downto 10 loop
					if (word_buf(I downto I-9) = align_pattern1) or (word_buf(I downto I-9) = align_pattern2) then
						align_pos <= I;
						do_align <= '0';
						rx_syncstatus_i <= "11";
					end if;
				end loop;
			end if;

			if (word_buf(align_pos downto align_pos-9) = align_pattern1) or (word_buf(align_pos downto align_pos-9) = align_pattern2) then
				rx_patterndetect_i(0) <= '1';
			else
				rx_patterndetect_i(0) <= '0';
			end if;

			if (word_buf(align_pos+10 downto align_pos+1) = align_pattern1) or (word_buf(align_pos+10 downto align_pos+1) = align_pattern2) then
				rx_patterndetect_i(1) <= '1';
			else
				rx_patterndetect_i(1) <= '0';
			end if;

			rx_dataout <= word_buf(align_pos+10 downto align_pos-9);

		end if;
	end process;

end synthesis;
