library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;
use std.standard.all;

library utils;
use utils.utils_pkg.all;

use work.fe_rich_pkg.all;

entity fe_rich_tb is
end fe_rich_tb;

architecture testbench of fe_rich_tb is
	signal CONFIG_DONE		: std_logic := '0';

	signal GLOBAL_CLK			: std_logic := '0';
	signal SYNC					: std_logic := '0';
	signal TRIG					: std_logic := '0';
	signal VMEBUS_DS_N		: std_logic_vector(1 downto 0) := (others=>'0');
	signal VMEBUS_AS_N		: std_logic := '0';
	signal VMEBUS_W_N			: std_logic := '0';
	signal VMEBUS_AM			: std_logic_vector(5 downto 0) := (others=>'0');
	signal VMEBUS_D			: std_logic_vector(31 downto 0) := (others=>'0');
	signal VMEBUS_A			: std_logic_vector(31 downto 0) := (others=>'0');
	signal VMEBUS_BERR_N		: std_logic := '0';
	signal VMEBUS_DTACK_N	: std_logic := '0';
	signal TDC_IN				: std_logic_vector(191 downto 0) := (others=>'0');
begin

	fe_rich_wrapper_inst: fe_rich_wrapper
		port map(
			GLOBAL_CLK		=> GLOBAL_CLK,
			SYNC				=> SYNC,
			TRIG				=> TRIG,
			VMEBUS_DS_N		=> VMEBUS_DS_N,
			VMEBUS_AS_N		=> VMEBUS_AS_N,
			VMEBUS_W_N		=> VMEBUS_W_N,
			VMEBUS_AM		=> VMEBUS_AM,
			VMEBUS_D			=> VMEBUS_D,
			VMEBUS_A			=> VMEBUS_A,
			VMEBUS_BERR_N	=> VMEBUS_BERR_N,
			VMEBUS_DTACK_N	=> VMEBUS_DTACK_N,
			TDC_IN			=> TDC_IN
		);
	
	process
	begin
		GLOBAL_CLK <= '0';
		wait for 4 ns;
		GLOBAL_CLK <= '1';
		wait for 4 ns;
	end process;

	process
	begin
		wait until CONFIG_DONE = '1';

		wait for 5 us;

