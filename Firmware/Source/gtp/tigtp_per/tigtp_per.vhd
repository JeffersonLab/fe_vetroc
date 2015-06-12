library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;
use work.tigtp_ser_pkg.all;

entity tigtp_per is
	generic(
		ADDR_INFO				: PER_ADDR_INFO
	);
	port(
		CLK_REF					: in std_logic;

		-- Serial pins to/from TI
		TI_GTP_TX				: out std_logic;
		TI_GTP_RX				: in std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_CLK					: in std_logic;
		BUS_RESET				: in std_logic;
		BUS_RESET_SOFT			: in std_logic;
		BUS_DIN					: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT					: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR					: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR					: in std_logic;
		BUS_RD					: in std_logic;
		BUS_ACK					: out std_logic;
		BUS_IRQ					: out std_logic
	);
end tigtp_per;


architecture synthesis of tigtp_per is
	component tigtp_ser_wrapper is
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
			TXD				: out std_logic;
			RXD				: in std_logic
		);
	end component;

	component tigtp_proc is
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
	end component;

	component tigtp_mon is
		port(
			CLK				: in std_logic;

			TX_CMD			: in std_logic_vector(1 downto 0);
			TX_DATA			: in std_logic_vector(7 downto 0);
			RX_CMD			: in std_logic_vector(1 downto 0);
			RX_DATA			: in std_logic_vector(7 downto 0);
			SYNC_EVT			: in std_logic;
			SYNC_EVT_RST	: in std_logic;
			SEND_ACK			: in std_logic;
			SEND_BL_REQ		: in std_logic;

			LA_MASK_EN0		: in std_logic_vector(21 downto 0);
			LA_MASK_VAL0	: in std_logic_vector(21 downto 0);
			LA_ENABLE		: in std_logic;
			LA_READY			: out std_logic;
			LA_DO				: out slv32a(0 downto 0);
			LA_RDEN			: in std_logic_vector(0 downto 0)
		);
	end component;

	signal PI							: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO							: pbus_if_o := (x"00000000", '0');

	-- Registers
	signal LINK_RESET_REG			: std_logic_vector(31 downto 0) := (others=>'0');
	signal LINK_CTRL_REG				: std_logic_vector(31 downto 0) := (others=>'0');
	signal LINK_STATUS_REG			: std_logic_vector(31 downto 0) := (others=>'0');
	signal FIFO_CTRL_REG				: std_logic_vector(31 downto 0) := (others=>'0');
	signal DATA_FIFO_STATUS_REG	: std_logic_vector(31 downto 0) := (others=>'0');
	signal DATA_FIFO_DOUT_REG		: std_logic_vector(31 downto 0) := (others=>'0');
	signal LEN_FIFO_STATUS_REG		: std_logic_vector(31 downto 0) := (others=>'0');
	signal LEN_FIFO_DOUT_REG		: std_logic_vector(31 downto 0) := (others=>'0');
	signal BL_REG						: std_logic_vector(31 downto 0) := (others=>'0');
	signal LA_MASK_EN0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_CTRL_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_STATUS_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO0_REG					: std_logic_vector(31 downto 0) := x"00000000";

	-- Register Bits
	signal RX_RESET					: std_logic;
	signal PLL_RESET					: std_logic;
	signal RX_FIFO_RESET				: std_logic;
	signal RX_READY					: std_logic;
	signal RX_LOCKED					: std_logic;
	signal RX_ERROR_CNT				: std_logic_vector(15 downto 0);

	signal LA_MASK_EN0				: std_logic_vector(21 downto 0);
	signal LA_MASK_VAL0				: std_logic_vector(21 downto 0);
	signal LA_ENABLE					: std_logic;
	signal LA_READY					: std_logic;
	signal LA_DO						: slv32a(0 downto 0);
	signal LA_RDEN						: std_logic_vector(0 downto 0);


	signal TX_CMD						: std_logic_vector(1 downto 0);
	signal TX_DATA						: std_logic_vector(7 downto 0);
	signal RX_CMD						: std_logic_vector(1 downto 0);
	signal RX_DATA						: std_logic_vector(7 downto 0);
	signal FIFO_RESET					: std_logic;
	signal DATA_FIFO_RD				: std_logic;
	signal DATA_FIFO_DOUT			: std_logic_vector(31 downto 0);
	signal DATA_FIFO_CNT				: std_logic_vector(12 downto 0);
	signal LEN_FIFO_RD				: std_logic;
	signal LEN_FIFO_DOUT				: std_logic_vector(31 downto 0);
	signal LEN_FIFO_CNT				: std_logic_vector(8 downto 0);
	signal SYNC_EVT					: std_logic;
	signal SYNC_EVT_RST				: std_logic;
	signal SEND_ACK					: std_logic;
	signal SEND_BL_REQ				: std_logic;
	signal CUR_BL_DATA				: std_logic_vector(7 downto 0);
	signal NEXT_BL_DATA				: std_logic_vector(7 downto 0);
