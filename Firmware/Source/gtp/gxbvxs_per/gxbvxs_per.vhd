library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity gxbvxs_per is
	generic(
		ADDR_INFO					: PER_ADDR_INFO;
		PAYLOAD_INST				: integer;
		SIM_GTXRESET_SPEEDUP		: integer := 0;
		GTX_QUICKSIM				: boolean := false
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		SYSCLK_50			: in std_logic;
		ATXCLK				: in std_logic;

		-- Transceiver I/O
		PAYLOAD_RX2			: in std_logic;
		PAYLOAD_RX3			: in std_logic;
		PAYLOAD_TX2			: out std_logic;
		PAYLOAD_TX3			: out std_logic;

		CAL_BLK_POWERDOWN	: in std_logic;
		CAL_BLK_BUSY		: in std_logic;
		RECONFIG_FROMGXB	: out std_logic_vector(67 downto 0);
		RECONFIG_TOGXB		: in std_logic_vector(3 downto 0);

		-- To trigger processing
		-- Note: uses CLK=125MHz when RATE_5G_2_5Gn = '0'
		--       uses CLK=250MHz when RATE_5G_2_5Gn = '1'
		CLK					: in std_logic;
		SYNC					: in std_logic;
		RX_D					: out std_logic_vector(31 downto 0);
		RX_SRC_RDY_N		: out std_logic;

		-- External Trigger for Monitor 
		EXT_TRIGGER			: in std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_RESET			: in std_logic;
		BUS_RESET_SOFT		: in std_logic;
		BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR				: in std_logic;
		BUS_RD				: in std_logic;
		BUS_ACK				: out std_logic
	);
end gxbvxs_per;

architecture synthesis of gxbvxs_per is
	component aurora_5G_wrapper is
		generic(
			STARTING_CHANNEL_NUMBER		: natural;
			PMA_DIRECT						: std_logic := '0';
			SIM_GTXRESET_SPEEDUP			: integer := 0;
			GTX_QUICKSIM					: boolean := false
		);
		port(
			CLK					: in std_logic;

			-- TX Stream Interface
			TX_D					: in std_logic_vector(31 downto 0);
			TX_SRC_RDY_N		: in std_logic;
			TX_DST_RDY_N		: out std_logic;

			-- RX Stream Interface
			RX_D					: out std_logic_vector(31 downto 0);
			RX_SRC_RDY_N		: out std_logic;

			-- GTX Serial I/O
			RXP					: in std_logic_vector(0 to 1);
			TXP					: out std_logic_vector(0 to 1);

			--GTX Reference Clock Interface
			GTXD0					: in std_logic;

			--SIV Specific
			CLK50					: in std_logic;
			CAL_BLK_POWERDOWN	: in std_logic;
			CAL_BLK_BUSY		: in std_logic;
			RECONFIG_FROMGXB	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB		: in std_logic_vector(3 downto 0);

			-- Registers
			GXB_CTRL				: in std_logic_vector(31 downto 0);
			GXB_STATUS			: out std_logic_vector(31 downto 0);
			GXB_ERR_TILE		: out std_logic_vector(31 downto 0);
			GXB_ERR				: out std_logic

		);
	end component;

	component gxbvxs_mon is
		port(
			CLK				: in std_logic;

			GXB_ERR			: in std_logic;
			RX_SRC_RDY_N	: in std_logic;
			RX_D				: in std_logic_vector(31 downto 0);

			LA_CMP_MODE0	: in std_logic_vector(2 downto 0);
			LA_CMP_THR0		: in std_logic_vector(31 downto 0);
			LA_MASK_EN0		: in std_logic_vector(31 downto 0);
			LA_MASK_VAL0	: in std_logic_vector(31 downto 0);
			LA_MASK_EN1		: in std_logic_vector(4 downto 0);
			LA_MASK_VAL1	: in std_logic_vector(4 downto 0);
			LA_ENABLE		: in std_logic;
			LA_READY			: out std_logic;
			LA_DO				: out slv32a(1 downto 0);
			LA_RDEN			: in std_logic_vector(1 downto 0)
		);
	end component;

	component serdeslatency is
		port(
			CLK				: in std_logic;
			SYNC				: in std_logic;
			RX_SRC_RDY_N	: in std_logic;
			LATENCY			: out std_logic_vector(15 downto 0)
		);
	end component;

	constant PMA_DIRECT				: std_logic_vector(7 downto 0) := "10010010";
	constant CHANNEL_NUMBER			: inta(7 downto 0) := (112,96,80,64,48,32,16,0);

	signal PI							: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO							: pbus_if_o := (x"00000000", '0');

	signal GXB_CTRL_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal GXB_STATUS_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal GXB_ERR_TILE_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal GXB_STATUS2_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_CMP_MODE0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_CMP_THR0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_EN0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_EN1_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL1_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_CTRL_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_STATUS_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO0_REG					: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO1_REG					: std_logic_vector(31 downto 0) := x"00000000";

	signal LATENCY						: std_logic_vector(15 downto 0);	
	signal CRC_RST						: std_logic;
	signal CRC_PASS					: std_logic_vector(1 downto 0);
	signal GXB_ERR						: std_logic;

	signal RX_D_I						: std_logic_vector(31 downto 0);
	signal RX_SRC_RDY_N_I			: std_logic;
	signal RX_D_O						: std_logic_vector(31 downto 0);
	signal RX_SRC_RDY_N_O			: std_logic_vector(1 downto 0);
	signal SYNC_Q						: std_logic_vector(1 downto 0);

	signal GXB_CTRL					: std_logic_vector(31 downto 0);
	signal GXB_STATUS					: std_logic_vector(31 downto 0);
	signal GXB_ERR_TILE				: std_logic_vector(31 downto 0);

	signal LA_CMP_MODE0				: std_logic_vector(2 downto 0);
	signal LA_CMP_THR0				: std_logic_vector(31 downto 0);
	signal LA_MASK_EN0				: std_logic_vector(31 downto 0);
	signal LA_MASK_VAL0				: std_logic_vector(31 downto 0);
	signal LA_MASK_EN1				: std_logic_vector(4 downto 0);
	signal LA_MASK_VAL1				: std_logic_vector(4 downto 0);
	signal LA_ENABLE					: std_logic;
	signal LA_READY					: std_logic;
	signal LA_DO						: slv32a(1 downto 0);
	signal LA_RDEN						: std_logic_vector(1 downto 0);
