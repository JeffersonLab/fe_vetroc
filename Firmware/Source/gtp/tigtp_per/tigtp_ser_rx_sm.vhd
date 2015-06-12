library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tigtp_ser_rx_sm is
	generic(
		FPGA		: string := "VIRTEX5"
	);
	port(
		CLK			: in std_logic;
		RESET			: in std_logic;

		-- V5 signals
		DLYCE			: out std_logic;
		DLYINC		: out std_logic;
		DLYRST		: out std_logic;

		-- EPS4 signals
		RX_LOCKED	: in std_logic;

		BITSLIP		: out std_logic;

		RX_ERROR		: in std_logic;
		RX_DATA		: in std_logic_vector(7 downto 0);
		RX_K			: in std_logic;

		RX_READY		: out std_logic;
		RX_RESET		: out std_logic
	);
end tigtp_ser_rx_sm;

architecture synthesis of tigtp_ser_rx_sm is
begin

	tx_serdes_eps4_gen: if FPGA = "STRATIX4" generate
		constant MAX_BITSLIP_CNT	: integer := 10;	-- maximum 10 views of data

		type RECEIVE_STATE_TYPE is (INIT, WAIT_LOCKED, SCAN_WINDOW, WAIT_DELAY_STABLE, DONE);
			
		signal RECEIVE_STATE			: RECEIVE_STATE_TYPE;
		signal RECEIVE_STATE_NEXT	: RECEIVE_STATE_TYPE;

		signal RX_RESET_D				: std_logic;

		signal RX_K28_5				: std_logic;

		signal BITSLIP_CNT_DONE		: std_logic;
		signal BITSLIP_CNT_RST		: std_logic;
		signal BITSLIP_CNT			: std_logic_vector(3 downto 0) := (others=>'0');
		signal BITSLIP_CNT_INC		: std_logic;

		signal CNT_DONE_LOCKTIMEOUT: std_logic;
		signal CNT_DONE				: std_logic;
		signal CNT						: std_logic_vector(23 downto 0) := (others=>'0');
		signal CNT_RST					: std_logic;
	begin
		DLYCE <= '0';
		DLYINC <= '0';
		DLYRST <= '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				RX_RESET <= RX_RESET_D;
			end if;
		end process;

		--------------------------
		-- BITSLIP COUNTER
		--------------------------
		BITSLIP <= BITSLIP_CNT_INC;

		BITSLIP_CNT_DONE <= '1' when BITSLIP_CNT = conv_std_logic_vector(MAX_BITSLIP_CNT, BITSLIP_CNT'length) else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				if BITSLIP_CNT_RST = '1' then
					BITSLIP_CNT <= (others=>'0');
				elsif BITSLIP_CNT_INC = '1' then
					BITSLIP_CNT <= BITSLIP_CNT + 1;
				end if;
			end if;
		end process;

		--------------------------
		-- STATE COUNTER
		--------------------------
		CNT_DONE_LOCKTIMEOUT <= '1' when CNT = conv_std_logic_vector(100000000, CNT'length) else '0';
		CNT_DONE <= '1' when CNT = conv_std_logic_vector(100, CNT'length) else '0';
		CNT_RST <= '1' when (RESET = '1') or (RECEIVE_STATE /= RECEIVE_STATE_NEXT) else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				if CNT_RST = '1' then
					CNT <= (others=>'0');
				else
					CNT <= CNT + 1;
				end if;
			end if;
		end process;

		--------------------------
		-- STATE MACHINE (scans all bitslip & tap combinations and tap center/bitslip from the widest measured eye of K28_5)
		--------------------------
		RX_K28_5 <= '1' when (RX_DATA = x"BC") and (RX_K = '1') and (RX_ERROR = '0') else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				if RESET = '1' then
					RECEIVE_STATE <= INIT;
				else
					RECEIVE_STATE <= RECEIVE_STATE_NEXT;
				end if;
			end if;
		end process;	

		process(RX_ERROR, RX_LOCKED, RECEIVE_STATE, RX_K28_5, CNT_DONE, CNT_DONE_LOCKTIMEOUT, BITSLIP_CNT_DONE)
		begin
			BITSLIP_CNT_RST <= '0';
			BITSLIP_CNT_INC <= '0';
			RX_READY <= '0';
			RX_RESET_D <= '0';

			RECEIVE_STATE_NEXT <= RECEIVE_STATE;

			case RECEIVE_STATE is
				when INIT =>
					BITSLIP_CNT_RST <= '1';
					RX_RESET_D <= '1';

					if CNT_DONE = '1' then
						RECEIVE_STATE_NEXT <= WAIT_LOCKED;
					end if;

				when WAIT_LOCKED =>
					if (CNT_DONE_LOCKTIMEOUT = '1') and (RX_LOCKED = '0') then
						RECEIVE_STATE_NEXT <= INIT;
					elsif (RX_LOCKED = '1') then
						RECEIVE_STATE_NEXT <= SCAN_WINDOW;
					end if;

				when SCAN_WINDOW =>
					if RX_K28_5 = '1' then
						RECEIVE_STATE_NEXT <= DONE;
					elsif BITSLIP_CNT_DONE = '1' then
						RECEIVE_STATE_NEXT <= INIT;
					else
						BITSLIP_CNT_INC <= '1';
						RECEIVE_STATE_NEXT <= WAIT_DELAY_STABLE;
					end if;

				when WAIT_DELAY_STABLE =>
					if CNT_DONE = '1' then
						RECEIVE_STATE_NEXT <= SCAN_WINDOW;
					end if;

				when DONE =>
					if RX_ERROR = '1' then
						RECEIVE_STATE_NEXT <= INIT;
					else
						RX_READY <= '1';
					end if;

				when others =>
					RECEIVE_STATE_NEXT <= INIT;

			end case;
		end process;

	end generate;

	tx_serdes_v5_gen: if FPGA = "VIRTEX5" generate
		constant MAX_DELAY_TAP		: integer := 63;	-- maximum value for idelay setting
		constant MAX_BITSLIP_CNT	: integer := 10;	-- maximum 10 views of data

		type RECEIVE_STATE_TYPE is (INIT, SCAN_WINDOW, INC_DELAY, WAIT_DELAY_STABLE, SET_BEST_TAP, SET_BEST_BITSLIP, WAIT_DELAY_STABLE2, DONE);
			
		signal RECEIVE_STATE			: RECEIVE_STATE_TYPE;
		signal RECEIVE_STATE_NEXT	: RECEIVE_STATE_TYPE;

		signal RX_RESET_D				: std_logic;

		signal INC_TAP					: std_logic;
		signal DEC_TAP					: std_logic;
		signal TAP_CNT_RST			: std_logic;
		signal TAP_CNT					: std_logic_vector(5 downto 0) := (others=>'0');
		signal TAP_CNT_DONE_BEST	: std_logic;
		signal TAP_CNT_DONE			: std_logic;

		signal RX_K28_5				: std_logic;

		signal BITSLIP_CNT_DONE		: std_logic;
		signal BITSLIP_CNT_RST		: std_logic;
		signal BITSLIP_CNT			: std_logic_vector(3 downto 0) := (others=>'0');
		signal BITSLIP_CNT_INC		: std_logic;

		signal CNT_DONE				: std_logic;
		signal CNT						: std_logic_vector(6 downto 0) := (others=>'0');
		signal CNT_RST					: std_logic;

		signal SAVE_TAP_BEST			: std_logic;
		signal SAVE_TAP_CUR			: std_logic;
		signal CLEAR_TAP_BEST		: std_logic;
		signal CLEAR_TAP_CUR			: std_logic;
		signal TAP_VALID_BEST		: std_logic;
		signal TAP_WIDTH_BEST		: std_logic_vector(5 downto 0) := (others=>'0');
		signal TAP_POS_BEST			: std_logic_vector(5 downto 0) := (others=>'0');
		signal TAP_VALID_CUR			: std_logic;
		signal TAP_START_CUR			: std_logic_vector(5 downto 0) := (others=>'0');
		signal TAP_POS_CUR			: std_logic_vector(5 downto 0) := (others=>'0');
		signal TAP_WIDTH_CUR			: std_logic_vector(5 downto 0);
	begin

		process(CLK)
		begin
			if rising_edge(CLK) then
				RX_RESET <= RX_RESET_D;
			end if;
		end process;

		--------------------------
		-- IDELAY TAP POINTS
		--------------------------
		TAP_WIDTH_CUR <= "000000" when TAP_START_CUR >= TAP_CNT else (TAP_CNT - TAP_START_CUR);

		process(TAP_CNT, TAP_START_CUR)
			variable tap_start_stop_sum		: std_logic_vector(6 downto 0);
		begin
			tap_start_stop_sum := ('0'&TAP_CNT) + ('0'&TAP_START_CUR);
			TAP_POS_CUR <= tap_start_stop_sum(6 downto 1);
		end process;

		process(CLK)
		begin
			if rising_edge(CLK) then
				if SAVE_TAP_BEST = '1' then
					TAP_WIDTH_BEST <= TAP_WIDTH_CUR;
					TAP_POS_BEST <= TAP_POS_CUR;
				end if;
			end if;
		end process;

		process(CLK)
		begin
			if rising_edge(CLK) then
				if CLEAR_TAP_BEST = '1' then
					TAP_VALID_BEST <= '0';
				elsif SAVE_TAP_BEST = '1' then
					TAP_VALID_BEST <= '1';
				end if;
			end if;
		end process;

		process(CLK)
		begin
			if rising_edge(CLK) then
				if SAVE_TAP_CUR = '1' then
					TAP_START_CUR <= TAP_CNT;
				end if;
			end if;
		end process;

		process(CLK)
		begin
			if rising_edge(CLK) then
				if CLEAR_TAP_CUR = '1' then
					TAP_VALID_CUR <= '0';
				elsif SAVE_TAP_CUR = '1' then
					TAP_VALID_CUR <= '1';
				end if;
			end if;
		end process;

		--------------------------
		-- DELAY TAP COUNTER
		--------------------------
		DLYCE <= INC_TAP or DEC_TAP;
		DLYINC <= INC_TAP;
		DLYRST <= TAP_CNT_RST;

		TAP_CNT_DONE_BEST <= '1' when TAP_CNT = TAP_POS_BEST else '0';
		TAP_CNT_DONE <= '1' when TAP_CNT = conv_std_logic_vector(MAX_DELAY_TAP, TAP_CNT'length) else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				if TAP_CNT_RST = '1' then
					TAP_CNT <= (others=>'0');
				elsif INC_TAP = '1' then
					TAP_CNT <= TAP_CNT + 1;
				elsif DEC_TAP = '1' then
					TAP_CNT <= TAP_CNT - 1;
				end if;
			end if;
		end process;

		--------------------------
		-- BITSLIP COUNTER
		--------------------------
		BITSLIP <= BITSLIP_CNT_INC;

		BITSLIP_CNT_DONE <= '1' when BITSLIP_CNT = conv_std_logic_vector(MAX_BITSLIP_CNT, BITSLIP_CNT'length) else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				if BITSLIP_CNT_RST = '1' then
					BITSLIP_CNT <= (others=>'0');
				elsif BITSLIP_CNT_INC = '1' then
					BITSLIP_CNT <= BITSLIP_CNT + 1;
				end if;
			end if;
		end process;

		--------------------------
		-- STATE COUNTER
		--------------------------
		CNT_DONE <= '1' when CNT = conv_std_logic_vector(100, CNT'length) else '0';
		CNT_RST <= '1' when (RESET = '1') or (RECEIVE_STATE /= RECEIVE_STATE_NEXT) else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				if CNT_RST = '1' then
					CNT <= (others=>'0');
				else
					CNT <= CNT + 1;
				end if;
			end if;
		end process;

		--------------------------
		-- STATE MACHINE (scans all bitslip & tap combinations and tap center/bitslip from the widest measured eye of K28_5)
		--------------------------
		RX_K28_5 <= '1' when (RX_DATA = x"BC") and (RX_K = '1') and (RX_ERROR = '0') else '0';

		process(CLK)
		begin
			if rising_edge(CLK) then
				if RESET = '1' then
					RECEIVE_STATE <= INIT;
				else
					RECEIVE_STATE <= RECEIVE_STATE_NEXT;
				end if;
			end if;
		end process;	

		process(RX_ERROR, RECEIVE_STATE, RX_K28_5, CNT_DONE, TAP_VALID_CUR, TAP_WIDTH_CUR, TAP_WIDTH_BEST, TAP_CNT_DONE, TAP_CNT_DONE_BEST, BITSLIP_CNT_DONE)
		begin
			TAP_CNT_RST <= '0';
			INC_TAP <= '0';
			DEC_TAP <= '0';
			BITSLIP_CNT_RST <= '0';
			BITSLIP_CNT_INC <= '0';
			CLEAR_TAP_BEST <= '0';
			CLEAR_TAP_CUR <= '0';
			SAVE_TAP_BEST <= '0';
			SAVE_TAP_CUR <= '0';
			RX_READY <= '0';
			RX_RESET_D <= '0';

			RECEIVE_STATE_NEXT <= RECEIVE_STATE;

			case RECEIVE_STATE is
				when INIT =>
					TAP_CNT_RST <= '1';
					BITSLIP_CNT_RST <= '1';
					CLEAR_TAP_BEST <= '1';
					CLEAR_TAP_CUR <= '1';
					RX_RESET_D <= '1';

					if CNT_DONE = '1' then
						RECEIVE_STATE_NEXT <= SCAN_WINDOW;
					end if;

				when SCAN_WINDOW =>
					if RX_K28_5 = '0' then
						CLEAR_TAP_CUR <= '1';
						RECEIVE_STATE_NEXT <= INC_DELAY;
					elsif CNT_DONE = '1' then
						if TAP_VALID_CUR = '0' then
							SAVE_TAP_CUR <= '1';
						elsif (TAP_VALID_BEST = '0') or (TAP_WIDTH_CUR >= TAP_WIDTH_BEST) then
							SAVE_TAP_BEST <= '1';
						end if;
						RECEIVE_STATE_NEXT <= INC_DELAY;
					end if;

				when INC_DELAY =>
					if TAP_CNT_DONE = '1' then
						if (BITSLIP_CNT_DONE = '1') and (TAP_VALID_BEST = '1') then
							TAP_CNT_RST <= '1';
							BITSLIP_CNT_RST <= '1';
							RECEIVE_STATE_NEXT <= SET_BEST_TAP;
						elsif (BITSLIP_CNT_DONE = '1') then
							RECEIVE_STATE_NEXT <= INIT;
						else
							TAP_CNT_RST <= '1';
							BITSLIP_CNT_INC <= '1';
							RECEIVE_STATE_NEXT <= WAIT_DELAY_STABLE;
						end if;
					else
						INC_TAP <= '1';
						RECEIVE_STATE_NEXT <= WAIT_DELAY_STABLE;
					end if;

				when WAIT_DELAY_STABLE =>
					if CNT_DONE = '1' then
						RECEIVE_STATE_NEXT <= SCAN_WINDOW;
					end if;

				when SET_BEST_TAP =>
					if TAP_CNT_DONE_BEST = '1' then
						RECEIVE_STATE_NEXT <= SET_BEST_BITSLIP;
					else
						INC_TAP <= '1';
					end if;

				when SET_BEST_BITSLIP =>
					if RX_K28_5 = '1' then
						RECEIVE_STATE_NEXT <= DONE;
					else
						if BITSLIP_CNT_DONE = '1' then
							RECEIVE_STATE_NEXT <= INIT;
						else
							BITSLIP_CNT_INC <= '1';
							RECEIVE_STATE_NEXT <= WAIT_DELAY_STABLE2;
						end if;
					end if;

				when WAIT_DELAY_STABLE2 =>
					if CNT_DONE = '1' then
						RECEIVE_STATE_NEXT <= SET_BEST_BITSLIP;
					end if;

				when DONE =>
					if RX_ERROR = '1' then
						RECEIVE_STATE_NEXT <= INIT;
					else
						RX_READY <= '1';
					end if;

				when others =>
					RECEIVE_STATE_NEXT <= INIT;

			end case;
		end process;

	end generate;

end synthesis;
