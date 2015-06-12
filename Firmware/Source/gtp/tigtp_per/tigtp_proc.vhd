library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

use work.tigtp_ser_pkg.all;

entity tigtp_proc is
	port(
		CLK				: in std_logic;
		RESET				: in std_logic;

		-- Transmitter Interface
		-- All signals 
		TX_CMD			: out std_logic_vector(1 downto 0);
		TX_DATA			: out std_logic_vector(7 downto 0);

		-- Receiver Interface
		RX_CMD			: in std_logic_vector(1 downto 0);
		RX_DATA			: in std_logic_vector(7 downto 0);

		FIFO_RESET		: in std_logic;

		DATA_FIFO_RD	: in std_logic;
		DATA_FIFO_DOUT	: out std_logic_vector(31 downto 0);
		DATA_FIFO_CNT	: out std_logic_vector(12 downto 0);

		LEN_FIFO_RD		: in std_logic;
		LEN_FIFO_DOUT	: out std_logic_vector(31 downto 0);
		LEN_FIFO_CNT	: out std_logic_vector(8 downto 0);

		SYNC_EVT			: out std_logic;
		SYNC_EVT_RST	: in std_logic;

		SEND_ACK			: in std_logic;
		SEND_BL_REQ		: in std_logic;

		CUR_BL_DATA		: out std_logic_vector(7 downto 0);
		NEXT_BL_DATA	: out std_logic_vector(7 downto 0);

		BUS_IRQ			: out std_logic
	);
end tigtp_proc;

architecture synthesis of tigtp_proc is
	component tigtp_proc_tx_sm is
		port(
			CLK				: in std_logic;
			RESET				: in std_logic;

			TX_CMD			: out std_logic_vector(1 downto 0);
			TX_DATA			: out std_logic_vector(7 downto 0);

			SEND_ACK			: in std_logic;
			SEND_BL_REQ		: in std_logic
		);
	end component;

	component tigtp_proc_rx_sm is
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
	end component;

	signal SYNC_EVT_SET			: std_logic;
	signal DATA_FIFO_WR			: std_logic;
	signal DATA_FIFO_DIN			: std_logic_vector(31 downto 0);
	signal LEN_FIFO_WR			: std_logic;
	signal LEN_FIFO_DIN			: std_logic_vector(31 downto 0);
	signal LEN_FIFO_EMPTY		: std_logic;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			BUS_IRQ <= not LEN_FIFO_EMPTY;
		end if;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			if (RESET = '1') or (SYNC_EVT_RST = '1') then
				SYNC_EVT <= '0';
			elsif SYNC_EVT_SET = '1' then
				SYNC_EVT <= '1';
			end if;
		end if;
	end process;

	tigtp_proc_tx_sm_inst: tigtp_proc_tx_sm
		port map(
			CLK			=> CLK,
			RESET			=> RESET,
			TX_CMD		=> TX_CMD,
			TX_DATA		=> TX_DATA,
			SEND_ACK		=> SEND_ACK,
			SEND_BL_REQ	=> SEND_BL_REQ
		);

	tigtp_proc_rx_sm_inst: tigtp_proc_rx_sm
		port map(
			CLK				=> CLK,
			RESET				=> RESET,
			RX_CMD			=> RX_CMD,
			RX_DATA			=> RX_DATA,
			CUR_BL_DATA		=> CUR_BL_DATA,
			NEXT_BL_DATA	=> NEXT_BL_DATA,
			SYNC_EVT_SET	=> SYNC_EVT_SET,
			DATA_FIFO_WR	=> DATA_FIFO_WR,
			DATA_FIFO_DIN	=> DATA_FIFO_DIN,
			LEN_FIFO_WR		=> LEN_FIFO_WR,
			LEN_FIFO_DIN	=> LEN_FIFO_DIN
		);

	-- NOTE: this FIFO is small and only supports ~512 TI events
	dcfifo_tiblockdata: scfifo
		generic map(
			add_ram_output_register	=> "OFF",
			intended_device_family	=> "Stratix IV",
			lpm_numwords				=> 4096,
			lpm_showahead				=> "ON",
			lpm_type						=> "scfifo",
			lpm_width					=> 32,
			lpm_widthu					=> 12,
			overflow_checking			=> "ON",
			underflow_checking		=> "ON",
			use_eab						=> "ON",
			lpm_hint						=> "RAM_BLOCK_TYPE=M144K"
		)
		port map(
			clock	=> CLK,
			sclr	=> FIFO_RESET,
			wrreq	=> DATA_FIFO_WR,
			data	=> DATA_FIFO_DIN,
			rdreq	=> DATA_FIFO_RD,
			usedw	=> DATA_FIFO_CNT(11 downto 0),
			empty	=> open,
			full	=> DATA_FIFO_CNT(12),
			q		=> DATA_FIFO_DOUT
		);

	dcfifo_tiblocksize: scfifo
		generic map(
			add_ram_output_register	=> "OFF",
			intended_device_family	=> "Stratix IV",
			lpm_numwords				=> 256,
			lpm_showahead				=> "ON",
			lpm_type						=> "scfifo",
			lpm_width					=> 32,
			lpm_widthu					=> 8,
			overflow_checking			=> "ON",
			underflow_checking		=> "ON",
			use_eab						=> "ON",
			lpm_hint						=> "RAM_BLOCK_TYPE=M9K"
		)
		port map(
			clock	=> CLK,
			sclr	=> FIFO_RESET,
			wrreq	=> LEN_FIFO_WR,
			data	=> LEN_FIFO_DIN,
			rdreq	=> LEN_FIFO_RD,
			usedw	=> LEN_FIFO_CNT(7 downto 0),
			empty	=> LEN_FIFO_EMPTY,
			full	=> LEN_FIFO_CNT(8),
			q		=> LEN_FIFO_DOUT
		);


end synthesis;