-- 		while true loop
-- 			for I in 0 to 15 loop
-- 				wait until rising_edge(GLOBAL_CLK);
-- 				TRIG <= transport '1' after 800 ns;
-- 				TRIG <= transport '0' after 808 ns;
-- 				wait for 0 ns;
-- 				TDC_IN(0) <= transport '1' after I*1 ns;
-- 				TDC_IN(0) <= transport '0' after 100 ns;
-- 				wait for 20 us;
-- 			end loop;
-- 		end loop;

		while true loop
			wait until rising_edge(GLOBAL_CLK);
			TRIG <= transport '1' after 800 ns;
			TRIG <= transport '0' after 808 ns;
			TDC_IN <= transport (others=>'1') after 0 ns;
			TDC_IN <= transport (others=>'0') after 100 ns;
			wait for 20 us;
		end loop;

		wait;
	end process;

	process
		constant EVENT_FILENAME			: string := "rich_events.txt";
		constant RICH_BASE				: std_logic_vector(15 downto 0) := x"0000";

		constant AM_A24_NP_DATA			: std_logic_vector(5 downto 0) := "111001";
		constant AM_A24_SP_DATA			: std_logic_vector(5 downto 0) := "111101";
		constant AM_A32_NP_DATA			: std_logic_vector(5 downto 0) := "001001";
		constant AM_A32_SP_DATA			: std_logic_vector(5 downto 0) := "001101";

		constant pl							: integer := 825;
		constant ptw						: integer := 100;
		constant nsa						: integer := 32;--6;
		constant nsb						: integer := 6;--3;
		constant ptw_max_buf				: integer := 2016/(ptw+8);
		constant ptw_last_adr			: integer := ptw_max_buf*(ptw+8)-1;

		variable DataBufferLen			: integer := 0;
		variable DataBuffer				: slv32a(0 to 9999) := (others=>x"00000000");
		variable Data						: std_logic_vector(31 downto 0) := x"00000000";
		variable addr						: std_logic_vector(15 downto 0) := x"0000";
		variable word_cnt					: integer := 0;

		file EventFile						: text;
		variable fstatus					: file_open_status;
		variable buf						: line;
		variable word						: std_logic_vector(31 downto 0) := x"00000000";
		variable tag						: std_logic_vector(3 downto 0) := "0000";
		variable tag_idx					: integer := 0;
	
		procedure VMEWrite32(Address : in std_logic_vector(31 downto 0); Data : in std_logic_vector(31 downto 0)) is
			variable I 		: integer;
		begin
			VMEBUS_A <= Address;
			VMEBUS_D <= Data;
			VMEBUS_AM <= AM_A24_NP_DATA;
			VMEBUS_W_N <= '0';
			wait for 10 ns;
			
			VMEBUS_AS_N <= '0';
			wait for 5 ns;
			VMEBUS_DS_N <= "00";
			wait for 5 ns;			

			I := 0;
			while (I < 1000) and To_X01(VMEBUS_DTACK_N) = '1' and To_X01(VMEBUS_BERR_N) = '1' loop
				I := I + 1;
				wait for 5 ns;
			end loop;
			
			VMEBUS_D <= (others=>'H');
			VMEBUS_AS_N <= '1';
			VMEBUS_DS_N <= "11";
			
			wait until To_X01(VMEBUS_DTACK_N) = '1';
			wait for 60 ns;
		end procedure;
		
		procedure VMERead32(Address : in std_logic_vector(31 downto 0); Data : out std_logic_vector(31 downto 0)) is
			variable I 		: integer;
		begin
			VMEBUS_A <= Address;
			VMEBUS_AM <= AM_A24_NP_DATA;
			VMEBUS_W_N <= '1';
			wait for 10 ns;
			
			VMEBUS_AS_N <= '0';
			wait for 5 ns;
			VMEBUS_DS_N <= "00";
			wait for 5 ns;

			I := 0;
			while (I < 1000) and To_X01(VMEBUS_DTACK_N) = '1' and To_X01(VMEBUS_BERR_N) = '1' loop
				I := I + 1;
				wait for 5 ns;
			end loop;
			
			Data := VMEBUS_D;
			VMEBUS_AS_N <= '1';
			VMEBUS_DS_N <= "11";
			
			wait until To_X01(VMEBUS_DTACK_N) = '1';
			wait for 60 ns;
		end procedure;

		function to_string (value     : std_logic_vector) return STRING is
			alias ivalue    : std_logic_vector(1 to value'length) is value;
			variable result : STRING(1 to value'length);
		begin
			for i in ivalue'range loop
					if iValue(i) = '0' then
						result(i) := '0';
					elsif iValue(i) = '1' then
						result(i) := '1';
					else
						result(i) := 'X';
					end if;
				end loop;
				return result;
		end function to_string;
	begin
		CONFIG_DONE <= '0';

		SYNC <= '1';

		VMEBUS_DS_N <= "11";
		VMEBUS_AS_N <= '1';
		VMEBUS_W_N <= '1';
		VMEBUS_AM <= (others=>'1');
		VMEBUS_D <= (others=>'H');
		VMEBUS_A <= (others=>'H');
		VMEBUS_BERR_N <= 'H';
		VMEBUS_DTACK_N <= 'H';	

		wait for 2 us;

		VMEWrite32(RICH_BASE & x"1000", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1004", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1008", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"100C", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1200", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1204", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1208", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"120C", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1400", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1404", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"1408", x"0000FFFF");					-- disable all channels
		VMEWrite32(RICH_BASE & x"140C", x"0000FFFF");					-- disable all channels

		VMEWrite32(RICH_BASE & x"1000", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1004", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1008", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"100C", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1200", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1204", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1208", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"120C", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1400", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1404", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"1408", x"00000000");					-- enable all channels
		VMEWrite32(RICH_BASE & x"140C", x"00000000");					-- enable all channels

		VMEWrite32(RICH_BASE & x"023C", x"00000000");					-- set trig 0

		VMEWrite32(RICH_BASE & x"0240", x"00000001");					-- set sync 1
		VMEWrite32(RICH_BASE & x"0240", x"00000000");					-- set sync 0

		VMEWrite32(RICH_BASE & x"2000", x"00000080");					-- set lookback = 128*8ns
		VMEWrite32(RICH_BASE & x"2004", x"00000064");					-- set window = 100*8ns
		VMEWrite32(RICH_BASE & x"2008", x"00000001");					-- set block size = 1 event

		VMEWrite32(RICH_BASE & x"0000", x"00000001");					-- set soft reset 1
		VMEWrite32(RICH_BASE & x"0000", x"00000000");					-- set soft reset 0

		wait until rising_edge(GLOBAL_CLK);
		SYNC <= '0';

		VMEWrite32(RICH_BASE & x"023C", x"00000005");					-- set trig source to input 1

		wait for 10 us;

		CONFIG_DONE <= '1';

		DataBufferLen := 0;
		file_open(fstatus, EventFile, EVENT_FILENAME, write_mode);
		while true loop
			VMERead32(RICH_BASE & x"2024", Data);
			
			word_cnt := to_integer(unsigned(Data));

			for I in 1 to word_cnt loop
				VMERead32(RICH_BASE & x"2080", Data);

				if (Data(31 downto 27) = "10010") and (DataBufferLen > 0) then
					RICHDecodeEvent(EventFile, DataBuffer, DataBufferLen);
					DataBufferLen := 0;
				end if;

report "rd = " & to_string(Data) severity note;

				if DataBufferLen < DataBuffer'length then
					DataBuffer(DataBufferLen) := Data;
					DataBufferLen := DataBufferLen + 1;
				end if;

			end loop;
		end loop;

		wait;		
	end process;

end testbench;
