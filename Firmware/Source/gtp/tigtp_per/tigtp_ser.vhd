library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tigtp_ser_pkg.all;

entity tigtp_ser is
	generic(
		FPGA					: string := "VIRTEX5"
	);
	port(
		CLK_REF				: in std_logic;
		CLK_REF_5X			: in std_logic;
		RX_RESET				: in std_logic;
		PLL_RESET			: in std_logic;
		RX_FIFO_RESET		: in std_logic;

		-- All signals below are synchronous to USER_CLK
		USER_CLK				: out std_logic;

		-- Transmitter Interface
		-- All signals 
		USER_TX_CMD			: in std_logic_vector(1 downto 0);
		USER_TX_DATA		: in std_logic_vector(7 downto 0);

		-- Receiver Interface
		USER_RX_CMD			: out std_logic_vector(1 downto 0);
		USER_RX_DATA		: out std_logic_vector(7 downto 0);
		USER_RX_ERROR_CNT	: out std_logic_vector(15 downto 0);
		USER_RX_READY		: out std_logic;
		USER_RX_LOCKED		: out std_logic;

		-- Serial pins
		TXD					: out std_logic;
		RXD					: in std_logic
	);
end tigtp_ser;

architecture synthesis of tigtp_ser is
	component tigtp_ser_tx is
		generic(
			FPGA		: string := "VIRTEX5"
		);
		port(
			CLK_REF		: in std_logic;
			CLK_REF_5X	: in std_logic;
			PLL_RESET	: in std_logic;

			TX_CLK		: out std_logic;
			TX_DATA		: in std_logic_vector(7 downto 0);
			TX_K			: in std_logic;

			TXD			: out std_logic
		);
	end component;

	component tigtp_ser_rx is
		generic(
			FPGA		: string := "VIRTEX5"
		);
		port(
			CLK_REF			: in std_logic;
			CLK_REF_5X		: in std_logic;

			RX_RESET			: in std_logic;
			PLL_RESET		: in std_logic;
			RX_FIFO_RESET	: in std_logic;

			DLYCE				: in std_logic;
			DLYINC			: in std_logic;
			DLYRST			: in std_logic;
			BITSLIP			: in std_logic;

			RX_CLK			: out std_logic;
			RX_LOCKED		: out std_logic;
			RX_ERROR			: out std_logic;
			RX_DATA			: out std_logic_vector(7 downto 0);
			RX_K				: out std_logic;

			RXD				: in std_logic
		);
	end component;

	component tigtp_ser_rx_sm is
		generic(
			FPGA		: string := "VIRTEX5"
		);
		port(
			CLK			: in std_logic;
			RESET			: in std_logic;

			DLYCE			: out std_logic;
			DLYINC		: out std_logic;
			DLYRST		: out std_logic;
			BITSLIP		: out std_logic;

			RX_LOCKED	: in std_logic;
			RX_ERROR		: in std_logic;
			RX_DATA		: in std_logic_vector(7 downto 0);
			RX_K			: in std_logic;

			RX_READY		: out std_logic;
			RX_RESET		: out std_logic
		);
	end component;

	signal RX_ERROR				: std_logic;
	signal RX_ERROR_CNT			: std_logic_vector(15 downto 0) := (others=>'0');
	signal RX_ERROR_CNT_DONE	: std_logic;
	signal RX_READY				: std_logic;
	signal TX_K						: std_logic := '0';
	signal TX_DATA					: std_logic_vector(7 downto 0) := (others=>'0');
	signal RX_K						: std_logic;
	signal RX_DATA					: std_logic_vector(7 downto 0);
	signal DLYCE					: std_logic;
	signal DLYINC					: std_logic;
	signal DLYRST					: std_logic;
	signal BITSLIP					: std_logic;
	signal TX_CLK					: std_logic;
	signal RX_CLK					: std_logic;
	signal RX_LOCKED				: std_logic;
	signal RX_RESET_Q				: std_logic;
	signal RX_FIFO_RESET_Q		: std_logic;
