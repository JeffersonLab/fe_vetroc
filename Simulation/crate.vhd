library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_textio.all;

library modelsim_lib;
use modelsim_lib.util.all;

library std;
use std.textio.all;
use std.standard.all;

library fadc250;
use fadc250.fadc250_pkg.all;

library gtp;
use gtp.gtp_pkg.all;

library ssp;
use ssp.ssp_pkg.all;

library utils;
use utils.utils_pkg.all;

entity crate is
	generic(
		VETROC_READOUT_EN	: std_logic := '0';
		PP_VETROC_EN		: std_logic_vector(15 downto 0) := x"FFFC";
		GTP_EN				: std_logic := '1';
		GTX_QUICKSIM		: boolean := false;
		EVENT_FILENAME		: string
	);
	port(
		CONFIG_DONE		: out std_logic;

		-- VXS Signal Distribution
		GLOBAL_CLK		: in std_logic;
		SYNC				: in std_logic;
		TRIG				: in std_logic;

		-- VETROC inputs
		VETROC_IN		: in std_logic_vector(16*128-1 downto 0)
	);
end crate;

architecture testbench of crate is
	function PayloadToSlot(payload : integer) return integer is
	begin
		if (payload > 0) and (payload < 17) then
			if (payload mod 2) = 1 then
				return 10 - (payload - 1) / 2;
			else
				return 13 + (payload - 2) / 2;
			end if;
		end if;
		return -1;
	end PayloadToSlot;

	function PayloadToSlotIdx(payload : integer) return integer is
	begin
		if (payload > 0) and (payload < 17) then
			if (payload mod 2) = 1 then
				return 7 - (payload - 1) / 2;
			else
				return 8 + (payload - 2) / 2;
			end if;
		end if;
		return -1;
	end PayloadToSlotIdx;

	type PP_GTX_TYPE is array(natural range <>) of std_logic_vector(0 to 1);
	type SLOT_ADDRESS_TYPE is array(natural range <>) of std_logic_vector(15 downto 0);

	signal VETROC_BASE32		: SLOT_ADDRESS_TYPE(0 to 15);
	signal VETROC_BASE		: SLOT_ADDRESS_TYPE(0 to 15);
	signal GTP_BASE			: std_logic_vector(15 downto 0) := x"0000";

	signal PP_GTP_TX			: PP_GTX_TYPE(0 to 15) := (others=>"00");
	signal PP_GTP_RX			: PP_GTX_TYPE(0 to 15) := (others=>"00");
	signal VMEBUS_DS_N		: std_logic_vector(1 downto 0);
	signal VMEBUS_AS_N		: std_logic;
	signal VMEBUS_W_N			: std_logic;
	signal VMEBUS_AM			: std_logic_vector(5 downto 0);
	signal VMEBUS_D			: std_logic_vector(31 downto 0);
	signal VMEBUS_A			: std_logic_vector(31 downto 0);
	signal VMEBUS_BERR_N		: std_logic;
	signal VMEBUS_DTACK_N	: std_logic;
	signal TRIG_CNT_RCV		: integer := 0;
	signal TRIG_CNT_RCV_DLY	: integer := 0;
	signal TRIG_CNT_READ		: integer := 0;