begin

	aurora_5G_wrapper_inst: aurora_5G_wrapper
		generic map(
			STARTING_CHANNEL_NUMBER		=> CHANNEL_NUMBER((PAYLOAD_INST-1) / 2),
			PMA_DIRECT						=> PMA_DIRECT((PAYLOAD_INST-1) / 2),
			SIM_GTXRESET_SPEEDUP			=> SIM_GTXRESET_SPEEDUP,
			GTX_QUICKSIM					=> GTX_QUICKSIM
		)
		port map(
			CLK					=> CLK,
			TX_D					=> (others=>'0'),
			TX_SRC_RDY_N		=> '1',
			TX_DST_RDY_N		=> open,
			RX_D					=> RX_D_I,
			RX_SRC_RDY_N		=> RX_SRC_RDY_N_I,
			RXP(0)				=> PAYLOAD_RX2,
			RXP(1)				=> PAYLOAD_RX3,
			TXP(0)				=> PAYLOAD_TX2,
			TXP(1)				=> PAYLOAD_TX3,
			GTXD0					=> ATXCLK,
			CLK50					=> SYSCLK_50,
			CAL_BLK_POWERDOWN	=> CAL_BLK_POWERDOWN,
			CAL_BLK_BUSY		=> CAL_BLK_BUSY,
			RECONFIG_FROMGXB	=> RECONFIG_FROMGXB,
			RECONFIG_TOGXB		=> RECONFIG_TOGXB,
			GXB_CTRL				=> GXB_CTRL,
			GXB_STATUS			=> GXB_STATUS,
			GXB_ERR_TILE		=> GXB_ERR_TILE,
			GXB_ERR				=> GXB_ERR
		);

	serdeslatency_inst: serdeslatency
		port map(
			CLK				=> CLK,
			SYNC				=> SYNC_Q(SYNC_Q'left),
			RX_SRC_RDY_N	=> RX_SRC_RDY_N_I,
			LATENCY			=> LATENCY
		);

	serdeslanecrc_rx_gen: for I in 0 to 1 generate
		serdeslanecrc_rx_inst: serdeslanecrc_rx
			port map(
				CLK					=> CLK,
				CRC_RST				=> CRC_RST,
				RX_D_I				=> RX_D_I(I*16+15 downto I*16),
				RX_D_SRC_RDY_N_I	=> RX_SRC_RDY_N_I,
				RX_D_O				=> RX_D_O(I*16+15 downto I*16),
				RX_D_SRC_RDY_N_O	=> RX_SRC_RDY_N_O(I),
				CRC_PASS				=> CRC_PASS(I)
			);
	end generate;

	gxbvxs_mon_inst: gxbvxs_mon
		port map(
			CLK				=> CLK,
			GXB_ERR			=> GXB_ERR,
			RX_SRC_RDY_N	=> RX_SRC_RDY_N_O(0),
			RX_D				=> RX_D_O,
			LA_CMP_MODE0	=> LA_CMP_MODE0,
			LA_CMP_THR0		=> LA_CMP_THR0,
			LA_MASK_EN0		=> LA_MASK_EN0,
			LA_MASK_VAL0	=> LA_MASK_VAL0,
			LA_MASK_EN1		=> LA_MASK_EN1,
			LA_MASK_VAL1	=> LA_MASK_VAL1,
			LA_ENABLE		=> LA_ENABLE,
			LA_READY			=> LA_READY,
			LA_DO				=> LA_DO,
			LA_RDEN			=> LA_RDEN
		);

	CRC_RST <= SYNC_Q(SYNC_Q'left) and not SYNC_Q(SYNC_Q'left-1);

	process(CLK)
	begin
		if rising_edge(CLK) then
			SYNC_Q <= SYNC_Q(SYNC_Q'length-2 downto 0) & SYNC;

			if RX_SRC_RDY_N_O(0) = '1' then
				RX_SRC_RDY_N <= '1';
				RX_D <= x"00000000";
			else
				RX_SRC_RDY_N <= '0';
				RX_D <= RX_D_O;
			end if;
		end if;
	end process;

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
			PER_CLK			=> CLK,
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

	--LA_CTRL_REG
	LA_ENABLE <= LA_CTRL_REG(0);

	--LA_STATUS_REG
	LA_STATUS_REG(0) <= LA_READY;
	LA_STATUS_REG(31 downto 1) <= (others=>'0');

	--LA_CMP_MODE0_REG
	LA_CMP_MODE0 <= LA_CMP_MODE0_REG(2 downto 0);

	--LA_CMP_THR0_REG
	LA_CMP_THR0 <= LA_CMP_THR0_REG;

	--LA_MASK_EN0_REG
	LA_MASK_EN0 <= LA_MASK_EN0_REG;

	--LA_MASK_VAL0_REG
	LA_MASK_VAL0 <= LA_MASK_VAL0_REG;

	--LA_MASK_EN1_REG
	LA_MASK_EN1 <= LA_MASK_EN1_REG(4 downto 0);

	--LA_MASK_VAL1_REG
	LA_MASK_VAL1 <= LA_MASK_VAL1_REG(4 downto 0);

	--LA_DO0_REG
	LA_DO0_REG <= LA_DO(0);

	--LA_DO1_REG
	LA_DO1_REG <= LA_DO(1);

	--GXB_CTRL_REG
	GXB_CTRL <= GXB_CTRL_REG;

	--GXB_STATUS_REG
	GXB_STATUS_REG <= GXB_STATUS;

	--GXB_ERR_TILE_REG
	GXB_ERR_TILE_REG <= GXB_ERR_TILE;

	--GXB_STATUS2_REG
	GXB_STATUS2_REG <= "00000000000000" & CRC_PASS & LATENCY;

	process(CLK)
	begin
		if rising_edge(CLK) then
			PO.ACK <= '0';
			
			-- GXB Registers
			rw_reg(		REG => GXB_CTRL_REG		,PI=>PI,PO=>PO, A => x"0000", RW => x"00000C01", I => x"00000001", R => x"00000400");
			ro_reg(		REG => GXB_STATUS_REG	,PI=>PI,PO=>PO, A => x"0010", RO => x"FFFFFFFF");
			ro_reg(		REG => GXB_ERR_TILE_REG	,PI=>PI,PO=>PO, A => x"0018", RO => x"FFFFFFFF");
			ro_reg(		REG => GXB_STATUS2_REG	,PI=>PI,PO=>PO, A => x"001C", RO => x"0003FFFF");

			-- Monitor Registers
			rw_reg(		REG => LA_CTRL_REG		,PI=>PI,PO=>PO, A => x"0020", RW => x"00000001");
			ro_reg(		REG => LA_STATUS_REG		,PI=>PI,PO=>PO, A => x"0024", RO => x"00000001");
			ro_reg_ack(	REG => LA_DO0_REG			,PI=>PI,PO=>PO, A => x"0030", RO => x"FFFFFFFF", ACK => LA_RDEN(0));
			ro_reg_ack(	REG => LA_DO1_REG			,PI=>PI,PO=>PO, A => x"0034", RO => x"0000001F", ACK => LA_RDEN(1));
			rw_reg(		REG => LA_CMP_MODE0_REG	,PI=>PI,PO=>PO, A => x"0050", RW => x"00000007");
			rw_reg(		REG => LA_CMP_THR0_REG	,PI=>PI,PO=>PO, A => x"0070", RW => x"FFFFFFFF");
			rw_reg(		REG => LA_MASK_EN0_REG	,PI=>PI,PO=>PO, A => x"0090", RW => x"FFFFFFFF");
			rw_reg(		REG => LA_MASK_EN1_REG	,PI=>PI,PO=>PO, A => x"0094", RW => x"0000001F");
			rw_reg(		REG => LA_MASK_VAL0_REG	,PI=>PI,PO=>PO, A => x"00B0", RW => x"FFFFFFFF");
			rw_reg(		REG => LA_MASK_VAL1_REG	,PI=>PI,PO=>PO, A => x"00B4", RW => x"0000001F");
		end if;
	end process;

end synthesis;