begin

	process(RX_CLK)
	begin
		if rising_edge(RX_CLK) then
			RX_RESET_Q <= RX_RESET;
			RX_FIFO_RESET_Q <= RX_FIFO_RESET;
		end if;
	end process;

	-- Note: TX_CLK and RX_CLK must be same!
	USER_CLK <= RX_CLK;

	------------------------
	-- Receiver Logic
	------------------------

	USER_RX_LOCKED <= RX_LOCKED;
	USER_RX_ERROR_CNT <= RX_ERROR_CNT;

	RX_ERROR_CNT_DONE <= '1' when RX_ERROR_CNT = conv_std_logic_vector(2**RX_ERROR_CNT'length-1, RX_ERROR_CNT'length) else '0';

	process(RX_CLK)
	begin
		if rising_edge(RX_CLK) then
			if RX_FIFO_RESET_Q = '1' then
				RX_ERROR_CNT <= (others=>'0');
			elsif (RX_READY = '1') and (RX_ERROR = '1') and (RX_ERROR_CNT_DONE = '0') then
				RX_ERROR_CNT <= RX_ERROR_CNT + 1;
			end if;
		end if;
	end process;

	process(RX_CLK)
	begin
		if rising_edge(RX_CLK) then
			USER_RX_READY <= RX_READY;
		end if;
	end process;

	process(RX_CLK)
	begin
		if rising_edge(RX_CLK) then
			if (RX_READY = '1') and (RX_K = '0') and (RX_ERROR = '0') then
				USER_RX_CMD <= TIGTP_CMD_DATA;
				USER_RX_DATA <= RX_DATA;
			elsif (RX_READY = '1') and (RX_K = '1') and (RX_DATA = TIGTP_CHAR_SOP) then
				USER_RX_CMD <= TIGTP_CMD_SOP;
				USER_RX_DATA <= (others=>'0');
			elsif (RX_READY = '1') and (RX_K = '1') and (RX_DATA = TIGTP_CHAR_EOP) then
				USER_RX_CMD <= TIGTP_CMD_EOP;
				USER_RX_DATA <= (others=>'0');
			else
				USER_RX_CMD <= TIGTP_CMD_IDLE;
				USER_RX_DATA <= (others=>'0');
			end if;
		end if;
	end process;

	tigtp_ser_rx_inst: tigtp_ser_rx
		generic map(
			FPGA				=> FPGA
		)
		port map(
			CLK_REF			=> CLK_REF,
			CLK_REF_5X		=> CLK_REF_5X,
			RX_RESET			=> RX_RESET_Q,
			PLL_RESET		=> PLL_RESET,
			RX_FIFO_RESET	=> RX_FIFO_RESET_Q,
			DLYCE				=> DLYCE,
			DLYINC			=> DLYINC,
			DLYRST			=> DLYRST,
			BITSLIP			=> BITSLIP,
			RX_CLK			=> RX_CLK,
			RX_LOCKED		=> RX_LOCKED,
			RX_ERROR			=> RX_ERROR,
			RX_DATA			=> RX_DATA,
			RX_K				=> RX_K,
			RXD				=> RXD
		);

	tigtp_ser_rx_sm_inst: tigtp_ser_rx_sm
		generic map(
			FPGA			=> FPGA
		)
		port map(
			CLK			=> RX_CLK,
			RESET			=> RX_FIFO_RESET_Q,
			DLYCE			=> DLYCE,
			DLYINC		=> DLYINC,
			DLYRST		=> DLYRST,
			BITSLIP		=> BITSLIP,
			RX_LOCKED	=> RX_LOCKED,
			RX_ERROR		=> RX_ERROR,
			RX_DATA		=> RX_DATA,
			RX_K			=> RX_K,
			RX_READY		=> RX_READY,
			RX_RESET		=> open
		);

	------------------------
	-- Transmitter Logic
	------------------------

	process(TX_CLK)
	begin
		if rising_edge(TX_CLK) then
			if (RX_READY = '1') and (USER_TX_CMD = TIGTP_CMD_SOP) then
				TX_DATA <= TIGTP_CHAR_SOP;
				TX_K <= '1';
			elsif (RX_READY = '1') and (USER_TX_CMD = TIGTP_CMD_EOP) then
				TX_DATA <= TIGTP_CHAR_EOP;
				TX_K <= '1';
			elsif (RX_READY = '1') and (USER_TX_CMD = TIGTP_CMD_DATA) then
				TX_DATA <= USER_TX_DATA;
				TX_K <= '0';
			else
				TX_DATA <= TIGTP_CHAR_COMMA;
				TX_K <= '1';
			end if;
		end if;
	end process;

	tigtp_ser_tx_inst: tigtp_ser_tx
		generic map(
			FPGA		=> FPGA
		)
		port map(
			CLK_REF		=> CLK_REF,
			CLK_REF_5X	=> CLK_REF_5X,
			PLL_RESET	=> PLL_RESET,
			TX_CLK		=> TX_CLK,
			TX_DATA		=> TX_DATA,
			TX_K			=> TX_K,
			TXD			=> TXD
		);

end synthesis;