begin

	tigtp_ser_wrapper_inst: tigtp_ser_wrapper
		generic map(
			FPGA				=> "STRATIX4"
		)
		port map(
			CLK_REF			=> CLK_REF,
			CLK_REF_5X		=> '0',
			RX_RESET			=> RX_RESET,
			PLL_RESET		=> PLL_RESET,
			RX_FIFO_RESET	=> RX_FIFO_RESET,
			BUS_CLK			=> BUS_CLK,
			TX_CMD			=> TX_CMD,
			TX_DATA			=> TX_DATA,
			RX_CMD			=> RX_CMD,
			RX_DATA			=> RX_DATA,
			RX_ERROR_CNT	=> RX_ERROR_CNT,
			RX_READY			=> RX_READY,
			RX_LOCKED		=> RX_LOCKED,
			TXD				=> TI_GTP_TX,
			RXD				=> TI_GTP_RX
		);

	tigtp_proc_inst: tigtp_proc
		port map(
			CLK				=> BUS_CLK,
			RESET				=> RX_FIFO_RESET,
			TX_CMD			=> TX_CMD,
			TX_DATA			=> TX_DATA,
			RX_CMD			=> RX_CMD,
			RX_DATA			=> RX_DATA,
			FIFO_RESET		=> FIFO_RESET,
			DATA_FIFO_RD	=> DATA_FIFO_RD,
			DATA_FIFO_DOUT	=> DATA_FIFO_DOUT,
			DATA_FIFO_CNT	=> DATA_FIFO_CNT,
			LEN_FIFO_RD		=> LEN_FIFO_RD,
			LEN_FIFO_DOUT	=> LEN_FIFO_DOUT,
			LEN_FIFO_CNT	=> LEN_FIFO_CNT,
			SYNC_EVT			=> SYNC_EVT,
			SYNC_EVT_RST	=> SYNC_EVT_RST,
			SEND_ACK			=> SEND_ACK,
			SEND_BL_REQ		=> SEND_BL_REQ,
			BUS_IRQ			=> BUS_IRQ
		);

	tigtp_mon_inst: tigtp_mon
		port map(
			CLK				=> BUS_CLK,
			TX_CMD			=> TX_CMD,
			TX_DATA			=> TX_DATA,
			RX_CMD			=> RX_CMD,
			RX_DATA			=> RX_DATA,
			SYNC_EVT			=> SYNC_EVT,
			SYNC_EVT_RST	=> SYNC_EVT_RST,
			SEND_ACK			=> SEND_ACK,
			SEND_BL_REQ		=> SEND_BL_REQ,
			LA_MASK_EN0		=> LA_MASK_EN0,
			LA_MASK_VAL0	=> LA_MASK_VAL0,
			LA_ENABLE		=> LA_ENABLE,
			LA_READY			=> LA_READY,
			LA_DO				=> LA_DO,
			LA_RDEN			=> LA_RDEN
		);