begin

	vetroc_gen: for I in 0 to 15 generate

		VETROC_BASE(PayloadToSlotIdx(I+1)) <= std_logic_vector(to_unsigned(PayloadToSlot(I+1), 13)) & "000";
		VETROC_BASE32(PayloadToSlotIdx(I+1)) <= std_logic_vector(to_unsigned(PayloadToSlot(I+1), 9)) & "0000000";

		pp_vetroc_en_gen: if PP_VETROC_EN(I) = '1' generate
			vetroc_wrapper_inst: vetroc_wrapper
				generic map(
					READOUT_EN		=> VETROC_READOUT_EN,
					GTX_QUICKSIM	=> GTX_QUICKSIM
				)
				port map(
					GLOBAL_CLK		=> GLOBAL_CLK,
					SYNC				=> SYNC,
					TRIG				=> TRIG,
					VMEBUS_ADDR		=> VETROC_BASE(PayloadToSlotIdx(I+1)),
					VMEBUS_DS_N		=> VMEBUS_DS_N,
					VMEBUS_AS_N		=> VMEBUS_AS_N,
					VMEBUS_W_N		=> VMEBUS_W_N,
					VMEBUS_AM		=> VMEBUS_AM,
					VMEBUS_D			=> VMEBUS_D,
					VMEBUS_A			=> VMEBUS_A,
					VMEBUS_BERR_N	=> VMEBUS_BERR_N,
					VMEBUS_DTACK_N	=> VMEBUS_DTACK_N,
					GTP_RX			=> PP_GTP_RX(I),
					GTP_TX			=> PP_GTP_TX(I),
					TDC_IN			=> VETROC_IN(128*PayloadToSlotIdx(I+1)+127 downto 128*PayloadToSlotIdx(I+1))
				);
		end generate;

	end generate;

	gtp_gen: if GTP_EN = '1' generate
		gtp_wrapper_inst: gtp_wrapper
			generic map(
				GTX_QUICKSIM	=> GTX_QUICKSIM
			)
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
				PP1_RX			=> PP_GTP_TX(0),
				PP1_TX			=> PP_GTP_RX(0),
				PP2_RX			=> PP_GTP_TX(1),
				PP2_TX			=> PP_GTP_RX(1),
				PP3_RX			=> PP_GTP_TX(2),
				PP3_TX			=> PP_GTP_RX(2),
				PP4_RX			=> PP_GTP_TX(3),
				PP4_TX			=> PP_GTP_RX(3),
				PP5_RX			=> PP_GTP_TX(4),
				PP5_TX			=> PP_GTP_RX(4),
				PP6_RX			=> PP_GTP_TX(5),
				PP6_TX			=> PP_GTP_RX(5),
				PP7_RX			=> PP_GTP_TX(6),
				PP7_TX			=> PP_GTP_RX(6),
				PP8_RX			=> PP_GTP_TX(7),
				PP8_TX			=> PP_GTP_RX(7),
				PP9_RX			=> PP_GTP_TX(8),
				PP9_TX			=> PP_GTP_RX(8),
				PP10_RX			=> PP_GTP_TX(9),
				PP10_TX			=> PP_GTP_RX(9),
				PP11_RX			=> PP_GTP_TX(10),
				PP11_TX			=> PP_GTP_RX(10),
				PP12_RX			=> PP_GTP_TX(11),
				PP12_TX			=> PP_GTP_RX(11),
				PP13_RX			=> PP_GTP_TX(12),
				PP13_TX			=> PP_GTP_RX(12),
				PP14_RX			=> PP_GTP_TX(13),
				PP14_TX			=> PP_GTP_RX(13),
				PP15_RX			=> PP_GTP_TX(14),
				PP15_TX			=> PP_GTP_RX(14),
				PP16_RX			=> PP_GTP_TX(15),
				PP16_TX			=> PP_GTP_RX(15),
				FIBER_RX			=> GTP_FIBER_RX,
				FIBER_TX			=> GTP_FIBER_TX
			);
	end generate;

	process
		constant AM_A24_NP_DATA			: std_logic_vector(5 downto 0) := "111001";
		constant AM_A24_SP_DATA			: std_logic_vector(5 downto 0) := "111101";
		constant AM_A32_NP_DATA			: std_logic_vector(5 downto 0) := "001001";
		constant AM_A32_SP_DATA			: std_logic_vector(5 downto 0) := "001101";

		variable DataBufferLen			: integer := 0;
		variable DataBuffer				: slv32a(0 to 9999) := (others=>x"00000000");
		variable Data						: std_logic_vector(31 downto 0) := x"00000000";
		variable addr						: std_logic_vector(15 downto 0) := x"0000";

		file EventFile						: text;
		variable fstatus					: file_open_status;
		variable buf						: line;
		variable word						: std_logic_vector(31 downto 0) := x"00000000";
		variable tag						: std_logic_vector(3 downto 0) := "0000";
		variable tag_idx					: integer := 0;

		procedure VMEReadMBLT(
				Address		: in std_logic_vector(31 downto 0);
				NWords		: out integer;
				DataBuffer	: out slv32a
			) is
			variable word_pos			: integer;
			variable words_to_read	: integer;
		begin
			word_pos := 0;

			while word_pos < DataBuffer'length loop
				if (DataBuffer'length - word_pos) > 64 then
					words_to_read := 64;
				else
					words_to_read := (DataBuffer'length - word_pos);
				end if;

				VMEBUS_A <= Address;
				VMEBUS_D <= (others=>'H');
				VMEBUS_AM <= "001000";	-- A32,MBLT
				VMEBUS_W_N <= '1';
				wait for 10 ns;
				
				VMEBUS_AS_N <= '0';
				wait for 5 ns;
				VMEBUS_DS_N <= "00";

				for I in 0 to 1000 loop
					if To_X01(VMEBUS_DTACK_N) = '0' then
						VMEBUS_DS_N <= "11";
						exit;
					elsif To_X01(VMEBUS_BERR_N) = '0' or I = 1000 then
						NWords := word_pos;
						VMEBUS_AS_N <= '1';
						VMEBUS_DS_N <= "11";
						return;
					end if;
					wait for 5 ns;
				end loop;
				VMEBUS_A <= (others=>'H');
				wait until To_X01(VMEBUS_DTACK_N) = '1';
				wait for 60 ns;
				
				for J in 0 to words_to_read-1 loop
					VMEBUS_DS_N <= "00";
					
					for I in 0 to 1000 loop
						if To_X01(VMEBUS_DTACK_N) = '0' then
							DataBuffer(word_pos) := VMEBUS_A;
							word_pos := word_pos + 1;
							DataBuffer(word_pos) := VMEBUS_D;
							word_pos := word_pos + 1;
							VMEBUS_DS_N <= "11";
							exit;
						elsif To_X01(VMEBUS_BERR_N) = '0' or I = 1000 then
							NWords := word_pos;
							VMEBUS_AS_N <= '1';
							VMEBUS_DS_N <= "11";
							wait until To_X01(VMEBUS_BERR_N) = '1';
							wait for 100 ns;
							return;
						end if;
						wait for 5 ns;
					end loop;

					wait until To_X01(VMEBUS_DTACK_N) = '1';
					wait for 60 ns;
				end loop;

				VMEBUS_AS_N <= '1';
				wait for 60 ns;
			end loop;
		end procedure;
	
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
	begin
		CONFIG_DONE <= '0';

		VMEBUS_DS_N <= "11";
		VMEBUS_AS_N <= '1';
		VMEBUS_W_N <= '1';
		VMEBUS_AM <= (others=>'1');
		VMEBUS_D <= (others=>'H');
		VMEBUS_A <= (others=>'H');
		VMEBUS_BERR_N <= 'H';
		VMEBUS_DTACK_N <= 'H';	

		wait for 2 us;

		if GTP_EN = '1' then
			VMEWrite32(GTP_BASE & x"0100", x"00000000");				-- enable clock
			VMEWrite32(GTP_BASE & x"0324", x"00000002");				-- enable VXS sync
			VMEWrite32(GTP_BASE & x"2000", x"0000" & PP_FADC_EN);	-- enable trigger for used FADC
			--VMEWrite32(GTP_BASE & x"2004", x"00010001");			-- 0 = 0ns coincidence, 1 = +/-4ns coincidence
			VMEWrite32(GTP_BASE & x"2004", x"00020002");				-- 0 = 0ns coincidence, 1 = +/-4ns coincidence, 2 = +/-8ns  coincidence
			--VMEWrite32(GTP_BASE & x"2008", x"00000032");			-- 0x32 = 50MeV cluster threshold
			VMEWrite32(GTP_BASE & x"2008", std_logic_vector(to_unsigned(200, 32)));				-- 0x0A = 10MeV cluster threshold

			for I in PP_FADC_EN'range loop
				addr := std_logic_vector(to_unsigned(4096+256*I, 16));
				VMEWrite32(GTP_BASE & addr, x"00000000");				-- enable serdes
			end loop;
			VMEWrite32(GTP_BASE & x"2400", x"00000000");				-- enable qsfp serdes
		end if;

		for I in PP_VETROC_EN'range loop
			if PP_VETROC_EN(I) = '1' then
				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"0004", x"80000000");	-- CSR_HARD_RESET
				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"002C", x"0000FFFF");	-- FA_RESET_ALL
				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"0008", x"00100332");	-- ctrl1: VXS clock, sync, trig1, berr en
 				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"000C", x"00000007");	-- ctrl2: enable sync, trig1, go

				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"002C", x"00001902");	-- FA_RESET_...

				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"0018", x"0000" & FADC_BASE32(PayloadToAdcIdx(I+1))(15 downto 1) & '1');	-- adr32
				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"0010", x"00000001");	-- blk_level=1

 				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"0500", x"00000203");	-- GTX ctrl
 				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"0500", x"00000000");	-- GTX ctrl

				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"010C", x"00000038");	-- adc_config[0]: mode=0, NP=3, enable

				VMEWrite32(VETROC_BASE(PayloadToAdcIdx(I+1)) & x"0004", x"40000000");	-- CSR_SOFT_RESET

			end if;
		end loop;

		CONFIG_DONE <= '1';

		if (VETROC_READOUT_EN = '1') then
			file_open(fstatus, EventFile, EVENT_FILENAME, write_mode);
			while true loop
				wait for 1 us;
				if TRIG_CNT_READ < TRIG_CNT_RCV_DLY then
					write(buf, string'("Event Number: "));
					write(buf, TRIG_CNT_READ);
					writeline(EventFile, buf);
					writeline(EventFile, buf);

					for I in PP_VETROC_EN'range loop
						if (VETROC_READOUT_EN = '1') and (PP_VETROC_EN(I) = '1') then
							-- Readout event using VME
							VMEReadMBLT(VETROC_BASE32(PayloadToSlotIdx(I+1)) & x"0000", DataBufferLen, DataBuffer);
							VETROCDecodeEvent(EventFile, DataBuffer, DataBufferLen);
						end if;
					end loop;

					TRIG_CNT_READ <= TRIG_CNT_READ + 1;
				end if;
			end loop;
		end if;

		wait;		
	end process;

	TRIG_CNT_RCV_DLY <= transport TRIG_CNT_RCV after 6 us;

	process
	begin
		TRIG_CNT_RCV <= 0;
		wait for 1 us;

		while true loop
			wait until rising_edge(TRIG);
			TRIG_CNT_RCV <= TRIG_CNT_RCV + 1;
		end loop;
	end process;

end testbench;
