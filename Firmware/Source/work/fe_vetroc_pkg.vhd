library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use std.standard.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

package fe_vetroc_pkg is
 	constant PER_ID_CLKRST				: integer := 0;
	constant PER_ID_SD					: integer := 1;
	constant PER_ID_TDCPROC0			: integer := 2;
	constant PER_ID_TDCPROC1			: integer := 3;
	constant PER_ID_TDCPROC2			: integer := 4;
	constant PER_ID_TDCPROC3			: integer := 5;
	constant PER_ID_TDCPROC4			: integer := 6;
	constant PER_ID_TDCPROC5			: integer := 7;
	constant PER_ID_TDCPROC6			: integer := 8;
	constant PER_ID_TDCPROC7			: integer := 9;
	constant PER_ID_EVTBUILDER			: integer := 10;

	-- BASE_ADDR, BASE_MASK, USER_MASK
	constant PER_ADDR_INFO_CFG	: PER_ADDR_INFO_ARRAY := (
		(x"0000", x"FF00", x"00FF"),	-- PER_ID_CLKRST
		(x"0200", x"FE00", x"01FF"),	-- PER_ID_SD
		(x"1000", x"FF00", x"00FF"),	-- PER_ID_TDCPROC0
		(x"1100", x"FF00", x"00FF"),	-- PER_ID_TDCPROC1
		(x"1200", x"FF00", x"00FF"),	-- PER_ID_TDCPROC2
		(x"1300", x"FF00", x"00FF"),	-- PER_ID_TDCPROC3
		(x"1400", x"FF00", x"00FF"),	-- PER_ID_TDCPROC4
		(x"1500", x"FF00", x"00FF"),	-- PER_ID_TDCPROC5
		(x"1600", x"FF00", x"00FF"),	-- PER_ID_TDCPROC6
		(x"1700", x"FF00", x"00FF"),	-- PER_ID_TDCPROC7
		(x"2000", x"FF00", x"00FF")	-- PER_ID_EVTBUILDER
	);

-- synthesis translate_off
	component fe_vetroc_wrapper is
		port(
			-- Trigger Interface
			GLOBAL_CLK		: in std_logic;
			SYNC				: in std_logic;
			TRIG				: in std_logic;

			-- VME Bus Interface
			VMEBUS_DS_N		: in std_logic_vector(1 downto 0);
			VMEBUS_AS_N		: in std_logic;
			VMEBUS_W_N		: in std_logic;
			VMEBUS_AM		: in std_logic_vector(5 downto 0);
			VMEBUS_D			: inout std_logic_vector(31 downto 0);
			VMEBUS_A			: inout std_logic_vector(31 downto 0);
			VMEBUS_BERR_N	: inout std_logic;
			VMEBUS_DTACK_N	: inout std_logic;
			
			-- TDC Inputs
			TDC_IN			: in std_logic_vector(191 downto 0)
		);
	end component;

	procedure VETROCDecodeEvent(
 			file EventFile 		: text;
 			variable EventData	: slv32a;
 			variable EventLen		: integer
		);
-- synthesis translate_on

end fe_vetroc_pkg;

package body fe_vetroc_pkg is

-- synthesis translate_off
	procedure VETROCDecodeEvent(
 			file EventFile 		: text;
 			variable EventData	: slv32a;
 			variable EventLen		: integer
		) is
		variable last_word	: std_logic_vector(31 downto 0) := x"00000000";
		variable word			: std_logic_vector(31 downto 0) := x"00000000";
		variable tag			: std_logic_vector(3 downto 0) := "0000";
		variable tag_idx		: integer := 0;
		variable buf			: line;
	begin
		write(buf, string'("VETROC Event Data Length="));
		write(buf, EventLen);
		writeline(EventFile, buf);

		for I in 0 to EventLen-1 loop
			last_word := word;
			word := EventData(I);
			
			if word(31) = '1' then
				tag := word(30 downto 27);
				tag_idx := 0;
			else
				tag_idx := tag_idx + 1;
			end if;

			write(buf, string'("   "));
--			hwrite(buf, word);
			write(buf, string'(":   "));

			case tag is
				-- Block header
				when "0000" =>
					write(buf, string'("[BLOCK HEADER]"));
					write(buf, string'(",SLOTID="));
					write(buf, integer'image(to_integer(unsigned(word(26 downto 22)))));
					write(buf, string'(",BLOCK_NUM="));
					write(buf, integer'image(to_integer(unsigned(word(17 downto 8)))));
					write(buf, string'(",BLOCK_SIZE="));
					write(buf, integer'image(to_integer(unsigned(word(7 downto 0)))));

				-- Block trailer
				when "0001" =>
					write(buf, string'("[BLOCK TRAILER]"));
					write(buf, string'(",SLOTID="));
					write(buf, integer'image(to_integer(unsigned(word(26 downto 22)))));
					write(buf, string'(",WORD_CNT="));
					write(buf, integer'image(to_integer(unsigned(word(21 downto 0)))));

				-- Event header
				when "0010" =>
					write(buf, string'("[EVENT HEADER]"));
					write(buf, string'(",TRIGGER_NUM="));
					write(buf, integer'image(to_integer(unsigned(word(21 downto 0)))));
					write(buf, string'(",DEVID="));
					write(buf, integer'image(to_integer(unsigned(word(26 downto 22)))));

				-- Trigger time
				when "0011" =>
					if tag_idx = 0 then
						write(buf, string'("[TRIGGER TIME]"));
						write(buf, string'(",TIME_L="));
						write(buf, integer'image(to_integer(unsigned(word(23 downto 0)))));
					else
						write(buf, string'("[TRIGGER TIME]"));
						write(buf, string'(",TIME_H="));
						write(buf, integer'image(to_integer(unsigned(word(23 downto 0)))));
					end if;

				when "1000" =>
					write(buf, string'("[TDC EVENT]"));
					write(buf, string'(",E="));
					write(buf, integer'image(to_integer(unsigned(word(26 downto 26)))));
					write(buf, string'(",CH="));
					write(buf, integer'image(to_integer(unsigned(word(23 downto 16)))));
					write(buf, string'(",TIME="));
					write(buf, integer'image(to_integer(signed(word(15 downto 0)))));
					write(buf, string'("ns"));

				-- Data not valid
				when "1110" =>
					write(buf, string'("[DNV]"));

				-- Filler word
				when "1111" =>
					write(buf, string'("[FILLER]"));

				-- Unknown
				when others =>
				write(buf, string'("Unknown"));
			end case;

			writeline(EventFile, buf);
		end loop;
	end VETROCDecodeEvent;
-- synthesis translate_on

end package body;