--DONE 1) BUS_IRQ...assert in BUS_CLK domain
--2) check BUS timing - probably overkill slow...
--DONE 3) add new commands GU recently implemented (BLOCK size req/rsp, SYNC evt flag)
--DONE 4) add end of block marker to fifo data (use EOP to tag end...maybe make first word the length? or add a fifo for length?...second option could be handy to change clock domain, consider moving as much to bus_clk domain)

	------------------------------------
	-- Registers
	------------------------------------

	PerBusCtrl_inst: PerBusCtrl
		generic map(
			ADDR_INFO		=> ADDR_INFO
		)
		port map(
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT,
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK,
			PER_CLK			=> BUS_CLK,
			PER_RESET		=> PI.RESET,
			PER_RESET_SOFT	=> PI.RESET_SOFT,
			PER_DIN			=> PI.DIN,
			PER_ADDR			=> PI.ADDR,
			PER_WR			=> PI.WR,
			PER_RD			=> PI.RD,
			PER_MATCH		=> PI.MATCH,
			PER_DOUT			=> PO.DOUT,
			PER_ACK			=> PO.ACK
		);

	--LINK_RESET_REG
	RX_RESET <= LINK_RESET_REG(0);
	PLL_RESET <= LINK_RESET_REG(1);
	RX_FIFO_RESET <= LINK_RESET_REG(2);

	--LINK_CTRL_REG
	SEND_BL_REQ <= LINK_CTRL_REG(0);
	SEND_ACK <= LINK_CTRL_REG(1);
	SYNC_EVT_RST <= LINK_CTRL_REG(2);

	--LINK_STATUS_REG
	LINK_STATUS_REG(15 downto 0) <= RX_ERROR_CNT;
	LINK_STATUS_REG(16) <= RX_READY;
	LINK_STATUS_REG(17) <= RX_LOCKED;

	--FIFO_CTRL_REG
	FIFO_RESET <= FIFO_CTRL_REG(0);

	--DATA_FIFO_STATUS_REG
	DATA_FIFO_STATUS_REG(12 downto 0) <= DATA_FIFO_CNT;

	--DATA_FIFO_DOUT_REG
	DATA_FIFO_DOUT_REG <= DATA_FIFO_DOUT;

	--LEN_FIFO_STATUS_REG
	LEN_FIFO_STATUS_REG(8 downto 0) <= LEN_FIFO_CNT;
	LEN_FIFO_STATUS_REG(31) <= SYNC_EVT;

	--LEN_FIFO_DOUT_REG
	LEN_FIFO_DOUT_REG <= LEN_FIFO_DOUT;

	--BL_REG
	BL_REG(7 downto 0) <= CUR_BL_DATA;
	BL_REG(15 downto 8) <= NEXT_BL_DATA;

	--LA_CTRL_REG
	LA_ENABLE <= LA_CTRL_REG(0);

	--LA_STATUS_REG
	LA_STATUS_REG(0) <= LA_READY;
	LA_STATUS_REG(31 downto 1) <= (others=>'0');

	--LA_MASK_EN0_REG
	LA_MASK_EN0 <= LA_MASK_EN0_REG(21 downto 0);

	--LA_MASK_VAL0_REG
	LA_MASK_VAL0 <= LA_MASK_VAL0_REG(21 downto 0);

	--LA_DO0_REG
	LA_DO0_REG <= LA_DO(0);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';
			
			rw_reg(		REG => LINK_CTRL_REG				,PI=>PI,PO=>PO, A => x"0000", RW => x"00000007", R => x"00000007");
			ro_reg(		REG => LINK_STATUS_REG			,PI=>PI,PO=>PO, A => x"0004", RO => x"0003FFFF");
			rw_reg(		REG => LINK_RESET_REG			,PI=>PI,PO=>PO, A => x"0008", RW => x"00000007", R => x"00000000");
			rw_reg(		REG => FIFO_CTRL_REG				,PI=>PI,PO=>PO, A => x"0010", RW => x"00000001");
			ro_reg(		REG => DATA_FIFO_STATUS_REG	,PI=>PI,PO=>PO, A => x"0014", RO => x"00001FFF");
			ro_reg_ack(	REG => DATA_FIFO_DOUT_REG		,PI=>PI,PO=>PO, A => x"0018", RO => x"FFFFFFFF", ACK => DATA_FIFO_RD);
			ro_reg(		REG => LEN_FIFO_STATUS_REG		,PI=>PI,PO=>PO, A => x"001C", RO => x"800001FF");
			ro_reg_ack(	REG => LEN_FIFO_DOUT_REG		,PI=>PI,PO=>PO, A => x"0020", RO => x"FFFFFFFF", ACK => LEN_FIFO_RD);
			ro_reg(		REG => BL_REG						,PI=>PI,PO=>PO, A => x"0024", RO => x"0000FFFF");

			-- Monitor Registers
			rw_reg(		REG => LA_CTRL_REG				,PI=>PI,PO=>PO, A => x"0080", RW => x"00000001");
			ro_reg(		REG => LA_STATUS_REG				,PI=>PI,PO=>PO, A => x"0084", RO => x"00000001");
			ro_reg_ack(	REG => LA_DO0_REG					,PI=>PI,PO=>PO, A => x"0090", RO => x"FFFFFFFF", ACK => LA_RDEN(0));
			rw_reg(		REG => LA_MASK_EN0_REG			,PI=>PI,PO=>PO, A => x"00A0", RW => x"003FFFFF");
			rw_reg(		REG => LA_MASK_VAL0_REG			,PI=>PI,PO=>PO, A => x"00B0", RW => x"003FFFFF");
		end if;
	end process;

end synthesis;
