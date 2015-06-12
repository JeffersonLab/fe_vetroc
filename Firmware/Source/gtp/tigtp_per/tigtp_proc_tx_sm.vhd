library ieee;
use ieee.std_logic_1164.all;

use work.tigtp_ser_pkg.all;

entity tigtp_proc_tx_sm is
	port(
		CLK				: in std_logic;
		RESET				: in std_logic;

		TX_CMD			: out std_logic_vector(1 downto 0);
		TX_DATA			: out std_logic_vector(7 downto 0);

		SEND_ACK			: in std_logic;
		SEND_BL_REQ		: in std_logic
	);
end tigtp_proc_tx_sm;

architecture synthesis of tigtp_proc_tx_sm is
	type TIGTP_PROC_TX_STATE_TYPE is (IDLE, SEND_ACK_SOP, SEND_ACK_DATA, SEND_BLOCK_REQ_SOP, SEND_BLOCK_REQ_DATA, SEND_EOP);

	signal TIGTP_PROC_TX_STATE			: TIGTP_PROC_TX_STATE_TYPE;
	signal TIGTP_PROC_TX_STATE_NEXT	: TIGTP_PROC_TX_STATE_TYPE;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				TIGTP_PROC_TX_STATE <= IDLE;
			else
				TIGTP_PROC_TX_STATE <= TIGTP_PROC_TX_STATE_NEXT;
			end if;
		end if;
	end process;

	process(TIGTP_PROC_TX_STATE, SEND_ACK, SEND_BL_REQ)
	begin
		case TIGTP_PROC_TX_STATE is
			when IDLE =>
				if SEND_ACK = '1' then
					TIGTP_PROC_TX_STATE_NEXT <= SEND_ACK_SOP;
				elsif SEND_BL_REQ = '1' then
					TIGTP_PROC_TX_STATE_NEXT <= SEND_BLOCK_REQ_SOP;
				else
					TIGTP_PROC_TX_STATE_NEXT <= IDLE;
				end if;

			when SEND_ACK_SOP =>
				TIGTP_PROC_TX_STATE_NEXT <= SEND_ACK_DATA;

			when SEND_ACK_DATA =>
				TIGTP_PROC_TX_STATE_NEXT <= SEND_EOP;

			when SEND_BLOCK_REQ_SOP =>
				TIGTP_PROC_TX_STATE_NEXT <= SEND_BLOCK_REQ_DATA;

			when SEND_BLOCK_REQ_DATA =>
				TIGTP_PROC_TX_STATE_NEXT <= SEND_EOP;

			when SEND_EOP =>
				TIGTP_PROC_TX_STATE_NEXT <= IDLE;

			when others =>
				TIGTP_PROC_TX_STATE_NEXT <= IDLE;

		end case;
	end process;

	process(TIGTP_PROC_TX_STATE, SEND_ACK)
	begin
		case TIGTP_PROC_TX_STATE is
			when IDLE =>
				TX_CMD <= TIGTP_CMD_IDLE;
				TX_DATA <= x"00";
			when SEND_ACK_SOP =>
				TX_CMD <= TIGTP_CMD_SOP;
				TX_DATA <= x"00";
			when SEND_ACK_DATA =>
				TX_CMD <= TIGTP_CMD_DATA;
				TX_DATA <= "0000" & PKT_CMD_BLOCKACK;
			when SEND_BLOCK_REQ_SOP =>
				TX_CMD <= TIGTP_CMD_SOP;
				TX_DATA <= x"00";
			when SEND_BLOCK_REQ_DATA =>
				TX_CMD <= TIGTP_CMD_DATA;
				TX_DATA <= "0000" & PKT_CMD_BL_REQ;
			when SEND_EOP =>
				TX_CMD <= TIGTP_CMD_EOP;
				TX_DATA <= x"00";
			when others =>
				TX_CMD <= TIGTP_CMD_IDLE;
				TX_DATA <= x"00";
		end case;
	end process;

end synthesis;
