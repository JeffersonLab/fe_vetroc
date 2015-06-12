library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

use work.tigtp_ser_pkg.all;

entity tigtp_ser_wrapper is
	generic(
		FPGA				: string := "VIRTEX5"
	);
	port(
		CLK_REF			: in std_logic;
		CLK_REF_5X		: in std_logic;
		RX_RESET			: in std_logic;
		PLL_RESET		: in std_logic;
		RX_FIFO_RESET	: in std_logic;

		BUS_CLK			: in std_logic;

		-- Transmitter Interface
		TX_CMD			: in std_logic_vector(1 downto 0);
		TX_DATA			: in std_logic_vector(7 downto 0);

		-- Receiver Interface
		RX_CMD			: out std_logic_vector(1 downto 0);
		RX_DATA			: out std_logic_vector(7 downto 0);
		RX_ERROR_CNT	: out std_logic_vector(15 downto 0);
		RX_READY			: out std_logic;
		RX_LOCKED		: out std_logic;

		-- Serial pins
		TXD					: out std_logic;
		RXD					: in std_logic
	);
end tigtp_ser_wrapper;

architecture synthesis of tigtp_ser_wrapper is
	component tigtp_ser is
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
	end component;

	signal USER_CLK				: std_logic;
	signal USER_TX_CMD			: std_logic_vector(1 downto 0);
	signal USER_TX_DATA			: std_logic_vector(7 downto 0);
	signal USER_RX_CMD			: std_logic_vector(1 downto 0);
	signal USER_RX_DATA			: std_logic_vector(7 downto 0);
	signal USER_RX_ERROR_CNT	: std_logic_vector(15 downto 0);
	signal USER_RX_READY			: std_logic;
	signal USER_RX_LOCKED		: std_logic;
	signal RX_FIFO_RD				: std_logic;
	signal RX_FIFO_EMPTY			: std_logic;
	signal RX_FIFO_DOUT			: std_logic_vector(9 downto 0);
	signal RX_FIFO_DIN			: std_logic_vector(9 downto 0);
	signal RX_FIFO_WR				: std_logic;
	signal TX_FIFO_RD				: std_logic;
	signal TX_FIFO_EMPTY			: std_logic;
	signal TX_FIFO_DOUT			: std_logic_vector(9 downto 0);
	signal TX_FIFO_DIN			: std_logic_vector(9 downto 0);
	signal TX_FIFO_WR				: std_logic;

begin

	tigtp_ser_inst: tigtp_ser
		generic map(
			FPGA					=> FPGA
		)
		port map(
			CLK_REF				=> CLK_REF,
			CLK_REF_5X			=> CLK_REF_5X,
			RX_RESET				=> RX_RESET,
			PLL_RESET			=> PLL_RESET,
			RX_FIFO_RESET		=> RX_FIFO_RESET,
			USER_CLK				=> USER_CLK,
			USER_TX_CMD			=> USER_TX_CMD,
			USER_TX_DATA		=> USER_TX_DATA,
			USER_RX_CMD			=> USER_RX_CMD,
			USER_RX_DATA		=> USER_RX_DATA,
			USER_RX_ERROR_CNT	=> USER_RX_ERROR_CNT,
			USER_RX_READY		=> USER_RX_READY,
			USER_RX_LOCKED		=> USER_RX_LOCKED,
			TXD					=> TXD,
			RXD					=> RXD
		);

	-- SERDES CLK -> BUS_CLK
	dcfifo_rx: dcfifo
		generic map(
			clocks_are_synchronized	=> "FALSE",
			intended_device_family	=> "Stratix IV",
			lpm_numwords				=> 16,
			lpm_showahead				=> "ON",
			lpm_width					=> 10,
			lpm_widthu					=> 4,
			lpm_hint						=> "RAM_BLOCK_TYPE=MLAB"
		)
		port map(
			aclr		=> RX_FIFO_RESET,
			data		=> RX_FIFO_DIN,
			q			=> RX_FIFO_DOUT,
			rdclk		=> BUS_CLK,
			rdempty	=> RX_FIFO_EMPTY,
			rdfull	=> open,
			rdreq		=> RX_FIFO_RD,
			rdusedw	=> open,
			wrclk		=> USER_CLK,
			wrempty	=> open,
			wrfull	=> open,
			wrreq		=> RX_FIFO_WR,
			wrusedw	=> open
		);

	-- BUS_CLK -> SERDES CLK
	dcfifo_tx: dcfifo
		generic map(
			clocks_are_synchronized	=> "FALSE",
			intended_device_family	=> "Stratix IV",
			lpm_numwords				=> 16,
			lpm_showahead				=> "ON",
			lpm_width					=> 10,
			lpm_widthu					=> 4,
			lpm_hint						=> "RAM_BLOCK_TYPE=MLAB"
		)
		port map(
			aclr		=> RX_FIFO_RESET,
			data		=> TX_FIFO_DIN,
			q			=> TX_FIFO_DOUT,
			rdclk		=> USER_CLK,
			rdempty	=> TX_FIFO_EMPTY,
			rdfull	=> open,
			rdreq		=> TX_FIFO_RD,
			rdusedw	=> open,
			wrclk		=> BUS_CLK,
			wrempty	=> open,
			wrfull	=> open,
			wrreq		=> TX_FIFO_WR,
			wrusedw	=> open
		);

	-- BUS_CLK -> USER_CLK FIFO DATA
	TX_FIFO_RD <= not TX_FIFO_EMPTY;

	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			RX_FIFO_DIN <= USER_RX_CMD & USER_RX_DATA;

			if USER_RX_CMD = TIGTP_CMD_IDLE then
				RX_FIFO_WR <= '0';
			else
				RX_FIFO_WR <= '1';
			end if;

			if TX_FIFO_EMPTY = '0' then
				USER_TX_CMD <= TX_FIFO_DOUT(9 downto 8);
				USER_TX_DATA <= TX_FIFO_DOUT(7 downto 0);
			else
				USER_TX_CMD <= TIGTP_CMD_IDLE;
				USER_TX_DATA <= x"00";
			end if;
		end if;
	end process;

	-- USER_CLK -> BUS_CLK FIFO DATA
	RX_FIFO_RD <= not RX_FIFO_EMPTY;

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			TX_FIFO_DIN <= TX_CMD & TX_DATA;

			if TX_CMD = TIGTP_CMD_IDLE then
				TX_FIFO_WR <= '0';
			else
				TX_FIFO_WR <= '1';
			end if;

			if RX_FIFO_EMPTY = '0' then
				RX_CMD <= RX_FIFO_DOUT(9 downto 8);
				RX_DATA <= RX_FIFO_DOUT(7 downto 0);
			else
				RX_CMD <= TIGTP_CMD_IDLE;
				RX_DATA <= x"00";
			end if;

			RX_LOCKED <= USER_RX_LOCKED;
			RX_READY <= USER_RX_READY;
			RX_ERROR_CNT <= USER_RX_ERROR_CNT;
		end if;
	end process;

end synthesis;
