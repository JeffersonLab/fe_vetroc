library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tigtp_ser_pkg.all;

entity tigtp_proc_rx_sm is
	port(
		CLK				: in std_logic;
		RESET				: in std_logic;

		RX_CMD			: in std_logic_vector(1 downto 0);
		RX_DATA			: in std_logic_vector(7 downto 0);

		CUR_BL_DATA		: out std_logic_vector(7 downto 0);
		NEXT_BL_DATA	: out std_logic_vector(7 downto 0);
		
		SYNC_EVT_SET	: out std_logic;

		DATA_FIFO_WR	: out std_logic;
		DATA_FIFO_DIN	: out std_logic_vector(31 downto 0);

		LEN_FIFO_WR		: out std_logic;
		LEN_FIFO_DIN	: out std_logic_vector(31 downto 0)
	);
end tigtp_proc_rx_sm;

architecture synthesis of tigtp_proc_rx_sm is
	type TIGTP_PROC_RX_STATE_TYPE is (IDLE, WAIT_CMD, WAIT_SET_NEXT_BL, WAIT_SET_CUR_BL, CMD_BLOCKDATA0, CMD_BLOCKDATA1, CMD_BLOCKDATA2, CMD_BLOCKDATA3);

	signal TIGTP_PROC_RX_STATE			: TIGTP_PROC_RX_STATE_TYPE;
	signal TIGTP_PROC_RX_STATE_NEXT	: TIGTP_PROC_RX_STATE_TYPE;

	signal WORD_CNT_RST					: std_logic := '0';
	signal WORD_CNT						: std_logic_vector(31 downto 0) := (others=>'0');
	signal WORD_CNT_INC					: std_logic := '0';

	signal CMD_BLOCKDATA_VALID			: std_logic := '0';
	signal CMD_SYNCEVT_VALID			: std_logic := '0';
	signal CMD_BL_RSP_VALID				: std_logic := '0';

	signal BYTE_EN							: std_logic_vector(2 downto 0) := (others=>'0');
	signal DO_SYNC_SET					: std_logic := '0';
	signal DO_CUR_BL						: std_logic := '0';
	signal DO_NEXT_BL						: std_logic := '0';
begin

	LEN_FIFO_DIN <= WORD_CNT;

	CMD_BLOCKDATA_VALID <= '1' when (RX_CMD = TIGTP_CMD_DATA) and (RX_DATA(3 downto 0) = PKT_CMD_BLOCKDATA) else '0';
	CMD_SYNCEVT_VALID <= '1' when (RX_CMD = TIGTP_CMD_DATA) and (RX_DATA(3 downto 0) = PKT_CMD_SYNCEVT) else '0';
	CMD_BL_RSP_VALID <= '1' when (RX_CMD = TIGTP_CMD_DATA) and (RX_DATA(3 downto 0) = PKT_CMD_BL_RSP) else '0';

	DATA_FIFO_DIN(31 downto 24) <= RX_DATA;

	process(CLK)
	begin
		if rising_edge(CLK) then
			SYNC_EVT_SET <= DO_SYNC_SET;

			if BYTE_EN(0) = '1' then
				DATA_FIFO_DIN(7 downto 0) <= RX_DATA;
			end if;

			if BYTE_EN(1) = '1' then
				DATA_FIFO_DIN(15 downto 8) <= RX_DATA;
			end if;

			if BYTE_EN(2) = '1' then
				DATA_FIFO_DIN(23 downto 16) <= RX_DATA;
			end if;

			if DO_CUR_BL = '1' then
				CUR_BL_DATA <= RX_DATA;
			end if;

			if DO_NEXT_BL = '1' then
				NEXT_BL_DATA <= RX_DATA;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if WORD_CNT_RST = '1' then
				WORD_CNT <= (others=>'0');
			elsif WORD_CNT_INC = '1' then
				WORD_CNT <= WORD_CNT + 1;
			end if;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				TIGTP_PROC_RX_STATE <= IDLE;
			elsif RX_CMD /= TIGTP_CMD_IDLE then
				TIGTP_PROC_RX_STATE <= TIGTP_PROC_RX_STATE_NEXT;
			end if;
		end if;
	end process;

	process(TIGTP_PROC_RX_STATE, RX_CMD, CMD_BLOCKDATA_VALID, CMD_SYNCEVT_VALID, CMD_BL_RSP_VALID)
	begin
		TIGTP_PROC_RX_STATE_NEXT <= TIGTP_PROC_RX_STATE;

		BYTE_EN <= "000";
		DO_SYNC_SET <= '0';
		DO_CUR_BL <= '0';
		DO_NEXT_BL <= '0';
		WORD_CNT_RST <= '0';
		LEN_FIFO_WR <= '0';
		WORD_CNT_INC <= '0';
		DATA_FIFO_WR <= '0';

		case TIGTP_PROC_RX_STATE is
			when IDLE =>
				if RX_CMD = TIGTP_CMD_SOP then
					TIGTP_PROC_RX_STATE_NEXT <= WAIT_CMD;
					WORD_CNT_RST <= '1';
				end if;

			when WAIT_CMD =>
				if CMD_BLOCKDATA_VALID = '1' then
					TIGTP_PROC_RX_STATE_NEXT <= CMD_BLOCKDATA0;
				elsif CMD_SYNCEVT_VALID = '1' then
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
					DO_SYNC_SET <= '1';
				elsif CMD_BL_RSP_VALID = '1' then
					TIGTP_PROC_RX_STATE_NEXT <= WAIT_SET_NEXT_BL;
				else
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
				end if;

			when WAIT_SET_NEXT_BL =>
				if RX_CMD = TIGTP_CMD_DATA then
					TIGTP_PROC_RX_STATE_NEXT <= WAIT_SET_CUR_BL;
					DO_NEXT_BL <= '1';
				else
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
				end if;

			when WAIT_SET_CUR_BL =>
				if RX_CMD = TIGTP_CMD_DATA then
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
					DO_CUR_BL <= '1';
				else
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
				end if;

			when CMD_BLOCKDATA0 =>
				if RX_CMD = TIGTP_CMD_DATA then
					TIGTP_PROC_RX_STATE_NEXT <= CMD_BLOCKDATA1;
					BYTE_EN(0) <= '1';
				elsif RX_CMD = TIGTP_CMD_EOP then
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
					LEN_FIFO_WR <= '1';
				else
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
				end if;

			when CMD_BLOCKDATA1 =>
				if RX_CMD = TIGTP_CMD_DATA then
					TIGTP_PROC_RX_STATE_NEXT <= CMD_BLOCKDATA2;
					BYTE_EN(1) <= '1';
				else
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
				end if;

			when CMD_BLOCKDATA2 =>
				if RX_CMD = TIGTP_CMD_DATA then
					TIGTP_PROC_RX_STATE_NEXT <= CMD_BLOCKDATA3;
					BYTE_EN(2) <= '1';
				else
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
				end if;

			when CMD_BLOCKDATA3 =>
				if RX_CMD = TIGTP_CMD_DATA then
					TIGTP_PROC_RX_STATE_NEXT <= CMD_BLOCKDATA0;
					DATA_FIFO_WR <= '1';
					WORD_CNT_INC <= '1';
				else
					TIGTP_PROC_RX_STATE_NEXT <= IDLE;
				end if;

			when others =>
				TIGTP_PROC_RX_STATE_NEXT <= IDLE;
		end case;
	end process;

end synthesis;
